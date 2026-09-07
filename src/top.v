// CLOCK IS CURRENTLY 200 MHz
// NEED TO FLOW CLK THROUGH A PLL
// TO OUTPUT 25 MHz

module top (
    input  sys_clk_p,
    input  sys_clk_n,
    input  rst_n,
    inout MDIO,
    output MDC,
    output PHY_rst_n,
    output PHY_init_complete
);
    wire clk;
    wire locked;
    wire rst_internal;
    assign rst_internal = (rst_n && locked); // reset finished and clock confirmed at 25 MHz

// Differential clk to single wire - WILL BE REMOVED AFTER PLL ADDED
//    IBUFDS #(.IOSTANDARD("DIFF_SSTL15")) u_clk_buf (
//        .I (sys_clk_p), .IB (sys_clk_n), .O (clk)
//    );

      clk_wiz_0 instance_name
       (
        // Clock out ports
        .clk_out1(clk),     // output clk_out1
        // Status and control signals
        .resetn(rst_n), // input resetn
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1_p(sys_clk_p),    // input clk_in1_p
        .clk_in1_n(sys_clk_n)    // input clk_in1_n
    );

// PHY INIT SHOULD ALWAY PRECEDE MDIO HANDSHAKE!! --> Fix this next time
    PHY_INIT #() phy_init(
        .clk(clk),
        .rst_n(rst_internal),
        .PHY_INIT_n(PHY_rst_n),
        .init_complete(PHY_init_complete)
    );

    MDIO_master #() MDIO_master(
        .clk(clk),
        .rst_n(rst_internal),
        .MDIO(MDIO),
        .MDC(MDC)
    );

endmodule