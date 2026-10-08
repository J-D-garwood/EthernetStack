
// parses the received bytes from the rgmii - outputs if frame if good or bad
//Uses CRC
// Will add additional feature to output the type of frame detected

module RGMII_frame_parser #(
    parameter WIDTH = 8,
)(
    input clk,
    input rst_n,
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output good_frame,
    //output frame_type - add this later
);

wire [(WIDTH-1):0] data;
wire byte_is_edge; //flag that indicates if byte is at the edge of a frame
wire frame_error; //flag that indicates if an error has been detected this frame
wire byte_valid;

reg [63:0] 
reg [31:0] register
wire feedback;
assign feedback = register[0];

RGMII_byte_packager #(WIDTH, 8) byte_packager(
    .clk(clk),
    .rst_n(rst_n),
    .RXC(RXC),
    .RXD(RXD),
    .RX_CTL(RX_CTL),
    .data(data),
    .byte_is_edge(byte_is_edge), 
    .frame_error(frame_error), 
    .byte_valid(byte_valid)
);

always @(posedge clk) begin
    if (!rst_n) begin 
        register <= 32'hFFFF_FFFF;
    end else begin
        if (byte_valid) begin
        end
    end
end

endmodule