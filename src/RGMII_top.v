module RGMII_top #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter WIDTH = 8,
    parameter fifo_addr_bits = 4

)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output reg [(WIDTH-1):0] data,
    output reg byte_valid
);

wire [3:0] wdata;
wire DV, ER, RXC_b, full, empty;
wire r_en;
wire valid;
wire [4:0] rdata;
wire [3:0] nibble;
assign nibble = rdata[3:0];
wire transmission;
assign transmission = rdata[4];
wire RXC_rst_n;

reg [3:0] stored_nibble;
reg byte_half;
reg DV_prev;
reg aligned;
reg in_frame;

assign r_en = !empty;

RGMII_receiver R (
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data_out(wdata),
    .DV(DV),
    .ER(ER),
    .RXC_b(RXC_b)
);

FIFO #(5, fifo_addr_bits) receiver_fifo(
    .rclk(clk), 
    .wclk(RXC_b), 
    .r_en(r_en), 
    .w_en((DV && !ER)),
    .rst_n(rst_n),
    .wdata({in_frame, wdata}),
    .rdata(rdata),
    .full(full),
    .empty(empty),
    .valid(valid)
);

synchroniser #(1) sync_rst_RXC(
    .clk(RXC_b),
	.rst_n(rst_n),
	.async_in(1'b1),
	.sync_out(RXC_rst_n)
);

always @(posedge RXC_b) begin
    if (!RXC_rst_n) begin
        DV_prev <= 1'b0;
        in_frame <= 1'b0;
    end else begin
        in_frame <= DV;
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        data <= {WIDTH{1'b0}};
        byte_valid <= 1'b0;
        byte_half <= 1'b0;
        aligned <= 1'b0;
    end else begin
        if (transmission) begin
            if (!aligned) begin
                if (valid) stored_nibble <= nibble;
                if (valid && {nibble, stored_nibble} == 8'hD5) begin
                    aligned <= 1'b1;
                    byte_half <= 1'b0;
                end
            end else begin
                case (byte_half)
                    1'b0: begin
                        if (valid) begin
                            stored_nibble <= nibble;
                            byte_half <= 1'b1;
                        end
                        byte_valid <= 1'b0;
                    end
                    1'b1: begin
                        if (valid) begin 
                            data <= {nibble, stored_nibble};
                            byte_valid <= 1'b1;
                            byte_half <= 1'b0;
                        end else byte_valid <= 1'b0;
                    end
                endcase
            end
        end else begin
            aligned <= 1'b0;
        end
    end
end
endmodule