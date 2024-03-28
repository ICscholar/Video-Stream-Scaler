`timescale 100ps / 100ps


module sim_example_top ();

`define sg125
`include "ddr3_controller.vh"

reg core_clk;
reg clk;
reg user_clk;
reg twd_clk;
reg tdqss_clk;
reg tac_clk;
reg nrst;

wire reset;
wire cs;
wire ras;
wire cas;
wire we;
wire cke;
wire [15:0]addr;
wire [2:0]ba;
wire odt;
wire [`DRAM_WIDTH-1:0] dq;
wire [`DRAM_GROUP-1:0] dm;
wire [`DRAM_GROUP-1:0] dqs;
wire [`DRAM_GROUP-1:0] dqs_n;
reg read;
reg write;

wire [`DRAM_GROUP-1:0]i_dqs_hi;
wire [`DRAM_GROUP-1:0]i_dqs_lo;

wire [`DRAM_GROUP-1:0]i_dqs_n_hi;
wire [`DRAM_GROUP-1:0]i_dqs_n_lo;


wire [`DRAM_GROUP-1:0]o_dqs_hi;
wire [`DRAM_GROUP-1:0]o_dqs_lo;

wire [`DRAM_GROUP-1:0]o_dqs_n_hi;
wire [`DRAM_GROUP-1:0]o_dqs_n_lo;


wire [`DRAM_GROUP-1:0]o_dqs_oe;
wire [`DRAM_GROUP-1:0]o_dqs_n_oe;

wire [`DRAM_GROUP-1:0]w_dqs;
wire [`DRAM_GROUP-1:0]w_dqs_n;

wire [`DRAM_GROUP-1:0]w_dqs_i;
wire [`DRAM_GROUP-1:0]w_dqs_n_i;

wire [`DRAM_GROUP-1:0]w_dqs_o;
wire [`DRAM_GROUP-1:0]w_dqs_n_o;


wire [`DRAM_WIDTH-1:0] i_dq_hi;
wire [`DRAM_WIDTH-1:0] i_dq_lo;

wire [`DRAM_WIDTH-1:0] o_dq_hi;
wire [`DRAM_WIDTH-1:0] o_dq_lo;

wire [`DRAM_WIDTH-1:0] w_dq_o;

wire [`DRAM_WIDTH-1:0] o_dq_oe;

wire [`DRAM_GROUP-1:0] o_dm_hi;
wire [`DRAM_GROUP-1:0] o_dm_lo;

genvar n;

generate
	for (n=0;n<`DRAM_GROUP;n=n+1 ) begin

		assign dqs[n] = (o_dqs_oe[n]==1)?w_dqs_o[n]:1'bz;
		assign dqs_n[n] = (o_dqs_n_oe[n]==1)?w_dqs_n_o[n]:1'bz;

		EFX_ODDR ddio_dm_out
		(
		.D0(o_dm_hi[n]), // data 0 input
		.D1(o_dm_lo[n]), // data 1 input
		.CE(1'b1), // clock-enable
		.CLK(twd_clk), // clock
		.SR(1'b0), // asyc/sync set/reset
		.Q(dm[n])    // data output
		);

		EFX_ODDR ddio_dqs_out
		(
		.D0(o_dqs_hi[n]), // data 0 input
		.D1(o_dqs_lo[n]), // data 1 input
		.CE(1'b1), // clock-enable
		.CLK(clk), // clock
		.SR(1'b0), // asyc/sync set/reset
		.Q(w_dqs_o[n])    // data output
		);

		EFX_ODDR ddio_dqs_n_out
		(
		.D0(o_dqs_n_hi[n]), // data 0 input
		.D1(o_dqs_n_lo[n]), // data 1 input
		.CE(1'b1), // clock-enable
		.CLK(clk), // clock
		.SR(1'b0), // asyc/sync set/reset
		.Q(w_dqs_n_o[n])    // data output
		);

		EFX_IDDR ddio_dqs_in
		(
		.D(dqs[n]),   // data input
		.CE(1'b1),  // clock-enable
		.CLK(tac_clk), // clock
		.SR(1'b0),  // asyc/sync set/reset
		.Q0(i_dqs_hi[n]),  // data 0 output
		.Q1(i_dqs_lo[n])   // data 1 output
		);

		EFX_IDDR ddio_dqs_n_in 
		(
		.D(dqs_n[n]),   // data input
		.CE(1'b1),  // clock-enable
		.CLK(tac_clk), // clock
		.SR(1'b0),  // asyc/sync set/reset
		.Q0(i_dqs_n_hi[n]),  // data 0 output
		.Q1(i_dqs_n_lo[n])   // data 1 output
		);


	end	
endgenerate



generate
	for (n =0 ;n<`DRAM_WIDTH;n=n+1) begin

		assign dq[n]=o_dq_oe[n]?w_dq_o[n]:1'bz;

		EFX_ODDR ddio_dq_out
		(
		.D0(o_dq_hi[n]), // data 0 input
		.D1(o_dq_lo[n]), // data 1 input
		.CE(1'b1), // clock-enable
		.CLK(twd_clk), // clock
		.SR(1'b0), // asyc/sync set/reset
		.Q(w_dq_o[n])    // data output
		);

		EFX_IDDR ddio_dq_in
		(
		.D(dq[n]),   // data input
		.CE(1'b1),  // clock-enable
		.CLK(tac_clk), // clock
		.SR(1'b0),  // asyc/sync set/reset
		.Q0(i_dq_hi[n]),  // data 0 output
		.Q1(i_dq_lo[n])   // data 1 output
		);

	end	
endgenerate

example_top u_top
(
.clk(user_clk),
.core_clk(core_clk),
.twd_clk(twd_clk),
.tdqss_clk(tdqss_clk),
.tac_clk(tac_clk),
.nrst(nrst),
.pll_lock(1'b1),
.pll1_lock(1'b1),

.reset(reset),
.cs(cs),
.ras(ras),
.cas(cas),
.we(we),
.cke(cke),
.addr(addr),
.ba(ba),
.odt(odt),
.o_dm_hi(o_dm_hi),
.o_dm_lo(o_dm_lo),

.i_dqs_hi(i_dqs_hi),
.i_dqs_lo(i_dqs_lo),

.i_dqs_n_hi(i_dqs_n_hi),
.i_dqs_n_lo(i_dqs_n_lo),


.o_dqs_hi(o_dqs_hi),
.o_dqs_lo(o_dqs_lo),

.o_dqs_n_hi(o_dqs_n_hi),
.o_dqs_n_lo(o_dqs_n_lo),


.o_dqs_oe(o_dqs_oe),
.o_dqs_n_oe(o_dqs_n_oe),

.i_dq_hi(i_dq_hi),
.i_dq_lo(i_dq_lo),

.o_dq_hi(o_dq_hi),
.o_dq_lo(o_dq_lo),

.o_dq_oe(o_dq_oe),

.shift(),
.shift_sel(),
.shift_ena(),

.cal_done(),
.cal_pass(),
.pass(),
.done()
);


ddr3 ddr3md
(
.rst_n(reset),
    .ck(~clk),
    .ck_n(clk),
    .cke(cke),
   .cs_n(cs),
   .ras_n(ras),
    .cas_n(cas),
    .we_n(we),
    .dm_tdqs(dm),
    .ba(ba),
    .addr(addr),
    .dq(dq),
    .dqs(dqs),
   .dqs_n(dqs_n),
    .tdqs_n(),
    .odt(odt)
);


initial
begin
	nrst <=1'b0;
	#1000
	nrst <=1'b1;	
end

initial begin
	core_clk = 1'b0;
	#1 core_clk = 1'b0;
	forever begin
		#20 core_clk = ~core_clk;
	end
end

initial begin
	tdqss_clk = 1'b0;
	#1 tdqss_clk = 1'b0;
	forever begin
		#10 tdqss_clk = ~tdqss_clk;
	end
end

initial begin
	tac_clk = 1'b1;
	#1 tac_clk = 1'b1;
	forever begin
		#10 tac_clk = ~tac_clk;
	end
end

initial begin
	clk = 1'b0;
	#1 clk = 1'b0;
	forever begin
		#10 clk = ~clk;
	end
end


initial begin
	user_clk = 1'b0;
	#1 user_clk = 1'b0;
	forever begin
		#40 user_clk = ~user_clk;
	end
end


initial begin
	twd_clk = 1'b0;
	#6 twd_clk = 1'b0;
	forever begin
		#10 twd_clk = ~twd_clk;
	end
end

initial
begin
    $dumpfile("wave.vcd");
    $dumpvars(0, sim);
end


endmodule