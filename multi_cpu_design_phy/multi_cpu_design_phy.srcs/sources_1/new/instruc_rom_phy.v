`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/12 22:32:33
// Design Name: 
// Module Name: instruc_rom_phy
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


module instruc_rom_phy(
input      [31:0] addr, // 指令地址
input clk,
output reg [31:0] inst       // 指令
    );
    
reg[31:0] mem[0:127];
reg [31:0] address;
initial 
     begin
        $readmemb("C:/Users/panhengyu/Desktop/gjx918101630110/gjx918101630110/ins.txt", mem); //读取测试文档中的指令
        inst = 0; // 指令初始化
     end
     always @(posedge clk) begin
         // IAddr中一个单元是1byte，即8位，那么32位地址需要4个单元
         // IAddr++ <=> pc += 4(100)，即IAddr的最后两位都为0
         // 从第三位开始取，即是代表指令的个数
         address = addr[31:2] ; // 因为4个内存单元存储一个指令，所以除以4得到第一个内存单元的下标
         // 将4个8位的内存单元合并为32位的指令
         inst = mem[address];
    end
endmodule
