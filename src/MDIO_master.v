// Currently working on just reading the PHY status register


module MDIO_master #()(
    input clk,
    input rst_n,
    input init,
    //input [1:0] op,
    //input [4:0] PHY_ad,
    //input [4:0] reg_ad,
    //input [15:0] data,
    input MDIO_i,
    output MDIO_o,
    output MDC
);

reg en = 1;
wire busy;
reg [1:0] op = 2;
reg [4:0] PHY_ad = 1;
reg [4:0] reg_ad = 1;
reg [15:0] data_in = 16'h0000;
wire [15:0] data_out;

MDC_generator MDC_generator #()(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);

MDIO MDIO #()(
    .rst_n(rst_n),
	.en(en),
    .clk(clk),
    .MDC(MDC),
	.MDIO_i(MDIO_i),
    .MDIO_o(MDIO_o),
	.busy(busy),
    .data_out(data_out),
    .op(op),
    .PHY_ad(PHY_ad),
    .reg_ad(reg_ad),
    .data_in(data_in)
);

always @(posedge clk) begin

end

endmodule