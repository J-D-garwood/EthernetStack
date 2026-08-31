module MDIO #()(
    input rst_n,
	input en,
    input clk,
    input MDC,
    output MDIO,
	output busy,
    input [1:0] op,
    input [4:0] PHY_ad,
    input [4:0] reg_ad,
    input [15:0] data
);

reg MDC_d;
reg [63:0] ins; 
reg [7:0] counter;
reg shift;
assign MDIO = ins[63];
assign busy = shift;

always @(posedge clk) begin
	if (!rst_n) begin
		MDC_d <= 1'b0;
		ins <= {~(32'b0), 2'b01, op, PHY_ad, reg_ad, 2'b10, data};
		counter <= 0;
		shift <= 1'b0;
	end else begin 
		MDC_d <= MDC;
		if ((MDC_d == 1'b1) && (MDC == 1'b0)) begin
			if (shift) begin
				ins <= {ins[62:0], 1'b1};
				counter <= counter + 1'b1;
			end else begin
				if (en) begin
					ins <= {~(32'b0), 2'b01, op, PHY_ad, reg_ad, 2'b10, data};
				end else begin
					ins <= ~(64'b0);
				end
				shift <= 1'b1;
			end
			if (counter == 63) begin
				shift <= 1'b0;
				counter <= 0;
			end
		end
	end
end
    
endmodule