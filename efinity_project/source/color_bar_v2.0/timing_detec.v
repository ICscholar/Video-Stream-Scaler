
module timing_detec(
    input clk,
    input rst_n,
    input i_hs,
    input i_vs,
    input i_de,
    input [63:0] i_vid,

    output [12:0] h_sync,
    output [12:0] h_back_porch,
    output [12:0] h_front_porch,
    output [12:0] h_active,
    output reg [12:0] v_active ='d0,
    output [12:0] v_sync,
    output reg [12:0] v_back_porch = 'd0,
    output reg [12:0] v_front_porch = 'd0
);

wire pos_hs;
wire neg_hs;
wire pos_vs;
wire neg_vs;
wire pos_de;
wire neg_de;
reg vs_r0 = 1'b0;
reg hs_r0 = 1'b0;
reg de_r0 = 1'b0;
wire [12:0] w_v_front_porch;
wire [12:0] w_v_back_porch ;
wire [12:0] w_v_active ;
assign pos_vs = {vs_r0,i_vs} == 2'b01;
assign neg_vs = {vs_r0,i_vs} == 2'b10;
assign pos_hs = {hs_r0,i_hs} == 2'b01;
assign neg_hs = {hs_r0,i_hs} == 2'b10;
assign pos_de = {de_r0,i_de} == 2'b01;
assign neg_de = {de_r0,i_de} == 2'b10;

always @( posedge clk )
begin
    vs_r0 <= i_vs;
end 

always@( posedge clk )
begin
    hs_r0 <= i_hs;
end 

always@( posedge clk )
begin
    de_r0 <= i_de;
end 


 length_calc u_h_sync(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (pos_hs),
    /*o*/.end_point     (neg_hs),
    /*o*/.length        (h_sync),
    /*o*/.update_point()

);

 length_calc u_h_active(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (pos_de),
    /*o*/.end_point     (neg_de),
    /*o*/.length        (h_active ),
    /*o*/.update_point()

);


 length_calc u_h_backporch(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (neg_hs),
    /*o*/.end_point     (pos_de),
    /*o*/.length        (h_back_porch ),
    /*o*/.update_point()

);

 length_calc u_h_frontporch(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (neg_de),
    /*i*/.middle_point  (),
    /*o*/.end_point     (pos_hs),
    /*o*/.length        (h_front_porch ),
    /*o*/.section_number(),
    /*o*/.update_point()

);
//================================================================
 length_calc u_v_sync(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (pos_vs),
    /*i*/.middle_point  (pos_hs),
    /*o*/.end_point     (neg_vs),
    /*o*/.length        ( ),
    /*o*/.section_number(v_sync),
    /*o*/.update_point()

);

 length_calc u_v_active(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (neg_vs),
    /*i*/.middle_point  (pos_de),
    /*o*/.end_point     (pos_vs),
    /*o*/.length        (), 
    /*o*/.section_number(w_v_active),
    /*o*/.update_point()

);
always @( posedge clk )
begin
    v_active <= w_v_active -1'b1;
    v_front_porch <= w_v_front_porch -1'b1;
    v_back_porch <= w_v_back_porch -1'b1;
end 

 length_calc u_v_backporch(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (neg_vs),
    /*i*/.middle_point  (pos_hs),
    /*o*/.end_point     (pos_de),
    /*o*/.length        ( ),
    /*o*/.section_number(w_v_front_porch),
    /*o*/.update_point()

);


 length_calc u_v_frontporch(
    /*i*/.clk           (clk ),
    /*i*/.rst_n         (),
    /*i*/.start_point   (neg_de),
    /*i*/.middle_point  (pos_hs),
    /*o*/.end_point     (pos_vs),
    /*o*/.length        ( ),
    /*o*/.section_number(w_v_back_porch),
    /*o*/.update_point()

);






endmodule
//============================================================================  
//    -------------------------------------------------- 
//    |                                                |                    calculate the length of the high level
// ---                                                 ----------------
//================================================================--------------------          
module length_calc(
    input clk ,
    input rst_n,
    input start_point,
    input middle_point,
    input end_point,
    output reg [12:0] length ='d0,
    output reg [12:0] section_number = 'd0,
    output reg update_point = 'd0

);
reg [12:0] cnt = 'd0;
reg [12:0] sec_cnt = 'd0;
reg end_flag = 'd0;
wire invalid_time ;
reg cnt_flag = 'd0;
    always @( posedge clk )
begin
    if( start_point )
        cnt  <= 1;
    else if( cnt_flag & ~end_point )
        cnt <= cnt + 1;
end 

always @( posedge clk )
begin
    cnt_flag <= start_point ? 1'b1: (end_point ? 1'b0 : cnt_flag);
end 

always @( posedge clk )
begin
    if( end_point )
        length <= cnt ;       
end 
always @( posedge clk )
begin
    update_point <= end_point;
end 

always @( posedge clk )
begin
    if( start_point )
        sec_cnt <= 'd1;
    else if( middle_point & ~invalid_time)
        sec_cnt <= sec_cnt + 1'b1;
end 

always @(posedge clk ) 
begin
    if( end_point )
        section_number <= sec_cnt;
end

always @( posedge clk )
begin
    if(end_point) 
            end_flag <= 1'b1;
    else if( start_point )
            end_flag <= 1'b0;
end 
assign  invalid_time = end_flag || end_point ;

endmodule 