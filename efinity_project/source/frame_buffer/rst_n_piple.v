module rst_n_piple #(                       
	parameter	DLY = 3                         
)(                                          
input		wire		clk,                        
input		wire		rst_n_i,                    
                                            
output	        wire		rst_n_o             
);                                          
                                            
generate                                    
if( DLY >= 2 ) begin :Delay_more_than2      
                                            
		reg	[DLY-1:0] rst_dly = {DLY{1'b0}};    
		                                        
		always @( posedge clk )                 
		begin                                   
			rst_dly <= {rst_n_i,rst_dly[DLY-1:1]};
		end                                     
           assign rst_n_o = rst_dly[0];     
end else begin                              
		reg[1:0] rst_dly = 2'b00;               
		always @( posedge clk )                 
		begin                                   
				rst_dly <= {rst_n_i,rst_dly[1]};    
		end                                     
            assign rst_n_o = rst_dly[0];    
end                                         
endgenerate                                 
                                            
                                            
                                            
                                            
endmodule                                   