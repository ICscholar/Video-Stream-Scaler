/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2018 Efinix Inc. All rights reserved.
//
// Dual Clock FIFO
//
//********************************
// Revisions:
// 0.0 Initial rev
// 0.1 Added read/write count, almost full, almost empty signal
//********************************

module dual_clock_fifo_wrapper
#(
	parameter	DATA_WIDTH		= 8,
	parameter	ADDR_WIDTH		= 8,
	parameter	LATENCY			= 1,
	parameter	FIFO_MODE		= "STD_FIFO",
	parameter	RAM_INIT_FILE	= "",
	/////////////////////////////////////////////////////////////////////////////////////
	// compatibility	output_reg			check_full_overflow		check_empty_underflow
	/////////////////////////////////////////////////////////////////////////////////////
	// E				user configurable	user configurable		user configurable
	// X				user configurable	always on				always on
	// A				always off			user configurable		user configurable
	parameter	COMPATIBILITY	= "E",
	parameter	OUTPUT_REG		= "TRUE",
	parameter	CHECK_FULL		= "TRUE",
	parameter	CHECK_EMPTY		= "TRUE",
	parameter	AFULL_THRESHOLD	= 2**ADDR_WIDTH-1,
	parameter	AEMPTY_THRESHOLD= 1,
	parameter	AFULL_OFFSET	= 2,
	parameter	AEMPTY_OFFSET	= 2
)
(
	input						i_arst,
	
	input						i_wclk,
	input						i_we,
	input	[DATA_WIDTH-1:0]	i_wdata,
	
	input						i_rclk,
	input						i_re,
//	input						i_restore,
	
	output						o_full,
	output						o_empty,
	output	[DATA_WIDTH-1:0]	o_rdata,
	
	output						o_afull,
	output	[ADDR_WIDTH-1:0]	o_wcnt,
	output						o_aempty,
	output	[ADDR_WIDTH-1:0]	o_rcnt,
	
	output						o_dbg_w_re,
	
	output	[ADDR_WIDTH:0]		o_dbg_w_waddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_w_waddrg_1P,
	output	[ADDR_WIDTH:0]		o_dbg_r_waddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_waddrg_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_waddrg_2P,
	output						o_dbg_r_wflag_1P,
	
	output	[ADDR_WIDTH:0]		o_dbg_w_raddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_w_raddrg_1P,
	output	[ADDR_WIDTH:0]		o_dbg_r_raddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_raddrg_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_raddrg_2P,
	output						o_dbg_r_rflag_1P,
	output						o_dbg_r_rflag_2P
);

generate
	if (COMPATIBILITY == "X")
	begin
		if (FIFO_MODE == "BYPASS")
		begin
			dual_clock_fifo
			#(
				.DATA_WIDTH			(DATA_WIDTH),
				.ADDR_WIDTH			(ADDR_WIDTH),
				.LATENCY			(LATENCY+4),
				.FIFO_MODE			(FIFO_MODE),
				.RAM_INIT_FILE		(RAM_INIT_FILE),
				.COMPATIBILITY		(COMPATIBILITY),
				.OUTPUT_REG			("FALSE"),
				.CHECK_FULL			("TRUE"),
				.CHECK_EMPTY		("TRUE"),
				.AFULL_THRESHOLD	(AFULL_THRESHOLD),
				.AEMPTY_THRESHOLD	(AEMPTY_THRESHOLD),
				.AFULL_OFFSET		(AFULL_OFFSET),
				.AEMPTY_OFFSET		(AEMPTY_OFFSET)
			)
			inst_dual_clock_fifo
			(
				.i_arst		(i_arst),
				.i_wclk		(i_wclk),
				.i_we		(i_we),
				.i_wdata	(i_wdata),
				.i_rclk		(i_rclk),
				.i_re		(i_re),
//				.i_restore	(i_restore),
				.o_full		(o_full),
				.o_empty	(o_empty),
				.o_rdata	(o_rdata),
				
				.o_afull	(o_afull),
				.o_wcnt		(o_wcnt),
				.o_aempty	(o_aempty),
				.o_rcnt		(o_rcnt)
			);
		end
		else
		begin
			dual_clock_fifo
			#(
				.DATA_WIDTH			(DATA_WIDTH),
				.ADDR_WIDTH			(ADDR_WIDTH),
				.LATENCY			(LATENCY+2),
				.FIFO_MODE			(FIFO_MODE),
				.RAM_INIT_FILE		(RAM_INIT_FILE),
				.COMPATIBILITY		(COMPATIBILITY),
				.OUTPUT_REG			(OUTPUT_REG),
				.CHECK_FULL			("TRUE"),
				.CHECK_EMPTY		("TRUE"),
				.AFULL_THRESHOLD	(AFULL_THRESHOLD),
				.AEMPTY_THRESHOLD	(AEMPTY_THRESHOLD),
				.AFULL_OFFSET		(AFULL_OFFSET),
				.AEMPTY_OFFSET		(AEMPTY_OFFSET)
			)
			inst_dual_clock_fifo
			(
				.i_arst		(i_arst),
				.i_wclk		(i_wclk),
				.i_we		(i_we),
				.i_wdata	(i_wdata),
				.i_rclk		(i_rclk),
				.i_re		(i_re),
//				.i_restore	(i_restore),
				.o_full		(o_full),
				.o_empty	(o_empty),
				.o_rdata	(o_rdata),
				
				.o_afull	(o_afull),
				.o_wcnt		(o_wcnt),
				.o_aempty	(o_aempty),
				.o_rcnt		(o_rcnt)
			);
		end
	end
	else if (COMPATIBILITY == "A")
	begin
		dual_clock_fifo
		#(
			.DATA_WIDTH			(DATA_WIDTH),
			.ADDR_WIDTH			(ADDR_WIDTH),
			.LATENCY			(LATENCY),
			.FIFO_MODE			(FIFO_MODE),
			.RAM_INIT_FILE		(RAM_INIT_FILE),
			.COMPATIBILITY		(COMPATIBILITY),
			.OUTPUT_REG			("FALSE"),
			.CHECK_FULL			(CHECK_FULL),
			.CHECK_EMPTY		(CHECK_EMPTY),
			.AFULL_THRESHOLD	(AFULL_THRESHOLD),
			.AEMPTY_THRESHOLD	(AEMPTY_THRESHOLD),
			.AFULL_OFFSET		(AFULL_OFFSET),
			.AEMPTY_OFFSET		(AEMPTY_OFFSET)
		)
		inst_dual_clock_fifo
		(
			.i_arst		(i_arst),
			.i_wclk		(i_wclk),
			.i_we		(i_we),
			.i_wdata	(i_wdata),
			.i_rclk		(i_rclk),
			.i_re		(i_re),
//			.i_restore	(i_restore),
			.o_full		(o_full),
			.o_empty	(o_empty),
			.o_rdata	(o_rdata),
			
			.o_afull	(o_afull),
			.o_wcnt		(o_wcnt),
			.o_aempty	(o_aempty),
			.o_rcnt		(o_rcnt)
		);
	end
	else
	begin
		dual_clock_fifo
		#(
			.DATA_WIDTH			(DATA_WIDTH),
			.ADDR_WIDTH			(ADDR_WIDTH),
			.LATENCY			(LATENCY),
			.FIFO_MODE			(FIFO_MODE),
			.RAM_INIT_FILE		(RAM_INIT_FILE),
			.COMPATIBILITY		(COMPATIBILITY),
			.OUTPUT_REG			(OUTPUT_REG),
			.CHECK_FULL			(CHECK_FULL),
			.CHECK_EMPTY		(CHECK_EMPTY),
			.AFULL_THRESHOLD	(AFULL_THRESHOLD),
			.AEMPTY_THRESHOLD	(AEMPTY_THRESHOLD),
			.AFULL_OFFSET		(AFULL_OFFSET),
			.AEMPTY_OFFSET		(AEMPTY_OFFSET)
		)
		inst_dual_clock_fifo
		(
			.i_arst		(i_arst),
			.i_wclk		(i_wclk),
			.i_we		(i_we),
			.i_wdata	(i_wdata),
			.i_rclk		(i_rclk),
			.i_re		(i_re),
//			.i_restore	(i_restore),
			.o_full		(o_full),
			.o_empty	(o_empty),
			.o_rdata	(o_rdata),
			
			.o_afull	(o_afull),
			.o_wcnt		(o_wcnt),
			.o_aempty	(o_aempty),
			.o_rcnt		(o_rcnt),
			
			.o_dbg_w_re			(o_dbg_w_re),
			
			.o_dbg_w_waddrb_1P	(o_dbg_w_waddrb_1P),
			.o_dbg_w_waddrg_1P	(o_dbg_w_waddrg_1P),
			.o_dbg_r_waddrb_1P	(o_dbg_r_waddrb_1P),
			.o_dbg_r_waddrg_1P	(o_dbg_r_waddrg_1P),
			.o_dbg_r_waddrg_2P	(o_dbg_r_waddrg_2P),
			.o_dbg_r_wflag_1P	(o_dbg_r_wflag_1P),
			
			.o_dbg_w_raddrb_1P	(o_dbg_w_raddrb_1P),
			.o_dbg_w_raddrg_1P	(o_dbg_w_raddrg_1P),
			.o_dbg_r_raddrb_1P	(o_dbg_r_raddrb_1P),
			.o_dbg_r_raddrg_1P	(o_dbg_r_raddrg_1P),
			.o_dbg_r_raddrg_2P	(o_dbg_r_raddrg_2P),
			.o_dbg_r_rflag_1P	(o_dbg_r_rflag_1P),
			.o_dbg_r_rflag_2P	(o_dbg_r_rflag_2P)
		);
	end
endgenerate

endmodule

module dual_clock_fifo
#(
	parameter	DATA_WIDTH		= 8,
	parameter	ADDR_WIDTH		= 8,
	parameter	LATENCY			= 1,
	parameter	FIFO_MODE		= "STD_FIFO",
	parameter	RAM_INIT_FILE	= "",
	parameter	COMPATIBILITY	= "E",
	parameter	OUTPUT_REG		= "FALSE",
	parameter	CHECK_FULL		= "TRUE",
	parameter	CHECK_EMPTY		= "TRUE",
	parameter	AFULL_THRESHOLD	= 2**ADDR_WIDTH-1,
	parameter	AEMPTY_THRESHOLD= 1,
	parameter	AFULL_OFFSET	= 2,
	parameter	AEMPTY_OFFSET	= 2
)
(
	input						i_arst,
	
	input						i_wclk,
	input						i_we,
	input	[DATA_WIDTH-1:0]	i_wdata,
	
	input						i_rclk,
	input						i_re,
//	input						i_restore,
	
	output						o_full,
	output						o_empty,
	output	[DATA_WIDTH-1:0]	o_rdata,
	
	output						o_afull,
	output	[ADDR_WIDTH-1:0]	o_wcnt,
	output						o_aempty,
	output	[ADDR_WIDTH-1:0]	o_rcnt,
	
	output						o_dbg_w_re,
	
	output	[ADDR_WIDTH:0]		o_dbg_w_waddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_w_waddrg_1P,
	output	[ADDR_WIDTH:0]		o_dbg_r_waddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_waddrg_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_waddrg_2P,
	output						o_dbg_r_wflag_1P,
	
	output	[ADDR_WIDTH:0]		o_dbg_w_raddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_w_raddrg_1P,
	output	[ADDR_WIDTH:0]		o_dbg_r_raddrb_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_raddrg_1P,
	output	[ADDR_WIDTH-1:0]	o_dbg_r_raddrg_2P,
	output						o_dbg_r_rflag_1P,
	output						o_dbg_r_rflag_2P
);

(* async_reg = "true" *)reg		[ADDR_WIDTH:0]	r_waddrb_1P;
(* async_reg = "true" *)reg						r_wflag_1P;
(* async_reg = "true" *)reg		[ADDR_WIDTH-1:0]r_waddrg_1P;
(* async_reg = "true" *)reg		[ADDR_WIDTH-1:0]r_waddrg_2P;

reg		[ADDR_WIDTH:0]r_raddrb_wclk_1P;
reg		[ADDR_WIDTH:0]r_raddrb_wclk_neg;
reg		[ADDR_WIDTH:0]wr_cnt;

reg		[ADDR_WIDTH:0]r_waddrb_rclk_1P;
reg		[ADDR_WIDTH:0]r_waddrb_rclk_neg;
reg		[ADDR_WIDTH:0]rd_cnt;

reg						r_we_1P;
reg						r_re_1P;
(* async_reg = "true" *)reg		[ADDR_WIDTH:0]	r_raddrb_1P;
(* async_reg = "true" *)reg						r_rflag_1P;
(* async_reg = "true" *)reg		[ADDR_WIDTH-1:0]r_raddrg_1P;
(* async_reg = "true" *)reg						r_rflag_2P;
(* async_reg = "true" *)reg		[ADDR_WIDTH-1:0]r_raddrg_2P;

reg		[LATENCY-1:0]	r_empty;
reg		[LATENCY:0]		r_full;

//reg		r_restore_1P;
reg		[ADDR_WIDTH:0]	r_raddrb_2P;
reg		[ADDR_WIDTH-1:0]r_raddrg_PP;
reg		[ADDR_WIDTH:0]	r_raddrb_3P;
reg		[ADDR_WIDTH-1:0]r_raddrg_3P;

wire	[ADDR_WIDTH:0]	w_waddrb_1P;
wire					w_wflag_1P;
wire	[ADDR_WIDTH-1:0]w_waddrg_1P;

wire	[ADDR_WIDTH:0]	w_raddrb_1P;
wire					w_rflag_1P;
wire	[ADDR_WIDTH-1:0]w_raddrg_1P;

wire	w_empty;
wire	w_full;

wire	w_empty_P;
wire	w_full_P;

wire					w_we;
wire					w_re;
wire	[ADDR_WIDTH-1:0]w_raddr;

assign	w_waddrb_1P					=	r_waddrb_1P + 1'b1;
assign	w_wflag_1P					=	w_waddrb_1P[ADDR_WIDTH];
assign	w_waddrg_1P[ADDR_WIDTH-1]	=	w_waddrb_1P[ADDR_WIDTH-1] ^ 1'b0;
assign	w_waddrg_1P[ADDR_WIDTH-2:0]	=	w_waddrb_1P[ADDR_WIDTH-2:0] ^ w_waddrb_1P[ADDR_WIDTH-1:1];

assign	w_full	=	((r_waddrg_1P == r_raddrg_1P) &
					(r_wflag_1P != r_rflag_1P))?
						1'b1:
					(i_we &
					((w_waddrg_1P == r_raddrg_2P) &
					(w_wflag_1P != r_rflag_2P)))?
						1'b1:
						1'b0;

always@(posedge i_arst or posedge i_wclk)
begin
	if (i_arst) begin
		r_raddrb_wclk_1P	<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		r_raddrb_wclk_1P	<= r_raddrb_1P;
	end
end

always@(posedge i_arst or posedge i_wclk)
begin
	if (i_arst) begin
		r_raddrb_wclk_neg	<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		r_raddrb_wclk_neg	<= ~r_raddrb_wclk_1P + 1'b1;
	end
end

always@(posedge i_arst or posedge i_wclk)
begin
	if (i_arst) begin
		wr_cnt			<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		wr_cnt			<= r_waddrb_1P + r_raddrb_wclk_neg;
	end
end

always@(posedge i_arst or posedge i_rclk)
begin
	if (i_arst) begin
		r_waddrb_rclk_1P	<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		r_waddrb_rclk_1P	<= r_waddrb_1P;
	end
end

always@(posedge i_arst or posedge i_rclk)
begin
	if (i_arst) begin
		r_waddrb_rclk_neg	<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		r_waddrb_rclk_neg	<= ~r_waddrb_rclk_1P;
	end
end

always@(posedge i_arst or posedge i_rclk)
begin
	if (i_arst) begin
		rd_cnt			<= {ADDR_WIDTH+1{1'b0}};
	end
	else begin
		rd_cnt			<= r_raddrb_1P + r_waddrb_rclk_neg;
	end
end

always@(posedge i_arst or posedge i_wclk)
begin
	if (i_arst)
	begin
		r_we_1P			<= 1'b0;
		r_waddrb_1P		<= {ADDR_WIDTH+1{1'b0}};
		r_wflag_1P		<= 1'b0;
		r_waddrg_1P		<= {ADDR_WIDTH{1'b0}};
		r_waddrg_2P		<= {ADDR_WIDTH{1'b0}};
		
		r_full[0]		<= 1'b0;
	end
	else
	begin
		r_we_1P	<= 1'b0;

		if (CHECK_FULL == "TRUE")
		begin
			if (i_we & ~w_full_P)
			begin
				r_we_1P			<= 1'b1;
				r_waddrb_1P		<= w_waddrb_1P;
				r_wflag_1P		<= w_wflag_1P;
				r_waddrg_1P		<= w_waddrg_1P;
			end
		end
		else
		begin
			if (i_we)
			begin
				r_we_1P			<= 1'b1;
				r_waddrb_1P		<= w_waddrb_1P;
				r_wflag_1P		<= w_wflag_1P;
				r_waddrg_1P		<= w_waddrg_1P;
			end
		end
		
		if (r_we_1P)
			r_waddrg_2P		<= r_waddrg_1P;
		
		r_full[0]		<= w_full;
	end
end

assign	w_raddrb_1P					=	r_raddrb_1P + 1'b1;
assign	w_rflag_1P					=	w_raddrb_1P[ADDR_WIDTH];
assign	w_raddrg_1P[ADDR_WIDTH-1]	=	w_raddrb_1P[ADDR_WIDTH-1] ^ 1'b0;
assign	w_raddrg_1P[ADDR_WIDTH-2:0]	=	w_raddrb_1P[ADDR_WIDTH-2:0] ^ w_raddrb_1P[ADDR_WIDTH-1:1];

assign	w_empty	=	((r_waddrg_2P == r_raddrg_1P) &
//					(r_wflag_1P == r_rflag_2P))?
					(r_wflag_1P == r_rflag_1P))?	// changed for BYPASS
						1'b1:
					(i_re &
					((r_waddrg_1P == r_raddrg_1P) &
					(r_wflag_1P == r_rflag_1P)))?
						1'b1:
						1'b0;
//assign	w_empty	=	(r_waddrg_2P == r_raddrg_1P)?
//						1'b1:
//					(i_re & (r_waddrg_1P == r_raddrg_1P))?
//						1'b1:
//						1'b0;

always@(posedge i_arst or posedge i_rclk)
begin
	if (i_arst)
	begin
		r_re_1P			<= 1'b0;
		r_raddrb_1P		<= {ADDR_WIDTH+1{1'b0}};
		r_rflag_1P		<= 1'b0;
		r_raddrg_1P		<= {ADDR_WIDTH{1'b0}};
		r_rflag_2P		<= 1'b0;
		r_raddrg_2P		<= {ADDR_WIDTH{1'b0}};
		
		r_empty[0]		<= 1'b1;
		
//		r_restore_1P	<= 1'b0;
		r_raddrb_2P		<= {ADDR_WIDTH+1{1'b0}};
		r_raddrg_PP		<= {ADDR_WIDTH{1'b0}};
		r_raddrb_3P		<= {ADDR_WIDTH+1{1'b0}};
		r_raddrg_3P		<= {ADDR_WIDTH{1'b0}};
	end
	else
	begin
		r_re_1P	<= 1'b0;
		
//		r_restore_1P	<= 1'b0;
		r_raddrb_2P		<= r_raddrb_1P;
		r_raddrg_PP		<= r_raddrg_1P;
		r_raddrb_3P		<= r_raddrb_2P;
		r_raddrg_3P		<= r_raddrg_PP;
		
//		if (CHECK_FULL == "TRUE")
		if (CHECK_EMPTY == "TRUE")
		begin
			if (i_re & ~w_empty_P)
			begin
				r_re_1P			<= 1'b1;
				r_raddrb_1P		<= w_raddrb_1P;
				r_rflag_1P		<= w_rflag_1P;
				r_raddrg_1P		<= w_raddrg_1P;
			end
/*			else if (i_restore)
			begin
				r_restore_1P	<= 1'b1;
				r_raddrb_1P		<= r_raddrb_3P;
				r_raddrg_1P		<= r_raddrg_3P;
			end*/
		end
		else
		begin
			if (i_re)
			begin
				r_re_1P			<= 1'b1;
				r_raddrb_1P		<= w_raddrb_1P;
				r_rflag_1P		<= w_rflag_1P;
				r_raddrg_1P		<= w_raddrg_1P;
			end
/*			else if (i_restore)
			begin
				r_restore_1P	<= 1'b1;
				r_raddrb_1P		<= r_raddrb_3P;
				r_raddrg_1P		<= r_raddrg_3P;
			end*/
		end
		
		if (r_re_1P)
		begin
			r_raddrg_2P		<= r_raddrg_1P;
			r_rflag_2P		<= r_rflag_1P;
		end
		
		r_empty[0]		<= w_empty;
	end
end

genvar i, j;
generate
	for (i=1; i<LATENCY; i=i+1)
	begin: pipe_empty
		always@(posedge i_arst or posedge i_rclk)
		begin
			if (i_arst)
				r_empty[i]	<= 1'b1;
			else
				r_empty[i]	<= r_empty[i-1];
		end
	end
	
	assign	w_empty_P	= w_empty | r_empty[LATENCY-1];
//	assign	w_empty_P	= r_empty[0];
	
	for (j=1; j<LATENCY+1; j=j+1)
	begin: pipe_full
		always@(posedge i_arst or posedge i_wclk)
		begin
			if (i_arst)
				r_full[j]	<= 1'b0;
			else
				r_full[j]	<= r_full[j-1];
		end
	end
	
	if (COMPATIBILITY == "X")
		if (FIFO_MODE == "BYPASS")
			assign	w_full_P	= r_full[0] | r_full[LATENCY-2];
		else
			assign	w_full_P	= r_full[0]	| r_full[LATENCY];
	else
		assign	w_full_P	= r_full[0] | r_full[LATENCY-1];
//	assign	w_full_P	= r_full[0];
	
	if (CHECK_FULL == "TRUE")
		assign	w_we	= i_we & ~w_full_P;
	else
		assign	w_we	= i_we;
	
	if (FIFO_MODE == "BYPASS")
	begin
		assign	w_re	= 1'b1;
		if (CHECK_EMPTY == "TRUE")
			assign	w_raddr	= (i_re & ~w_empty_P)?
								w_raddrg_1P[ADDR_WIDTH-1:0]:
								r_raddrg_1P[ADDR_WIDTH-1:0];
		else
			assign	w_raddr	= (i_re)?
								w_raddrg_1P[ADDR_WIDTH-1:0]:
								r_raddrg_1P[ADDR_WIDTH-1:0];
	end
	else
	begin
		if (CHECK_EMPTY == "TRUE")
			assign	w_re	= i_re & ~w_empty_P;
//			assign	w_re	= (i_re | r_restore_1P) & ~w_empty_P;
		else
			assign	w_re	= i_re;
//			assign	w_re	= i_re | r_restore_1P;
		assign	w_raddr	= r_raddrg_1P[ADDR_WIDTH-1:0];
	end

	simple_dual_port_ram
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.OUTPUT_REG(OUTPUT_REG),
		.RAM_INIT_FILE(RAM_INIT_FILE)
	)
	inst_simple_dual_port_ram
	(
		.wdata(i_wdata),
		.waddr(r_waddrg_1P[ADDR_WIDTH-1:0]),
		.raddr(w_raddr),
		.we(w_we),
		.wclk(i_wclk),
		.re(w_re),
		.rclk(i_rclk),
		.rdata(o_rdata)
	);
endgenerate

//assign	o_empty	= w_empty_P;
//assign	o_full	= w_full_P;
//assign	o_empty	= (r_empty == {LATENCY{1'b1}});
/*assign	o_full	= (COMPATIBILITY == "X")?
						(FIFO_MODE == "BYPASS")?
							(r_full[LATENCY-2:0] != {LATENCY-1{1'b0}}):
							(r_full != {LATENCY+1{1'b1}}):
						(r_full[LATENCY-1:0] != {LATENCY{1'b0}});*/
assign	o_empty	= w_empty_P;
assign	o_full	= w_full_P;

//assign	o_aempty= w_empty_P;
//assign	o_wcnt	= r_waddrb_1P;
//assign	o_afull	= w_full_P;
//assign	o_rcnt	= r_raddrb_1P;

//assign	o_aempty= w_empty_P | (rd_cnt[ADDR_WIDTH-1] & rd_cnt[ADDR_WIDTH-2] & rd_cnt[ADDR_WIDTH-3]);
assign	o_wcnt	= wr_cnt[ADDR_WIDTH] ? {ADDR_WIDTH{1'b1}} : wr_cnt[ADDR_WIDTH-1:0];
//assign	o_afull	= w_full_P | wr_cnt[ADDR_WIDTH] | (wr_cnt[ADDR_WIDTH-1] & wr_cnt[ADDR_WIDTH-2] & wr_cnt[ADDR_WIDTH-3]);
assign	o_rcnt	= w_full_P ? {ADDR_WIDTH{1'b0}} : rd_cnt[ADDR_WIDTH-1:0];

assign	o_aempty= w_empty_P | (rd_cnt[ADDR_WIDTH-1:AEMPTY_OFFSET] == {ADDR_WIDTH-AEMPTY_OFFSET{1'b1}});
assign	o_afull	= w_full_P | wr_cnt[ADDR_WIDTH] | (wr_cnt[ADDR_WIDTH-1:AFULL_OFFSET] == {ADDR_WIDTH-AFULL_OFFSET{1'b1}});

assign	o_dbg_w_re			= w_re;

assign	o_dbg_w_waddrb_1P	= w_waddrb_1P;
assign	o_dbg_w_waddrg_1P	= w_waddrg_1P;
assign	o_dbg_r_waddrb_1P	= r_waddrb_1P;
assign	o_dbg_r_waddrg_1P	= r_waddrg_1P;
assign	o_dbg_r_waddrg_2P	= r_waddrg_2P;
assign	o_dbg_r_wflag_1P	= r_wflag_1P;

assign	o_dbg_w_raddrb_1P	= w_raddrb_1P;
assign	o_dbg_w_raddrg_1P	= w_raddrg_1P;
assign	o_dbg_r_raddrb_1P	= r_raddrb_1P;
assign	o_dbg_r_raddrg_1P	= r_raddrg_1P;
assign	o_dbg_r_raddrg_2P	= r_raddrg_2P;
assign	o_dbg_r_rflag_1P	= r_rflag_1P;
assign	o_dbg_r_rflag_2P	= r_rflag_2P;

endmodule
