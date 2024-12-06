`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 10:37:49
// Design Name: 
// Module Name: Mux5
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

// 5 位多路选择器 仅支持基本的MIPS指令

module Mux5(
    input select,
    input [4:0] input0,
    input [4:0] input1,
    output [4:0] out
    );

    assign out = select ? input1 : input0;
endmodule
