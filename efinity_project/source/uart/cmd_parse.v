
module cmd_parse#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)(
	input clk,
	output glob_irq,
	//global cmmand                 
	input [2:0] 							glob_cmd					,     
	input [10:0] 							glob_cmd_data  		, 
	input 										glob_cmd_en				,             
	output 	[10:0] 						glob_cmd_fb_data	,       
	input 										glob_cmd_fb_en		,       
	   
//sub uart cmd                  	
	input [1:0] 							sub_cmd							,     
	input [DATA_WIDTH-1:0] 		sub_cmd_data 				,     
	input  [3:0] 							sub_cmd_addr 				,   
	output [DATA_WIDTH:0] 		sub_cmd_fb_data			,       
	input 										sub_cmd_fb_en				,         
	input 										sub_cmd_en 					,            
	
	input [3:0] 						fifo_wr_addr,//FIFO控制，选择要写入的FIFO
	input [DATA_WIDTH-1:0] 	fifo_wr_data,
	input 									fifo_wr_en,
	output									fifo_wr_full,
	//FPGA TX FIFO
	input [3:0] 						fifo_rd_addr,
	output [DATA_WIDTH-1:0] fifo_rd_data,
	input 									fifo_rd_en,
	output 									fifo_rd_empty,
	
	output 						uart01_rx_en						 ,				
	output 						uart01_tx_en						 ,				
	output [7:0] 			uart01_bps 			 ,	
	output  					uart01_stop_bit_w ,		
	output 						uart01_checksum_en 	   ,
	output 	[1:0]			uart01_checksum_mode    , 
	output						iq_en01,      
	output						uart01_rst, 
	input		[4:0]			uart01_state ,
	input							iq01,  
	output	[DATA_WIDTH-1:0] uart01_fifo_wr_data,
	output 				uart01_fifo_wr_en,
	input [DATA_WIDTH-1:0] 		uart01_fifo_rd_data,
	output       		uart01_fifo_rd_en,
	
	output 				uart02_rx_en						 ,		
	output 				uart02_tx_en						 ,		
	output [7:0] 	uart02_bps 			 ,	          
	output 		 	uart02_stop_bit_w ,		        
	output 				uart02_checksum_en 	   ,      
	output 	[1:0]			uart02_checksum_mode    , 
	output				iq_en02,			    
	output				uart02_rst, 
	input		[4:0]	uart02_state , 
	input				iq02,   
	output	[DATA_WIDTH-1:0] uart02_fifo_wr_data,  
	output 				uart02_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart02_fifo_rd_data,
	output       		uart02_fifo_rd_en,
	   
	output 				uart03_rx_en						 ,		
	output 				uart03_tx_en						 ,		
	output [7:0] 	uart03_bps 			 ,	          
	output  	uart03_stop_bit_w ,		        
	output 				uart03_checksum_en 	   ,      
	output 	[1:0]			uart03_checksum_mode    ,     
	output				iq_en03,  
	output				uart03_rst,
	input		[4:0]	uart03_state , 
	input				iq03, 
	output	[DATA_WIDTH-1:0] uart03_fifo_wr_data,  
	output 				uart03_fifo_wr_en,   
	input [DATA_WIDTH-1:0] 		uart03_fifo_rd_data,
	output       		uart03_fifo_rd_en, 
	
	output 				uart04_rx_en						 ,		
	output 				uart04_tx_en						 ,		
	output [7:0] 	uart04_bps 			 ,	          
	output  	uart04_stop_bit_w ,		        
	output 				uart04_checksum_en 	   ,      
	output [1:0]	uart04_checksum_mode    ,     
	output				iq_en04,  
	output				uart04_rst,
	input		[4:0]	uart04_state , 
	input				iq04,  
	output	[DATA_WIDTH-1:0] uart04_fifo_wr_data,  
	output 				uart04_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart04_fifo_rd_data,
	output       		uart04_fifo_rd_en,
	   
	output 				uart05_rx_en						 ,		
	output 				uart05_tx_en						 ,		
	output [7:0] 	uart05_bps 			 ,	          
	output 	uart05_stop_bit_w ,		        
	output 				uart05_checksum_en 	   ,      
	output 	[1:0]			uart05_checksum_mode    ,     
	output				iq_en05,
	output				uart05_rst, 
	input		[4:0]	uart05_state ,  
	input				iq05,   
	output	[DATA_WIDTH-1:0] uart05_fifo_wr_data,  
	output 				uart05_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart05_fifo_rd_data,
	output       		uart05_fifo_rd_en,
	   
	output 				uart06_rx_en						 ,		
	output 				uart06_tx_en						 ,		
	output [7:0] 	uart06_bps 			 ,	          
	output  	uart06_stop_bit_w ,		        
	output 				uart06_checksum_en 	   ,      
	output 	[1:0]			uart06_checksum_mode    ,    
	output				iq_en06,
	output				uart06_rst, 
	input		[4:0]	uart06_state ,  
	input				iq06, 
	output	[DATA_WIDTH-1:0] uart06_fifo_wr_data,  
	output 				uart06_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart06_fifo_rd_data,
	output       		uart06_fifo_rd_en,  
	 
	output 				uart07_rx_en						 ,		
	output 				uart07_tx_en						 ,		
	output [7:0] 	uart07_bps 			 ,	          
	output  	uart07_stop_bit_w ,		        
	output 				uart07_checksum_en 	   ,      
	output 	[1:0]			uart07_checksum_mode    ,     
	output				iq_en07,
	output				uart07_rst, 
	input		[4:0]	uart07_state ,  
	input				iq07,  
	output	[DATA_WIDTH-1:0] uart07_fifo_wr_data,  
	output 				uart07_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart07_fifo_rd_data,
	output       		uart07_fifo_rd_en,
	   
	output 				uart08_rx_en						 ,		
	output 				uart08_tx_en						 ,		
	output [7:0] 	uart08_bps 			 ,	          
	output  	uart08_stop_bit_w ,		        
	output 				uart08_checksum_en 	   ,      
	output 	[1:0]			uart08_checksum_mode    ,      
	output				iq_en08,
	output				uart08_rst, 
	input		[4:0]	uart08_state ,  
	input				iq08,   
	output	[DATA_WIDTH-1:0] uart08_fifo_wr_data,  
	output 				uart08_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart08_fifo_rd_data,
	output       		uart08_fifo_rd_en,
	   
	output 				uart09_rx_en						 ,		
	output 				uart09_tx_en						 ,		
	output [7:0] 	uart09_bps 			 ,	          
	output  	uart09_stop_bit_w ,		        
	output 				uart09_checksum_en 	   ,      
	output 	[1:0]			uart09_checksum_mode    ,     
	output				iq_en09,
	output				uart09_rst, 
	input		[4:0]	uart09_state , 
	input				iq09,  
	output	[DATA_WIDTH-1:0] uart09_fifo_wr_data,  
	output 				uart09_fifo_wr_en, 
	input [DATA_WIDTH-1:0] 		uart09_fifo_rd_data,
	output       		uart09_fifo_rd_en,
	    
	output 				uart10_rx_en						 ,		
	output 				uart10_tx_en						 ,		
	output [7:0] 	uart10_bps 			 ,	          
	output  	uart10_stop_bit_w ,		        
	output 				uart10_checksum_en 	   ,      
	output 	[1:0]			uart10_checksum_mode    ,     
	output				iq_en10,
	output				uart10_rst, 
	input		[4:0]	uart10_state ,  
	input				iq10,
	output	[DATA_WIDTH-1:0] uart10_fifo_wr_data,  
  output 				uart10_fifo_wr_en,  
  input [DATA_WIDTH-1:0] 		uart10_fifo_rd_data,
  output       		uart10_fifo_rd_en,
   
	output 				uart11_rx_en						 ,		
	output 				uart11_tx_en						 ,		
	output [7:0] 	uart11_bps 			 ,	          
	output  	uart11_stop_bit_w ,		        
	output 				uart11_checksum_en 	   ,      
	output 	[1:0]			uart11_checksum_mode    ,   
	output				iq_en11  ,
	output				uart11_rst, 
	input		[4:0]	uart11_state ,
	input				iq11 ,
	output	[DATA_WIDTH-1:0] uart11_fifo_wr_data,  
	output 				uart11_fifo_wr_en,
	input [DATA_WIDTH-1:0] 		uart11_fifo_rd_data,    
  output       		uart11_fifo_rd_en,
  
  
  input  uart01_fifo_wr_full	, 
	input  uart01_fifo_rd_empty	, 
	input  uart02_fifo_wr_full	, 
	input  uart02_fifo_rd_empty	, 
	input  uart03_fifo_wr_full	, 
	input  uart03_fifo_rd_empty	, 
	input  uart04_fifo_wr_full	, 
	input  uart04_fifo_rd_empty	, 
	input  uart05_fifo_wr_full	, 
	input  uart05_fifo_rd_empty	, 
	input  uart06_fifo_wr_full	, 
	input  uart06_fifo_rd_empty	, 
	input  uart07_fifo_wr_full	, 
	input  uart07_fifo_rd_empty	, 
	input  uart08_fifo_wr_full	, 
	input  uart08_fifo_rd_empty	, 
	input  uart09_fifo_wr_full	, 
	input  uart09_fifo_rd_empty	, 
	input  uart10_fifo_wr_full	, 
	input  uart10_fifo_rd_empty	, 
	input  uart11_fifo_wr_full	, 
	input  uart11_fifo_rd_empty	 

);

   reg iq_en01_r = 0;
   reg iq_en02_r = 0;
   reg iq_en03_r = 0;
   reg iq_en04_r = 0;
   reg iq_en05_r = 0;
   reg iq_en06_r = 0;
   reg iq_en07_r = 0;
   reg iq_en08_r = 0;
   reg iq_en09_r = 0;
   reg iq_en10_r = 0;
   reg iq_en11_r = 0; 
   
   reg uart11_rst_r = 0;
   reg uart10_rst_r = 0;
   reg uart09_rst_r = 0;
   reg uart08_rst_r = 0;
   reg uart07_rst_r = 0;
   reg uart06_rst_r = 0;
   reg uart05_rst_r = 0;
   reg uart04_rst_r = 0;
   reg uart03_rst_r = 0;
   reg uart02_rst_r = 0;
   reg uart01_rst_r = 0;
     
   
   reg [10:0] glob_cmd_fb_data_r = 0; 
   reg [DATA_WIDTH-1:0] sub_cmd_fb_data_r = 0;
	//==============================================================
	//glob cmd process
	//==============================================================
	assign glob_cmd_fb_data = glob_cmd_fb_data_r;
	always @( posedge clk )
	begin
			if( glob_cmd_fb_en) begin
				case(glob_cmd)
				3'b000 :
						glob_cmd_fb_data_r <= {iq_en11_r,iq_en10_r,iq_en09_r,iq_en08_r,iq_en07_r,iq_en06_r,iq_en05_r,iq_en04_r,iq_en03_r,iq_en02_r,iq_en01_r};
				3'b001 ://子串口中断高电平有效
						glob_cmd_fb_data_r <= {iq11,iq10,iq09,iq08,iq07,iq06,iq05,iq04,iq03,iq02,iq01};
				3'b010 :
						glob_cmd_fb_data_r <= {2'b10,3'b001,3'b000,3'b000};//固定值[10:9]	主版本号[8:6]	次版本号[5:3]	修订版本号[2:0]
				default :	glob_cmd_fb_data_r <= 16'd0;
				endcase
			end
			
	end
	reg glob_irq_r ;
	always @( posedge clk )
	begin
		 glob_irq_r <= |{iq11,iq10,iq09,iq08,iq07,iq06,iq05,iq04,iq03,iq02,iq01};
	end
	assign glob_irq = ~glob_irq_r;//全局中断低电平有效
	always @( posedge clk )
	begin
			if( glob_cmd_en ) begin
				case(glob_cmd )
						3'b000 :begin //串口全局中断使能（GLOBAL_IRQ_ENABLE_CMD）
								iq_en11_r <= glob_cmd_data[10];
								iq_en10_r <= glob_cmd_data[9]; 
								iq_en09_r <= glob_cmd_data[8]; 
								iq_en08_r <= glob_cmd_data[7]; 
								iq_en07_r <= glob_cmd_data[6]; 
								iq_en06_r <= glob_cmd_data[5]; 
								iq_en05_r <= glob_cmd_data[4]; 
								iq_en04_r <= glob_cmd_data[3]; 
								iq_en03_r <= glob_cmd_data[2]; 
								iq_en02_r <= glob_cmd_data[1]; 
								iq_en01_r <= glob_cmd_data[0];  
								end
				default:;
				endcase
			end
			
	end
	always @( posedge clk )
	begin
			if( glob_cmd_en ) begin
				case(glob_cmd )
						3'b010 :begin // 全局子串口复位（GLOBAL_RESTART_CMD）
								/*asset high*/
								uart11_rst_r <= glob_cmd_data[10]; 
								uart10_rst_r <= glob_cmd_data[9];
								uart09_rst_r <= glob_cmd_data[8];
								uart08_rst_r <= glob_cmd_data[7];
								uart07_rst_r <= glob_cmd_data[6];
								uart06_rst_r <= glob_cmd_data[5];
								uart05_rst_r <= glob_cmd_data[4];
								uart04_rst_r <= glob_cmd_data[3];
								uart03_rst_r <= glob_cmd_data[2];
								uart02_rst_r <= glob_cmd_data[1];
								uart01_rst_r <= glob_cmd_data[0];
								end
				default:begin // 全局子串口复位（GLOBAL_RESTART_CMD）
								/*asset high*/
								uart11_rst_r <= 0; 
								uart10_rst_r <= 0;
								uart09_rst_r <= 0;
								uart08_rst_r <= 0;
								uart07_rst_r <= 0;
								uart06_rst_r <= 0;
								uart05_rst_r <= 0;
								uart04_rst_r <= 0;
								uart03_rst_r <= 0;
								uart02_rst_r <= 0;
								uart01_rst_r <= 0;
								end
				endcase
			end
			
	end
	
	
	assign iq_en01 = iq_en01_r ;
	assign iq_en02 = iq_en02_r ;
	assign iq_en03 = iq_en03_r ;
	assign iq_en04 = iq_en04_r ;
	assign iq_en05 = iq_en05_r ;
	assign iq_en06 = iq_en06_r ;
	assign iq_en07 = iq_en07_r ;
	assign iq_en08 = iq_en08_r ;
	assign iq_en09 = iq_en09_r ;
	assign iq_en10 = iq_en10_r ;
	assign iq_en11 = iq_en11_r ;
	
	assign uart01_rst = uart01_rst_r;
	assign uart02_rst = uart02_rst_r;
	assign uart03_rst = uart03_rst_r;
	assign uart04_rst = uart04_rst_r;
	assign uart05_rst = uart05_rst_r;
	assign uart06_rst = uart06_rst_r;
	assign uart07_rst = uart07_rst_r;
	assign uart08_rst = uart08_rst_r;
	assign uart09_rst = uart09_rst_r;
	assign uart10_rst = uart10_rst_r;
	assign uart11_rst = uart11_rst_r;
	
 
	//==============================================================
	//sub cmd process
	//============================================================== 
	assign sub_cmd_fb_data = sub_cmd_fb_data_r;
//	reg [DATA_WIDTH-1:0] sub_cmd_data_r = 0;
	reg sub_cmd_en_r = 0;
//	always @( posedge clk )
//	begin
//			case( {sub_cmd_addr,sub_cmd} )
//			6'b0000_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart01_state[4:0],sub_cmd_data[1:0]};
//			6'b0001_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart02_state[4:0],sub_cmd_data[1:0]};
//			6'b0010_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart03_state[4:0],sub_cmd_data[1:0]}; 
//			6'b0011_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart04_state[4:0],sub_cmd_data[1:0]};  
//			6'b0100_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart05_state[4:0],sub_cmd_data[1:0]}; 
//			6'b0101_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart06_state[4:0],sub_cmd_data[1:0]};  
//			6'b0110_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart07_state[4:0],sub_cmd_data[1:0]}; 		
//			6'b0111_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart08_state[4:0],sub_cmd_data[1:0]}; 
//			6'b1000_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart09_state[4:0],sub_cmd_data[1:0]}; 
//			6'b1001_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart10_state[4:0],sub_cmd_data[1:0]}; 
//			6'b1010_00 : sub_cmd_data_r <= {{~fifo_rd_empty_r},uart11_state[4:0],sub_cmd_data[1:0]}; 
//			default : sub_cmd_data_r <=  sub_cmd_data;
//			endcase
//	end
	
	always @( posedge clk )
	begin
			sub_cmd_en_r <= sub_cmd_en;
	end


	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Port A 
	always @ (posedge clk)
	begin
		if (sub_cmd_en_r) 
		begin
			
			ram[{sub_cmd_addr,sub_cmd}] <= sub_cmd_data;

		end
	end 
	always @ (posedge clk)
	begin
	 if( sub_cmd_fb_en )
		begin
//			sub_cmd_fb_data_r <= ram[{sub_cmd_addr,sub_cmd}];
					case( {sub_cmd_addr,sub_cmd} )//不需要把数据存在ROM，这样可以保证读取的数据就是当前的状态
			6'b0000_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart01_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]};
			6'b0001_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart02_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]};
			6'b0010_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart03_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			6'b0011_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart04_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]};  
			6'b0100_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart05_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			6'b0101_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart06_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]};  
			6'b0110_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart07_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 		
			6'b0111_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart08_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			6'b1000_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart09_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			6'b1001_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart10_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			6'b1010_00 : sub_cmd_fb_data_r <= {{~fifo_rd_empty_r[0]},uart11_state[4:0], ram[{sub_cmd_addr,sub_cmd}][1:0]}; 
			default : sub_cmd_fb_data_r <=  ram[{sub_cmd_addr,sub_cmd}];
			endcase
		end 
	end 

	assign uart01_rx_en 				= ram[0][0] ; 
	assign uart01_tx_en 				= ram[0][1];
	assign uart01_bps 					= ram[1];
	assign uart01_stop_bit_w 		= ram[2][7];
	assign uart01_checksum_en 	= ram[2][6];
	assign uart01_checksum_mode = ram[2][5:4];
	//3
	assign uart02_rx_en = ram[4][0] ; 
	assign uart02_tx_en = ram[4][1];
	assign uart02_bps 	= ram[5];
	assign uart02_stop_bit_w 		= ram[6][7];
	assign uart02_checksum_en 	= ram[6][6];
	assign uart02_checksum_mode = ram[6][5:4];
	//7
	assign uart03_rx_en 	=  ram[8][0] ; 
	assign uart03_tx_en 	= ram[8][1];
	assign uart03_bps 		= ram[9];
	assign uart03_stop_bit_w 		= ram[10][7];
	assign uart03_checksum_en 	= ram[10][6];
	assign uart03_checksum_mode = ram[10][5:4];
	//11
	
	assign uart04_rx_en =  ram[12][0] ; 
	assign uart04_tx_en =  ram[12][1];
	assign uart04_bps = ram[13];
	assign uart04_stop_bit_w =  	ram[14][7];
	assign uart04_checksum_en = 	ram[14][6];
	assign uart04_checksum_mode = ram[14][5:4];
	//15
	assign uart05_rx_en =  ram[16][0] ; 
	assign uart05_tx_en =  ram[16][1];
	assign uart05_bps = ram[17];
	assign uart05_stop_bit_w =  	ram[18][7];
	assign uart05_checksum_en = 	ram[18][6];
	assign uart05_checksum_mode = ram[18][5:4];
	//19
	assign uart06_rx_en =  ram[20][0] ; 
	assign uart06_tx_en =  ram[20][1];
	assign uart06_bps = ram[21];
	assign uart06_stop_bit_w =  	ram[22][7];
	assign uart06_checksum_en = 	ram[22][6];
	assign uart06_checksum_mode = ram[22][5:4];
	//23
	assign uart07_rx_en =  ram[24][0] ; 
	assign uart07_tx_en =  ram[24][1];
	assign uart07_bps = ram[25];
	assign uart07_stop_bit_w =  	ram[26][7];
	assign uart07_checksum_en = 	ram[26][6];
	assign uart07_checksum_mode = ram[26][5:4];
	//27
	assign uart08_rx_en =  ram[28][0] ; 
	assign uart08_tx_en =  ram[28][1];
	assign uart08_bps = ram[29];
	assign uart08_stop_bit_w =  	ram[30][7];
	assign uart08_checksum_en = 	ram[30][6];
	assign uart08_checksum_mode = ram[30][5:4];
	//31
	assign uart09_rx_en =  ram[32][0] ; 
	assign uart09_tx_en =  ram[32][1];
	assign uart09_bps = ram[33];
	assign uart09_stop_bit_w =  	ram[34][7];
	assign uart09_checksum_en = 	ram[34][6];
	assign uart09_checksum_mode = ram[34][5:4];
	//35
	assign uart10_rx_en =  ram[36][0] ; 
	assign uart10_tx_en =  ram[36][1];
	assign uart10_bps = ram[37];
	assign uart10_stop_bit_w =  	ram[38][7];
	assign uart10_checksum_en = 	ram[38][6];
	assign uart10_checksum_mode = ram[38][5:4];
	//39
	assign uart11_rx_en =  ram[40][0] ; 
	assign uart11_tx_en =  ram[40][1];
	assign uart11_bps = ram[41];
	assign uart11_stop_bit_w =  	ram[42][7];
	assign uart11_checksum_en = 	ram[42][6];
	assign uart11_checksum_mode = ram[42][5:4];
	//43
//========================================================================	
// wr fifo process 
//把SPI的数据转给相应的UART
//fifo_wr_addr:选择相应的UART FIFO,使能FIFO写
//========================================================================
reg [7: 0] fifo_wr_data01_r = 0;
reg [7: 0] fifo_wr_data02_r = 0;
reg [7: 0] fifo_wr_data03_r = 0;
reg [7: 0] fifo_wr_data04_r = 0;
reg [7: 0] fifo_wr_data05_r = 0;
reg [7: 0] fifo_wr_data06_r = 0;
reg [7: 0] fifo_wr_data07_r = 0;
reg [7: 0] fifo_wr_data08_r = 0;
reg [7: 0] fifo_wr_data09_r = 0;
reg [7: 0] fifo_wr_data10_r = 0;
reg [7: 0] fifo_wr_data11_r = 0;
reg fifo_wr_en01_r = 0;
reg fifo_wr_en02_r = 0;
reg fifo_wr_en03_r = 0;
reg fifo_wr_en04_r = 0;
reg fifo_wr_en05_r = 0;
reg fifo_wr_en06_r = 0;
reg fifo_wr_en07_r = 0;
reg fifo_wr_en08_r = 0;
reg fifo_wr_en09_r = 0;
reg fifo_wr_en10_r = 0;
reg fifo_wr_en11_r = 0; 

reg fifo_wr_full_r  =0;


   always @( posedge clk )
   begin
   	fifo_wr_data01_r <= fifo_wr_data;
   	fifo_wr_data02_r <= fifo_wr_data;
   	fifo_wr_data03_r <= fifo_wr_data;
   	fifo_wr_data04_r <= fifo_wr_data;
   	fifo_wr_data05_r <= fifo_wr_data;
   	fifo_wr_data06_r <= fifo_wr_data;
   	fifo_wr_data07_r <= fifo_wr_data;
   	fifo_wr_data08_r <= fifo_wr_data;
   	fifo_wr_data09_r <= fifo_wr_data;
   	fifo_wr_data10_r <= fifo_wr_data;
   	fifo_wr_data11_r <= fifo_wr_data;
   end
   
	always @( posedge clk )
	begin
		case( fifo_wr_addr )
		4'b0000 :begin
						 fifo_wr_en01_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart01_fifo_wr_full;
						 end
		4'b0001 :begin
						 fifo_wr_en02_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart02_fifo_wr_full;
						 end
		4'b0010 :begin
						 fifo_wr_en03_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart03_fifo_wr_full;
						 end
		4'b0011 :begin
						 fifo_wr_en04_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart04_fifo_wr_full;
						 end
		4'b0100 :begin
						 fifo_wr_en05_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart05_fifo_wr_full;
						 end
		4'b0101 :begin
						 fifo_wr_en06_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart06_fifo_wr_full;
						 end
		4'b0110 :begin
						 fifo_wr_en07_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart07_fifo_wr_full;
						 end
		4'b0111 :begin
						 fifo_wr_en08_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart08_fifo_wr_full;
						 end
		4'b1000 :begin
						 fifo_wr_en09_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart09_fifo_wr_full;
						 end
		4'b1001 :begin
						 fifo_wr_en10_r <= fifo_wr_en; 
						 fifo_wr_full_r <= uart10_fifo_wr_full;
						 end
		4'b1010 :begin
						 fifo_wr_en11_r <= fifo_wr_en;
						 fifo_wr_full_r <= uart11_fifo_wr_full;
						 end
		default:;
		endcase
		
	end
	assign uart01_fifo_wr_data =  fifo_wr_data01_r;
	assign uart02_fifo_wr_data =  fifo_wr_data02_r;
	assign uart03_fifo_wr_data =  fifo_wr_data03_r;
	assign uart04_fifo_wr_data =  fifo_wr_data04_r;
	assign uart05_fifo_wr_data =  fifo_wr_data05_r;
	assign uart06_fifo_wr_data =  fifo_wr_data06_r;
	assign uart07_fifo_wr_data =  fifo_wr_data07_r;
	assign uart08_fifo_wr_data =  fifo_wr_data08_r;
	assign uart09_fifo_wr_data =  fifo_wr_data09_r;
	assign uart10_fifo_wr_data =  fifo_wr_data10_r;
	assign uart11_fifo_wr_data =  fifo_wr_data11_r;

  assign uart01_fifo_wr_en = fifo_wr_en01_r; 
  assign uart02_fifo_wr_en = fifo_wr_en02_r;
  assign uart03_fifo_wr_en = fifo_wr_en03_r;
  assign uart04_fifo_wr_en = fifo_wr_en04_r;
  assign uart05_fifo_wr_en = fifo_wr_en05_r;
  assign uart06_fifo_wr_en = fifo_wr_en06_r;
  assign uart07_fifo_wr_en = fifo_wr_en07_r;
  assign uart08_fifo_wr_en = fifo_wr_en08_r;
  assign uart09_fifo_wr_en = fifo_wr_en09_r;
  assign uart10_fifo_wr_en = fifo_wr_en10_r;
  assign uart11_fifo_wr_en = fifo_wr_en11_r;  
  
  assign fifo_wr_full = fifo_wr_full_r;
 //===========================================================================
 //rd fifo process
 //===========================================================================  
 	reg fifo_rd_en01_r = 0;
	reg fifo_rd_en02_r = 0;
	reg fifo_rd_en03_r = 0;
	reg fifo_rd_en04_r = 0;
	reg fifo_rd_en05_r = 0;
	reg fifo_rd_en06_r = 0;
	reg fifo_rd_en07_r = 0;
	reg fifo_rd_en08_r = 0;
	reg fifo_rd_en09_r = 0;
	reg fifo_rd_en10_r = 0;
	reg fifo_rd_en11_r = 0;
	reg [7:0] fifo_rd_data_r = 0;

	always @( posedge clk )
	begin
		case( fifo_rd_addr )
		4'b0000 : fifo_rd_en01_r <= fifo_rd_en;
		4'b0001 : fifo_rd_en02_r <= fifo_rd_en;
		4'b0010 : fifo_rd_en03_r <= fifo_rd_en;
		4'b0011 : fifo_rd_en04_r <= fifo_rd_en;
		4'b0100 : fifo_rd_en05_r <= fifo_rd_en;
		4'b0101 : fifo_rd_en06_r <= fifo_rd_en;
		4'b0110 : fifo_rd_en07_r <= fifo_rd_en;
		4'b0111 : fifo_rd_en08_r <= fifo_rd_en;
		4'b1000 : fifo_rd_en09_r <= fifo_rd_en;
		4'b1001 : fifo_rd_en10_r <= fifo_rd_en;
		4'b1010 : fifo_rd_en11_r <= fifo_rd_en;
		default:;
		endcase
		
	end
//	reg [1:0] uart01_fifo_rd_empty_r = 0;
//	reg [1:0] uart02_fifo_rd_empty_r = 0;
//	reg [1:0] uart03_fifo_rd_empty_r = 0;
//	reg [1:0] uart04_fifo_rd_empty_r = 0;
//	reg [1:0] uart05_fifo_rd_empty_r = 0;
//	reg [1:0] uart06_fifo_rd_empty_r = 0;
//	reg [1:0] uart07_fifo_rd_empty_r = 0;
//	reg [1:0] uart08_fifo_rd_empty_r = 0;
//	reg [1:0] uart09_fifo_rd_empty_r = 0;
//	reg [1:0] uart10_fifo_rd_empty_r = 0;
//	reg [1:0] uart11_fifo_rd_empty_r = 0;
//	always @( posedge clk )
//	begin
//			uart01_fifo_rd_empty_r <= {uart01_fifo_rd_empty_r[0],uart01_fifo_rd_empty};   
//			uart02_fifo_rd_empty_r <= {uart02_fifo_rd_empty_r[0],uart02_fifo_rd_empty};
//			uart03_fifo_rd_empty_r <= {uart03_fifo_rd_empty_r[0],uart03_fifo_rd_empty};   
//			uart04_fifo_rd_empty_r <= {uart04_fifo_rd_empty_r[0],uart04_fifo_rd_empty};   
//			uart05_fifo_rd_empty_r <= {uart05_fifo_rd_empty_r[0],uart05_fifo_rd_empty};   
//			uart06_fifo_rd_empty_r <= {uart06_fifo_rd_empty_r[0],uart06_fifo_rd_empty};   
//			uart07_fifo_rd_empty_r <= {uart07_fifo_rd_empty_r[0],uart07_fifo_rd_empty};   
//			uart08_fifo_rd_empty_r <= {uart08_fifo_rd_empty_r[0],uart08_fifo_rd_empty};   
//			uart09_fifo_rd_empty_r <= {uart09_fifo_rd_empty_r[0],uart09_fifo_rd_empty};      
//			uart10_fifo_rd_empty_r <= {uart10_fifo_rd_empty_r[0],uart10_fifo_rd_empty};   
//			uart11_fifo_rd_empty_r <= {uart11_fifo_rd_empty_r[0],uart11_fifo_rd_empty};   
//			
//	end
	
	reg [1:0] fifo_rd_empty_r = 0;

	always @( posedge clk )
	begin
		case( fifo_rd_addr )
		4'b0000 :begin  
								fifo_rd_data_r <= uart01_fifo_rd_data; 
								fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart01_fifo_rd_empty};
						end
		4'b0001 :begin  
								fifo_rd_data_r <= uart02_fifo_rd_data; 
								fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart02_fifo_rd_empty};
							end
		4'b0010 :begin  
								fifo_rd_data_r <= uart03_fifo_rd_data;  
								fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart03_fifo_rd_empty};
								
							end
		4'b0011 :begin  
								fifo_rd_data_r <= uart04_fifo_rd_data;
								fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart04_fifo_rd_empty};
								
						 end
		4'b0100 :begin
						  fifo_rd_data_r <= uart05_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart05_fifo_rd_empty};
						  
						  end
		4'b0101 :begin
						  fifo_rd_data_r <= uart06_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart06_fifo_rd_empty};
						  
						  end
		4'b0110 :begin
						  fifo_rd_data_r <= uart07_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart07_fifo_rd_empty};
						  
						  end
		4'b0111 :begin
						  fifo_rd_data_r <= uart08_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart08_fifo_rd_empty};
						  
						   end
		4'b1000 :begin
						  fifo_rd_data_r <= uart09_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart09_fifo_rd_empty};
						  
						   end
		4'b1001 :begin
						  fifo_rd_data_r <= uart10_fifo_rd_data;
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart10_fifo_rd_empty};
						  
						  end
		4'b1010 :begin
						  fifo_rd_data_r <= uart11_fifo_rd_data; 
						  fifo_rd_empty_r <= {fifo_rd_empty_r[0],uart11_fifo_rd_empty};
						   end
		default:;
		endcase
	end

	assign fifo_rd_data = fifo_rd_data_r; 
	assign uart01_fifo_rd_en = fifo_rd_en01_r;
	assign uart02_fifo_rd_en = fifo_rd_en02_r;
	assign uart03_fifo_rd_en = fifo_rd_en03_r;
	assign uart04_fifo_rd_en = fifo_rd_en04_r;
	assign uart05_fifo_rd_en = fifo_rd_en05_r;
	assign uart06_fifo_rd_en = fifo_rd_en06_r;
	assign uart07_fifo_rd_en = fifo_rd_en07_r;
	assign uart08_fifo_rd_en = fifo_rd_en08_r;
	assign uart09_fifo_rd_en = fifo_rd_en09_r;
	assign uart10_fifo_rd_en = fifo_rd_en10_r;
	assign uart11_fifo_rd_en = fifo_rd_en11_r;  
	
	assign fifo_rd_empty = fifo_rd_empty_r[1];
	
endmodule