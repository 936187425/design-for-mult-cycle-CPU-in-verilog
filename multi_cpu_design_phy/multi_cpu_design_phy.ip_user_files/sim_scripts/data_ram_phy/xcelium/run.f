-makelib xcelium_lib/xil_defaultlib -sv \
  "E:/vivaoinstall/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "E:/vivaoinstall/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_3 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../multi_cpu_design_phy.srcs/sources_1/ip/data_ram_phy/sim/data_ram_phy.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

