// 3rd iteration - Only reads at the moment
// NEXT STEP FIGURE OUT WHERE SYNCHRONISATION COMES INTO PLAY...
module MDIO #()(
	input init,
    input rst_n,
    input clk,
    input MDC,
	input [31:0] transmitting,
	inout MDIO,
	output reg done,
	output reg busy,
	output reg [15:0] received
);
//
reg MDC_d;
//
reg en;
wire transmit;
wire receive;

reg [7:0] counter;

reg [63:0] ins;
assign transmit = ins[63];

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
		received <= 16'hFFFF;
		counter <= 0;
 		done <= 0;
		busy <= 0;
		MDC_d <= 0;
		ins <= 64'hFFFF_FFFF_FFFF_FFFF;
		en <= 0;
	end else begin
		MDC_d <= MDC;
		// USE case (state) as opposed to chain of ifs
		//counter needs to be reset
		if ((MDC_d == 1'b1) && (MDC == 1'b0)) begin
			//if (init && state == (1 << IDLE)) begin
			//	state <= 1 << PREAMBLE;
			//	en <= 1;
			//end
			case (state)
				(1 << IDLE): begin
					if (init) begin
						state <= 1 << PREAMBLE;
						busy <= 1;
						en <= 1;
						ins <= {32'hFFFF_FFFF, transmitting};
					end
				end
				(1 << PREAMBLE): begin
					ins <= {ins[62:0], 1'b1};
					if (counter == 31) begin
						counter <= 0;
						state <= 1 << HEADER;
					end else begin
						counter <= counter + 1;
					end
				end
				(1 << HEADER): begin
					ins <= {ins[62:0], 1'b1};
					if (counter == 13) begin
						en <= 0;
						state <= 1 << TURNAROUND;
						counter <=0;
					end else begin
						counter <= counter + 1;
					end
				end 
				(1 << TURNAROUND): begin
					if (counter == 1) begin
						state <= 1 << DATA;
						counter <= 0;
					end else begin
						counter <= counter + 1;
					end
				end
				(1 << DATA): begin
					received <= {received[14:0], receive};
					if (counter == 15) begin
						state <= 1 << DONE;
						counter <= 0;
						done <= 1'b1;
						busy <= 1'b0;
					end else begin
						counter <= counter + 1;
					end
				end 
				(1 << DONE): begin 
					done <= 0;
					counter <= 0;
					state <= 1 << IDLE;
				end
				default: state <= 1 << IDLE;
			endcase
		end
	end
end
endmodule