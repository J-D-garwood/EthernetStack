module MDIO_master #()(
    input clk,
    input rst_n,
    input init,
    input [1:0] op,
    input [4:0] PHY_ad,
    input [4:0] reg_ad,
    input [15:0] data,
    output MDIO,
    output MDC
);


MDC_generator MDC_generator #()(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);



always @(posedge clk) begin
end

endmodule