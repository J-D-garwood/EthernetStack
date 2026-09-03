// Currently working on just reading the PHY status register every x s and outputting that to UART


module MDIO_master #()(
    input clk,
    input rst_n,
    inout MDIO,
    output MDC
);

MDC #() mdc(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);

MDIO #() mdio(

);

always @(posedge clk) begin
    if !(rst_n) begin
        MDC <= 1'b0;
    end else begin
    end
end

endmodule