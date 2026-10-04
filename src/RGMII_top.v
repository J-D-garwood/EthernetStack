module RGMII_top #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter WIDTH = 4,
    parameter fifo_addr_bits = 4

)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output [(WIDTH-1):0] data,
    output valid
);

wire [(WIDTH-1):0] wdata, rdata;
wire DV, ER, RXC_b, full, empty;
wire r_en;
assign r_en = !empty;

assign data = rdata;

RGMII_receiver R (
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data_out(wdata),
    .DV(DV),
    .ER(ER),
    .RXC_b(RXC_b)
);

FIFO #(WIDTH, fifo_addr_bits) receiver_fifo(
    .rclk(clk), 
    .wclk(RXC_b), 
    .r_en(r_en), 
    .w_en((DV && !ER)),
    .rst_n(rst_n),
    .wdata(wdata),
    .rdata(rdata),
    .full(full),
    .empty(empty),
    .valid(valid)
);

endmodule