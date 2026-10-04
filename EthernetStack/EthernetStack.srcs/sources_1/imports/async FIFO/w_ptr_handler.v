module w_ptr_handler #(
    parameter addr_bits = 4 //16 mem addresses
)(
    input w_en, wclk, w_rst_n,
    input [(addr_bits):0] g_rptr_sync,
    output [(addr_bits-1):0] b_wptr,
    output reg [(addr_bits):0] g_wptr,
    output reg full
);

reg [(addr_bits):0] internal_wptr;
wire [(addr_bits):0] internal_rptr;

wire [(addr_bits):0] W_next;

assign W_next = (w_en && !full) ? internal_wptr + 1 : internal_wptr;

assign b_wptr = internal_wptr[(addr_bits-1):0];

gray_to_binary #(addr_bits+1) GtoB(
    .gray(g_rptr_sync),
    .binary(internal_rptr)
);

always @(posedge wclk) begin
    if (!w_rst_n) begin
        internal_wptr <= 0;
        full <= 0;
        g_wptr <= 0;
    end else begin
        internal_wptr <= W_next;
        full <= (W_next == internal_rptr + {1'b1, {(addr_bits){1'b0}}});
        g_wptr[addr_bits] <= internal_wptr[addr_bits];
        g_wptr[(addr_bits-1):0] <= internal_wptr[addr_bits:1]^internal_wptr[(addr_bits-1):0];
    end
end

endmodule