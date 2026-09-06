// CLOCK IS CURRENTLY 200 MHz
// NEED TO FLOW CLK THROUGH A PLL
// TO OUTPUT 25 MHz

module top (
    input  sys_clk_p,
    input  sys_clk_n,
    input  rst_n,
    inout MDIO
    output MDC,
    output PHY_rst_n,
    output PHY_init_complete;
);
    wire clk;

// Differential clk to single wire - WILL BE REMOVED AFTER PLL ADDED
    IBUFDS #(.IOSTANDARD("DIFF_SSTL15")) u_clk_buf (
        .I (sys_clk_p), .IB (sys_clk_n), .O (clk)
    );

    PHY_INIT #() phy_init(
        .clk(clk),
        .rst_n(rst_n),
        .PHY_INIT_n(PHY_rst_n),
        .init_complete(PHY_init_complete)
    );

    MDIO_master #() MDIO_master(
        .clk(clk),
        .rst_n(rst_n),
        .MDIO(MDIO),
        .MDC(MDC)
    );

endmodule