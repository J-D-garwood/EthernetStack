// Generated using Claude

`timescale 1ns / 1ps

// Testbench for MDIO master: tests reads and writes against a behavioural PHY.
//
// PHY model behaviour (IEEE 802.3 Clause 22):
//   - Samples MDIO on MDC rising edges.
//   - Waits for >= 32 preamble ones, then ST = 01.
//   - Captures OP (2), PHYAD (5), REGAD (5).
//   - Read:  TA1 = Z (master releases), PHY drives TA2 = 0, then 16 data bits.
//            PHY changes its output shortly after each MDC rising edge.
//   - Write: checks TA = 10, captures 16 data bits, stores them in phy_regs.

module MDIO_tb;

    // ---------------- Parameters ----------------
    localparam CLK_PERIOD = 10;        // 100 MHz system clock
    localparam MDC_DIV    = 20;        // MDC toggles every 20 clk -> 2.5 MHz
    localparam PHY_ADDR   = 5'd1;
    localparam PHY_HOLD   = 10;        // ns after MDC rise before PHY changes output

    localparam [1:0] OP_READ  = 2'b10;
    localparam [1:0] OP_WRITE = 2'b01;

    // ---------------- DUT signals ----------------
    reg         clk = 0;
    reg         rst_n = 0;
    reg         MDC = 0;
    reg         init = 0;
    reg  [31:0] transmitting = 32'hFFFF_FFFF;
    wire        MDIO;
    wire        done;
    wire        busy;
    wire [15:0] received;

    // Bus pull-up and PHY driver
    pullup (MDIO);
    reg phy_oe  = 0;
    reg phy_out = 1;
    assign MDIO = phy_oe ? phy_out : 1'bz;

    MDIO dut (
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

    // ---------------- Clocks ----------------
    always #(CLK_PERIOD/2) clk = ~clk;

    integer mdc_cnt = 0;
    always @(posedge clk) begin
        if (mdc_cnt == MDC_DIV - 1) begin
            mdc_cnt <= 0;
            MDC     <= ~MDC;
        end else begin
            mdc_cnt <= mdc_cnt + 1;
        end
    end

    // ---------------- PHY model ----------------
    reg [15:0] phy_regs [0:31];

    localparam P_PRE   = 0;
    localparam P_ST    = 1;
    localparam P_HDR   = 2;
    localparam P_RTA1  = 3;
    localparam P_RTA2  = 4;
    localparam P_RDATA = 5;
    localparam P_REND  = 6;
    localparam P_WTA   = 7;
    localparam P_WDATA = 8;

    integer    p_state = P_PRE;
    integer    ones    = 0;
    integer    bitcnt  = 0;
    reg [11:0] hdr;
    reg [1:0]  p_op;
    reg [4:0]  p_phy;
    reg [4:0]  p_reg;
    reg [1:0]  p_ta;
    reg [15:0] p_data;
    reg [15:0] rd_word;

    integer errors = 0;

    always @(posedge MDC) begin
        case (p_state)
            P_PRE: begin
                if (MDIO === 1'b1) begin
                    if (ones < 63) ones = ones + 1;
                end else if (MDIO === 1'b0 && ones >= 32) begin
                    p_state = P_ST;            // first ST bit (0)
                end else begin
                    ones = 0;
                end
            end

            P_ST: begin
                if (MDIO === 1'b1) begin       // second ST bit (1)
                    p_state = P_HDR;
                    bitcnt  = 0;
                end else begin
                    $display("[%0t] PHY: bad ST bit", $time);
                    errors  = errors + 1;
                    ones    = 0;
                    p_state = P_PRE;
                end
            end

            P_HDR: begin
                hdr    = {hdr[10:0], MDIO};
                bitcnt = bitcnt + 1;
                if (bitcnt == 12) begin
                    p_op  = hdr[11:10];
                    p_phy = hdr[9:5];
                    p_reg = hdr[4:0];
                    if (p_phy != PHY_ADDR) begin
                        ones    = 0;
                        p_state = P_PRE;       // not addressed to us, ignore
                    end else if (p_op == OP_READ) begin
                        p_state = P_RTA1;
                    end else if (p_op == OP_WRITE) begin
                        p_state = P_WTA;
                        bitcnt  = 0;
                    end else begin
                        $display("[%0t] PHY: bad OP %b", $time, p_op);
                        errors  = errors + 1;
                        ones    = 0;
                        p_state = P_PRE;
                    end
                end
            end

            // ---- Read path ----
            P_RTA1: begin
                // TA1 sample point. Master must not be driving here.
                if (dut.en !== 1'b0) begin
                    $display("[%0t] PHY: master still driving during read TA1", $time);
                    errors = errors + 1;
                end
                rd_word = phy_regs[p_reg];
                phy_oe  <= #PHY_HOLD 1'b1;
                phy_out <= #PHY_HOLD 1'b0;     // drive TA2 = 0
                p_state = P_RTA2;
            end

            P_RTA2: begin
                phy_out <= #PHY_HOLD rd_word[15];
                bitcnt  = 14;
                p_state = P_RDATA;
            end

            P_RDATA: begin
                phy_out <= #PHY_HOLD rd_word[bitcnt];
                if (bitcnt == 0) p_state = P_REND;
                else bitcnt = bitcnt - 1;
            end

            P_REND: begin
                phy_oe  <= #PHY_HOLD 1'b0;     // release bus
                phy_out <= #PHY_HOLD 1'b1;
                ones    = 0;
                p_state = P_PRE;
            end

            // ---- Write path ----
            P_WTA: begin
                p_ta   = {p_ta[0], MDIO};
                bitcnt = bitcnt + 1;
                if (bitcnt == 2) begin
                    if (p_ta !== 2'b10) begin
                        $display("[%0t] PHY: bad write TA %b (expected 10)", $time, p_ta);
                        errors = errors + 1;
                    end
                    bitcnt  = 0;
                    p_state = P_WDATA;
                end
            end

            P_WDATA: begin
                p_data = {p_data[14:0], MDIO};
                bitcnt = bitcnt + 1;
                if (bitcnt == 16) begin
                    phy_regs[p_reg] = p_data;
                    ones    = 0;
                    p_state = P_PRE;
                end
            end
        endcase
    end

    // ---------------- Frame builder ----------------
    function [31:0] frame(input [1:0] op, input [4:0] phy, input [4:0] regad, input [15:0] data);
        frame = {2'b01, op, phy, regad, (op == OP_WRITE) ? 2'b10 : 2'b11, data};
    endfunction

    // ---------------- Transaction tasks ----------------
    // Start a transaction and wait for it to finish.
    task run_txn(input [31:0] word);
        begin
            @(posedge clk);
            transmitting = word;
            init = 1;
            @(posedge busy);
            init = 0;
            @(posedge done);
        end
    endtask

    task mdio_read(input [4:0] regad, input [15:0] expected);
        begin
            run_txn(frame(OP_READ, PHY_ADDR, regad, 16'h0000));
            // received must be valid while done is high
            #1;
            if (received !== expected) begin
                $display("FAIL read  reg %0d: got %h, expected %h", regad, received, expected);
                errors = errors + 1;
            end else begin
                $display("PASS read  reg %0d: %h", regad, received);
            end
            @(negedge done);
        end
    endtask

    task mdio_write(input [4:0] regad, input [15:0] value);
        begin
            run_txn(frame(OP_WRITE, PHY_ADDR, regad, value));
            @(negedge done);
            #1;
            // Bus must be released after a write
            if (dut.en !== 1'b0) begin
                $display("FAIL write reg %0d: master still driving after frame", regad);
                errors = errors + 1;
            end
            if (phy_regs[regad] !== value) begin
                $display("FAIL write reg %0d: PHY got %h, expected %h", regad, phy_regs[regad], value);
                errors = errors + 1;
            end else begin
                $display("PASS write reg %0d: %h", regad, value);
            end
        end
    endtask

    // ---------------- Test sequence ----------------
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) phy_regs[i] = 16'h0000;
        phy_regs[2]  = 16'h1234;
        phy_regs[3]  = 16'h8001;   // MSB and LSB set, catches off-by-one shifts

        repeat (10) @(posedge clk);
        rst_n = 1;
        repeat (10) @(posedge clk);

        // Reads of preset values
        mdio_read(5'd2, 16'h1234);
        mdio_read(5'd3, 16'h8001);

        // Write then read back
        mdio_write(5'd16, 16'hA5A5);
        mdio_read (5'd16, 16'hA5A5);

        mdio_write(5'd16, 16'h8001);
        mdio_read (5'd16, 16'h8001);

        mdio_write(5'd17, 16'h5A5A);
        mdio_read (5'd17, 16'h5A5A);

        // Earlier register must be untouched
        mdio_read (5'd16, 16'h8001);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d ERROR(S)", errors);
        $finish;
    end

    // Timeout
    initial begin
        #5_000_000;
        $display("TIMEOUT");
        $finish;
    end

endmodule