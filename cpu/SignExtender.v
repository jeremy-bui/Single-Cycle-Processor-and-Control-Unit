`define I     3'b000
`define D     3'b001 
`define B     3'b010 
`define CBZ   3'b011
`define MOVZ  3'b100
module SignExtender(BusImm, In, Ctrl, Op); 
   //Outputs
   output [63:0] BusImm; 
   //Inputs
   input [25:0]  In; 
   input [2:0] Ctrl;
   input [1:0] Op;
   //Intermediate value
   wire 	 extBit; 
   
   //all follow syntax of condition? true : false where the false condition nests to the next condition 
   assign extBit = (Ctrl == `I)? In[21] : 
                   ((Ctrl == `D)? In[20] : 
                   ((Ctrl == `B)? In[25] :
                   ((Ctrl == `CBZ)? In[23] : In[25] )));
                   
   assign BusImm = (Ctrl == `I)? {{34{extBit}},In[21:10]} : 
                   ((Ctrl == `D)? {{33{extBit}},In[20:12]} : 
                   ((Ctrl == `B)? {{39{extBit}},In[25:0]} : 
                   ((Ctrl == `MOVZ && Op == 2'b00)? {{48{1'b0}},In[20:5]}:
                   ((Ctrl == `MOVZ && Op == 2'b01)? {{32{1'b0}},In[20:5],{16{1'b0}}}:
                   ((Ctrl == `MOVZ && Op == 2'b10)? {{16{1'b0}},In[20:5],{32{1'b0}}}:
                   ((Ctrl == `MOVZ && Op == 2'b11)? {In[20:5],{48{1'b0}}}:
                   ((Ctrl == `CBZ)? {{45{extBit}},In[23:5]} : {{39{extBit}},In[25:0]} )))))));

endmodule
