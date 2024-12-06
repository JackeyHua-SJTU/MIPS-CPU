`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/29 08:13:30
// Design Name: 
// Module Name: Mux32
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

// 32 位多路选择器 适配更多的指令

module Mux32(
    input select,
    input [31:0] input0,
    input [31:0] input1,
    output [31:0] out
    );

    assign out = select ? input1 : input0;
endmodule
