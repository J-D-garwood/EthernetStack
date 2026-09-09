// Currently working on just reading the PHY status register every 1 s and outputting that to UART
// Add synchronous release of rst NEXT!!

module MDIO_master #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter MDC_HZ = 2500000
)(
    input clk,
    input rst_n,
    inout MDIO,
    output MDC
);

reg init;
reg [31:0] transmitting;
wire done;
wire busy;
wire [15:0] received;

reg [31:0] counter; 

MDC #() mdc(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);

MDIO #() mdio(
	.init(init),
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC),
	.transmitting(transmitting),
	.MDIO(MDIO),
	.done(done),
	.busy(busy),
	.received(received)
);

always @(posedge clk) begin
    if (!rst_n) begin
        init <= 1'b0;
        transmitting <= {2'b01, 2'b10, 5'b00001, 5'b00001, 2'b00, 16'hFFFF};
        counter <= 0;
    end else begin
        if (counter==CLK_HZ-1) begin
            init <= 1;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
        if (busy && init) begin
            init <= 0;
        end
    end
end

endmodule