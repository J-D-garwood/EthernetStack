
module MDIO #()(
	input init,
    input rst_n,
    input clk,
    input MDC,
	input [31:0] transmitting,
	inout MDIO,
	(* MARK_DEBUG = "TRUE" *) output reg done,
	output reg busy,
	(* MARK_DEBUG = "TRUE" *) output reg [15:0] received //probed
);
//
reg MDC_d;
//
reg en;
(* MARK_DEBUG = "TRUE" *) wire transmit;
(* MARK_DEBUG = "TRUE" *) wire receive_async;
(* MARK_DEBUG = "TRUE" *) wire receive;


reg [7:0] counter;

reg read;

reg [63:0] ins;
assign transmit = ins[63];
reg [15:0] buffer; 

//STATES 
(* MARK_DEBUG = "TRUE" *) reg [5:0] state;

localparam IDLE = 0;
localparam PREAMBLE = 1;
localparam HEADER = 2;
localparam TURNAROUND = 3;
localparam DATA = 4;
localparam DONE = 5;


tristate tristate(
	.drive(en),
	.transmit(transmit),
	.receive(receive_async),
	.pin(MDIO)
);

synchroniser receive_sync(
	.clk(clk),
	.rst_n(rst_n),
	.async_in(receive_async),
	.sync_out(receive)
);

always @(posedge clk) begin
	if (!rst_n) begin
		state <= 1 << IDLE;
		received <= 16'hFFFF;
		buffer <= 16'hFFFF;
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
						read <= transmitting[29];
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
						if (read) begin en <= 0; end
						state <= 1 << TURNAROUND;
						counter <=0;
					end else begin
						counter <= counter + 1;
					end
				end 
				(1 << TURNAROUND): begin 
					if (!read) begin ins <= {ins[62:0], 1'b1}; end
					if (counter == 0) begin // Turnaround time is now 1 clk cycle
						state <= 1 << DATA;
						counter <= 0;
					end else begin
						counter <= counter + 1;
					end
				end
				(1 << DATA): begin
					if (read) begin buffer <= {buffer[14:0], receive}; end
					else begin ins <= {ins[62:0], 1'b1}; end
					if (counter == 15) begin
						state <= 1 << DONE;
						counter <= 0;
						done <= 1'b1;
						busy <= 1'b0;
						if (read) begin received <= {buffer[14:0], receive}; end
					end else begin
						counter <= counter + 1;
					end
				end 
				(1 << DONE): begin 
					done <= 0;
					counter <= 0;
					state <= 1 << IDLE;
					en <= 0;
				end
				default: state <= 1 << IDLE;
			endcase
		end
	end
end
endmodule