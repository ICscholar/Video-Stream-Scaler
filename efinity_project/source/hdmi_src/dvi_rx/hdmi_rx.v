

module hdmi_rx(
 input cfg_clk,
 input rst_n,
 input hdmi_rx_5v_n,
 output hdmi_rx_hpd_n,
 
 input 	scl_i,
 output scl_o,
 output scl_oe,
 input 	sda_i,
 output sda_o,
 output sda_oe 
 
);

localparam [31:0] HPD_TIMEOUT_COUNT = 32'd50000000; //hold HPD for 1s

wire clr_count;
wire [7:0]  edid_rdata;
wire        edid_w;
wire        edid_r;
wire [7:0] edid_addr;
wire [7:0] edid_wdata;
wire        edid_sda_oe;
wire        i2c_sda_in;

assign clr_count = ~hdmi_rx_5v_n ;
//============================================================
reg [31:0] hpd_count = 32'd0;
always @ (posedge cfg_clk or negedge rst_n)
begin
    if(!rst_n ) begin
        hpd_count <= 32'd0;
    end else begin
        if(clr_count) begin
            hpd_count <= 32'd0;
        end else begin
            if (hpd_count < HPD_TIMEOUT_COUNT) begin 
                hpd_count <= hpd_count + 32'd1;
            end
        end
    end
end
assign rx_hpd = hpd_count > (HPD_TIMEOUT_COUNT - 32'd1);
assign hdmi_rx_hpd_n = ~hdmi_rx_5v_n ? 1'b0 : rx_hpd;

I2Cslave #(
   .I2C_ADDR(7'b1010000)
) u_I2Cslave_edid (
   /* O */ .sda_out (),
   /* I */ .sda_in (sda_i),
   /* I */ .scl_in (scl_i), 
   /* O */ .sda_oe (sda_oe),
   /* I */ .rd_bus_7_0_in (edid_rdata),
   /* I */ .clk_in (cfg_clk ),
   /* I */ .clr_in (1'b0),
   /* O */ .subaddr_7_0_out (edid_addr),
   /* O */ .wr_bus_7_0_out (edid_wdata),
   /* O */ .wr_pulse_out (edid_w),
   /* O */ .rd_pulse_out (edid_r),
   /* O */ .rd_wr_out ()
);
//
//edid_ram u_edid_ram (
//   /* I */ .wren(edid_w),// ({edid_ram_write & ~edid_ram_write_r0}), //write data change after the first clock cycle of write, write pulse for 2 cycles, so need to limit write to 1 cycle
//   /* I */ .rden(1'b1),// (edid_ram_read_tmp),
//   /* I */ .clock (i2c_clk),
//   /* I */ .address (edid_addr),//(edid_ram_address_tmp),
//   /* I */ .data(edid_wdata),// (edid_ram_writedata),
//   /* O */ .q (edid_rdata)
//);

simple_dual_port_ram
#(
	.DATA_WIDTH	( 8				),
	.ADDR_WIDTH	( 9				),
	.OUTPUT_REG	( "FALSE"	),
	.RAM_INIT_FILE("./ram_init_file.inithex"  )//\source\hdmi_src\dvi_rx
)   u_simple_dual_port_ram
(
	/*i*/.wdata	(edid_wdata),
	/*i*/.waddr	(edid_addr), 
	/*i*/.raddr	(edid_addr),
	/*i*/.we		(edid_w), 
	/*i*/.wclk	(cfg_clk),
	/*i*/.re		(1'b1), 
	/*i*/.rclk	(cfg_clk),
	/*o*/.rdata (edid_rdata)
);



endmodule