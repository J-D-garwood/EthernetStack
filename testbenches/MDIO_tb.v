`timescale 1ns/1ps;

module MDIO_tb;

reg clk = 0;
reg rst_n = 0;
wire MDC;

reg [1:0] op = 2'b10;
reg [4:0] PHY_ad = 5'b00001;
reg [4:0] reg_ad = 5'b00001;
reg [15:0] data = 16'b001100110011100110;
wire MDIO;

always #20 clk = ~clk;

MDC #() MDC_gen(
    .clk(clk),
    .rst_n(rst_n),
    .MDC(MDC)
);

MDIO #() dut (
    .rst_n(rst_n),
    .clk(clk),
    .MDC(MDC),
    .MDIO(MDIO),
    .op(op),
    .PHY_ad(PHY_ad),
    .reg_ad(reg_ad),
    .data(data)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, MDIO_tb);
    #100 rst_n = 1;
    #100000;
    $finish;
end

endmodule