`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 08:04:59
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input reset
    );
    
    reg NOP;    // For stall 
    reg STALL;  // Stall 

    // IF
    reg [31:0] IF_PC;       // PC out 
    wire [31:0] IF_INST;    // Instruction
    InstMem inst_mem(
        .address(IF_PC),
        .inst(IF_INST)
    );

    // IF to ID
    reg [31:0] IF_TO_ID_INST;
    reg [31:0] IF_TO_ID_PC;

    // ID
    wire [12:0] ID_CTR_SIGNAL_BUS;
    wire [2:0] ID_CTR_SIGNAL_ALUOP;
    wire ID_JUMP_SIGN;
    wire ID_JR_SIGN;
    wire ID_EXT_SIGN;
    wire ID_REG_DST_SIGN;
    wire ID_JAL_SIGN;
    wire ID_ALU_SRC_SIGN;
    wire ID_LUI_SIGN;
    wire ID_BEQ_SIGN;
    wire ID_BNE_SIGN;
    wire ID_MEM_WRITE_SIGN;
    wire ID_MEM_READ_SIGN;
    wire ID_MEM_TO_REG_SIGN;
    wire ID_REG_WRITE_SIGN;
    wire ID_ALU_OP;
    Ctr main_ctr(
        .opCode(IF_TO_ID_INST[31:26]),
        .funct(IF_TO_ID_INST[5:0]),
        .jumpSign(ID_JUMP_SIGN),
        .jrSign(ID_JR_SIGN),
        .extSign(ID_EXT_SIGN),
        .regDst(ID_REG_DST_SIGN),
        .jalSign(ID_JAL_SIGN),
        .aluSrc(ID_ALU_SRC_SIGN),
        .luiSign(ID_LUI_SIGN),
        .beqSign(ID_BEQ_SIGN),
        .bneSign(ID_BNE_SIGN),
        .memWrite(ID_MEM_WRITE_SIGN),
        .memRead(ID_MEM_READ_SIGN),
        .memToReg(ID_MEM_TO_REG_SIGN),
        .regWrite(ID_REG_WRITE_SIGN),
        .aluOp(ID_CTR_SIGNAL_ALUOP)
    );
    
    // 数据挂到总线上 

    assign ID_CTR_SIGNAL_BUS[12] = ID_JUMP_SIGN;
    assign ID_CTR_SIGNAL_BUS[11] = ID_JR_SIGN;
    assign ID_CTR_SIGNAL_BUS[10] = ID_EXT_SIGN;
    assign ID_CTR_SIGNAL_BUS[9] = ID_REG_DST_SIGN;
    assign ID_CTR_SIGNAL_BUS[8] = ID_JAL_SIGN;
    assign ID_CTR_SIGNAL_BUS[7] = ID_ALU_SRC_SIGN;
    assign ID_CTR_SIGNAL_BUS[6] = ID_LUI_SIGN;
    assign ID_CTR_SIGNAL_BUS[5] = ID_BEQ_SIGN;
    assign ID_CTR_SIGNAL_BUS[4] = ID_BNE_SIGN;
    assign ID_CTR_SIGNAL_BUS[3] = ID_MEM_WRITE_SIGN;
    assign ID_CTR_SIGNAL_BUS[2] = ID_MEM_READ_SIGN;
    assign ID_CTR_SIGNAL_BUS[1] = ID_MEM_TO_REG_SIGN;
    assign ID_CTR_SIGNAL_BUS[0] = ID_REG_WRITE_SIGN;

    wire[31:0] ID_REG_RD_DATA1;     // Register for ID read
    wire[31:0] ID_REG_RD_DATA2;   

    wire[4:0] WB_WR_REG_ID;                     // wire for write id
    wire[4:0] WB_WR_REG_ID_AFTER_JAL_MUX;       // Especially for register after JAL mux
    wire[31:0] WB_REG_WR_DATA;                  // wire for data 
    wire[31:0] WB_REG_WR_DATA_AFTER_JAL_MUX;    // Especially for data after JAL mux
    wire WB_REG_WR;                             // wire for write register

    wire [4:0] ID_REG_DEST;
    wire [4:0] ID_REG_RS = IF_TO_ID_INST[25:21];
    wire [4:0] ID_REG_RT = IF_TO_ID_INST[20:16];
    wire [4:0] ID_REG_RD = IF_TO_ID_INST[15:11];

    Mux32 jal_data_mux(
        .select(ID_JAL_SIGN),
        .input0(WB_REG_WR_DATA),
        .input1(IF_TO_ID_PC + 4),   // PC存的是下一条指令的位置
        .out(WB_REG_WR_DATA_AFTER_JAL_MUX)
    );

    Mux32 jal_reg_id_mux(
        .select(ID_JAL_SIGN),
        .input0(WB_WR_REG_ID),
        .input1(5'b11111),
        .out(WB_WR_REG_ID_AFTER_JAL_MUX)
    );
    
    // 数据写回在WB阶段
    Mux5 reg_dst_mux(
        .select(ID_CTR_SIGNAL_BUS[9]),
        .input0(ID_REG_RT),
        .input1(ID_REG_RD),
        .out(ID_REG_DEST)
    );

    Registers reg_file(
        .readReg1(ID_REG_RS),
        .readReg2(IF_TO_ID_INST[20:16]),
        .writeReg(WB_WR_REG_ID_AFTER_JAL_MUX),
        .writeData(WB_REG_WR_DATA_AFTER_JAL_MUX),
        .regWrite(WB_REG_WR),
        .clk(clk),
        .reset(reset),
        .readData1(ID_REG_RD_DATA1),
        .readData2(ID_REG_RD_DATA2)
    );
    
    wire [31:0] ID_EXT_RES;

    signext sign_ext(
        .inst(IF_TO_ID_INST[15:0]),
        .signExt(ID_EXT_SIGN),
        .data(ID_EXT_RES)
    );


    // ID to EX
    reg [2:0] ID_TO_EX_ALUOP;
    reg [7:0] ID_TO_EX_CTR_SIGNAL;
    reg [31:0] ID_TO_EX_EXT_RES;
    reg [4:0] ID_TO_EX_INST_RS;        
    reg [4:0] ID_TO_EX_INST_RT;       
    reg [31:0] ID_TO_EX_REG_RD_DATA1;
    reg [31:0] ID_TO_EX_REG_RD_DATA2;
    reg [5:0] ID_TO_EX_INST_FUNCT;
    reg [4:0] ID_TO_EX_INST_SHAMT;
    reg [4:0] ID_TO_EX_REG_DST;
    reg [31:0] ID_TO_EX_PC;


    // EX 
    wire EX_ALU_SRC_SIG = ID_TO_EX_CTR_SIGNAL[7];
    wire EX_LUI_SIG = ID_TO_EX_CTR_SIGNAL[6];
    wire EX_BEQ_SIG = ID_TO_EX_CTR_SIGNAL[5];
    wire EX_BNE_SIG = ID_TO_EX_CTR_SIGNAL[4];

    wire [3:0] EX_ALU_CTR_OUT;   
    wire EX_SHAMT_SIGNAL;   

    ALUCtr alu_ctr(
        .aluOp(ID_TO_EX_ALUOP),
        .funct(ID_TO_EX_INST_FUNCT),
        .shamtSign(EX_SHAMT_SIGNAL),
        .aluCtrOut(EX_ALU_CTR_OUT)
    );

    // ! Forwarding
    wire [31:0] FORWARDING_RES_A;
    wire [31:0] FORWARDING_RES_B;

    wire [31:0] EX_ALU_INPUT2;
    wire [31:0] EX_ALU_INPUT1;

    Mux32 rt_ext_mux(
        .select(EX_ALU_SRC_SIG),
        .input1(ID_TO_EX_EXT_RES),
        .input0(FORWARDING_RES_B),
        .out(EX_ALU_INPUT2)
    );
    Mux32 rs_shamt_mux(
        .select(EX_SHAMT_SIGNAL),
        .input1({27'b0, ID_TO_EX_INST_SHAMT}),  // 27'b0是为了补全32位
        .input0(FORWARDING_RES_A),
        .out(EX_ALU_INPUT1)
    );

    wire EX_ALU_ZERO;   //ALU_ZERO
    wire [31:0] EX_ALU_RES;
    wire [31:0] EX_FINAL_DATA;
    ALU alu(
        .input1(EX_ALU_INPUT1),
        .input2(EX_ALU_INPUT2),
        .aluCtr(EX_ALU_CTR_OUT),
        .aluRes(EX_ALU_RES),
        .zero(EX_ALU_ZERO)
    );

    Mux32 lui_mux(
        .select(EX_LUI_SIG),
        .input0(EX_ALU_RES),
        .input1({ID_TO_EX_EXT_RES[15:0], 16'b0}),
        .out(EX_FINAL_DATA)
    );

    wire [31:0] BRANCH_DST = ID_TO_EX_PC + (ID_TO_EX_EXT_RES << 2) + 4;

    // EX to MA
    reg [3:0] EX_TO_MA_CTR_SIGNAL;
    reg [31:0] EX_TO_MA_ALU_RES;
    reg [31:0] EX_TO_MA_REG_RD_DATA2;
    reg [4:0] EX_TO_MA_REG_DST;

    wire MA_MEM_WR = EX_TO_MA_CTR_SIGNAL[3];
    wire MA_MEM_RD = EX_TO_MA_CTR_SIGNAL[2];
    wire MA_MEM_TO_REG = EX_TO_MA_CTR_SIGNAL[1];
    wire MA_REG_WR = EX_TO_MA_CTR_SIGNAL[0];

    // MA
    wire [31:0] MA_MEM_RD_DATA;
    Cache memory(
        .clk(clk),
        .address(EX_TO_MA_ALU_RES),
        .writeData(EX_TO_MA_REG_RD_DATA2),
        .memWrite(MA_MEM_WR),
        .memRead(MA_MEM_RD),
        .readData(MA_MEM_RD_DATA)
    );

    wire [31:0] MA_FINAL_DATA;
    Mux32 mem_to_reg_mux(
        .select(MA_MEM_TO_REG),
        .input0(EX_TO_MA_ALU_RES),
        .input1(MA_MEM_RD_DATA),
        .out(MA_FINAL_DATA)
    );

    // MA to WB
    reg MA_TO_WB_CTR_SIGNAL;
    reg [31:0] MA_TO_WB_FINAL_DATA;
    reg [4:0] MA_TO_WB_REG_DST;

    // WB
    assign WB_WR_REG_ID = MA_TO_WB_REG_DST;
    assign WB_REG_WR_DATA = MA_TO_WB_FINAL_DATA;
    assign WB_REG_WR = MA_TO_WB_CTR_SIGNAL;

    // Jump/Branch part
    // ID 
    wire[31:0] PC_AFTER_JUMP_MUX;
    Mux32 jump_mux(
        .select(ID_JUMP_SIGN), 
        .input0(IF_PC + 4),
        .input1(((IF_TO_ID_PC + 4) & 32'hf0000000) + (IF_TO_ID_INST[25 : 0] << 2)),
        .out(PC_AFTER_JUMP_MUX)
    );
    
    wire[31:0] PC_AFTER_JR_MUX;
    Mux32 jr_mux(
        .select(ID_JR_SIGN),   
        .input0(PC_AFTER_JUMP_MUX),
        .input1(ID_REG_RD_DATA1),
        .out(PC_AFTER_JR_MUX)
    );
    
    // EX 
    wire EX_BEQ_BRANCH = EX_BEQ_SIG & EX_ALU_ZERO;
    wire[31:0] PC_AFTER_BEQ_MUX;
    Mux32 beq_mux(
        .select(EX_BEQ_BRANCH),
        .input0(PC_AFTER_JR_MUX),
        .input1(BRANCH_DST),
        .out(PC_AFTER_BEQ_MUX)
    );
    
    wire EX_BNE_BRANCH = EX_BNE_SIG & (~ EX_ALU_ZERO);
    wire[31:0] PC_AFTER_BNE_MUX;
    Mux32 bne_mux(
        .select(EX_BNE_BRANCH),
        .input0(PC_AFTER_BEQ_MUX),
        .input1(BRANCH_DST),
        .out(PC_AFTER_BNE_MUX)
    );

    wire[31:0] NEXT_PC = PC_AFTER_BNE_MUX;
    
    wire BRANCH = EX_BEQ_BRANCH | EX_BNE_BRANCH;  // Branch signal

    // forwarding 定义前向传递需要的信号和 MUX
    wire[31:0] EX_FORWARDING_A_TEMP;
    wire[31:0] EX_FORWARDING_B_TEMP;
    Mux32 forward_A_mux1(
        .select(WB_REG_WR & (MA_TO_WB_REG_DST == ID_TO_EX_INST_RS)),
        .input0(ID_TO_EX_REG_RD_DATA1),
        .input1(MA_TO_WB_FINAL_DATA),
        .out(EX_FORWARDING_A_TEMP)
    );
    Mux32 forward_A_mux2(
        .select(MA_REG_WR & (EX_TO_MA_REG_DST == ID_TO_EX_INST_RS)),
        .input0(EX_FORWARDING_A_TEMP),
        .input1(EX_TO_MA_ALU_RES),
        .out(FORWARDING_RES_A)
    );
    
    Mux32 forward_B_mux1(
        .select(WB_REG_WR & (MA_TO_WB_REG_DST == ID_TO_EX_INST_RT)),
        .input0(ID_TO_EX_REG_RD_DATA2),
        .input1(MA_TO_WB_FINAL_DATA),
        .out(EX_FORWARDING_B_TEMP)
    );
    Mux32 forward_B_mux2(
        .select(MA_REG_WR & (EX_TO_MA_REG_DST == ID_TO_EX_INST_RT)),
        .input0(EX_FORWARDING_B_TEMP),
        .input1(EX_TO_MA_ALU_RES),
        .out(FORWARDING_RES_B)
    );

    initial IF_PC = 0;
    
    always @(reset)
    begin
        if (reset) begin
            IF_PC = 0;
            IF_TO_ID_INST = 0;
            IF_TO_ID_PC = 0;
            ID_TO_EX_ALUOP = 0;
            ID_TO_EX_CTR_SIGNAL = 0;
            ID_TO_EX_EXT_RES = 0;
            ID_TO_EX_INST_RS = 0;
            ID_TO_EX_INST_RT = 0;
            ID_TO_EX_REG_RD_DATA1 = 0;
            ID_TO_EX_REG_RD_DATA2 = 0;
            ID_TO_EX_INST_FUNCT = 0;
            ID_TO_EX_INST_SHAMT = 0;
            ID_TO_EX_REG_DST = 0;
            EX_TO_MA_CTR_SIGNAL; = 0;
            EX_TO_MA_ALU_RES = 0;
            EX_TO_MA_REG_RD_DATA2 = 0;
            EX_TO_MA_REG_DST = 0;
            MA_TO_WB_CTR_SIGNAL; = 0;
            MA_TO_WB_FINAL_DATA = 0;
            MA_TO_WB_REG_DST = 0;
        end
    end
    
    always @(posedge clk) 
    begin
        NOP = BRANCH | ID_JUMP_SIGN | ID_JR_SIGN;
        // 需要Stall的情况
        // 1. 读取的两个寄存器与内存读冲突
        // 2. ID_MEM_READ_SIGN 为 1
        STALL = ID_TO_EX_CTR_SIGNAL[2] & 
                 ((ID_TO_EX_INST_RT == ID_REG_RS) |  
                 (ID_TO_EX_INST_RT == ID_REG_RT)); 

        // IF ==> ID
        if(!STALL)
        begin
            if(NOP)
            begin
                if(IF_PC == NEXT_PC)
                begin
                    IF_TO_ID_INST <= IF_INST;
                    IF_TO_ID_PC <= IF_PC;
                    IF_PC <= IF_PC + 4;
                end
                else begin
                    IF_TO_ID_INST <= 0;
                    IF_TO_ID_PC <= 0;
                    IF_PC <= NEXT_PC;
                end
            end
            else begin
                IF_TO_ID_INST <= IF_INST;
                IF_TO_ID_PC <= IF_PC;
                IF_PC <= NEXT_PC;
            end
        end
        
        // ID ==> EX
        if (!ID_JAL_SIGN)
        begin
            if (STALL | NOP)
            begin
                // JUMP 不影响，在ID阶段就已经决定了
                // BRANCH 需要发生跳转，在此处截断
                // 需要等待上条指令MA完成才进行EX的需要插入STALL

                ID_TO_EX_PC <= IF_TO_ID_PC;
                ID_TO_EX_ALUOP <= 3'b000;
                ID_TO_EX_CTR_SIGNAL <= 0;
                ID_TO_EX_EXT_RES <= 0;
                ID_TO_EX_INST_RS <= 0;
                ID_TO_EX_INST_RT <= 0;
                ID_TO_EX_REG_RD_DATA1 <= 0;
                ID_TO_EX_REG_RD_DATA2 <= 0;
                ID_TO_EX_INST_FUNCT <= 0;
                ID_TO_EX_INST_SHAMT <= 0;
                ID_TO_EX_REG_DST <= 0;
            end else 
            begin
                ID_TO_EX_PC <= IF_TO_ID_PC;
                ID_TO_EX_ALUOP <= ID_CTR_SIGNAL_ALUOP;
                ID_TO_EX_CTR_SIGNAL <= ID_CTR_SIGNAL_BUS[7:0];
                ID_TO_EX_EXT_RES <= ID_EXT_RES;
                ID_TO_EX_INST_RS <= ID_REG_RS;
                ID_TO_EX_INST_RT <= ID_REG_RT;
                ID_TO_EX_REG_DST <= ID_REG_DEST;
                ID_TO_EX_REG_RD_DATA1 <= ID_REG_RD_DATA1;
                ID_TO_EX_REG_RD_DATA2 <= ID_REG_RD_DATA2;
                ID_TO_EX_INST_FUNCT <= IF_TO_ID_INST[5:0];
                ID_TO_EX_INST_SHAMT <= IF_TO_ID_INST[10:6];
            end
        end

        // EX ==> MA
        if (!ID_JAL_SIGN)
        begin
            EX_TO_MA_CTR_SIGNAL <= ID_TO_EX_CTR_SIGNAL[3:0];
            EX_TO_MA_ALU_RES <= EX_FINAL_DATA;
            EX_TO_MA_REG_RD_DATA2 <= FORWARDING_RES_B;
            EX_TO_MA_REG_DST <= ID_TO_EX_REG_DST;
        end

        // MA - WB
        if (!ID_JAL_SIGN)
        begin
            MA_TO_WB_CTR_SIGNAL; <= EX_TO_MA_CTR_SIGNAL[0];
            MA_TO_WB_FINAL_DATA <= MA_FINAL_DATA;
            MA_TO_WB_REG_DST <= EX_TO_MA_REG_DST;
        end
        
    end

endmodule
