`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/29 10:02:17
// Design Name: 
// Module Name: Registers
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


module Registers(
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    input regWrite,
    input clk,
    input reset,
    output [31:0] readData1,
    output [31:0] readData2
    );
    
    reg [31:0] RegFile[31:0];
    integer i;

    initial begin
        RegFile[0] = 0;
    end

    always @ (negedge clk or reset)
    begin
        if (reset)
        begin
            for(i = 0; i < 32; i = i + 1)
                RegFile[i] = 0;
        end
        else begin
            if (regWrite)
                RegFile[writeReg] = writeData; 
        end
    end

    assign readData1 = RegFile[readReg1];
    assign readData2 = RegFile[readReg2];

endmodule
