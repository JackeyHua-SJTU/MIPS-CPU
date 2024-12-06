`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/27 10:20:37
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input clk,
    input [31:0] address,
    input [31:0] writeData,
    input memWrite,
    input memRead,
    output [127:0] readData
    );

    reg [31:0] memFile [0:1023];
    reg [127:0] ReadData;

    // 初始化的时候清空内存 
    integer i = 0;
    
    initial begin
        for(i = 0; i < 1024; i = i + 1)
            memFile[i] = 0;
    end

    always @(memRead or address or memWrite) 
    begin
        if(memRead)
        begin
            if(address < 1024)
                ReadData = {memFile[address], memFile[address + 1],
                            memFile[address + 2], memFile[address + 3]};
            else
                ReadData = 0;
        end
    end

    always @(negedge clk)
    begin
        if(memWrite)
            if(address < 1024)
                memFile[address] = writeData;
    end

    assign readData = ReadData;
endmodule
