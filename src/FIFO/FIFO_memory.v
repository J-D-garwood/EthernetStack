// Code modelled after the following FIFOs 
// --> https://github.com/ujjwal-2001/Async_FIFO_Design/blob/main/Verilog_Code/FIFO.v
// --> https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/

module FIFO_memory #(
    parameter width = 4,
    parameter addr_bits = 4 //16 mem addresses
) (
    input [(width-1):0] wdata,
    input w_en, wclk,
    input full,
    input [(addr_bits-1):0] b_wptr,
    input [(addr_bits-1):0] b_rptr,
    output [(width-1):0] rdata
);

reg [width-1:0] memory [0:(2**addr_bits)-1];

assign rdata = memory[b_rptr];

always @(posedge wclk) begin
    if (w_en && !full) memory[b_wptr] <= wdata;
end

endmodule

