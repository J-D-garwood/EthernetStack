module MDIO_master #()(
    input rst_n,
    input clk,
    output reg MDIO,
    output MDC
);

MDC_generator MDC_generator #()(
    .clk(clk),
    .MDC(MDC)
);

always @(posedge MDC) begin
    if (!rst_n) begin
        MDIO <= 1'b1;
    end else begin
    end
end
endmodule