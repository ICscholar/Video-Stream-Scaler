
	module uart_manage#(
	parameter SUB_UART_ADDR = 0
	)(
	input clk, //clk == 27M 
	input [7:0] uart_bps,

	
	output [15:0] bps_cnt_data
	);
	
	//==========================================================================
	//band rate set,当数据传输完成后可以设置波特率
	//mind:数据计数是在27M的时钟下控制的
	//==========================================================================   
	reg [15:0] bps_cnt_data_r = 0;  
	always @( posedge clk )
	begin
		//	if( ) begin
					case( uart_bps[3:0] )//clk == 27M
					4'b0000:bps_cnt_data_r <=  45000	;				//(bps = 600    )( clk=27M )  27000000/600 =  45000
					4'b0001:bps_cnt_data_r <=  22500 ;       //(bps = 1200 	)( clk=27M )	 27000000/1200
					4'b0010:bps_cnt_data_r <=  15000;        //(bps = 1800 	)( clk=27M )
					4'b0011:bps_cnt_data_r <=  11250;        //(bps = 2400 	)( clk=27M )
					4'b0100:bps_cnt_data_r <=  7500;         //(bps = 3600  	)( clk=27M )
					4'b0101:bps_cnt_data_r <=  5625;         //(bps = 4800  	)( clk=27M )
					4'b0110:bps_cnt_data_r <=  3750;         //(bps = 7200  	)( clk=27M )
					4'b0111:bps_cnt_data_r <=  2812;         //(bps = 9600  	)( clk=27M )
					4'b1000:bps_cnt_data_r <=  1406;         //(bps = 19200 	)( clk=27M )
					4'b1001:bps_cnt_data_r <=  703;          //(bps = 38400  )( clk=27M )
					4'b1010:bps_cnt_data_r <=  1875;         //(bps = 14400  )( clk=27M )
					4'b1011:bps_cnt_data_r <=  937;          //(bps = 28800  )( clk=27M )
					4'b1100:bps_cnt_data_r <=  469;          //(bps = 57600  )( clk=27M )
					4'b1101:bps_cnt_data_r <=  352 ;         //(bps = 76800  )( clk=27M )
					4'b1110:bps_cnt_data_r <=  234;          //(bps = 115200 )( clk=27M )
					4'b1111:bps_cnt_data_r <=  117;          //(bps = 230400 )( clk=27M )
					default:;
					endcase
		//	end
	end      
	assign bps_cnt_data = bps_cnt_data_r;
	endmodule
	
