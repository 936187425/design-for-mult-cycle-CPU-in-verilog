`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/27 00:05:59
// Design Name: PanHengyu
// Module Name: 取指模块,其中包含instruc_rom_phy模块之间的交互
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  多周期取指模块,交互的模块有instruc_rom_phy模块和decoder_code_phy模块
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define START_ADDR 32d'0   
module fetch_instruc_phy(
       //输出信号
       input clk,//时钟信号
       input resetn,//复位信号，低电平有效
       
       input IF_valid,//取指级有效信号
       input next_fetch,//取下一条指令，用来锁存PC值
       input[31:0] inst,//instruc_rom取出的指令
       input[32:0] jbr_bus,//跳转总线
       
       //输出信号
       output [31:0] inst_addr,//发往instruc_rom的取指地址
       output reg IF_over,//IF模块执行完成flag
       output[64:0] IF2ID_bus,//IF->ID总线
       
       //展示PC和取出的指令
       output[31:0] IF_pc,//当前取指模块的程序计数器的值
       output[31:0] IF_inst//当前取指模块的取出的指令
    );
    
    //==============================改变当前程序计数器的值(begin)===============
    wire[31:0] next_pc;//下一个指令的PC值
    wire[31:0] seg_pc;//中间pc值
    reg[31:0] pc;
    
    //跳转指令和顺序执行的下一条执行
    wire[31:0] jbr_target;//跳转或分支的目标地址
    wire jbr_taken;//跳转或分支有效
    
    assign {jbr_taken,jbr_target}=jbr_bus;//跳转总线
    assign  seg_pc[31:0]=pc[31:0]+3'b100;//顺序执行的下一条执行 PC=PC+4
    
    
    //新指令：若指令跳转，为跳转地址;否则为下一个指令
    assign next_pc = jbr_taken? jbr_target:seg_pc;
    
    //设置程序计数器
    always @(posedge clk)//PC计数器
    begin
        if(!resetn)begin
            pc <= 32'd0;//程序的初始地址
        end
        else if(next_fetch)
        begin
            pc<=next_pc;//取下一条指令
        end
    end
    //================================程序计数器end=============================
    
    //instrcu_rom的取指地址
    assign inst_addr=pc;
    
    //取指模块执行
    //由于取数据时,有一拍延时,(是instruc_inst_phy去控制)
    //即发地址的下一拍时钟才能得到对应的指令
    //故取指模块需要两拍时间
    //将IF_valid锁存一拍即是IF_over信号
    always@(posedge clk)
    begin
        IF_over<= IF_valid;
    end
    
    //================================取指模块和译码模块之间的交互总线===============
     assign  IF2ID_bus= {pc,inst};
    
    //====================================展示IF模块的PC值和指令=====================
     assign IF_pc = pc; 
     assign IF_inst = inst;
    
    
endmodule
