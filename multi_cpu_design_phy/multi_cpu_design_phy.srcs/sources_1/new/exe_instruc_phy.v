`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/27 00:05:59
// Design Name: Panhengyu from njust
// Module Name: alu_phy
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 执行模块
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module exe_instruc_phy(
     input EXE_valid,//执行模块的有效信号
     input [149:0] ID_EXE_bus_r,//译码模块ID->执行模块EXE总线
     output EXE_over,//执行模块执行完成
     output [105:0] EXE_MEM_bus,//EXE->MEM总线
     //展示PC
     output[31:0] EXE_pc
    );
    //EXE需要用到的信息
    wire[11:0] alu_control;
    wire[31:0] alu_operand1;
    wire[31:0] alu_operand2;
    
    //访存需要用到的信息
    wire[3:0]  mem_control;//MEM需要使用的控制信号
    wire[31:0] store_data;//store操作的存的数据
    
    //写回需要用到的信息
    wire rf_wen;//写回的寄存器写使能
    wire[4:0] rf_wdest;//写回目的寄存器
    
    //pc
    wire[31:0] pc;
    assign {alu_control,alu_operand1,alu_operand2,
            mem_control,store_data,
            rf_wen,rf_wdest,
            pc}=ID_EXE_bus_r;
    
    //实例化算术逻辑运算单元
    wire[31:0] alu_result;
    alu_phy alu_module(
        .alu_control(alu_control),//(input)
        .alu_src1(alu_operand1),//(input)
        .alu_src2(alu_operand2),//(input)
        .alu_result(alu_result)//(output)
    );
    
    //执行模块执行完成
    //由于是多周期,不存在数据相关
    //且所有ALU运算都可在一拍内完成
    //故EXE模块一拍就能完成所有操作
    //故EXE_valid即是EXE_over信号
    assign EXE_over=EXE_valid;
    
    //赋值执行模块到访存模块之间的数据总线
    assign EXE_MEM_bus={
            mem_control,//load/store控制信号
            store_data,//load/store存储的数据
            alu_result,//alu的运算结果
            rf_wen,
            rf_wdest,
            pc
        };
        assign EXE_pc=pc;
endmodule
