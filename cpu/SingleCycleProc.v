module singlecycle(
		   input 	     resetl,
		   input [63:0]      startpc,
		   output reg [63:0] currentpc,
		   output [63:0]     MemtoRegOut,  // this should be
						   // attached to the
						   // output of the
						   // MemtoReg Mux
		   input 	     CLK
		   );

   // Next PC connections
   wire [63:0] 			     nextpc;       // The next PC, to be updated on clock cycle
   wire [63:0]			     pcAdd4;
   wire [63:0] 			     pcAddSigExt;

   // Instruction Memory connections
   wire [31:0] 			     instruction;  // The current instruction

   // Parts of instruction
   wire [4:0] 			     rd;            // The destination register
   wire [4:0] 			     rm;            // Operand 1
   wire [4:0] 			     rn;            // Operand 2
   wire [10:0] 			     opcode;

   // Control wires
   wire 			     reg2loc;
   wire 			     alusrc;
   wire 			     mem2reg;
   wire 			     regwrite;
   wire 			     memread;
   wire 			     memwrite;
   wire 			     branch;
   wire 			     uncond_branch;
   wire [3:0] 			     aluctrl;
   wire [2:0] 			     signop;

   // Register file connections
   wire [63:0] 			     regoutA;     // Output A
   wire [63:0] 			     regoutB;     // Output B

   // ALU connections
   wire [63:0] 			     aluout;
   wire 			     zero;
   wire 			     toBranch; //input for upper mux
   wire [63:0]			     sigExtMUXB;
   
   //data mem connections
   wire [63:0] 		             readData;

   // Sign Extender connections
   wire [63:0] 			     extimm;
   wire [25:0]			     inSigExt;
   wire [1:0]			     movzOp;	

   // PC update logic
   always @(negedge CLK)
     begin
        if (resetl)
          currentpc <= #3 nextpc;
        else
          currentpc <= #3 startpc;
     end

   // Parts of instruction
   assign rd = instruction[4:0];
   assign rm = instruction[9:5];
   assign rn = reg2loc ? instruction[4:0] : instruction[20:16];
   assign opcode = instruction[31:21];

   InstructionMemory imem(
			  .Data(instruction),
			  .Address(currentpc)
			  );

   control control(
		   .reg2loc(reg2loc),
		   .alusrc(alusrc),
		   .mem2reg(mem2reg),
		   .regwrite(regwrite),
		   .memread(memread),
		   .memwrite(memwrite),
		   .branch(branch),
		   .uncond_branch(uncond_branch),
		   .aluop(aluctrl),
		   .signop(signop),
		   .opcode(opcode)
		   );

   /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */
   DataMemory dmem(
		     .ReadData(readData) , 
		     .Address(aluout) ,
		     .WriteData(regoutB) , 
		     .MemoryRead(memread) ,
		     .MemoryWrite(memwrite),
		     .Clock(CLK)
		     );
   assign MemtoRegOut= mem2reg ? readData : aluout; //simulate mux
   
   assign inSigExt = instruction[25:0];
   assign movzOp = instruction[22:21];
   
   SignExtender sigext(
		  .BusImm(extimm), 
		  .In(inSigExt), 
		  .Ctrl(signop),
		  .Op(movzOp)
	       ); 
   assign sigExtMUXB = alusrc ? extimm :regoutB;
   ALU alu(
		  .BusW(aluout), 
		  .BusA(regoutA), 
		  .BusB(sigExtMUXB), 
		  .ALUCtrl(aluctrl), 
		  .Zero(zero)
      );
      
   NextPC next(	
		  .NextPC(nextpc), 
		  .CurrentPC(currentpc), 
		  .SignExtImm64(extimm), 
		  .Branch(branch), 
		  .ALUZero(zero), 
		  .Uncondbranch(uncond_branch)
	 );
   
   assign toBranch = (zero & branch) | uncond_branch;
   
   
   assign pcAdd4 = nextpc + 4;
   assign pcAddSigExt = nextpc + (extimm << 2);
   
   RegisterFile regfile(
		  .BusA(regoutA), 
		  .BusB(regoutB), 
		  .BusW(MemtoRegOut), 
		  .RA(rm), 
		  .RB(rn), 
		  .RW(rd), 
		  .RegWr(regwrite), 
		  .Clk(CLK)
		  );
endmodule

