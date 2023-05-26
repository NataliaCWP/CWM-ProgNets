/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*
Firewall must drop packets with a pre-specified header and allow other to pass
Firewall must also reflect for the purpose of checking that certain packets have been dropped - start with reflector code from assignemnt 3.

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        packet.extract(hdr.ethernet);
        transition accept;
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

// reflect the terms to the original machine so that drops can be measured 
    
    action swap_mac_addresses() {
       macAddr_t tmp_mac;
       tmp_mac = hdr.ethernet.dstAddr;
       hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
       hdr.ethernet.srcAddr = tmp_mac;
       //send it back to the same port
       standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

// drop    
    action drop() {
        mark_to_drop(standard_metadata);
    }
// counter
   //ADD LATER     
    
// table 1: swap and refelct adresses from allowed source
    table src_mac_swap {
        key = {
            hdr.ethernet.srcAddr: exact;
        }
        actions = {
            swap_mac_addresses;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

// table 2: swap and refelct adresses to allowed destination
    table dst_mac_swap {
        key = {
            hdr.ethernet.dstAddr: exact;
        }
        actions = {
            swap_mac_addresses;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop;
    }
        
    apply {
        if (hdr.ethernet.isValid()) {   //check if header fits the format of ethernet
            src_mac_swap.apply();	// apply table 1
            dst_mac_swap.apply();	// apply table 2
            
        }
    }
}
       
       
    


/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {

     }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
