`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 09:59:26
// Design Name: 
// Module Name: syncasync
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


module syncasync(

     input      areset,
     input      ain,
     input      outclk,     
     
     output     oout   
    );

wire          oout;
reg     [1:0] osyncstages=0;     
    
 assign oout = osyncstages[1] ;   
    
  
 always@(posedge outclk)begin
    if(areset)
         osyncstages <= 2'b11; 
    else
         osyncstages <= {osyncstages[0],ain};   
end    
      
endmodule
