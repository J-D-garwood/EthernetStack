module r_ptr_handler #(
    parameter addr_bits = 4 //16 mem addresses
)(
    input r_en, rclk, r_rst_n,
    input [(addr_bits):0] g_wptr_sync,
    output [(addr_bits-1):0] b_rptr,
    output reg [(addr_bits):0] g_rptr,
    output reg empty
);

reg [(addr_bits):0] internal_rptr;
wire [(addr_bits):0] internal_wptr;

wire [(addr_bits):0] R_next;

assign R_next = (r_en && !empty) ? internal_rptr + 1 : internal_rptr;

assign b_rptr = internal_rptr[(addr_bits-1):0];

gray_to_binary #(addr_bits+1) GtoB(
    .gray(g_wptr_sync),
    .binary(internal_wptr)
);

always @(posedge rclk) begin
    if (!r_rst_n) begin
        internal_rptr <= 0;
        empty <= 1;
        g_rptr <= 0;
    end else begin
        internal_rptr <= R_next;
        empty <= (internal_wptr == R_next); 
        g_rptr[addr_bits] <= internal_rptr[addr_bits];
        g_rptr[(addr_bits-1):0] <= internal_rptr[addr_bits:1]^internal_rptr[(addr_bits-1):0];
    end
end
endmodule