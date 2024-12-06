`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 09:25:54
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] input1,
    input [31:0] input2,
    input [3:0] aluCtr,
    output [31:0] aluRes,
    output zero
    );

    reg Zero;
    reg [31:0] ALURes;

    always @ (aluCtr or input1 or input2)
    begin
    // 按照aluCtr的值的大小从小到大进行比较

        case(aluCtr)    
        4'b0000:    // and
            ALURes = input1 & input2;
        4'b0001:    // or
            ALURes = input1 | input2;
        4'b0010:    // add
            ALURes = input1 + input2;
        4'b0011:    // shift left logical
            ALURes = input2 << input1;
        4'b0100:    // shift right logical
            ALURes = input2 >> input1;
        4'b0101:    // shift right arithmetic
            ALURes = input1;
        4'b0110:    // sub
            ALURes = input1 - input2;
        4'b0111:    // set less than
            ALURes = ($signed(input1) < $signed(input2));
        4'b1000:    // set less than unsigned
            ALURes = (input1 < input2);
        4'b1011:    // xor
            ALURes = input1 ^ input2;
        4'b1100:    // nor
            ALURes = ~(input1 | input2);
        4'b1110:    // shift right ARITHMETIC!!!
            ALURes = ($signed(input2) >> input1);
        endcase
        
        Zero = (ALURes == 0);
    end

    assign zero = Zero;
    assign aluRes = ALURes;
endmodule
