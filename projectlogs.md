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
- Reviewed RGMII interface, MDIO sub interface, and UART
- Built out PHY_init.v module w. 20ms reset and assert length (10ms specified on PHY datasheet, 20ms selected for margin of safety). 

## 27/08/2026
- Drafted **MDC generator**
- Started work on the **MDIO master**. Two wires, MDC and MDIO. 
- Important Figures from PHY datasheet:
![alt text](misc%20resources%20and%20images/PHY_register_table.png)

## 30/08/2026
- Tested MDC generator w. MDC_tb.v
- Added makefile for quick testing using verilator

## 31/08/2026
- Wrote preliminary MDIO.v + MDIO_tb for it
- Tested using questa sim

## 02/09/2026
- Started work on allowing MAC to read the PHY status register
- (This one - BMSR: page 0x00, register 0x01 - See PHY datasheet)

## 03/09/2026
- (Dated)--> Determined to keep enable logic in MDIO_master as opposed to MDIO to prevent me from having to redesign MDIO in future iterations
- ^ Changed my mind on this as this would ultimately just be putting a wrapper around a tristate buffer
- Moved over to FSM structure for clarity --> was using counter for too many things

## 04/09/2026