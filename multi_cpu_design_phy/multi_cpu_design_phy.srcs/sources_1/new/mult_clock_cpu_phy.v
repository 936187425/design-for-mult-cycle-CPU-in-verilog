`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/26 23:52:32
// Design Name:  PanHengyu from Njust 
// Module Name: mult_clock_cpu_phy
// Project Name: 
// Target Devices: 
// Tool Versions: vivado  2019.01
// Description: 
//  此模块为借鉴MIPS的五段流水线实现的多周期CPU模块。
//五段流水线子模块分别为：取指模块(fetch_instruc_phy.v),译码模块(decode_instruc_phy),执行模块(exe_instruc_phy.v),访存(access_mem_phy.v),写回模块(wb_reg_phy.v)
//物理存储模块:指令存储器(instruc_rom_phy.v),数据存储器(data_ram.v)
//计算部件:算术逻辑模块（alu.v）其中有一个加法器（adder.v）
//实现的CPU：指令长度为32位,寄存器32个，内存为4GB
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mult_clock_cpu_phy(
    input clk,//时钟
    input resetn,//低电平有效,重置信号
    input[4:0] regStack_addr,//寄存器堆标号
    input[31:0] mem_addr,//内存的地址
    
    //output:经过取指，译码，执行，读存，写回后的总线
    output[31:0] regStack_data,//调试端口
    output[31:0] mem_data,
    output rf_wen,//寄存器的写使能端
    output[31:0] IF_pc,
    output[31:0] IF_inst,//指令的机器码
    output[31:0] ID_pc,
    output[31:0] EXE_pc,
    output[31:0] MEM_pc,
    output[31:0] WB_pc,
    output[31:0] display_state//输出为当前处理器的状态
    );
    
    //================================控制状态(利用有限状态机完成)=========================================
    //此时用always的过程块和assign连续赋值语句实现控制CPU指令执行的状态
    
    //状态机的状态
    parameter IDLE   = 3'd0;  // 开始
    parameter FETCH  = 3'd1;  // 取指
    parameter DECODE = 3'd2;  // 译码
    parameter EXE    = 3'd3;  // 执行
    parameter MEM    = 3'd4;  // 访存
    parameter WB     = 3'd5;  // 写回
    
    
    //xx_over信号是由各个模块的output值决定
    wire IF_over;     // IF模块已执行完
    wire ID_over;     // ID模块已执行完
    wire EXE_over;    // EXE模块已执行完
    wire MEM_over;    // MEM模块已执行完
    wire WB_over;     // WB模块已执行完
    wire jbr_not_link;//分支指令(非link类)，只走IF和ID级
    
    
    
    
    //状态寄存器
    reg[2:0] state;//当前状态
    reg[2:0] nextState;//下一个状态
    assign display_state={29'd0,state}; //展示当前处理器正在执行哪个模块
    
    
    
    
    //在上升沿改变当前处理器的状态
    always@(posedge clk)
    begin
            if(!resetn) //如果复位信号有效，那么该CPU就处于复位状态
            begin
                state<=IDLE;//复位启动后，此时CPU处于开始状态
            end
            else 
            begin
               state<=nextState;//处理器就处于下一个状态
            end
    end
    
    
    
    //改变当前处理器的存储单元nextState
    always@(*) //根据always语句中的输入变量自动添加敏感变量此处就是state
    begin
        case(state)
           IDLE:
           begin
             nextState=FETCH;//nextState:开始->取指
           end
           FETCH:
           begin
             if(IF_over)begin //如果取指模块执行完成(即使当处理器的时钟处于上升沿状态但该模块并没有执行完处理器状态也不会发生改变)
                nextState=DECODE; //nextState:取指->译码
             end 
             else begin
                nextState=FETCH; 
             end   
           end
           DECODE: 
            begin
                if (ID_over)
                begin                      // nextState:译码->执行或取指   
                    nextState = jbr_not_link ? FETCH : EXE;
                end
                else
                begin
                    nextState = DECODE;   // nextState:取指->译码
                end
            end
            EXE: 
            begin
                if (EXE_over)
                begin
                    nextState = MEM;      // nextState:执行->访存
                end
                else
                begin
                    nextState = EXE;   // nextState:取指->译码
                end
            end
            MEM:
            begin
                if (MEM_over)
                begin
                    nextState = WB;       // nextState:访存->写回
                end
                else
                begin
                    nextState = MEM;   // nextState:取指->译码
                end
            end
            WB:
            begin
                if (WB_over)
                begin
                    nextState = FETCH;    // nextState:写回->取指
                end
                else
                begin
                    nextState = WB;   // nextState:取指->译码
                end
            end
            default : nextState = IDLE;
       endcase     
    end
    
    //控制5个模块(取指，译码，执行，访存，写回)的有效信号
    //控制5个模块的执行
    wire IF_valid;//xx_valid信号是有state来传递的
    wire ID_valid;
    wire EXE_valid;
    wire MEM_valid;
    wire WB_valid;
    assign  IF_valid = (state == FETCH );  // 当前状态为取指时，IF级有效
    assign  ID_valid = (state == DECODE);  // 当前状态为译码时，ID级有效
    assign EXE_valid = (state == EXE   );  // 当前状态为执行时，EXE级有效
    assign MEM_valid = (state == MEM   );  // 当前状态为访存时，MEM级有效
    assign  WB_valid = (state == WB    );  // 当前状态为写回时，WB级有效
    
    
    
   //=======================================锁存5个模块之间的信号==========================
   wire[63:0] IF2ID_bus;//IF->ID级总线
   wire[149:0] ID2EXE_bus;//ID->EXE级总线
   wire[105:0] EXE2MEM_bus;//EXE->MEM级总线
   wire[69:0] MEM2WB_bus;//MEM->WB级总线
   
   //流水线每个模块之间的锁存器
   reg[63:0] IF2ID_bus_reg;
   reg[149:0]ID2EXE_bus_reg;
   reg[105:0]EXE2MEM_bus_reg;
   reg[69:0]MEM2WB_bus_reg;
   
   //流水线每个模块之间
   //取指模块和译码模块之间的锁存器
   always@(posedge clk)
   begin
     if(IF_over)
     begin
        IF2ID_bus_reg<=IF2ID_bus;
     end
   end
   //译码模块和执行模块之间的锁存器
   always@(posedge clk)
   begin
     if(ID_over)
     begin
        ID2EXE_bus_reg<=ID2EXE_bus;
     end
   end
   //执行模块和访存模块之间的锁存器
   always@(posedge clk)
   begin
     if(EXE_over)
     begin
        EXE2MEM_bus_reg<=EXE2MEM_bus;
     end
   end
   //访存模块与写回模块之间的锁存器
   always@(posedge clk)
   begin
    if(MEM_over)
    begin
        MEM2WB_bus_reg<=MEM2WB_bus;
    end
   end
   
   //======================================其他交互总线===============================
   //每个模块与存储模块之间的交互总线
   //跳转总线
   wire[32:0] jbr_bus;
   
   //取指模块与instruc_rom模块交互
   wire[31:0] instruc_addr;//指令在rom中的地址
   wire[31:0] instruc;//32位指令的机器码
   
   //译码模块与reg_stack模块交互
   wire[4:0] rs;//源操作数1
   wire[4:0] rt;//源操作数2
   wire[31:0] rs_value;//源操作数1值
   wire[31:0] rt_value;//源操作数2值
   
   //访存模块与data_ram模块交互
   wire[3:0] dm_wen;//写内存的使能端
   wire[31:0] dm_addr;//内存的地址
   wire[31:0] dm_wdata;//写内存值
   wire[31:0] dm_rdata;//读内存值
   
   //写回模块与reg_stack模块之间的交互
   wire rd_wen;//寄存器的写使能端
   wire[4:0] rd_wdest;//目的操作数的寄存器编号
   wire[31:0] rd_wdata;//目的操作数的值
   assign rf_wen = rd_wen;
   
   
  //=======================================各个模块之间的实例化元件============
    wire next_fetch;//即将执行取指模块，需要先锁存PC值（决定是否取下一个指令）
    //当前如果处于译码状态且指令为跳转分支指令(非link类)，且decode执行状态完成
    //或者 当前状态为wb,且wb执行完成，即将进入fetch状态
    assign next_fetch =(state==DECODE & ID_over & jbr_not_link)
                        |(state==WB & WB_over);
    
   //实例化取指fetch_instruc_phy模块
    fetch_instruc_phy IF_module(
        .clk (clk),//时钟(input)
        .resetn(resetn),//复位信号(input)
        .IF_valid(IF_valid),//取指模块有效信号(input)
        .next_fetch(next_fetch),//(input)
        .inst(instruc),//从instruc_rom取出的指令(input)
        .inst_addr(instruc_addr),//向instruc_rom发出的地址(output)
        .jbr_bus(jbr_bus),//（input）
        .IF_over(IF_over),//取指模块执行完成信号(output)
        .IF2ID_bus(IF2ID_bus),//（output）
        //展示PC和取出的指令
        .IF_pc(IF_pc),//(output)
        .IF_inst(IF_inst)//(output)
    );
  //译码decoder_code_phy模块
  decoder_code_phy ID_module(
        .ID_valid(ID_valid),//译码级有效信号(input)
        .IF_ID_bus_r(IF2ID_bus_reg),//取指模块和译码模块之间的寄存器(input)
        .rs_value(rs_value),//(input)
        .rt_value(rt_value),//(input)
        .rs(rs),//源操作数在寄存器堆的编号(output)
        .rt(rt),//源操作数在寄存器的编号(output)
        .jbr_bus(jbr_bus),//(output)
        .jbr_not_link(jbr_not_link),//(output)
        .ID_over(ID_over),//译码模块执行完成(output)
        .ID_EXE_bus(ID2EXE_bus),//流向译码模块与执行模块之间的数据总线(output)
        
        //展示PC
        .ID_pc(ID_pc)
  );
  //执行exe_instruc_phy模块
  exe_instruc_phy EXE_module(
       .EXE_valid(EXE_valid),//执行模块有效信号（input）
       .ID_EXE_bus_r(ID2EXE_bus_reg),//译码模块到执行模块的寄存器(input)
       .EXE_over(EXE_over),//执行模块执行结束信号(output)
       .EXE_MEM_bus(EXE2MEM_bus), //执行模块到访存模块的总线(output)
       
       //展示PC
       .EXE_pc(EXE_pc)
  );
  //访存access_mem_phy模块
  access_mem_phy MEM_module(//访存模块
        .clk(clk),//时钟信号(input)
        .MEM_valid(MEM_valid),//访存有效信号(input)
        .EXE_MEM_bus_r(EXE2MEM_bus_reg),//执行模块与访存模块之间的寄存器(input)
        .dm_rdata(dm_rdata),//从data_ram读出的数据(input)
        .dm_addr(dm_addr),//data_ram数据操作的地址(output)
        .dm_wen(dm_wen),//data_ram的写使能端(output)
        .dm_wdata(dm_wdata),//data_ram的写数据(output)
        .MEM_over(MEM_over),//访存结束信号（output）
        .MEM_WB_bus(MEM2WB_bus),//访存模块与写回模块之间的寄存器(output)
        
        //展示PC
        .MEM_pc(MEM_pc)
  );
  //写回wb_reg_phy模块
   wb_reg_phy WB_module(
        .WB_valid(WB_valid),//写回模块的有效信号(input)
        .MEM_WB_bus_r(MEM2WB_bus_reg),//访存模块与写回模块的寄存器(input)
        .rf_wen(rd_wen),//寄存器堆使能端(output)
        .rf_wdest(rd_wdest),//寄存器堆目的寄存器编号(output)
        .rf_wdata(rd_wdata),//寄存器堆写数据(output)
        .WB_over(WB_over),//写回模块完成信号(output)
        //展示pc
        .WB_pc(WB_pc)
   );
   
   //寄存器堆
   reg_stack_phy reg_stack_module(
        .clk(clk),//时钟(input)
        .wen(rd_wen),//目的寄存器的写使能端(intput)
        .raddr1(rs),//源操作数1地址(input)
        .raddr2(rt),//源操作数2地址(input)
        .waddr(rd_wdest),//目的操作数地址(input)
        .wdata(rd_wdata),//目的操作数值(input)
        .rdata1(rs_value),//源操作数1值(output)
        .rdata2(rt_value),//源操作数2值(output)
        
        //展示寄存器
        .test_addr(regStack_addr),
        .test_data(regStack_data)
   );
   
   //存放数据
   data_ram_phy data_ram_module(
       .clka   (clk         ),  // I, 1,  时钟
        .wea    (dm_wen      ),  // I, 1,  写使能
        .addra  (dm_addr[9:2]),  // I, 8,  读地址
        .dina   (dm_wdata    ),  // I, 32, 写数据
        .douta  (dm_rdata    ),  // O, 32, 读数据

        //display mem
        .clkb   (clk          ),
        .web    (4'd0         ),
        .addrb  (mem_addr[9:2]),
        .doutb  (mem_data     ),
        .dinb   (32'd0        )
    
   );
   
   //存放指令只读存储器
   instruc_rom_phy inst_rom_module(
            .clk(clk),//input 时钟
            .addr(instruc_addr),//input指令地址
            .inst(instruc)//output 指令
   );
   
   
endmodule
