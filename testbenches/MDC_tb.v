`timescale 1ns/1ps

module MDC_tb;

reg clk = 0;
reg rst_n = 0;
wire MDC;

always #20 clk = ~clk;

MDC #() dut(
    .clk(clk),
    .rst_n(rst_n),
    .MDC(MDC)
);

initial begin
    $dumpfile("dump.fst");
    $dumpvars(0, MDC_tb);
    #100 rst_n = 1;
    #10000
    $finish;
end

endmodule 