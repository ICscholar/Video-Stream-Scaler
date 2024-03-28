/*
1.输入数据节拍，DE_IN为高时,依次输出16bit
Cb0Y0,Cr0Y1,Cb1Y2,Cr1Y3,....Cb159Y638,Cr169Y639
2.YCbCr422 to YCbCr444

（ 1） 寄存 cb0、 Y0
（ 2） 寄存 cr0、 Y1
（ 3） 输出 Y0、 cb0、 cr0， 寄存 cb1、 Y2
（ 4） 输出 Y1、 cb0、 cr0， 寄存 cr1、 Y3
（ 5） 输出 Y2、 cb1、 cr1， 寄存 cb0、 Y0
（ 6） 输出 Y3、 cb1、 cr1， 寄存 cr0、 Y1
（ 7） ……
*/


module yuv422_2_ycbcr444(
  input         rst_n    ,   
  input         clk     ,
           
  input         i_v_sync ,
  input         i_h_sync ,
  input         i_de    ,
  input  [7:0] c_in  ,
  input [7:0] 	y_in,
           
 output       o_v_sync,
 output       o_h_sync,
 output       o_de   ,
 output  [7:0] y_out    ,
 output  [7:0] cb_out   ,
 output  [7:0] cr_out   

);

//===================================================================  
wire [15:0] ycbcr_in = {c_in,y_in};
  reg [4:0]vsync_dly,hsync_dly,de_dly;
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		vsync_dly <= 0;
		hsync_dly <= 0;
		de_dly    <=0;
	end
	else begin
		vsync_dly <= {vsync_dly[3:0],i_v_sync};
		hsync_dly <= {hsync_dly[3:0],i_h_sync};
		de_dly    <= {de_dly[3:0]  ,i_de   };
	end
end

wire  o_v_sync = vsync_dly[4];                       //打5拍
wire  o_h_sync = hsync_dly[4];
wire  o_de    = de_dly[4];


//===================================================================
  reg     [7:0]cb0,cb1;
  reg     [7:0]cr0,cr1;
  reg     [7:0]Y0,Y1,Y2,Y3;
  reg     [2:0]yuv_state;
  reg     [7:0]y_out,cb_out,cr_out;
always @ (posedge clk or negedge rst_n)
  begin
  	if(!rst_n)begin
  			y_out <= 8'd0;
  			cb_out<= 8'd0;
  			cr_out<= 8'd0;
  			yuv_state<=3'd0;
  	end else if(i_de || de_dly[3])begin    //补充两个DE信号
    case(yuv_state)
    3'd0: begin  //（ 1） 寄存 Cb0、 Y0
    	{cb0,Y0} <= ycbcr_in;
    	yuv_state<=3'd1; 				
    end
    3'd1: begin //（ 2） 寄存 cr0、 Y1
  	    	{cr0,Y1} <= ycbcr_in;
  		yuv_state<=3'd2;	    	
  	 end
  	 3'd2: begin //（ 3） 输出 Y0、 cb0、 cr0， 寄存 cb1、 Y2
  	    	{cb1,Y2} <= ycbcr_in;
  	    	{y_out,cb_out,cr_out} <= {Y0,cb0,cr0};
  	    	yuv_state<=3'd3;
  	 end  	    	    
  	 3'd3: begin //（ 4） 输出 Y1、 cb0、 cr0， 寄存 cr1、 Y3
  	    	{cr1,Y3} <= ycbcr_in;
  	    	{y_out,cb_out,cr_out} <= {Y1,cb0,cr0};
  	    	yuv_state<=3'd4;
  	  end  	    
  	 3'd4: begin //（ 5） 输出 Y2、 cb1、 cr1， 寄存 cb0、 Y0
  	    	{cb0,Y0} <= ycbcr_in;
  	    	{y_out,cb_out,cr_out} <= {Y2,cb1,cr1};
  	    	yuv_state<=3'd5;
  	  end  					 
    3'd5: begin //（ 6） 输出 Y3、 cb1、 cr1， 寄存 cr0、 Y1
  		{cr0,Y1} <= ycbcr_in;
           {y_out,cb_out,cr_out} <= {Y3,cb1,cr1};
  		yuv_state<=3'd2;
  	end
    default:begin
          y_out <= 8'd0;
	       cb_out<= 8'd0;
	       cr_out<= 8'd0;
	       yuv_state<=3'd0;
	end	   		
  endcase	
  	end
end
endmodule