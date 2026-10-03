module RGMII_receiver(
    input RXC,
    input [3:0] RXD,
    input RX_CTL,
    output [3:0] data_out,
    output DV,
    output ER,
    output RXC_b
);
wire RXC_neg;
assign ER =  DV ^ RXC_neg;

wire [3:0] nibble_pos;
wire [3:0] nibble_neg;

assign data_out = nibble_pos;
   // BUFG: Global Clock Simple Buffer
   //       Artix-7
   // Xilinx HDL Language Template, version 2025.2
  // Taken from Vivado Language Templates for Artix-7
   BUFG BUFG_inst (
      .O(RXC_b), // 1-bit output: Clock output
      .I(RXC)  // 1-bit input: Clock input
   );

// Template taken from Vivado Tools → Language Templates → Verilog → Device Primitive Instantiation → Artix-7 → I/O Components → DDR Registers → IDDR
   IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_RX_CTL (
      .Q1(DV), // 1-bit output for positive edge of clock
      .Q2(RXC_neg), // 1-bit output for negative edge of clock
      .C(RXC_b),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(RX_CTL),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

genvar i;
generate 
    for (i = 0; i<4; i = i + 1) begin: gen_bits
        IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
        ) IDDR_RXD(
      .Q1(nibble_pos[i]), // 1-bit output for positive edge of clock
      .Q2(nibble_neg[i]), // 1-bit output for negative edge of clock
      .C(RXC_b),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(RXD[i]),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
        );
    end
endgenerate

endmodule