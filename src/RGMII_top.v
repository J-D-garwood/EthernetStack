module RGMII_top#(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output [7:0] bytes
);

wire [3:0] nibble;
wire DV;
wire ER;
wire RXC_b;

RGMII_receiver R (
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data_out(nibble),
    .DV(DV),
    .ER(ER),
    .RXC_b(RXC_b)
);


endmodule