onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib data_ram_phy_opt

do {wave.do}

view wave
view structure
view signals

do {data_ram_phy.udo}

run -all

quit -force
