`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 08:55:06
// Design Name: 
// Module Name: ALUCtr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALUCtr(
    input [2:0] aluOp,
    input [5:0] funct,
    output [3:0] aluCtrOut,
    output shamtSign    // MIPS Shamt Sign
    );

    reg [3:0] ALUCtrOut;
    reg ShamtSign;

    always @ (aluOp or funct)
    begin
        ShamtSign = 0;
        // casex 表示按照两个操作数拼接之后的值进行匹配
        // x 是通配符，表示任意值
        casex({aluOp,funct})
            9'b000xxxxxx:  // lw,sw,add,addiu
                ALUCtrOut = 4'b0010;    

            9'b011xxxxxx:   // andi
                ALUCtrOut = 4'b0000;

            9'b100xxxxxx:   // ori
                ALUCtrOut = 4'b0001;

            9'b111xxxxxx:   // xori
                ALUCtrOut = 4'b1011;

            9'b001xxxxxx:   // beq, bne
                ALUCtrOut = 4'b0110;    

            9'b010xxxxxx:   // stli
                ALUCtrOut = 4'b0111;

            9'b110xxxxxx:   // stliu
                ALUCtrOut = 4'b1000;

            9'b101000100:   // sllv
                ALUCtrOut = 4'b0011;

            9'b101000110:   // srlv
                ALUCtrOut = 4'b0100;

            9'b101000111:   // srav
                ALUCtrOut = 4'b1110;

            9'b101100000:   // add
                ALUCtrOut = 4'b0010;

            9'b101100001:   // addu
                ALUCtrOut = 4'b0010;

            9'b101100010:   // sub
                ALUCtrOut = 4'b0110;

            9'b101100011:   // subu
                ALUCtrOut = 4'b0110;

            9'b101100100:   // and
                ALUCtrOut = 4'b0000;

            9'b101100101:   // or
                ALUCtrOut = 4'b0001;

            9'b101100110:   // xor
                ALUCtrOut = 4'b1011;

            9'b101100111:   // nor
                ALUCtrOut = 4'b1100;

            9'b101101010:   // slt
                ALUCtrOut = 4'b0111;

            9'b101101011:   // sltu
                ALUCtrOut = 4'b1000;

            9'b101001000:   // jr
                ALUCtrOut = 4'b0101;

            9'b101000000:   // sll
            begin
                ALUCtrOut = 4'b0011;
                ShamtSign = 1;
            end

            9'b101000010:   // srl
            begin
                ALUCtrOut = 4'b0100;
                ShamtSign = 1;
            end

            9'b101000011:   // sra
            begin
                ALUCtrOut = 4'b1110;
                ShamtSign = 1;
            end
            
        endcase
    end
    
    assign aluCtrOut = ALUCtrOut;
    assign shamtSign = ShamtSign;

endmodule
