`timescale 1ns / 1ps
/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */
module InstructionMemory(Data, Address);
   parameter T_rd = 20;
   parameter MemSize = 40;
   
   output [31:0] Data;
   input [63:0]  Address;
   reg [31:0] 	 Data;
   
   /*
    * ECEN 350 Processor Test Functions
    * Texas A&M University
    */
   
   always @ (Address) begin

      case(Address)

	/* Test Program 1:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * 0: LDUR X9, [XZR, 0x0]    //Load 1 into x9
	 * 4: LDUR X10, [XZR, 0x8]   //Load a into x10
	 * 8: LDUR X11, [XZR, 0x10]  //Load 5 into x11
	 * C: LDUR X12, [XZR, 0x18]  //Load big constant into x12
	 * 10: LDUR X13, [XZR, 0x20]  //load a 0 into X13
	 * 
	 * 14: ORR X10, X10, X11  //Create mask of 0xf
	 * 18: AND X12, X12, X10  //Mask off low order bits of big constant
	 * 
	 * loop:
	 * 1C: CBZ X12, end  //while X12 is not 0
	 * 20: ADD X13, X13, X9  //Increment counter in X13
	 * 24: SUB X12, X12, X9  //Decrement remainder of big constant in X12
	 * 28: B loop  //Repeat till X12 is 0
	 * 2C: STUR X13, [XZR, 0x20]  //store back the counter value into the memory location 0x20
	 */
	

	63'h000: Data = 32'hF84003E9;
	63'h004: Data = 32'hF84083EA;
	63'h008: Data = 32'hF84103EB;
	63'h00c: Data = 32'hF84183EC;
	63'h010: Data = 32'hF84203ED;
	63'h014: Data = 32'hAA0B014A;
	63'h018: Data = 32'h8A0A018C;
	63'h01c: Data = 32'hB400008C;
	63'h020: Data = 32'h8B0901AD;
	63'h024: Data = 32'hCB09018C;
	63'h028: Data = 32'h17FFFFFD;
	63'h02c: Data = 32'hF80203ED;
	63'h030: Data = 32'hF84203ED;  //One last load to place stored value on memdbus for test checking.

	/* Add code for your tests here */
	//GOAL:: MOVZ X9, 0x123456789abcdef0
	//MOVZ is 110100101 from green sheet 
	//MOVZ X0, 0x1234, 3 // opcode 11010010111 //immediate 0001001000110100 //X0 0000
	//MOVZ X1, 0x5678, 2 // opcode 11010010110 //immediate 0101011001101000 //X1 0001
	//MOVZ X2, 0x9abc, 1 // opcode 11010010101 //immediate 1001101010111100 //X2 0010
	//MOVZ X3, 0xdef0, 0 // opcode 11010010100 //immediate 1101111011110000 //X3 0011
	//ADD X1, X0, X1 //opcode 10001011000 Rd = Rm +Rn based on Rd, Rm, Rn
	//ADD X3, X2, X3 //opcode 10001011000
	//ADD X9, X1, X3 //opcode 10001011000
	//STUR X9,[XZR,0x28] //opcode 11111000000 //Rt X9 Rn XZR/31 DtAddr = 0x28
	//LDUR X10,[XZR, X9] //opcode 11111000010 //Rt X10 Rn XZR/31 DtAddr = X9
	
	/*
	63'h034: Data = 32'b110100101 11 0001 0010 0011 0100 00000;
	63'h038: Data = 32'b110100101 10 0101 0110 0111 1000 00001;
	63'h03c: Data = 32'b110100101 01 1001 1010 1011 1100 00010;
	63'h040: Data = 32'b110100101 00 1101 1110 1111 0000 00011;
	*/
	//MOVZ
	63'h034: Data = 32'b11010010111000100100011010000000;
	63'h038: Data = 32'b11010010110010101100111100000001;
	63'h03c: Data = 32'b11010010101100110101011110000010;
	63'h040: Data = 32'b11010010100110111101111000000011;
	
	//ADD
	63'h044: Data = 32'b10001011000000010000000000000001;
	63'h048: Data = 32'b10001011000000110000000001000011;
	63'h04c: Data = 32'b10001011000000010000000001101001;
	
	//STUR
	63'h050: Data = 32'b11111000000000011100001111101001;
	//LDUR
	63'h054: Data = 32'b11111000010000011100001111101010;

	
	default: Data = 32'hXXXXXXXX;
      endcase
   end
endmodule
