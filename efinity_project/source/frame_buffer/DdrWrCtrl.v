
////////////////// DdrWrCtrl /////////////////////////////
/**********************************************************
  Function Description:

  Establishment : Richard Zhu
  Create date   : 2020-01-09
  Versions      : V0.1
  Revision of records:
  Ver0.1

**********************************************************/

module  DdrWrCtrl #(                                                  
  parameter   AXI_WR_ID       = 8'ha5             ,
  parameter   AXI_DATA_WIDTH  = 256               ,
  parameter 	AXI_ID_WIDTH		= 8									,
                                                  
  parameter  AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8  ,
  parameter  AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER) ,  
                                                  
  parameter  ADW_C           = AXI_DATA_WIDTH    ,
  parameter  ABN_C           = AXI_BYTE_NUMBER   

)
(
  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input         clk    ,     //System Clock
  input         rst_n   ,     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  input             burst_start  , //(I)[DdrWrCtrl]Ram Operate Start
  output   reg      RamWrEnd  = 'd0  , //(O)[DdrWrCtrl]Ram Operate End
  output            RamWrNext   , //(O)[DdrWrCtrl]Ram Write Next
  input [ADW_C-1:0] RamWrData   , //(I)[DdrWrCtrl]Ram Write Data
  output            RamWrALoad  , //(O)Ram Write Address Load

  /////////////////////////////////////////////////////////
  //Config DDR Operate Parameter
  input   [31:0]    addr_i   	, //(I)[DdrWrCtrl]Config Write Start Address
  input   [ 7:0]    burst_len_i , //(I)[DdrWrCtrl]Config Write Burst Length

  /////////////////////////////////////////////////////////
  output  wire[AXI_ID_WIDTH-1:0]    AWID        , //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  output  reg	[31:0]AWADDR ='d0     , //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  output  reg [ 7:0]AWLEN = 'd0      , //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  output  [ 2:0]    AWSIZE      , //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  output  [ 1:0]    AWBURST     , //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  output  [ 1:0]    AWLOCK      , //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  output   reg      AWVALID = 'd0    , //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  input             AWREADY     , //(I)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////                 
  output  [AXI_ID_WIDTH-1:0]    WID         , //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  output[ABN_C-1:0] WSTRB       , //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  output   reg      WLAST  = 1'b0     , //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  output   reg      WVALID = 'b0     , //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  input             WREADY      , //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  output[ADW_C-1:0] WDATA       , //(I)[WrData]Write data.
  /////////////                 
  input   [AXI_ID_WIDTH-1:0]    BID         , //(I)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  input             BVALID      , //(I)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  output   reg      BREADY = 'b0      //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  

  /////////////////////////////////////////////////////////
  reg   				DataWrAddrAva   = 1'h0 ;
  reg   				DataWrStart     = 1'h0 ;
  wire					DataWrNextBrst		   ;
  wire  				DataWrEnd			   ;	
  wire  				DataWrEn			   ;
 /////////////////////////////////////////////////////////
 
  assign    AWID    	= AXI_WR_ID     ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
                                        
  assign    AWSIZE  	= AXI_DATA_SIZE ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  assign    AWBURST 	= 2'b01         ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  assign    AWLOCK  	= 2'b00         ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.

/////////////////////////////////////////////////////////
  assign  		WID     = AXI_WR_ID     ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  assign     	WSTRB   = {ABN_C{1'h1}} ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  assign  		WDATA   = RamWrData     ; //(I)[WrData]Write data.

  /////////////////////////////////////////////////////////
  

  /////////////////////////////////////////////////////////
  
	//锁存地址和突发长度
  always @( posedge clk)   
  		if(burst_start)  AWLEN  <= burst_len_i;
  always @( posedge clk)   
  		if(burst_start)  AWADDR <= addr_i;
   /////////////////////////////////////////////////////////
	
  always @( posedge clk or negedge rst_n)
  begin//AWVALID
    if (!rst_n)         	AWVALID <= 1'h0;
    else if (burst_start)  	AWVALID <= 1'h1;
    else if (AWREADY)   	AWVALID <= 1'h0;
  end

  wire AddrWrEn = (AWVALID & AWREADY);
   /////////////////////////////////////////////////////////
	always @( posedge clk)  
  		DataWrStart    <= (AddrWrEn & (~WVALID)) | DataWrNextBrst;
                  
  always @( posedge clk or negedge rst_n)
  begin
    if (!rst_n)           	WVALID  <=  1'h0;
    else if (DataWrStart)   WVALID  <=  1'h1;
    else if (DataWrEnd)     WVALID  <=  1'h0;
  end

        
  assign  DataWrEn    = WVALID & WREADY         ;
  assign  DataWrEnd   = WVALID & WREADY & WLAST ;
  assign  RamWrALoad  = DataWrStart							; //(O)Ram Write Address Load
//1111111111111111111111111111111111111111111111111111111

  reg   [7:0]   WrBurstCnt = 8'h0;

  always @( posedge clk or negedge rst_n)
  begin
	    if (!rst_n)           	WrBurstCnt  <= 8'h0;
	    else if (DataWrStart)   WrBurstCnt  <= AWLEN;
	    else if (DataWrEn)      WrBurstCnt  <= WrBurstCnt - {7'h0,(|WrBurstCnt)};
  end

  always @( posedge clk)
  begin//WLAST
    if (DataWrStart)      WLAST <=   (~|AWLEN);
    else if (DataWrEn)    WLAST <=   (WrBurstCnt == 8'h1);
    else if (DataWrEnd)   WLAST <=   1'h0;
  end

  /////////////////////////////////////////////////////////

  always @( posedge clk or negedge rst_n)
  begin
    if (~rst_n)       	DataWrAddrAva <=  1'h0;
    else if (DataWrEnd) DataWrAddrAva <=  1'h0;
    else if (AddrWrEn)  DataWrAddrAva <=  WVALID;
  end
    
  assign DataWrNextBrst  = (AddrWrEn | DataWrAddrAva ) & DataWrEnd;
  
  
  /////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////
  reg   DataWrBusy  = 1'h0  ;

  always @( posedge clk )
  begin
    if (DataWrEnd)       DataWrBusy <=  1'h0;
    else if (DataWrEn)   DataWrBusy <=  1'h1;
  end
  
  always @( posedge clk)   
  		RamWrEnd  <=  (~DataWrBusy) & DataWrEn;   
  
  /////////////////////////////////////////////////////////  
  assign          RamWrNext = DataWrEn & (~DataWrEnd)    ;    //(O)[DdrWrCtrl]Ram Write Next
  
  /////////////////////////////////////////////////////////  
//=========================================================
  /////////////////////////////////////////////////////////

  always @( posedge clk or negedge rst_n)
  begin
    if (!rst_n)           BREADY  <=  1'h0;
    else if (WLAST)    BREADY  <=  1'h1;
    else if (BVALID)     BREADY  <=  1'h0;
  end

  wire    BackRespond = BREADY & BVALID;

  /////////////////////////////////////////////////////////

endmodule