// 2nd iteration
// retained ideas like the shift registers but decided to shift to a
// more explicit FSM format 
module MDIO #()(
	input enable,
    input rst_n,
    input clk,
    input MDC,
	input [31:0] transmitting,
	inout MDIO,
	output reg [15:0] received
);

reg MDC_d;

reg en = 0;
wire transmit;
wire receive;
reg [7:0] counter;
reg [63:0] ins;
reg read;

assign transmit = ins[63];

tristate tristate(
	.drive(en),
	.transmit(transmit),
	.receive(receive),
	.pin(MDIO)
);

always @(posedge clk) begin
	if (!rst_n) begin
		received <= 16'hFFFF;
		counter <= 0;
		read <= 1;
	end else begin
		MDC_d <= MDC;
		if ((MDC_d == 1'b1) && (MDC == 1'b0)) begin
			if (enable) begin
				if (counter == 0) begin
					en <= 1;
					ins <= {32'hFFFF_FFFF, transmitting};
				end
				if (read && (counter <= 46) && (counter > 0)) begin
					ins <= {ins[62:0], 1'b1};
				end
				if (read && (counter>46 && counter <= 64)) begin
					en <= 0;
					received <= {received[14:0], receive};
				end
				if (counter == 64) begin
					counter <= 0
				end else begin
					counter <= counter + 1;
				end
			end
		end
	end
end

endmodule