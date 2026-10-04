module w_ptr_handler #(
    parameter addr_bits = 4 //16 mem addresses
)(
    input w_en, wclk, w_rst_n,
    input [(addr_bits):0] g_rptr_sync,
    output [(addr_bits-1):0] b_wptr,
    output [(addr_bits):0] g_wptr,
    output full
);

reg [(addr_bits):0] internal_wptr;
wire [(addr_bits):0] internal_rptr;

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
        b_wptr <= 0;
    end else begin
        // Logic to determine whether to increment the write pointer and whether to
        // output full...
        g_wptr[addr_bits] <= internal_wptr[addr_bits];
        g_wptr[(addr_bits-1):0] <= internal_wptr[addr_bits:1]^internal_wptr[(addr_bits-1):0];
    end
end

endmodule