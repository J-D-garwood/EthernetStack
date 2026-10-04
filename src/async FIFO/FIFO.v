// HDL modelled after the following FIFOs 
// --> https://github.com/ujjwal-2001/Async_FIFO_Design/blob/main/Verilog_Code/FIFO.v
// --> https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/

module FIFO #(
    parameter width = 4,
    parameter addr_bits = 4 //16 mem addresses
)(
    input rclk, wclk, r_en, w_en,
    input rst_n,
    input [(width-1):0] wdata,
    output [(width-1):0] rdata,
    output full, empty,
    output valid
);

wire [addr_bits:0] g_rptr_sync, g_wptr_sync, g_wptr, g_rptr;
wire [(addr_bits-1):0] b_wptr, b_rptr;
wire w_rst_n, r_rst_n;

synchroniser #(addr_bits+1) sync_R(
    .clk(rclk),
	.rst_n(r_rst_n),
	.async_in(g_wptr),
	.sync_out(g_wptr_sync)
);

synchroniser #(addr_bits+1) sync_W(
    .clk(wclk),
	.rst_n(w_rst_n),
	.async_in(g_rptr),
	.sync_out(g_rptr_sync)
);

FIFO_memory #(width,addr_bits) mem (
    .wdata(wdata),
    .w_en(w_en), 
    .wclk(wclk),
    .r_en(r_en), 
    .rclk(rclk),
    .r_rst_n(r_rst_n),
    .full(full),
    .empty(empty),
    .b_wptr(b_wptr),
    .b_rptr(b_rptr),
    .rdata(rdata),
    .valid(valid)
);

w_ptr_handler #(addr_bits) W_handler (
    .w_en(w_en),
    .wclk(wclk), 
    .w_rst_n(w_rst_n),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr),
    .g_wptr(g_wptr),
    .full(full)
);

r_ptr_handler #(addr_bits) R_handler (
    .r_en(r_en),
    .rclk(rclk), 
    .r_rst_n(r_rst_n),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr),
    .g_rptr(g_rptr),
    .empty(empty)
);

// RESET SYNCHRONISERS

synchroniser #(1) sync_rst_PHY(
    .clk(wclk),
	.rst_n(rst_n),
	.async_in(1'b1),
	.sync_out(w_rst_n)
);

synchroniser #(1) sync_rst_MAC(
    .clk(rclk),
	.rst_n(rst_n),
	.async_in(1'b1),
	.sync_out(r_rst_n)
);

endmodule