module frame_receiver #(
    parameter WIDTH = 8
)(
    input clk,
    input rst_n,
    input frame_error,
    input [(WIDTH-1):0] data,
    input byte_valid,
    output reg frame_error_ack
);

reg [31:0] remainder // Remainder for CRC check

always @ (posedge clk) begin
    if (!rst_n) begin
        frame_error_ack <= 1'b0;
        remainder <= 32'hFFFF_FFFF;
    end else begin
        frame_error_ack <= (frame_error) ? 1'b1 : 1'b0;
    end
end
endmodule