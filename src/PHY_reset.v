module PHY_RESET(
    //
    input clk,
    input rst_n,
    output reg PHY_rst_n
);

localparam CLK_HZ = 25000000;
localparam RESET_S = 0.01;

reg [31:0] counter;

always @(posedge clk) begin
    if (!rst_n) begin
        counter <= 32'h0000_0000;
        PHY_rst_n <= 1'b0;
    end else begin
        if (counter < (RESET_S*CLK_HZ)) begin
            counter <= counter + 1'b1;
        end else begin 
            PHY_rst_n <= 1'b1;
        end
    end
end
endmodule
