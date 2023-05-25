#include <core.p4>
#include <v1model.p4>

 /* X is an ASCII Letter 'X' (0x88)
  * O is an ASCII Letter '4' (0x79)
  
  The board:
	      |     |     
	  1 1 | 1 2 | 1 3 
	 _____|_____|_____
	      |     |     
	  2 1 | 2 2 | 2 3 
	 _____|_____|_____
	      |     |     
	  3 1 | 3 2 | 3 3 
	      |     |
	
/*************************************************************************
 ******************************   HEADERS   ******************************
 *************************************************************************/
 
 
 /* Standard Ethernet header */
  
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}   
    
 /* tictactoe_t header */

header tictactoe_t {
	bit<8> TIC;
	bit<16> ver;
	bit<8> row;
	bit<8> column;
	bit<32> res;      
}

/*************************************************************************
 ******************************   STRUCTS   ******************************
 *************************************************************************/
struct headers {
    ethernet_t   ethernet;
    tictactoe_t     tic;
}


struct metadata {
    /* In our case it is empty */
}
