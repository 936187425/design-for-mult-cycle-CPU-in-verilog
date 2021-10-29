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
// 加法器,直接使用"+",会自动调用库里的加法器
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_phy(
    input[31:0] operand1,
    input[31:0] operand2,
    input cin,
    output[31:0] result,
    output cout
    );
    assign{cout,result} = operand1+operand2+cin;
endmodule
