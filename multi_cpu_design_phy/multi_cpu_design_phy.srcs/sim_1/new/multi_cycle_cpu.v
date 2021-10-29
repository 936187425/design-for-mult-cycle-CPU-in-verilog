`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/04 12:07:06
// Design Name: 
// Module Name: multi_cycle_cpu
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


module multi_cycle_cpu(

    );
    //cpu实例元件输入(input)
    reg clk;//时钟
    reg resetn;//低电平有效,重置信号
    reg[4:0] regStack_addr;//扫描寄存器堆寄存器标号
    reg[31:0] mem_addr;//观察的内存地址
    //cpu实例元件的输出(output)
    wire[31:0]   regStack_data ;//寄存器堆从调试端口读出的数据
    wire[31:0]   mem_data;//内存地址对应的数据
    wire[31:0]   IF_pc;//取指模块的pc值
    wire[31:0]   IF_inst;//取指模块的指令
    wire[31:0]   ID_pc;//译码模块的pc值
    wire[31:0]   EXE_pc;//执行模块的pc值
    wire[31:0]   MEM_pc;//访存模块的pc值
    wire[31:0]   WB_pc;//写回模块的pc值
    wire[31:0]   display_state;//当前cpu的状态
    wire rf_wen;
    
    mult_clock_cpu_phy mult_cpu_module(
        .clk(clk),
        .resetn(resetn),
        .regStack_addr(regStack_addr),
        .regStack_data(regStack_data),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .IF_pc(IF_pc),
        .IF_inst(IF_inst),
        .ID_pc(ID_pc),
        .EXE_pc(EXE_pc),
        .MEM_pc(MEM_pc),
        .WB_pc(WB_pc),
        .display_state(display_state),
        .rf_wen(rf_wen)
    );
    initial begin
           //Iinitial Inputs
           clk=0;
           resetn=0;
           //仿真文件中要显示的寄存器值和内存值
            regStack_addr=5'd01;
            mem_addr=32'h14;
       
           #100;
                resetn=1; 
            
                       
    end
    always #5 clk=~clk;
    
endmodule
