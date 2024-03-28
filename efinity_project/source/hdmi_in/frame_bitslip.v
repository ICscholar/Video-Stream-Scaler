

module frame_bitslip (
    input                   clk     ,
    input                   rstn    ,
    input                   bitslip ,
    input           [9:0]   data_in ,
    output reg      [9:0]   data_out
);

    reg     [19:0]  data_buff 	  = 'd0;
    reg             bitslip_dly1  = 'd0;
    reg 						bitslip_dly2  = 'd0;
    reg     [3:0]   Output_switch = 'd0;
    wire 						bitslip_pos ;
    
	assign bitslip_pos = (bitslip_dly1 == 1'b1 & bitslip_dly2 == 1'b0) ;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bitslip_dly1 <= 1'b0;
        bitslip_dly2 <= 1'b0;
    end else begin
        bitslip_dly1 <= bitslip;
        bitslip_dly2 <= bitslip_dly1;
    end
end


//Output_switch
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        Output_switch <= 4'b0;
    end else begin
        if( bitslip_pos ) begin
        
            Output_switch <= Output_switch == 9 ? 0 : Output_switch + 1;
        end else begin
            Output_switch <= Output_switch;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_buff <= 'd0;
    end else begin
        data_buff <= {data_in,data_buff[19:10]};
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_out <= 8'h00;
    end else begin
        case(Output_switch)
            4'h0: data_out <= data_buff[19:10];
            4'h1: data_out <= data_buff[18:9];
            4'h2: data_out <= data_buff[17:8];
            4'h3: data_out <= data_buff[16:7];
            4'h4: data_out <= data_buff[15:6];
            4'h5: data_out <= data_buff[14:5];
            4'h6: data_out <= data_buff[13:4];
            4'h7: data_out <= data_buff[12:3];  
            4'h8: data_out <= data_buff[11:2];
            4'h9: data_out <= data_buff[10:1];
            default:;
        endcase
    end
end
endmodule