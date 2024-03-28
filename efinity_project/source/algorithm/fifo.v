module fifo#(
    parameter   data_width = 16,
    parameter   data_depth = 256,
    parameter   addr_width = 8
)
(
    input                           rst,
    input                           wr_clk,
    input                           wr_en,
    input      [data_width-1:0]     din,         
    input                           rd_clk,
    input                           rd_en,
    output reg                     valid = 0,
    output reg [data_width-1:0]     dout = 0,
    output                          empty,
    output                          full
    );

reg    [addr_width:0]    wr_addr_ptr = 0;//��ַָ�룬�ȵ�ַ��һλ��MSB���ڼ�����ͬһȦ
reg    [addr_width:0]    rd_addr_ptr = 0;
wire   [addr_width-1:0]  wr_addr;//RAM ��ַ
wire   [addr_width-1:0]  rd_addr;

wire   [addr_width:0]    wr_addr_gray;//��ַָ����Ӧ�ĸ�����
reg    [addr_width:0]    wr_addr_gray_d1 = 0;
reg    [addr_width:0]    wr_addr_gray_d2 = 0;
wire   [addr_width:0]    rd_addr_gray;
reg    [addr_width:0]    rd_addr_gray_d1 = 0;
reg    [addr_width:0]    rd_addr_gray_d2 = 0;

reg [data_width-1:0] fifo_ram [data_depth-1:0];

//=========================================================write fifo 
//genvar i;
//generate 
//for(i = 0; i < data_depth; i = i + 1 )
//begin:fifo_init
//always@(posedge wr_clk or posedge rst)
//    begin
//       if(rst)
//          fifo_ram[i] <= 'h0;//fifo��λ��������������0������ram�����ĸ�λ������
//       else if(wr_en && (~full))
//          fifo_ram[wr_addr] <= din;
//       else
//          fifo_ram[wr_addr] <= fifo_ram[wr_addr];
//    end   
//end    
//endgenerate    

//д����
always@(posedge wr_clk)
begin
    if(wr_en && (~full))
        fifo_ram[wr_addr] <= din;
    else
        fifo_ram[wr_addr] <= fifo_ram[wr_addr];
end

//========================================================read_fifo
always@(posedge rd_clk or posedge rst)
   begin
      if(rst)
         begin
            dout <= 'h0;
            valid <= 1'b0;
         end
      else if(rd_en && (~empty))
         begin
            dout <= fifo_ram[rd_addr];
            valid <= 1'b1;
         end
      else
         begin
            dout <=   'h0;//fifo��λ��������������0������ram�����ĸ�λ��ֻ��������Ϊ0��
            valid <= 1'b0;
         end
   end
assign wr_addr = wr_addr_ptr[addr_width-1-:addr_width];
assign rd_addr = rd_addr_ptr[addr_width-1-:addr_width];
//=============================================================������ͬ����
always@(posedge wr_clk )
   begin
      rd_addr_gray_d1 <= rd_addr_gray;
      rd_addr_gray_d2 <= rd_addr_gray_d1;
   end
always@(posedge wr_clk or posedge rst)
   begin
      if(rst)
         wr_addr_ptr <= 'h0;
      else if(wr_en && (~full))
         wr_addr_ptr <= wr_addr_ptr + 1;
      else 
         wr_addr_ptr <= wr_addr_ptr;
   end
//=========================================================rd_clk
always@(posedge rd_clk )
      begin
         wr_addr_gray_d1 <= wr_addr_gray;
         wr_addr_gray_d2 <= wr_addr_gray_d1;
      end
always@(posedge rd_clk or posedge rst)
   begin
      if(rst)
         rd_addr_ptr <= 'h0;
      else if(rd_en && (~empty))
         rd_addr_ptr <= rd_addr_ptr + 1;
      else 
         rd_addr_ptr <= rd_addr_ptr;
   end

//========================================================== translation gary code
assign wr_addr_gray = (wr_addr_ptr >> 1) ^ wr_addr_ptr;
assign rd_addr_gray = (rd_addr_ptr >> 1) ^ rd_addr_ptr;

assign full = (wr_addr_gray == {~(rd_addr_gray_d2[addr_width-:2]),rd_addr_gray_d2[addr_width-2:0]}) ;//����λ��ͬ
assign empty = ( rd_addr_gray == wr_addr_gray_d2 );

endmodule