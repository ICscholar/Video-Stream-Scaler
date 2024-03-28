
module sep2par  #(
parameter SEP_DATA_WIDTH = 24,
parameter SHIFT_WIDTH = 8

)(
input [SEP_DATA_WIDTH-1:0] din,
input sync,
input wrclk,
input rdclk,
output reg [SHIFT_WIDTH*SEP_DATA_WIDTH-1:0] dout = 'd0
);
reg [SHIFT_WIDTH-1:0] shift_reg = 'd1;
reg [SHIFT_WIDTH*SEP_DATA_WIDTH-1:0] shift_data = 'd0;
always @( posedge wrclk )
begin
    shift_reg <= sync ? 'd1 : {shift_reg[SHIFT_WIDTH-2:0],shift_reg[SHIFT_WIDTH-1]};
end 

always @( posedge wrclk )
begin
    shift_data <= {shift_data[(SHIFT_WIDTH-1)*SEP_DATA_WIDTH-1:0],din};
end 

always @( posedge rdclk )
begin
        dout <= shift_data;
end 

endmodule