
module user_ycbcr2rgb_top(
input	wire			ch0_clk			,
input	wire			ch1_clk			,
input	wire			ch2_clk			,
input	wire			ch3_clk			,

input	wire	[47:0]	ch0_ycbcr_din	,	
input	wire	[1:0]	ch0_ycbcr_h_sync,	
input	wire	[1:0]	ch0_ycbcr_v_sync,	
input	wire	[1:0]	ch0_ycbcr_de    ,  
input	wire	[47:0]	ch1_ycbcr_din	,	
input	wire	[1:0]	ch1_ycbcr_h_sync,	
input	wire	[1:0]	ch1_ycbcr_v_sync,	
input	wire	[1:0]	ch1_ycbcr_de    ,  
input	wire	[47:0]	ch2_ycbcr_din	,	
input	wire	[1:0]	ch2_ycbcr_h_sync,	
input	wire	[1:0]	ch2_ycbcr_v_sync,	
input	wire	[1:0]	ch2_ycbcr_de    ,  
input	wire	[47:0]	ch3_ycbcr_din	,	
input	wire	[1:0]	ch3_ycbcr_h_sync,	
input	wire	[1:0]	ch3_ycbcr_v_sync,	
input	wire	[1:0]	ch3_ycbcr_de    , 

output	wire	[47:0]	ch0_rgb_dout	,
output	wire	[1:0]	ch0_rgb_h_sync	,	
output	wire	[1:0]	ch0_rgb_v_sync	,	
output	wire	[1:0]	ch0_rgb_de		,
output	wire	[47:0]	ch1_rgb_dout	,
output	wire	[1:0]	ch1_rgb_h_sync	,
output	wire	[1:0]	ch1_rgb_v_sync	,
output	wire	[1:0]	ch1_rgb_de		,
output	wire	[47:0]	ch2_rgb_dout	,
output	wire	[1:0]	ch2_rgb_h_sync	,
output	wire	[1:0]	ch2_rgb_v_sync	,
output	wire	[1:0]	ch2_rgb_de		,
output	wire	[47:0]	ch3_rgb_dout	,
output	wire	[1:0]	ch3_rgb_h_sync	,
output	wire	[1:0]	ch3_rgb_v_sync	,
output	wire	[1:0]	ch3_rgb_de		


);


ycbcr2rgb_2pix #(
	.BIT_PER_SYMBLE( 8),
	.PIXCEL_NUM( 2)
)u0_ycbcr2rgb_2pix(
	.clk			(ch0_clk			),
	.ycbcr_din		(ch0_ycbcr_din		),
	.ycbcr_h_sync	(ch0_ycbcr_h_sync	),
	.ycbcr_v_sync	(ch0_ycbcr_v_sync	),
	.ycbcr_de		(ch0_ycbcr_de		),
	.rgb_dout		(ch0_rgb_dout		),
	.rgb_h_sync		(ch0_rgb_h_sync		),
	.rgb_v_sync		(ch0_rgb_v_sync		),
	.rgb_de       	(ch0_rgb_de       	)
);		

ycbcr2rgb_2pix #(
	.BIT_PER_SYMBLE( 8),
	.PIXCEL_NUM( 2)
)u1_ycbcr2rgb_2pix(
	.clk			(ch1_clk			),
	.ycbcr_din		(ch1_ycbcr_din		),
	.ycbcr_h_sync	(ch1_ycbcr_h_sync	),
	.ycbcr_v_sync	(ch1_ycbcr_v_sync	),
	.ycbcr_de		(ch1_ycbcr_de		),
	.rgb_dout		(ch1_rgb_dout		),
	.rgb_h_sync		(ch1_rgb_h_sync		),
	.rgb_v_sync		(ch1_rgb_v_sync		),
	.rgb_de       	(ch1_rgb_de       	)
);		

ycbcr2rgb_2pix #(
	.BIT_PER_SYMBLE( 8),
	.PIXCEL_NUM( 2)
)u2_ycbcr2rgb_2pix(
	.clk			(ch2_clk			),
	.ycbcr_din		(ch2_ycbcr_din		),
	.ycbcr_h_sync	(ch2_ycbcr_h_sync	),
	.ycbcr_v_sync	(ch2_ycbcr_v_sync	),
	.ycbcr_de		(ch2_ycbcr_de		),
	.rgb_dout		(ch2_rgb_dout		),
	.rgb_h_sync		(ch2_rgb_h_sync		),
	.rgb_v_sync		(ch2_rgb_v_sync		),
	.rgb_de       	(ch2_rgb_de       	)
);		

ycbcr2rgb_2pix #(
	.BIT_PER_SYMBLE( 8),
	.PIXCEL_NUM( 2)
)u3_ycbcr2rgb_2pix(
	.clk			(ch3_clk			),
	.ycbcr_din		(ch3_ycbcr_din		),
	.ycbcr_h_sync	(ch3_ycbcr_h_sync	),
	.ycbcr_v_sync	(ch3_ycbcr_v_sync	),
	.ycbcr_de		(ch3_ycbcr_de		),
	.rgb_dout		(ch3_rgb_dout		),
	.rgb_h_sync		(ch3_rgb_h_sync		),
	.rgb_v_sync		(ch3_rgb_v_sync		),
	.rgb_de       	(ch3_rgb_de       	)
);		





endmodule
