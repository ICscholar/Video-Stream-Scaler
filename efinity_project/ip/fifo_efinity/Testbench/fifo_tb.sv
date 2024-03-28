`resetall
`timescale 1ns/1ps
`include "fifo_efinity_define.vh"

module fifo_tb;

`ifdef XRUN
initial begin
    $shm_open("fifo_tb.shm");
    $shm_probe(fifo_tb,"ACMTF");
end
`endif

localparam WDATA_WIDTH_WGR	= (ASYM_WIDTH_RATIO == 0)? 16 : 
                              (ASYM_WIDTH_RATIO == 1)? 16 :
                              (ASYM_WIDTH_RATIO == 2)? 16 :
                              (ASYM_WIDTH_RATIO == 3)? 16 :
                              (ASYM_WIDTH_RATIO == 4)? 16 :
                              (ASYM_WIDTH_RATIO == 5)? 16 :
                              (ASYM_WIDTH_RATIO == 6)? 16 :
                              (ASYM_WIDTH_RATIO == 7)? 16 :
                              (ASYM_WIDTH_RATIO == 8)? 16 : 16;
                              
localparam WDATA_WIDTH_RGW	= (ASYM_WIDTH_RATIO == 0)? 16 : 
                              (ASYM_WIDTH_RATIO == 1)? 16 :
                              (ASYM_WIDTH_RATIO == 2)? 16 :
                              (ASYM_WIDTH_RATIO == 3)? 16 :
                              (ASYM_WIDTH_RATIO == 4)? 16 :
                              (ASYM_WIDTH_RATIO == 5)? 8  :
                              (ASYM_WIDTH_RATIO == 6)? 8  :
                              (ASYM_WIDTH_RATIO == 7)? 4  :
                              (ASYM_WIDTH_RATIO == 8)? 1  : 16;
	
localparam WDATA_WIDTH        = DATA_WIDTH;
localparam RDATA_WIDTH        = rdwidthcompute(ASYM_WIDTH_RATIO,WDATA_WIDTH);
localparam RDATA_WIDTH_48     = (ASYM_WIDTH_RATIO >= 4) ? RDATA_WIDTH : 16;

localparam WR_DEPTH           = DEPTH;
localparam WADDR_WIDTH        = depth2width(WR_DEPTH);
localparam RD_DEPTH           = rddepthcompute(WR_DEPTH,WDATA_WIDTH,RDATA_WIDTH);
localparam RADDR_WIDTH        = depth2width(RD_DEPTH);
localparam MEM_DATA_WIDTH     = (WDATA_WIDTH >= RDATA_WIDTH) ? RDATA_WIDTH : WDATA_WIDTH;
localparam RAM_MUX_RATIO      = (RDATA_WIDTH <= WDATA_WIDTH/32) ? 32 :
                                (RDATA_WIDTH <= WDATA_WIDTH/16) ? 16 :
                                (RDATA_WIDTH <= WDATA_WIDTH/8)  ? 8  :
                                (RDATA_WIDTH <= WDATA_WIDTH/4)  ? 4  :
                                (RDATA_WIDTH <= WDATA_WIDTH/2)  ? 2  :
                                (RDATA_WIDTH <= WDATA_WIDTH)    ? 1  :
                                (RDATA_WIDTH <= WDATA_WIDTH*2)  ? 2  :
                                (RDATA_WIDTH <= WDATA_WIDTH*4)  ? 4  :
                                (RDATA_WIDTH <= WDATA_WIDTH*8)  ? 8  :
                                (RDATA_WIDTH <= WDATA_WIDTH*16) ? 16 : 32; 
localparam LSB_WIDTH          = (WADDR_WIDTH > RADDR_WIDTH) ? (WADDR_WIDTH - RADDR_WIDTH) : (RADDR_WIDTH - WADDR_WIDTH);

reg                      a_rst_i;
reg                      wr_clk;
reg                      rd_clk;
reg                      wr_en_i;
reg                      rd_en_i;
reg [WDATA_WIDTH-1:0]    wdata;
reg [WADDR_WIDTH-1:0]    waddr;
reg [RADDR_WIDTH-1:0]    raddr;
reg [MEM_DATA_WIDTH-1:0] dynamic_a[$];
reg [MEM_DATA_WIDTH-1:0] dynamic_b[$];
reg [RDATA_WIDTH-1:0]    monitor, monitor_temp;
reg [RDATA_WIDTH-1:0]    read_lastdata;
reg                      temp_empty_o;

wire [RDATA_WIDTH-1:0] rdata;
wire                   rd_valid_o;
wire                   prog_full_o;
wire                   almost_full_o;
wire                   full_o;
wire                   overflow_o;
wire                   wr_ack_o;
wire                   prog_empty_o;
wire                   almost_empty_o;
wire                   empty_o;
wire                   underflow_o;
wire [WADDR_WIDTH:0]   datacount_o;
wire [WADDR_WIDTH:0]   wr_datacount_o;
wire [RADDR_WIDTH:0]   rd_datacount_o;
wire                   clk_i;
wire                   wr_clk_i;
wire                   rd_clk_i;
wire                   rst_busy_0;

integer write_period;
integer read_period;
integer count;
integer wr_count;
integer rd_count;

initial begin
    wr_clk   = 0;
    rd_clk   = 0;
    write_period = 7;
    read_period  = 9;
end

always begin
    #(write_period) wr_clk <= ~wr_clk;
end

always begin
    #(read_period) rd_clk <= ~rd_clk;
end

assign clk_i    = wr_clk;
assign wr_clk_i = wr_clk;
assign rd_clk_i = wr_clk; 

initial begin
    a_rst_i = 1'b1;
    #1080
    a_rst_i = 1'b0;
end

initial begin
    wr_en_i   = 1'b0;
    rd_en_i   = 1'b0;
    wdata     = 'h0;
    waddr     = 'd0;
    dynamic_a = {};
    dynamic_b = {};
end

assign wr_count = WR_DEPTH;
assign rd_count = ASYM_WIDTH_RATIO < 4 ? wr_count * RAM_MUX_RATIO : wr_count / RAM_MUX_RATIO;

initial begin
    wait (~a_rst_i & rst_busy_0);
    repeat (10) @ (negedge wr_clk_i) ;  
    count = WR_DEPTH;
    repeat (wr_count) @ (negedge wr_clk_i) begin
        wr_en_i = 1'b1;
        wdata   = {WDATA_WIDTH{$random}};
    end
    repeat (2) @ (negedge wr_clk_i) begin
        wr_en_i = 1'b0;
    end
    repeat (rd_count) @ (negedge wr_clk_i) begin
        rd_en_i = 1'b1;
    end
    repeat (2) @ (negedge wr_clk_i) begin
        rd_en_i = 1'b0;
    end
    repeat (10) @ (negedge wr_clk_i) ;
    $finish;
end

initial begin
    forever begin
        @(posedge wr_clk_i) begin
            if (wr_en_i && ~full_o) begin
                waddr <= waddr +1;
            end
        end
    end
end

initial begin
    forever begin
        @(posedge wr_clk_i) begin
            if (wr_en_i && ~full_o) begin
                if (ENDIANESS == 0) begin
                	if (WDATA_WIDTH <= RDATA_WIDTH) begin
                		dynamic_a.push_back(wdata);
                		dynamic_b.push_back(wdata);
                		$display("%t - write data %h to address: %d ", $time(), wdata, waddr );
                		end
                	else begin
                		integer i;
                		reg  [LSB_WIDTH-1 :0 ] lsbaddr;
                		for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                        	lsbaddr = i;
                        	dynamic_a.push_back(wdata[((WDATA_WIDTH_WGR/RAM_MUX_RATIO)*i)-1 -: WDATA_WIDTH_WGR/RAM_MUX_RATIO]);
                        	dynamic_b.push_back(wdata[((WDATA_WIDTH_WGR/RAM_MUX_RATIO)*i)-1 -: WDATA_WIDTH_WGR/RAM_MUX_RATIO]);
                        end
                        	$display("%t - write data %h to address: %d", $time(), wdata, waddr);
                    end
                end
                else begin 
                	if (WDATA_WIDTH <= RDATA_WIDTH) begin 
                		dynamic_a.push_back(wdata);
                		dynamic_b.push_back(wdata);
                		$display("%t - write data %h to address: %d ", $time(), wdata, waddr );
                		end
                	else begin //downsize
                		integer i;
                		reg  [LSB_WIDTH-1 :0 ] lsbaddr;
                		for (i=0; i < RAM_MUX_RATIO; i=i+1) begin
                        	lsbaddr = i;
                        	dynamic_a.push_back(wdata[((WDATA_WIDTH_WGR/RAM_MUX_RATIO)*i) +: WDATA_WIDTH_WGR/RAM_MUX_RATIO]);
                        	dynamic_b.push_back(wdata[((WDATA_WIDTH_WGR/RAM_MUX_RATIO)*i) +: WDATA_WIDTH_WGR/RAM_MUX_RATIO]);
                        end
                        	$display("%t - write data %h to address: %d", $time(), wdata, waddr);
                    end
                end
            end
        end
    end
end

initial begin
    forever begin
        if (MODE == "STANDARD") begin
            @(posedge rd_clk_i) begin
                if (RDATA_WIDTH <= WDATA_WIDTH) begin 
                    if(rd_en_i == 1 && ~empty_o) begin
                        monitor <= dynamic_a.pop_front();
                    end
                end
                else if (RDATA_WIDTH > WDATA_WIDTH && ENDIANESS == 0) begin 
                    integer i;
                    for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                        if (rd_en_i && ~empty_o) begin
                            monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i)-1 -: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                        end
                    end
                end
                else if (RDATA_WIDTH > WDATA_WIDTH && ENDIANESS == 1) begin 
                	integer i;
                    for (i=0; i < RAM_MUX_RATIO; i=i+1) begin
                        if (rd_en_i && ~empty_o) begin
                            monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i) +: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                        end
                    end
                end
            end
        end
        else begin
            if (SYNC_CLK) begin
                @(posedge rd_clk_i) begin
                    if (RDATA_WIDTH <= WDATA_WIDTH) begin 
                        if (dynamic_b.size() == RAM_MUX_RATIO) begin
                            monitor <= dynamic_a.pop_front();
                        end
                        else if (rd_en_i == 1 && ~empty_o) begin
                            monitor <= dynamic_a.pop_front();
                        end
                    end
                    else begin 
                        integer i;
                        if (dynamic_b.size() == RAM_MUX_RATIO) begin
                            for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                                monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i)-1 -: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                            end	
                        end
                        else begin
                            integer i;
                            for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                                if (rd_en_i && ~almost_empty_o) begin
                                    monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i)-1 -: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                                end
                            end
                        end					
                    end
                end
			end
            else begin
                @(posedge rd_clk_i) begin
                    if (RDATA_WIDTH <= WDATA_WIDTH) begin 
                        #0.1
                        if (rd_en_i && ~empty_o) begin
                            monitor <= dynamic_a.pop_front();
                        end
                    end
                    else if(RDATA_WIDTH > WDATA_WIDTH && ENDIANESS == 0) begin 
                        integer i;
                        for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                            if (rd_en_i && ~almost_empty_o) begin
                                monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i)-1 -: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                            end
                        end					
                    end
                    else begin 
                    	integer i;
                        for (i=0; i < RAM_MUX_RATIO; i=i+1) begin
                            if (rd_en_i && ~almost_empty_o) begin
                                monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i) +: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                            end
                        end	
                    end
                end
            end
        end
    end
end

initial begin
    forever begin
        if (MODE == "FWFT") begin
            if (SYNC_CLK == 0) begin
                @ (negedge empty_o) begin
                    if (~rd_en_i && dynamic_b.size() != 1) begin
                    	//integer i
                        if (RDATA_WIDTH <= WDATA_WIDTH) begin 
                            monitor <= dynamic_a.pop_front();					
                        end
                        else if (RDATA_WIDTH > WDATA_WIDTH && ENDIANESS == 0) begin
                            integer i;
                            for (i=RAM_MUX_RATIO; i > 0; i=i-1) begin
                                monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i)-1 -: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                            end
                        end
                        else begin
                        	integer i;
                            for (i=0; i < RAM_MUX_RATIO; i=i+1) begin
                                monitor[((RDATA_WIDTH_48/RAM_MUX_RATIO)*i) +: (RDATA_WIDTH_48/RAM_MUX_RATIO)] <= dynamic_a.pop_front();
                            end
                        end
                    end
                end				
            end
            else begin
                @ (negedge empty_o);
            end
		end
        else begin
            @ (negedge empty_o);
        end
    end
end

always @ (posedge rd_clk_i)begin
    monitor_temp <= monitor;
    temp_empty_o <= empty_o;
end

initial begin
    forever begin
        if (MODE == "STANDARD") begin
            @(negedge rd_clk_i) begin
                if (rd_valid_o == 1 && ~a_rst_i) begin
                    if (monitor  === rdata) begin
                        $display("%t - PASS! FIFO read data %h is match to expected data %h", $time(), rdata, monitor);
                    end
                    else begin
                        $error("%t - FAIL! FIFO read data %h does not match to expected data %h", $time(), rdata, monitor);
                    end
                end
            end
        end
        else begin
            @(posedge rd_clk_i) begin
                if (rd_en_i && rd_valid_o) begin
                    if (monitor  === rdata) begin
                        $display("%t - PASS! FIFO read data %h is match to expected data %h", $time(), rdata, monitor);
                    end
                    else begin
                        $error("%t - ERROR! FIFO read data %h does not match to expected data %h", $time(), rdata, monitor);
                    end
                end
            end		
        end	
    end
end

generate
    if (SYNC_CLK == 1 && ASYM_WIDTH_RATIO == 4) begin
        fifo_efinity u_efx_fifo_top (
            .a_rst_i        (a_rst_i),
            .rst_busy       (rst_busy_0),   
            .clk_i          (clk_i),
            .wr_en_i        (wr_en_i),
            .wdata          (wdata),
            .rd_en_i        (rd_en_i),
            .rdata          (rdata),
            .rd_valid_o     (rd_valid_o),
            .full_o         (full_o),
            .almost_empty_o (almost_empty_o),
            .empty_o        (empty_o)
        );
    end
    else if (SYNC_CLK == 0 && ASYM_WIDTH_RATIO == 4) begin
        fifo_efinity u_efx_fifo_top (
            .a_rst_i        (a_rst_i),   
            .rst_busy       (rst_busy_0),   
            .wr_clk_i       (wr_clk_i),
            .wr_en_i        (wr_en_i),
            .wdata          (wdata),
            .rd_clk_i       (rd_clk_i),
            .rd_en_i        (rd_en_i),
            .rdata          (rdata),
            .rd_valid_o     (rd_valid_o),
            .full_o         (full_o),
            .almost_empty_o (almost_empty_o),
            .empty_o        (empty_o)
        );
    end
    else if (SYNC_CLK == 1 && ASYM_WIDTH_RATIO != 4) begin
        fifo_efinity u_efx_fifo_top (
            .a_rst_i        (a_rst_i),     
            .rst_busy       (rst_busy_0),   
            .clk_i          (clk_i),
            .wr_en_i        (wr_en_i),
            .wdata          (wdata),
            .rd_en_i        (rd_en_i),
            .rdata          (rdata),
            .rd_valid_o     (rd_valid_o),
            .full_o         (full_o),
            .almost_empty_o (almost_empty_o),
            .empty_o        (empty_o)
        );
    end if (SYNC_CLK == 0 && ASYM_WIDTH_RATIO != 4) begin
        fifo_efinity u_efx_fifo_top (
            .a_rst_i        (a_rst_i),   
            .rst_busy       (rst_busy_0),   
            .wr_clk_i       (wr_clk_i),
            .wr_en_i        (wr_en_i),
            .wdata          (wdata),
            .rd_clk_i       (rd_clk_i),
            .rd_en_i        (rd_en_i),
            .rdata          (rdata),
            .rd_valid_o     (rd_valid_o),
            .full_o         (full_o),
            .almost_empty_o (almost_empty_o),
            .empty_o        (empty_o)
        );
    end
endgenerate

function integer depth2width;
input [31:0] depth;
begin : fnDepth2Width
    if (depth > 1) begin
        depth = depth - 1;
        for (depth2width=0; depth>0; depth2width = depth2width + 1)
            depth = depth>>1;
        end
    else
    depth2width = 0;
end
endfunction 

function integer rdwidthcompute;
input [31:0] asym_option;
input [31:0] wr_width;
begin : RdWidthCompute
    rdwidthcompute = (asym_option==0)? wr_width/16 :
                     (asym_option==1)? wr_width/8  :
                     (asym_option==2)? wr_width/4  :
                     (asym_option==3)? wr_width/2  :
                     (asym_option==4)? wr_width/1  :
                     (asym_option==5)? wr_width*2  :
                     (asym_option==6)? wr_width*4  :
                     (asym_option==7)? wr_width*8  :
                     (asym_option==8)? wr_width*16 : wr_width/1;
end
endfunction

function integer rddepthcompute;
input [31:0] wr_depth;
input [31:0] wr_width;
input [31:0] rd_width;
begin : RdDepthCompute
    rddepthcompute = (wr_depth * wr_width) / rd_width;
end
endfunction

endmodule
