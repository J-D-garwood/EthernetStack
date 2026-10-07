// PERSISTENT ERRS
// - frame_error clears on the same cycle the last byte comes out.
// - The end-of-frame edge marker never gets written into the FIFO.

module RGMII_byte_packager #(
    parameter WIDTH = 8,
    parameter fifo_addr_bits = 8

)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output reg [(WIDTH-1):0] data,
    output reg byte_is_edge, //flag that indicates if byte is at the edge of a frame
    output reg frame_error, //flage that indicates if an error has been detected this frame
    output reg byte_valid
);

wire DV; // Data valid
reg DV_Q; // --> delayed by 1 PHY clk cycle
reg DV_Q2; // --> delayed by 2 PHY clk cycle
wire ER; // Error in nibble/byte
reg ER_Q; // --> delayed by 1 PHY clk cycle
reg ER_Q2; // --> delayed by 1 PHY clk cycle


wire RXC_b; // buffered PHY clk

wire full; //FIFO full
wire empty; //FIFO empty
wire r_en; //enable FIFO reads if...
assign r_en = !(empty); // .. FIFO is not empty
wire [3:0] wdata; //nibble written to fifo by RGMII
reg [3:0] wdata_Q; //--> delayed by 1 PHY clk cycle
reg [3:0] wdata_Q2; //--> delayed by 2 PHY clk cycle
wire [5:0] rdata; // read nibble data and metadata (edge of frame or detected err.)
wire nibble_edge; // wire stores whether nibble is edge of frame
assign nibble_edge = (DV_Q2 != DV_Q);
reg nibble_edge_Q; // --> delayed by 1 clk cycle
wire RXC_rst_n; //Reset PHY clk domain 
wire valid; // wire if FIFO read returns valid
reg [5:0] FIFO_package;

reg frame; //reg which indicates whether we are currently in frame

wire [3:0] nibble; // current nibble output from FIFO
assign nibble = rdata[3:0]; // --> assigned to designated rdata bits
reg [3:0] prev_nibble; //stored prev nibble for byte packaging

wire edge_nibble; //wire to indicate if read nibble is at the edge of frame
assign edge_nibble = rdata[5];

wire nibble_error; // wire to indicate if current nibble has an error
assign nibble_error = rdata[4];

reg byte_idx; // reg which stores which byte index we have
reg byte_aligned; // reg to store whether bytes have been aligned using SFD

reg first_byte;
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
    .w_en(DV_Q2),
    .rst_n(rst_n),
    .wdata({(nibble_edge), (ER_Q2), (wdata_Q2)}),
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
        DV_Q <= 1'b0;
        DV_Q2 <= 1'b0;
        wdata_Q <= 4'b0000;
        wdata_Q2 <= 4'b0000;
        ER_Q <= 1'b0;
        ER_Q2 <= 1'b0;
    end else begin
        DV_Q <= DV;
        DV_Q2 <= DV_Q;
        wdata_Q <= wdata;
        wdata_Q2 <= wdata_Q;
        ER_Q <= ER;
        ER_Q2 <= ER_Q;  
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        data <= {WIDTH{1'b0}};
        byte_idx <= 1'b0;
        byte_aligned <= 1'b0;
        byte_valid <= 1'b0;
        byte_is_edge <= 1'b0;
        frame_error <= 1'b0;
        first_byte <= 1'b0;
    end else begin
        if (!byte_aligned && valid) begin
            frame_error <= 1'b0;
            prev_nibble <= nibble;
            byte_valid <= 1'b0;
            if ({nibble, prev_nibble} == 8'hD5) begin
                byte_aligned <= 1'b1;
                byte_idx <= 1'b0;
                first_byte <= 1'b1;
            end
        end else begin
            case (byte_idx) 
                1'b0: begin
                    if (valid) begin
                        prev_nibble <= nibble;
                        byte_idx <= 1'b1;
                    end
                    byte_valid <= 1'b0;
                end
                1'b1: begin
                    if (valid) begin 
                        data <= {nibble, prev_nibble};
                        byte_valid <= 1'b1;
                        byte_idx <= 1'b0;
                        if (first_byte) begin
                            byte_is_edge <= 1'b1;
                            first_byte <= 1'b0;
                        end else byte_is_edge <= edge_nibble;
                    end else byte_valid <= 1'b0;
                end
            endcase
            if (valid) begin 
                byte_aligned <= (edge_nibble) ? 1'b0 : 1'b1;
                frame_error <= frame_error||nibble_error;
            end
        end
    end
end

endmodule
//module RGMII_top #(
//    parameter WIDTH = 8,
//    parameter fifo_addr_bits = 8
//
//)(
//    input clk,
//    input rst_n,
//    input RXC,
//    input [3:0] RXD,
//    input RX_CTL,
//    input frame_error_ack,
//    output reg [(WIDTH-1):0] data,
//    output reg byte_valid,
//    output FE
//);
//
//wire [3:0] wdata;
//reg [3:0] wdata_Q;
//wire DV, ER, RXC_b, full, empty;
//wire r_en;
//wire valid;
//wire [5:0] rdata;
//wire [3:0] nibble;
//assign nibble = rdata[3:0];
//wire first_nibble_r;
//assign first_nibble_r = rdata[4];
//wire RXC_rst_n;
//
//reg [3:0] stored_nibble;
//reg byte_half;
//reg aligned;
//reg in_frame;
//reg frame_error;
//reg FE_reg;
//reg first_nibble_w;
//assign FE = FE_reg;
//
//
//assign r_en = !empty;
//
//RGMII_receiver R (
//    .RXC(RXC),
//    .RXD(RXD),
//    .RX_CTL(RX_CTL),
//    .data_out(wdata),
//    .DV(DV),
//    .ER(ER),
//    .RXC_b(RXC_b)
//);
//
//FIFO #(6, fifo_addr_bits) receiver_fifo(
//    .rclk(clk), 
//    .wclk(RXC_b), 
//    .r_en(r_en), 
//    .w_en(in_frame),
//    .rst_n(rst_n),
//    .wdata({frame_error, first_nibble_w, wdata_Q}),
//    .rdata(rdata),
//    .full(full),
//    .empty(empty),
//    .valid(valid)
//);
//
//synchroniser #(1) sync_rst_RXC(
//    .clk(RXC_b),
//	.rst_n(rst_n),
//	.async_in(1'b1),
//	.sync_out(RXC_rst_n)
//);
//
//always @(posedge RXC_b) begin
//    if (!RXC_rst_n) begin
//        in_frame <= 1'b0;
//        wdata_Q <= 4'b0000;
//        first_nibble_w <= 1'b0;
//        frame_error <= 1'b0;
//    end else begin
//        first_nibble_w <= (DV==1&&in_frame==0);
//        in_frame <= DV;
//        wdata_Q <= wdata;
//        frame_error <= (ER||(full && in_frame));
//    end
//end
//
//always @(posedge clk) begin
//    if (!rst_n) begin
//        data <= {WIDTH{1'b0}};
//        byte_valid <= 1'b0;
//        byte_half <= 1'b0;
//        aligned <= 1'b0;
//        FE_reg <= 1'b0;
//        stored_nibble <= 4'b0000;
//    end else begin
//        if (!FE) begin
//            if (valid && first_nibble_r) begin
//                byte_valid <= 1'b0;
//                byte_half <= 1'b0;
//                aligned <= 1'b0;
//            end else if (!aligned) begin
//                if (valid) stored_nibble <= nibble;
//                if (valid && {nibble, stored_nibble} == 8'hD5) begin
//                    aligned <= 1'b1;
//                    byte_half <= 1'b0;
//                end
//            end else begin
//                case (byte_half)
//                    1'b0: begin
//                        if (valid) begin
//                            stored_nibble <= nibble;
//                            byte_half <= 1'b1;
//                        end
//                        byte_valid <= 1'b0;
//                    end
//                    1'b1: begin
//                        if (valid) begin 
//                            data <= {nibble, stored_nibble};
//                            byte_valid <= 1'b1;
//                            byte_half <= 1'b0;
//                        end else byte_valid <= 1'b0;
//                    end
//                endcase
//            end 
//        end else begin
//            byte_valid <= 1'b0;
//            byte_half <= 1'b0;
//            aligned <= 1'b0;
//        end
//        FE_reg <= ((valid && rdata[5])||FE) ? ((frame_error_ack && first_nibble_r && valid && !rdata[5]) ? 1'b0 : 1'b1) : 1'b0;
//    end
//end
//endmodule