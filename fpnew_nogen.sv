// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

module fpnew_nogen (
  input logic                               clk_i,
  input logic                               rst_ni,
  // Input signals
  input logic [2:0][63:0]                   operands_i,
  input fpnew_pkg::roundmode_e              rnd_mode_i,
  input fpnew_pkg::operation_e              op_i,
  input logic                               op_mod_i,
  input fpnew_pkg::fp_format_e              src_fmt_i,
  input fpnew_pkg::fp_format_e              dst_fmt_i,
  input fpnew_pkg::int_format_e             int_fmt_i,
  input logic                               vectorial_op_i,
  input logic                               tag_i,
  // Input Handshake
  input  logic                              in_valid_i,
  output logic                              in_ready_o,
  input  logic                              flush_i,
  // Output signals
  output logic [63:0]                       result_o,
  output fpnew_pkg::status_t                status_o,
  output logic                              tag_o,
  // Output handshake
  output logic                              out_valid_o,
  input  logic                              out_ready_i,
  // Indication of valid data in flight
  output logic                              busy_o
);

localparam fpnew_pkg::fpu_features_t RV64D_Xsflt_nobox = '{
	Width:         64,
	EnableVectors: 1'b1,
	EnableNanBox:  1'b0,
	FpFmtMask:     5'b11111,
	IntFmtMask:    4'b1111
};

localparam fpnew_pkg::fpu_implementation_t PIPELINED = '{
   PipeRegs:   '{1: '{default: 3}, default: '{default: 1}},
   UnitTypes:  '{'{default: fpnew_pkg::PARALLEL}, // ADDMUL
                 '{default: fpnew_pkg::MERGED},   // DIVSQRT
                 '{default: fpnew_pkg::PARALLEL}, // NONCOMP
                 '{default: fpnew_pkg::MERGED}},  // CONV
   PipeConfig: fpnew_pkg::DISTRIBUTED
};

fpnew_top #(
	.Features(RV64D_Xsflt_nobox),
	.Implementation(PIPELINED)
) fpnew (
	.clk_i,
	.rst_ni,
	.operands_i,
	.rnd_mode_i,
	.op_i,
	.op_mod_i,
	.src_fmt_i,
	.dst_fmt_i,
	.int_fmt_i,
	.vectorial_op_i,
	.tag_i,
	.in_valid_i,
	.in_ready_o,
	.flush_i,
	.result_o,
	.status_o,
	.tag_o,
	.out_valid_o,
	.out_ready_i,
	.busy_o
);

endmodule
