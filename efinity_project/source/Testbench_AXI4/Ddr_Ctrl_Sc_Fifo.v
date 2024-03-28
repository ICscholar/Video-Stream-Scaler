
///////////////////////////////////////////////////////////
/**********************************************************
  Function Description:

  Establishment : Richard Zhu
  Create date   : 2022-09-24
  Versions      : V0.1
  Revision of records:
  Ver0.1

**********************************************************/
module  Ddr_Ctrl_Sc_Fifo
(
  Sys_Clk     , //System Clock
  Sync_Clr    , //Sync Reset
  I_Wr_En     , //(I) FIFO Write Enable
  I_Wr_Data   , //(I) FIFO Write Data
  I_Rd_En     , //(I) FIFO Read Enable
  O_Rd_Data   , //(I) FIFO Read Data
  O_Data_Num  , //(I) FIFO Data Number
  O_Wr_Full   , //(O) FIFO Write Full
  O_Rd_Empty  , //(O) FIFO Write Empty
  O_Fifo_Err    //Fifo Error
) ;

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   OUT_REG       = "No"  ; //"Yes" Output Register Eanble ; "No"  Output Register Disble
  parameter   DATA_WIDTH    = 32    ; //Data Width
  parameter   DATA_DEPTH    = 8     ; //Address Width
  parameter   INITIAL_VALUE = 8'h0  ;

  localparam  ADDR_WIDTH    = $clog2(DATA_DEPTH)  ;
  localparam  SRL8_NUMBER   = (DATA_DEPTH / 8) + (((DATA_DEPTH % 8) == 0) ? 0 : 1 ) ;


  localparam  DW  = DATA_WIDTH    ;
  localparam  AW  = ADDR_WIDTH    ;
  localparam  SN  = SRL8_NUMBER   ;

  /////////////////////////////////////////////////////////

  // Signal Define
  /////////////////////////////////////////////////////////
  input             Sys_Clk     ; //System Clock
  input             Sync_Clr    ; //Sync Reset
  input             I_Wr_En     ; //(I) Write Enable
  input   [DW-1:0]  I_Wr_Data   ; //(I) Write Data
  input             I_Rd_En     ; //(I) Read Enable
  output  [DW-1:0]  O_Rd_Data   ; //(O) Read Data
  output  [AW  :0]  O_Data_Num  ; //(O) Ram Data Number
  output            O_Wr_Full   ; //(O) FIFO Write Full
  output            O_Rd_Empty  ; //(O) FIFO Write Empty
  output            O_Fifo_Err  ; //(O) FIFO Error

  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  wire            Wr_En     = I_Wr_En     ; //Write Enable
  wire  [DW-1:0]  Wr_Data   = I_Wr_Data   ; //Write Data
  wire            Rd_En     = I_Rd_En     ; //Read Enable

  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  reg   Wr_Full     = 1'h0  ;
  reg   Rd_Empty    = 1'h1  ;

  wire  Fifo_Wr_En  = Wr_En & ( ~Wr_Full  ) ;
  wire  Fifo_Rd_En  = Rd_En & ( ~Rd_Empty ) ;

  /////////////////////////////////////////////////////////
  reg   [AW:0]  Data_Num  = {AW+1{1'h0}}  ;

  always @(posedge Sys_Clk)
  begin
    if (Sync_Clr)           Data_Num  <= {AW+1{1'h0}} ;
    else if (Fifo_Wr_En ^ Fifo_Rd_En)
    begin
      if (Fifo_Wr_En)       Data_Num  <= Data_Num + {{AW{1'h0}},1'h1} ;
      else if (Fifo_Rd_En)  Data_Num  <= Data_Num - {{AW{1'h0}},1'h1} ;
    end
  end

  /////////////////////////////////////////////////////////
  wire    [AW  :0]  Out_Sel  ;

  assign  Out_Sel = (|Data_Num)   ? ( DATA_DEPTH  - Data_Num) : {AW+1{1'h0}} ;

  /////////////////////////////////////////////////////////
  wire    [AW:0]    O_Data_Num  = Data_Num  ; //(O)Data Number In Fifo

  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  wire  [   2:0]  Shift_Out_Sel   = Out_Sel[2:0]  ;
  wire            Shift_Clk_En    = Fifo_Wr_En    ;

  wire  [DW-1:0]  Shift_Data_In   [SN-1:0]  ;
  wire  [DW-1:0]  Shift_Data_Out  [SN-1:0]  ;
  wire  [DW-1:0]  Shift_Q7_Out    [SN  :0]  ; //(O)Shift Output

  genvar  i , j ;
  generate
    for (i=0; i<SRL8_NUMBER ; i=i+1)
    begin : U_SRL8_D
      if (i==SRL8_NUMBER-1) assign  Shift_Data_In[i]  = ~Wr_Data          ;
      else                  assign  Shift_Data_In[i]  = Shift_Q7_Out[i+1] ;

      for (j=0; j<DATA_WIDTH; j=j+1)
      begin : U_SRL8_W
        EFX_SRL8
        #(
            .CLK_POLARITY ( 1'b1            ) , // clk polarity
            .CE_POLARITY  ( 1'b1            ) , // clk polarity
            .INIT         ( INITIAL_VALUE   )   // 8-bit initial value
        )
        srl8_inst
        (
            .A      ( Shift_Out_Sel         ) ,   // 3-bit address select for Q
            .D      ( Shift_Data_In [i][j]  ) ,   // 1-bit data-in
            .CLK    ( Sys_Clk               ) ,   // clock
            .CE     ( Shift_Clk_En          ) ,   // clock enable
            .Q      ( Shift_Data_Out[i][j]  ) ,   // 1-bit data output
            .Q7     ( Shift_Q7_Out  [i][j]  )     // 1-bit last shift register output
        );
      end
    end
  endgenerate

  /////////////////////////////////////////////////////////
  reg   [DW-1:0]  Data_Out  = {DW{1'h0}}  ;
  reg   [DW-1:0]  Shift_Out = {DW{1'h0}}  ;

  always @(posedge  Sys_Clk )
  begin
    if (Sync_Clr)               Data_Out  <=  {DW{1'h0}}  ;
    else if (SRL8_NUMBER == 1)  Data_Out  <=  Shift_Data_Out[0][DW-1:0]  ;
    else
    begin
      if (Out_Sel != 0 )        Data_Out  <=  Shift_Data_Out[Out_Sel[AW-1:3]][DW-1:0]  ;
      else if (Shift_Clk_En)    Data_Out  <=  Wr_Data     ;
      else                      Data_Out  <=  Shift_Data_Out[Out_Sel[AW-1:3]][DW-1:0]  ;
    end
  end

  /////////////////////////////////////////////////////////
  reg  [DW-1:0]  Rd_Data   ;

  always @ ( * )
  begin
    if (OUT_REG == "Yes")           Rd_Data = Data_Out  ;
    else if ( (SRL8_NUMBER <= 1) )  Rd_Data = Shift_Data_Out[              0][DW-1:0] ;
    else                            Rd_Data = Shift_Data_Out[Out_Sel[AW:3]][DW-1:0] ;
  end

  /////////////////////////////////////////////////////////
  wire  [DW-1:0]  O_Rd_Data   = Rd_Data ; //(O) Read Data

  /////////////////////////////////////////////////////////
  localparam  [AW:0]  FULL_ENTER      = DATA_DEPTH  - {{AW{1'h0}},1'h1} ;
  localparam  [AW:0]  EMPTY_ENTER     = {{AW{1'h0}} , 1'h1  }  ;

  /////////////////////////////////////////////////////////
  always @(posedge Sys_Clk)
  begin
    if (Sync_Clr)           Wr_Full   <=  1'h0 ;
    else if (Fifo_Rd_En)    Wr_Full   <=  1'h0 ;
    else if (Fifo_Wr_En)    Wr_Full   <=  (Data_Num == FULL_ENTER)  ;
  end

  /////////////////////////////////////////////////////////
  always @(posedge Sys_Clk)
  begin
    if (Sync_Clr)           Rd_Empty  <=  1'h1 ;
    else if (Fifo_Wr_En)    Rd_Empty  <=  1'h0 ;
    else if (Fifo_Rd_En)    Rd_Empty  <=  (Data_Num == EMPTY_ENTER) ;
  end

  /////////////////////////////////////////////////////////
  reg   Fifo_Err  = 1'h0 ;

  always @(posedge Sys_Clk)   Fifo_Err  <=  (Rd_En & Rd_Empty) | (Wr_En & Wr_Full) ;

  /////////////////////////////////////////////////////////
  assign    O_Wr_Full   = Wr_Full   ; //(O) FIFO Write Full
  assign    O_Rd_Empty  = Rd_Empty  ; //(O) FIFO Write Empty
  assign    O_Fifo_Err  = Fifo_Err  ; //(O) Fifo Error

endmodule