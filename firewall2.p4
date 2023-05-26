/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*
Firewall must drop packets with a pre-specified header and allow other to pass
Firewall must also reflect for the purpose of checking that certain packets have been dropped - start with reflector code from assignemnt 3.*/


/*************************************************************************
*************************** SETUP  ***************************************
*************************************************************************/
// Define a register to count the number of packets sent from a single source address
register Packet_counter {
	width : 8; 		//can store 8 bits (and so count to 256)
	init : 0;		//initial value of 0
// Note: the register can only count 1 ip address at a time	
	
	
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
       //swap source and destination addresses:
       macAddr_t tmp_mac;
       tmp_mac = hdr.ethernet.srcAddr;
       hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
       hdr.ethernet.dstAddr = tmp_mac;
       //send it back to the same port
       standard_metadata.egress_spec = standard_metadata.ingress_port;
       //Look up the packet count for the srcAddr and increase by 1
       packet_counter.increment(tmp_mac, 1)
    }

// drop    
    action drop() {
        mark_to_drop(standard_metadata);
    }

// counter
    
    
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

    apply {
        if (hdr.ethernet.isValid()) {   //check if header fits the format of ethernet
            src_mac_swap.apply();	// apply table 1
            
            
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
