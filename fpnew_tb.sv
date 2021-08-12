`timescale 1ns/1ps
// SPDX-License-Identifier: MIT
// SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

import fpnew_pkg::*;

module fpnew_tb;

logic clk_i = 0,
		rst_ni = 1,
		op_mod_i = '0,
		vectorial_op_i = '0,
		tag_i = '0,
		in_valid_i = '0,
		in_ready_o,
		flush_i = '0,
		tag_o,
		out_valid_o,
		out_ready_i = '0,
		busy_o;

fpnew_pkg::roundmode_e rnd_mode_i;
fpnew_pkg::operation_e op_i;
fpnew_pkg::fp_format_e src_fmt_i, dst_fmt_i;
fpnew_pkg::int_format_e int_fmt_i;

logic [2:0][63:0] operands_i;
logic      [63:0] result_o;

fpnew_pkg::status_t status_o;

localparam fpu_features_t RV64D_Xsflt_nobox = '{
	Width:         64,
	EnableVectors: 1'b1,
	EnableNanBox:  1'b0,
	FpFmtMask:     5'b11111,
	IntFmtMask:    4'b1111
};

localparam fpu_implementation_t PIPELINED = '{
   PipeRegs:   '{1: '{default: 3}, default: '{default: 1}},
   UnitTypes:  '{'{default: PARALLEL}, // ADDMUL
                 '{default: MERGED},   // DIVSQRT
                 '{default: PARALLEL}, // NONCOMP
                 '{default: MERGED}},  // CONV
   PipeConfig: DISTRIBUTED
};

fpnew_top #(
	.Features(RV64D_Xsflt_nobox),
	.Implementation(PIPELINED)
) dut (
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

always #4 clk_i = ~clk_i;

logic [31:0] float32_out;
logic [63:0] result_reg, float64_out, int64_out;
logic [3:0][15:0] vec_reg;

assign float32_out = result_o[31:0];
assign float64_out = result_o;
assign int64_out = result_o;

initial begin
	#8;
	rst_ni = 0;
	#16;
	rst_ni = 1;
	#8;
/*	
	operands_i[0] = 103;
	op_i = I2F;
	op_mod_i = 0;
	int_fmt_i = INT32;
	dst_fmt_i = FP16;
	rnd_mode_i = RTZ;
	in_valid_i = 1;
	#8;
	vec_reg = {4{result_o[15:0]}};
	
	operands_i[0] = 145;
	#8;
	operands_i[0] = {4{result_o[15:0]}};
	operands_i[1] = vec_reg;
	
	vectorial_op_i = 1;
	op_i = MUL;
	src_fmt_i = FP16;
	
	#8;
	deassign vec_reg;
	vec_reg = result_o;
	
	operands_i[1] = {64{0}};
	operands_i[2] = vec_reg[0];
	op_i = ADD; // SUB
	op_mod_i = 1;
	
	#1;
	
	operands_i[0] = result_o[15:0];
	op_i = F2F;
	op_mod_i = 0;
	dst_fmt_i = FP64;
	
	#8;
	operands_i[0] = vec_reg[1];
	
	#8;
	
	@(posedge clk_i);
	*/
	
	@(posedge clk_i);
	operands_i[0] = 'hd640;
	op_i = F2I;
	op_mod_i = 0;
	rnd_mode_i = RNE;
	src_fmt_i = FP16;
	dst_fmt_i = FP16;
	int_fmt_i = INT32;
	in_valid_i = 1;
	@(posedge clk_i);
	in_valid_i = 0;
	@(posedge out_valid_o);
	result_reg = result_o;
	out_ready_i = 1;
	@(negedge busy_o);
	out_ready_i = 0;
	@(posedge clk_i);

    @(negedge clk_i);
    operands_i[1] = 32'h3f800000;
    operands_i[2] = 32'h3f800000;
    op_i = ADD;
    op_mod_i = 0;
    src_fmt_i = FP32;
    dst_fmt_i = FP32;
    rnd_mode_i = RNE;
    in_valid_i = 1;
    @(negedge clk_i);
    in_valid_i = 0;
    if (out_valid_o != 1)
        @(posedge out_valid_o);
    out_ready_i = 1;
    result_reg = result_o;
    @(posedge clk_i);
    @(posedge clk_i);
    out_ready_i = 0;
    assert (result_reg == 'h4000000000)
        else $warning("Incorrect result %x", result_reg);
    
    @(posedge clk_i);

    @(negedge clk_i);
    operands_i[1] = 32'h40000000;
    operands_i[2] = 32'h40400000;
    op_i = ADD;
    op_mod_i = 0;
    src_fmt_i = FP32;
    dst_fmt_i = FP32;
    rnd_mode_i = RNE;
    in_valid_i = 1;
    @(negedge clk_i);
    in_valid_i = 0;
    if (out_valid_o != 1)
        @(posedge out_valid_o);
    out_ready_i = 1;
    result_reg = result_o;
    @(posedge clk_i);
    @(posedge clk_i);
    out_ready_i = 0;
    assert (result_reg == 'h40a00000)
        else $warning("Incorrect result %x", result_reg);
    
    @(posedge clk_i);
    
	
	// (-10.0) + (-20.0) FP16
	operands_i[1] = {1, 5'b10010, 10'b0100000000};
	operands_i[2] = {1, 5'b10011, 10'b0100000000};
	op_i = ADD;
	op_mod_i = 0;
	src_fmt_i = FP16;
	dst_fmt_i = FP16;
	rnd_mode_i = RTZ;
	in_valid_i = 1;
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	in_valid_i = 0;
	#3;
	result_reg = result_o;
	out_ready_i = 1;
	#64;
	out_ready_i = 0;
	@(posedge clk_i);
	#56;
	@(posedge clk_i);
	operands_i[1] = {0, 5'b10010, 10'b0100000000};
	operands_i[2] = {0, 5'b10011, 10'b0100000000};
	in_valid_i = 1;
	@(posedge clk_i);
	in_valid_i = 0;
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	out_ready_i = 1;
	@(posedge clk_i);
	out_ready_i = 0;
	#4;
	
	operands_i[0] = result_reg[15:0];
	dst_fmt_i = FP32;
	op_mod_i = 0;
	op_i = F2F;
	
	in_valid_i = 1;
	
	@(posedge clk_i);
	in_valid_i = 0;
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	out_ready_i = 1;
	@(posedge clk_i);
	out_ready_i = 0;
	
	#4;
	
	int_fmt_i = INT64;
	op_i = F2I;
	in_valid_i = 1;
	
	@(posedge clk_i);
	in_valid_i = 0;
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	out_ready_i = 1;
	@(posedge clk_i);
	out_ready_i = 0;
	@(posedge clk_i);
	@(posedge clk_i);
	
	operands_i[0] = 'hCF80;
	op_i = F2F;
	src_fmt_i = FP16;
	dst_fmt_i = FP64;
	in_valid_i = 1;
	@(posedge clk_i);
	in_valid_i = 0;
	@(posedge out_valid_o);
	out_ready_i = 1;
	@(posedge clk_i);
	@(posedge clk_i);
	@(posedge clk_i);
	out_ready_i = 0;
	
	
	$stop;
end

endmodule
