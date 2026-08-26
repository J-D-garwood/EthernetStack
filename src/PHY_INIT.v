module PHY_INIT #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter RESET_MS = 20
)(
    input clk,
    input rst_n,
    output reg PHY_rst_n,
    output reg init_complete
);

reg [31:0] counter;

always @(posedge clk) begin
    if (!rst_n) begin
        counter <= 32'h0000_0000;
        PHY_rst_n <= 1'b0;
        init_complete <= 1'b0;
    end else begin
        if (counter < ((CLK_HZ/1000)*RESET_MS)) begin
            counter <= counter + 1'b1;
        end else if (counter < (2*(CLK_HZ/1000)*RESET_MS)) begin
            counter <= counter + 1'b1; 
            PHY_rst_n <= 1'b1;
        end else begin
            init_complete <= 1'b1;
        end
    end
end
endmodule
 