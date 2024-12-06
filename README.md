# Five Stage MIPS CPU in Verilog
This is a simple 5-stage MIPS CPU implemented in Verilog. 

Five stages are:
1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

The CPU supports the following instructions:
1. R, J, I type instructions (31 instructions in total)
2. Data forwarding
3. Stall control for _lw_
4. Branch prediction (Not Taken)

Check `lab06.srcs/` for the source code.
Check `report.pdf` for the report.