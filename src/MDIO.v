// 2nd iteration
module MDIO #()(
	input init,
    input rst_n,
    input clk,
    input MDC,
	input [31:0] transmitting,
	inout MDIO,
	output done
	output reg [15:0] received
);
//
reg MDC_d;
//
reg en = 0;
wire transmit;
wire receive;

reg [7:0] counter;

reg [63:0] ins;
assign transmit = ins[63];
//reg read;

//STATES 
reg [5:0] state;

localparam IDLE = 0;
localparam PREAMBLE = 1;
localparam HEADER = 2;
localparam TURNAROUND = 3;
localparam DATA = 4;
localparam DONE = 5;


tristate tristate(
	.drive(en),
	.transmit(transmit),
	.receive(receive),
	.pin(MDIO)
);
//
always @(posedge clk) begin
	if (!rst_n) begin
		state <= 1 << IDLE;
//		received <= 16'hFFFF;
		counter <= 0;
//		read <= 1;
	end else begin
		MDC_d <= MDC;
		// USE case (state) as opposed to chain of ifs
		//counter needs to be reset
		if ((MDC_d == 1'b1) && (MDC == 1'b0)) begin
			if (init && state == (1 << IDLE)) begin
				state <= 1 << PREAMBLE;
				en <= 1;
			end
			if (state == (1 << PREAMBLE)) begin
				ins <= 64'hFFFF_FFFF_FFFF_FFFF;
				if (counter<32) begin
					counter <= counter + 1;
				end
			end
		end
	end
end
endmodule