module MDC #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter MDC_HZ = 2500000

)(
    input rst_n,
    input clk,
    output reg MDC
);

reg [3:0] counter;

always @(negedge clk) begin
    if (!rst_n) begin
        MDC <= 1'b0;
        counter <= 0;
    end else begin
        if (counter == ((CLK_HZ/(2*MDC_HZ))-1)) begin
            MDC <= !MDC;
            counter <= 0;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end
endmodule
