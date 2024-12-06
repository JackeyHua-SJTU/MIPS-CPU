`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/02 01:25:36
// Design Name: 
// Module Name: top_tb
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

// 测试整个模块是否能够正常运行

module single_cycle_cpu_tb(

    );

    reg clk;
    reg reset;

    top processor(
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $readmemb("/home/huazhendong/Desktop/sjtu/course/archexp/lab06/mem_inst.dat",top.inst_mem.instFile);
        $readmemh("/home/huazhendong/Desktop/sjtu/course/archexp/lab06/mem_data.dat",top.memory.mem.memFile);
        reset = 1;
        clk = 0;
    end

    always #20 clk = ~clk;

    initial begin
        #20 reset = 0;
        #3000;
        $finish;
    end
endmodule
