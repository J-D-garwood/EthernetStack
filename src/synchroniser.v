// Synchroniser written during ButtonDebounce project - see github

module synchroniser (
	input clk,
	input rst_n,
	input async_in,
	(* ASYNC_REG = "TRUE" *) output reg sync_out
);
	(* ASYNC_REG = "TRUE" *) reg Ds;

always @(posedge clk) begin
	if (!rst_n) begin
		Ds <= 1'b0;
		sync_out<= 1'b0;
	end else begin
		Ds <= async_in;
		sync_out <= Ds;
	end
end
endmodule