## Bank-0 / configuration voltage ----------------------------------------
set_property CFGBVS VCCO             [current_design]
set_property CONFIG_VOLTAGE 3.3      [current_design]
## Boot from the on-board QSPI flash in x4 mode at 50 MHz -----------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4  [current_design]
set_property CONFIG_MODE SPIx4                [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50   [current_design]

create_clock -period 5.000 [get_ports sys_clk_p]
set_property PACKAGE_PIN R4          [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15  [get_ports sys_clk_p]
set_property PACKAGE_PIN T4         [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

set_property PACKAGE_PIN N13 [get_ports MDC]
set_property IOSTANDARD LVCMOS33 [get_ports MDC]
set_property PACKAGE_PIN P14 [get_ports MDIO]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO]
set_property PACKAGE_PIN R14 [get_ports PHY_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports PHY_rst_n]
set_property PACKAGE_PIN F15         [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]