`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111
`define MOVZ  4'b1000


module ALU(BusW, BusA, BusB, ALUCtrl, Zero);
    
    output  [63:0] BusW;
    input   [63:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  Zero;
    
    reg     [63:0] BusW;
    
    always @(ALUCtrl or BusA or BusB) begin
        case(ALUCtrl)
            `AND: begin
                BusW = BusA & BusB;
            end
             `OR:begin
                BusW = BusA | BusB;
            end
             `ADD:begin
                BusW = BusA + BusB;
            end
             `SUB:begin
                BusW = BusA - BusB;
            end
             `PassB:begin
                BusW = BusB;
            end
             `MOVZ:begin
                BusW = BusA[20:5] << (BusA[22:21]*16);
            end
            
        endcase
    end

    assign Zero = BusW ?0:1;
endmodule
