module NextPC(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch); 
   input [63:0] CurrentPC, SignExtImm64; 
   input 	Branch, ALUZero, Uncondbranch; 
   output reg [63:0] NextPC; 

   /* write your code here */ 
   always @(*) begin
       if(Uncondbranch || (Branch && ALUZero)) begin //unconditional branch or CBZ 
            NextPC <= #3 CurrentPC + (SignExtImm64 << 2); //add PC with sign extender 
           end
       else begin
            NextPC <= #2 CurrentPC + 4; //increase pc by 4
           end
    end
endmodule
