
module MDIO_master #(
    parameter CLK_HZ = 25000000, // Default reset, assert of 20ms
    parameter MDC_HZ = 2500000
)(
    input clk,
    input rst_n,
    inout MDIO,
    output MDC
);

reg init;
reg [31:0] transmitting;
reg [31:0] read_1;
wire done;
wire busy;
wire [15:0] received;

reg [31:0] counter; 

MDC #() mdc(
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC)
);

reg [2:0] state;

localparam  transmission_1 = 0;
localparam  transmission_2 = 1;

MDIO #() mdio(
	.init(init),
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC),
	.transmitting(transmitting),
	.MDIO(MDIO),
	.done(done),
	.busy(busy),
	.received(received)
);

always @(posedge clk) begin
    if (!rst_n) begin
        init <= 1'b0;
        transmitting <= {2'b01, 2'b01, 5'b00001, 5'b00000, 2'b10, 16'b0010000100000000};
        read_1 <= {2'b01, 2'b10, 5'b00001, 5'b00000, 2'b00, 16'hFFFF};
        counter <= 0;
        state <= transmission_1;
    end else begin
        if (counter==CLK_HZ-1) begin
            init <= 1;
            counter <= 0;
        end else begin
            case (state)
            transmission_1: begin
                if (done) begin 
                    state <= transmission_2;
                    transmitting <= read_1; 
                end
            end
            //transmission_2: begin
            //    
            //end
            endcase
            counter <= counter + 1;
        end
        if (busy && init) begin
            init <= 0;
        end
    end
end

endmodule