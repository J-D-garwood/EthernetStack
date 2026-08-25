## 16/08/2026
Deciding key params for implementation (implemented on a AX7A035B Development board w. xc7a35tfgg484-2)
- **FPGA board**: XC7A35T
- **PHY**: JL2121-N040I Ethernet PHY chip
- **PHY MDIO address**: 1
- **Board clk freq**: 200MHz

## 18/08/2026
Continued to review key params required....
- **RGMII pin names**: See below img
- **MDIO pins**: See below img
- **PHY reset pin**: See below img
![RGMII pin assignments](misc%20resources%20and%20images/RGMII_pins.png)
- **MAC address - selected for the board**: 2E.FC.32.BA.7C.99
- **Host MAC address**: 4C:56:DF:3C:A3:51
- **IP address**: To be chosen at bring-up, not assigned by anything. The board and my laptop will be the only two devices on a direct cable, so I pick a private subnet, give the laptop's Ethernet adapter a manual address on it, and give the board a different host address on the same subnet.
- **Toolchain**: Vivado (Questa for simulation)

## 20/08/2026
Read PHY schematic pgs 0-15

## 24/08/2026
Skimmed PHY schematic pgs 15-60

## 25/08/2026
Adding basic PHY resetting logic
PHY_reset.v 

## 26/08/2026

