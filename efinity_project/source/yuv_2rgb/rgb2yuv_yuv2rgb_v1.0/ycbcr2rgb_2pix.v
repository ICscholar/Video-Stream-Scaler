
module ycbcr2rgb_2pix #(
	parameter BIT_PER_SYMBLE = 8,
	parameter PIXCEL_NUM = 2
)(
input	wire		clk,
input	wire	[3*PIXCEL_NUM*BIT_PER_SYMBLE-1:0]	ycbcr_din,
input	wire	[PIXCEL_NUM-1:0]					ycbcr_h_sync,
input	wire	[PIXCEL_NUM-1:0]					ycbcr_v_sync,
input	wire	[PIXCEL_NUM-1:0]					ycbcr_de,

output	wire	[3*PIXCEL_NUM*BIT_PER_SYMBLE-1:0]	rgb_dout,
output	wire	[PIXCEL_NUM-1:0]  					rgb_h_sync,
output	wire	[PIXCEL_NUM-1:0]					rgb_v_sync,
output	wire	[PIXCEL_NUM-1:0]					rgb_de
);


user_ycbcr2rgb_hdtv #(
	.BIT_PER_SYMBLE (8)
)user_rgb2ycbcr_23_00(
	.clk			(clk),
	.ycbcr_din		(ycbcr_din[3*BIT_PER_SYMBLE-1:0]  ),
	.ycbcr_h_sync	(ycbcr_h_sync[0]  	),
	.ycbcr_v_sync	(ycbcr_v_sync[0] 	),
	.ycbcr_de		(ycbcr_de[0] 		),
	.rgb_dout		(rgb_dout[23:0]	),
	.rgb_h_sync		(rgb_h_sync[0]),
	.rgb_v_sync		(rgb_v_sync[0]),
	.rgb_de       	(rgb_de[0]    )
);
user_ycbcr2rgb_hdtv #(
	.BIT_PER_SYMBLE (8)
)user_rgb2ycbcr_47_24(
	.clk			(clk),
	.ycbcr_din		(ycbcr_din[47:24] ),
	.ycbcr_h_sync	(ycbcr_h_sync[1]  	),
	.ycbcr_v_sync	(ycbcr_v_sync[1] 	),
	.ycbcr_de		(ycbcr_de[1] 		),
	.rgb_dout		(rgb_dout[47:24]	),
	.rgb_h_sync		(rgb_h_sync[1]),
	.rgb_v_sync		(rgb_v_sync[1]),
	.rgb_de       	(rgb_de[1]    )
);

user_ycbcr2rgb_hdtv #(
	.BIT_PER_SYMBLE (8)
)user_rgb2ycbcr_63_48(
	.clk			(clk),
	.ycbcr_din		(ycbcr_din[71:48] ),
	.ycbcr_h_sync	(ycbcr_h_sync[1]  	),
	.ycbcr_v_sync	(ycbcr_v_sync[1] 	),
	.ycbcr_de		(ycbcr_de[1] 		),
	.rgb_dout		(rgb_dout[71:48]	),
	.rgb_h_sync		(rgb_h_sync[1]),
	.rgb_v_sync		(rgb_v_sync[1]),
	.rgb_de       	(rgb_de[1]    )
);

user_ycbcr2rgb_hdtv #(
	.BIT_PER_SYMBLE (8)
)user_rgb2ycbcr_95_64(
	.clk			(clk),
	.ycbcr_din		(ycbcr_din[95:72] ),
	.ycbcr_h_sync	(ycbcr_h_sync[1]  	),
	.ycbcr_v_sync	(ycbcr_v_sync[1] 	),
	.ycbcr_de		(ycbcr_de[1] 		),
	.rgb_dout		(rgb_dout[95:72]	),
	.rgb_h_sync		(rgb_h_sync[1]),
	.rgb_v_sync		(rgb_v_sync[1]),
	.rgb_de       	(rgb_de[1]    )
);


endmodule
