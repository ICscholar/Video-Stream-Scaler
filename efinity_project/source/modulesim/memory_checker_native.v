`include "ddr3_controller.vh"

module memory_checker_native
(
input clk,
input nrst,
input test_start,

input wr_busy,
output [`WFIFO_WIDTH-1'b1:0]wr_data,
output [`DM_BIT_WIDTH-1'b1:0]wr_datamask,
output [31:0]wr_addr,
output wr_en,
input wr_ack,

input rd_busy,
output [31:0] rd_addr,
output rd_en,
input [`WFIFO_WIDTH-1'b1:0]rd_data,
input rd_valid,

output test_pass,
output test_done

);

wire [`WFIFO_WIDTH-1:0]data_temp[0:15];

assign data_temp[0] = 128'h17181920212223242526272829303132;
assign data_temp[1] = 128'h01020304050607080910111213141516;
assign data_temp[2] = 128'h00112233445566778899AABBCCDDEEFF;
assign data_temp[3] = 128'hFFEEDDCCBBAA99887766554433221100;

assign data_temp[4] = 128'h55555555AAAAAAAA55555555AAAAAAAA;
assign data_temp[5] = 128'h5555AAAA5555AAAA5555AAAA5555AAAA;
assign data_temp[6] = 128'h55AA55AA55AA55AA55AA55AA55AA55AA;
assign data_temp[7] = 128'h5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A;

assign data_temp[8]  = 128'hFF00FF00FF00FF00FF00FF00FF00FF00;
assign data_temp[9]  = 128'hF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0;
assign data_temp[10] = 128'hFFFEFDFCFBFAF9F8F7F6F5F4F3F2F1F0;
assign data_temp[11] = 128'hF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF;

assign data_temp[12] = 128'h10001000010001000010001000010001;
assign data_temp[13] = 128'h00010001001000100100010010001000;
assign data_temp[14] = 128'hFFFF0000FFFF0000FFFF0000FFFF0000;
assign data_temp[15] = 128'h0000FFFF0000FFFF0000FFFF0000FFFF;

reg [`WFIFO_WIDTH-1'b1:0]r_wr_data;
reg [`DM_BIT_WIDTH-1'b1:0]r_wr_datamask;
reg [31:0]r_wr_addr;
reg r_wr_en;

assign wr_data 		= r_wr_data;
assign wr_datamask 	= r_wr_datamask;
assign wr_addr		= r_wr_addr;
assign wr_en 		= r_wr_en;

reg[31:0] r_rd_addr;
reg r_rd_en;

assign rd_addr = r_rd_addr;
assign rd_en = r_rd_en;

reg [3:0] test_state;

reg test_start_p0;
reg test_run;
reg [3:0]loop_cnt;

reg r_test_pass;
reg r_test_done;
assign test_pass = r_test_pass;
assign test_done = r_test_done;
reg [3:0]cmp_cnt;
reg [31:0]cmp_sub_cnt;
reg bFail;

reg [15:0]inc_addr_p;
reg [31:0] ack_cnt;


localparam TEST_IDLE    = 0;
localparam PATTERN0 	= 1;
localparam PATTERN0_p 	= 2;
localparam PATTERN1 	= 3;
localparam PATTERN1_p 	= 4;
localparam PATTERN2 	= 5;
localparam PATTERN2_p 	= 6;
localparam PATTERN3 	= 7;
localparam PATTERN3_p 	= 8;

`ifdef RTL_SIM
	parameter END_ADDR = 32'h000800;
`else
	parameter END_ADDR = 32'h4000000;
`endif

always @(posedge clk or negedge nrst) begin
    if(~nrst)
    begin
        test_state      <=TEST_IDLE;
        test_start_p0   <=1'b1;
        test_run        <=1'b0;
        loop_cnt        <=4'b0;
		r_wr_data		<={`WFIFO_WIDTH{1'b0}};
		r_wr_datamask 	<={`DM_BIT_WIDTH{1'b0}};
		r_wr_addr		<=32'b0;
		r_wr_en			<=1'b0;
		r_rd_addr		<=32'b0;
		r_rd_en			<=1'b0;
		inc_addr_p		<=16'b0;
		ack_cnt			<=32'b0;
		r_test_done		<=1'b0;
		r_test_pass		<=1'b0;
		cmp_sub_cnt		<=32'b0;
		cmp_cnt			<=4'b0;
		bFail			<=1'b0;
    end
    else
    begin
        test_start_p0 <=test_start;

        if((~test_start_p0) && (test_start))
            test_run <=1'b1;

		r_wr_en		<=1'b0;
		r_rd_en		<=1'b0;

		if(test_run && wr_ack)
			ack_cnt <= ack_cnt +1'b1;

		r_test_pass <= (~bFail);

		if(rd_valid)
		begin
			if((test_state==PATTERN1) || (test_state==PATTERN1_p))
			begin
				if(rd_data !=data_temp[cmp_cnt])
					bFail <=1'b1;
			end
			else if((test_state==PATTERN2) || (test_state==PATTERN2_p))
			begin
				if(rd_data !=(~data_temp[4'd15-cmp_cnt]))
					bFail <=1'b1;
			end

			cmp_cnt <=cmp_cnt +1'b1;
			cmp_sub_cnt <=cmp_sub_cnt +1'b1;
		end

        case (test_state)
            TEST_IDLE:
            begin
				r_wr_en		<=1'b0;
				r_rd_en		<=1'b0;

                if(test_run)
                begin
					loop_cnt 		<=4'b0;
                    test_state 		<= PATTERN0;
					r_test_done		<=1'b0;
					r_test_pass		<=1'b0;
					bFail			<=1'b0;
					cmp_cnt 		<=4'b0;
					cmp_sub_cnt 	<= 32'b0;
                end
            end

            PATTERN0:	//WRITE0
            begin
				if(~wr_busy)
				begin
					inc_addr_p 	<= 16'd1;
					r_wr_en 	<= 1'b1;
					r_wr_data <= data_temp[loop_cnt];
					r_wr_addr <= r_wr_addr + {16'b0,inc_addr_p};
					loop_cnt 	<= loop_cnt + 1'b1;
				end

				if(r_wr_addr >= (END_ADDR-{16'b0,inc_addr_p}))
                begin
                    test_state 	<= PATTERN0_p;
					r_wr_addr <= 32'b0;
					r_rd_addr <= 32'b0;
					r_wr_en 	<= 1'b0;
					loop_cnt 	<= 4'b0;
					inc_addr_p 	<=16'b0;
                end
            end

			PATTERN0_p:
			begin
				if(ack_cnt == (END_ADDR))
				begin
					test_state 	<= PATTERN1;
					r_wr_addr <=32'b0;
					r_rd_addr <=32'b0;
					ack_cnt 	<=32'b0;
					cmp_cnt 	<=4'b0;
					cmp_sub_cnt <=32'b0;
				end
			end

            PATTERN1: //READ0 WRITE1 
            begin
				if((~wr_busy) && (~rd_busy))
				begin
					inc_addr_p 	<= 16'd1;
					r_rd_en 	<= 1'b1;
					r_rd_addr <= r_rd_addr + {16'b0,inc_addr_p};

					r_wr_en 	<= 1'b1;
					r_wr_data <= (~data_temp[loop_cnt]);
					r_wr_addr <= r_wr_addr + {16'b0,inc_addr_p};

					loop_cnt <= loop_cnt + 1'b1;
				end

                if(r_wr_addr >= (END_ADDR-1'b1))
                begin
					loop_cnt 	<=4'b0;
					r_wr_en 	<=1'b0;
					r_rd_en 	<=1'b0;
					inc_addr_p 	<=16'b0;
                    test_state 	<= PATTERN1_p;
                end
            end

			PATTERN1_p:
			begin
				if(cmp_sub_cnt == (END_ADDR))
				begin
					test_state <= PATTERN2;
					r_wr_addr <= END_ADDR-1'b1;
					r_rd_addr <= END_ADDR-1'b1;
					cmp_cnt 	<=4'b0;
					cmp_sub_cnt <= 32'b0;
				end
			end

			PATTERN2:	//READ1 WRITE0 INVERT DIRECTION
			begin
				if((~wr_busy) && (~rd_busy))
				begin
					inc_addr_p 	<= 16'd1;
					r_rd_en 	<= 1'b1;
					r_rd_addr <= r_rd_addr - {16'b0,inc_addr_p};

					r_wr_en 	<= 1'b1;
					r_wr_data <= (data_temp[loop_cnt]);
					r_wr_addr <= r_wr_addr - {16'b0,inc_addr_p};

					loop_cnt <= loop_cnt + 1'b1;
				end

                if(r_wr_addr == 32'b0)
                begin
					loop_cnt 	<=4'b0;
					r_wr_en 	<=1'b0;
					r_rd_en 	<=1'b0;
					inc_addr_p 	<=0;
                    test_state 	<= PATTERN2_p;
                end
			end

			PATTERN2_p:
			begin
				if(cmp_sub_cnt == (END_ADDR))
				begin
					test_state 	<= PATTERN3;
					test_run	<=1'b0;
					r_wr_addr <= 32'b0;
					r_rd_addr <= 32'b0;
					ack_cnt 	<=32'b0;
					cmp_cnt 	<=4'b0;
					cmp_sub_cnt <= 32'b0;
				end
			end
			PATTERN3: //READ0
			begin
				if(~rd_busy)
				begin
					inc_addr_p 	<= 16'd1;
					r_rd_en 	<= 1'b1;
					r_rd_addr <= r_rd_addr + {16'b0,inc_addr_p};

					loop_cnt <= loop_cnt + 1'b1;
				end

                if(r_rd_addr >= (END_ADDR-1'b1))
                begin
					loop_cnt 	<=4'b0;
					r_rd_en 	<=1'b0;
					inc_addr_p 	<=16'b0;
                    test_state 	<= PATTERN3_p;
                end
            end

			PATTERN3_p:
			begin
				if(cmp_sub_cnt == (END_ADDR))
				begin
					test_state 	<= PATTERN3_p;
					test_run	<=	1'b0;
					r_rd_addr 	<= 	32'b0;
					ack_cnt 	<=	32'b0;
					cmp_cnt 	<=	4'b0;
					cmp_sub_cnt <= 	32'b0;
					r_test_done	<=	1'b1;
				end
			end
        endcase
    end
end


endmodule
