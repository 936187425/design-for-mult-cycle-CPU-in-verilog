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


module access_mem_phy(
      input clk,//时钟
      input   MEM_valid,//访存级有效信号
      input[105:0] EXE_MEM_bus_r,//执行模块到访存模块的寄存器信号
      input[31:0] dm_rdata,//访存读数据
      output[31:0]dm_addr,//访存读写地址
      output reg [3:0] dm_wen,//访存写使能
      output reg [31:0] dm_wdata,//访存写数据
      output MEM_over,//执行模块执行完成
      output [69:0] MEM_WB_bus,//MEM_WB总线
      
      //展示PC
      output [31:0] MEM_pc
    );
    
    //访存需要用到的信息
    wire[3:0] mem_control;
    wire[31:0] store_data;
    
    //alu运算结果
    wire[31:0] alu_result;
    
    //写回需要用的信息
    wire rf_wen;
    wire[4:0] rf_wdest;
    
    //pc
    wire[31:0] pc;
    assign {mem_control,store_data,alu_result,rf_wen,rf_wdest,pc}=EXE_MEM_bus_r;
    
    //=========================load/store访存=============================
    wire inst_load;//load操作
    wire inst_store;//store操作
    wire ls_word;//load/store为字节还是字，0：byte;1:word;
    wire lb_sign;//load一字节为有符号load
    
    assign{inst_load,inst_store,ls_word,lb_sign}=mem_control;
    
    //访存读写地址
    assign dm_addr=alu_result;
    
    //store操作的写使能
    always @ (*)
    begin
        if(MEM_valid && inst_store)//访存级有效时，且为store操作
        begin
            if(ls_word)
            begin
                dm_wen<=4'b1111;//存储字指令，写使能全1
            end
            else
            begin //SB指令,需要依据地址底两位，确定对应的写使能
                case(dm_addr[1:0])
                    2'b00: dm_wen<=4'b0001;
                    2'b01: dm_wen<=4'b0010;
                    2'b10: dm_wen<=4'b0100;
                    2'b11: dm_wen<=4'b1000;
                    default:dm_wen<=4'b0000;
                endcase    
            end 
        end
        else 
        begin
            dm_wen<=4'b0000;
        end
    end
    
    //store操作的写数据
    always@(*)//对于SB指令，需要依据地址低两位，移动store的字节至对应位置
    begin
        case(dm_addr[1:0])
            2'b00:dm_wdata<=store_data;
            2'b01:dm_wdata<={16'd0,store_data[7:0],8'd0};
            2'b10:dm_wdata<={8'd0,store_data[7:0],16'd0};
            2'b11:dm_wdata<={store_data[7:0],24'd0};
            default:dm_wdata<=store_data;
         endcase   
    end
    
      //load读出的数据
     wire        load_sign;
     wire [31:0] load_result;
     assign load_sign = (dm_addr[1:0]==2'd0) ? dm_rdata[ 7] :
                        (dm_addr[1:0]==2'd1) ? dm_rdata[15] :
                        (dm_addr[1:0]==2'd2) ? dm_rdata[23] : dm_rdata[31] ;
     assign load_result[7:0] = (dm_addr[1:0]==2'd0) ? dm_rdata[ 7:0 ] :
                               (dm_addr[1:0]==2'd1) ? dm_rdata[15:8 ] :
                               (dm_addr[1:0]==2'd2) ? dm_rdata[23:16] :
                                                      dm_rdata[31:24] ;
     assign load_result[31:8]= ls_word ? dm_rdata[31:8] :
                                         {24{lb_sign & load_sign}};
     //由于数据RAM为同步读写
     //故对load指令，取数据时，有一拍延时
     //即发地址的下一拍时钟才能得到load的数据
     //故mem在进行load操作时有需要两拍时间才能取到数据
     //而对其他操作，则只需要一拍时间
     reg MEM_valid_r;
     always @(posedge clk)
     begin  
        MEM_valid_r <= MEM_valid;
     end
     assign MEM_over=inst_load?MEM_valid_r:MEM_valid;
     
     
     //访存模块到写回模块之间的数据总线
     wire[31:0] mem_result;//MEM传到WB的result为load结果或ALU结果
     assign mem_result=inst_load?load_result:alu_result;
     
     assign MEM_WB_bus={
            rf_wen,rf_wdest,//WB需要使用的信号
            mem_result,//最终要写回寄存器的数据
            pc
        };
        assign MEM_pc=pc;
endmodule
