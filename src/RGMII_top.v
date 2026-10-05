module RGMII_top #(
    parameter WIDTH = 8,
    parameter fifo_addr_bits = 8

)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    input frame_error_ack,
    output reg [(WIDTH-1):0] data,
    output reg byte_valid,
    output FE
);

wire [3:0] wdata;
reg [3:0] wdata_Q;
wire DV, ER, RXC_b, full, empty;
wire r_en;
wire valid;
wire [5:0] rdata;
wire [3:0] nibble;
assign nibble = rdata[3:0];
wire first_nibble_r;
assign first_nibble_r = rdata[4];
wire RXC_rst_n;

reg [3:0] stored_nibble;
reg byte_half;
reg aligned;
reg in_frame;
reg frame_error;
reg FE_reg;
reg first_nibble_w;
assign FE = FE_reg;


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

FIFO #(6, fifo_addr_bits) receiver_fifo(
    .rclk(clk), 
    .wclk(RXC_b), 
    .r_en(r_en), 
    .w_en(in_frame),
    .rst_n(rst_n),
    .wdata({frame_error, first_nibble_w, wdata_Q}),
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
        in_frame <= 1'b0;
        wdata_Q <= 4'b0000;
        first_nibble_w <= 1'b0;
        frame_error <= 1'b0;
    end else begin
        first_nibble_w <= (DV==1&&in_frame==0);
        in_frame <= DV;
        wdata_Q <= wdata;
        frame_error <= (ER||(full && in_frame));
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        data <= {WIDTH{1'b0}};
        byte_valid <= 1'b0;
        byte_half <= 1'b0;
        aligned <= 1'b0;
        FE_reg <= 1'b0;
        stored_nibble <= 4'b0000;
    end else begin
        if (!FE) begin
            if (valid && first_nibble_r) begin
                byte_valid <= 1'b0;
                byte_half <= 1'b0;
                aligned <= 1'b0;
            end else if (!aligned) begin
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
            byte_valid <= 1'b0;
            byte_half <= 1'b0;
            aligned <= 1'b0;
        end
        FE_reg <= ((valid && rdata[5])||FE) ? ((frame_error_ack && first_nibble_r && valid && !rdata[5]) ? 1'b0 : 1'b1) : 1'b0;
    end
end
endmodule