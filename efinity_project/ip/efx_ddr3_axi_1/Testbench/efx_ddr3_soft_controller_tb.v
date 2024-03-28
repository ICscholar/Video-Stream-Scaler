`timescale 100ps/10ps
`include "ddr3_controller.vh"
`define den4096Mb
`define x16

module efx_ddr3_soft_controller_tb ();
`include "ddr3_device_ID.vh"

reg core_clk;
reg clk;
reg user_clk;
reg twd_clk;
reg tdqss_clk;
reg tac_clk;
reg reset_n; //active_low

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

wire pass;
wire done;

reg [1:0]r_done;


initial begin 
	$dumpfile("efx_ddr3_soft_controller_tb.vcd");
    $dumpvars(0, efx_ddr3_soft_controller_tb);
    //$shm_open("efx_ddr3_soft_controller_simulate.shm");
    //$shm_probe(efx_ddr3_soft_controller_tb,"ACMTF");
    end

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
.ddr_core_clk(core_clk),
.ddr_twd_clk(twd_clk),
.ddr_tdqss_clk(tdqss_clk),
.ddr_tac_clk(tac_clk),
.reset_n(reset_n),
.pll_lock(1'b1),
.pll1_lock(1'b1),

.ddr_pll_rstn(),
.sys_pll_rstn(),

.ddr_reset(reset),
.ddr_cs(cs),
.ddr_ras(ras),
.ddr_cas(cas),
.ddr_we(we),
.ddr_cke(cke),
.ddr_addr(addr),
.ddr_ba(ba),
.ddr_odt(odt),
.o_ddr_dm_hi(o_dm_hi),
.o_ddr_dm_lo(o_dm_lo),

.i_ddr_dqs_hi(i_dqs_hi),
.i_ddr_dqs_lo(i_dqs_lo),

.i_ddr_dqs_n_hi(i_dqs_n_hi),
.i_ddr_dqs_n_lo(i_dqs_n_lo),


.o_ddr_dqs_hi(o_dqs_hi),
.o_ddr_dqs_lo(o_dqs_lo),

.o_ddr_dqs_n_hi(o_dqs_n_hi),
.o_ddr_dqs_n_lo(o_dqs_n_lo),


.o_ddr_dqs_oe(o_dqs_oe),
.o_ddr_dqs_n_oe(o_dqs_n_oe),

.i_ddr_dq_hi(i_dq_hi),
.i_ddr_dq_lo(i_dq_lo),

.o_ddr_dq_hi(o_dq_hi),
.o_ddr_dq_lo(o_dq_lo),

.o_ddr_dq_oe(o_dq_oe),

.ddr_shift(),
.ddr_shift_sel(),
.ddr_shift_ena(),

.ddr_cal_done(),
.ddr_cal_pass(),
.pass(pass),
.done(done)
);


always@(posedge user_clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		r_done <= 2'b0;
	end
	else
	begin
		if((r_done[1]==1'b0) && (r_done[0]==1'b1))
		begin
			if(pass)
				$display ("DDR3 Controller PASS");
			else
				$display ("DDR3 Controller FAIL");

			$finish;
		end

		r_done[0] <= done;
		r_done[1] <= r_done[0];
	end
end

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
	reset_n <=1'b0;
	#1000
	reset_n <=1'b1;	
end

initial begin
	core_clk = 1'b0;
	#1 core_clk = 1'b0;
	forever begin
		#25 core_clk = ~core_clk;
	end
end

initial begin
	tdqss_clk = 1'b0;
	#1 tdqss_clk = 1'b0;
	forever begin
		#12.5 tdqss_clk = ~tdqss_clk;
	end
end

initial begin
	tac_clk = 1'b1;
	#1 tac_clk = 1'b1;
	forever begin
		#12.5 tac_clk = ~tac_clk;
	end
end

initial begin
	clk = 1'b0;
	#1 clk = 1'b0;
	forever begin
		#12.5 clk = ~clk;
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
	#7 twd_clk = 1'b0;
	forever begin
		#12.5 twd_clk = ~twd_clk;
	end
end

endmodule
