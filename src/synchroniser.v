// Synchroniser written during ButtonDebounce project - see github

module synchroniser #(parameter SIZE = 1) (
	input clk,
	input rst_n,
	input [SIZE-1:0] async_in,
	(* ASYNC_REG = "TRUE" *) output reg [SIZE-1:0] sync_out
);
	(* ASYNC_REG = "TRUE" *) reg [SIZE-1:0] Ds;

always @(posedge clk) begin
	if (!rst_n) begin
		Ds <= 1'b0;
		sync_out<= 1'b0;
	end else begin
		{sync_out, Ds} <= {Ds, async_in};
	end
end
endmodule