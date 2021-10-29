`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/27 00:01:19
// Design Name: 
// Module Name: adder_phy
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


module wb_reg_phy(
        input  WB_valid,     // 写回级有效
        input  [69:0] MEM_WB_bus_r, // MEM->WB总线
        output  rf_wen,       // 寄存器写使能
        output [ 4:0] rf_wdest,     // 寄存器写地址
        output [31:0] rf_wdata,     // 寄存器写数据
        output        WB_over,      // WB模块执行完成
         //展示PC
        output [ 31:0] WB_pc
    );
    
    //访存总线到写回总线
    //寄存器堆写使能和写地址
    wire wen;
    wire[4:0] wdest;
    
    //MEM传来的result
    wire[31:0]mem_result;
    
    //pc
    wire[31:0] pc;
    assign{wen,wdest,mem_result,pc}=MEM_WB_bus_r;
    
    //=================================WB执行完成=========================
    assign WB_over=WB_valid;
    
    //=========================WB->regfile信号============================
    assign rf_wen=wen & WB_valid;//写寄存器使能端:译码端有关
    assign rf_wdest=wdest;
    assign rf_wdata=mem_result;
    
    assign WB_pc=pc;
    
endmodule
