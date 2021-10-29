// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sat Oct  2 22:34:54 2021
// Host        : LAPTOP-JVFPP69E running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/design-for-mult-cycle-CPU-in-verilog/multi_cpu_design_phy/multi_cpu_design_phy.srcs/sources_1/ip/data_ram_phy/data_ram_phy_stub.v
// Design      : data_ram_phy
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module data_ram_phy(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[3:0],addra[7:0],dina[31:0],douta[31:0],clkb,web[3:0],addrb[7:0],dinb[31:0],doutb[31:0]" */;
  input clka;
  input [3:0]wea;
  input [7:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb;
  input [3:0]web;
  input [7:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule
