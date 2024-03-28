`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/27 09:47:27
// Design Name: 
// Module Name: syncbase
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module syncbase #(
     parameter   kResetTo =0 
)
(
    input       areset ,
    input       inclk  ,
    input       iin    ,
    input       outclk ,
    output      oout   

    );
     
 reg    iin_q=0;
 wire   oout;
        
always@(posedge inclk)begin
    if(areset)
        iin_q <= kResetTo;
    else
        iin_q <= iin;   
end      
        
//Crossing clock boundary here      
 syncasync u_syncasync(
    .areset        (areset),
    .ain           (iin_q),
    .outclk        (outclk),
    .oout          (oout)     
 );     
       
endmodule
