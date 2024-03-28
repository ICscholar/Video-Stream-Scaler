
`timescale 100ps/10ps
/////////////////// Axi4FullDeplex ///////////////////////////
module Axi4FullDeplex
(
  //System Signal
  SysClk    , //System Clock
  Reset_N   , //System Reset
  //Axi Slave Interfac Signal
  AWID      , //(I)[WrAddr]Write address ID.
  AWADDR    , //(I)[WrAddr]Write address.
  AWLEN     , //(I)[WrAddr]Burst length.
  AWSIZE    , //(I)[WrAddr]Burst size.
  AWBURST   , //(I)[WrAddr]Burst type.
  AWLOCK    , //(I)[WrAddr]Lock type.
  AWVALID   , //(I)[WrAddr]Write address valid.
  AWREADY   , //(O)[WrAddr]Write address ready.
  ///////////
  WID       , //(I)[WrData]Write ID tag.
  WDATA     , //(I)[WrData]Write data.
  WSTRB     , //(I)[WrData]Write strobes.
  WLAST     , //(I)[WrData]Write last.
  WVALID    , //(I)[WrData]Write valid.
  WREADY    , //(O)[WrData]Write ready.
  ///////////
  BID       , //(O)[WrResp]Response ID tag.
  BVALID    , //(O)[WrResp]Write response valid.
  BREADY    , //(I)[WrResp]Response ready.
  ///////////
  ARID      , //(I)[RdAddr]Read address ID.
  ARADDR    , //(I)[RdAddr]Read address.
  ARLEN     , //(I)[RdAddr]Burst length.
  ARSIZE    , //(I)[RdAddr]Burst size.
  ARBURST   , //(I)[RdAddr]Burst type.
  ARLOCK    , //(I)[RdAddr]Lock type.
  ARVALID   , //(I)[RdAddr]Read address valid.
  ARREADY   , //(O)[RdAddr]Read address ready.
  ///////////
  RID       , //(O)[RdData]Read ID tag.
  RDATA     , //(O)[RdData]Read data.
  RRESP     , //(O)[RdData]Read response.
  RLAST     , //(O)[RdData]Read last.
  RVALID    , //(O)[RdData]Read valid.
  RREADY    , //(I)[RdData]Read ready.
  /////////////
  //DDR Controner AXI4 Signal
  aid       , //(O)[Addres] Address ID
  aaddr     , //(O)[Addres] Address
  alen      , //(O)[Addres] Address Brust Length
  asize     , //(O)[Addres] Address Burst size
  aburst    , //(O)[Addres] Address Burst type
  alock     , //(O)[Addres] Address Lock type
  avalid    , //(O)[Addres] Address Valid
  aready    , //(I)[Addres] Address Ready
  atype     , //(O)[Addres] Operate Type 0=Read, 1=Write
  /////////////
  wid       , //(O)[Write]  ID
  wdata     , //(O)[Write]  Data
  wstrb     , //(O)[Write]  Data Strobes(Byte valid)
  wlast     , //(O)[Write]  Data Last
  wvalid    , //(O)[Write]  Data Valid
  wready    , //(I)[Write]  Data Ready
  /////////////
  rid       , //(I)[Read]   ID
  rdata     , //(I)[Read]   Data
  rlast     , //(I)[Read]   Data Last
  rvalid    , //(I)[Read]   Data Valid
  rready    , //(O)[Read]   Data Ready
  rresp     , //(I)[Read]   Response
  /////////////
  bid       , //(I)[Answer] Response Write ID
  bvalid    , //(I)[Answer] Response valid
  bready      //(O)[Answer] Response Ready
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C  = 1;

  parameter   DDR_WRITE_FIRST     = 1'h1;
  parameter   AXI_DATA_WIDTH      = 256 ;

  localparam  AXI_BYTE_NUMBER     = AXI_DATA_WIDTH/8  ;
                                                      
  localparam  ADW_C               = AXI_DATA_WIDTH    ;
  localparam  ABN_C               = AXI_BYTE_NUMBER   ;

  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input               SysClk  ; //System Clock
  input               Reset_N ; //System Reset

  /////////////////////////////////////////////////////////
  //AXI4 Full Deplex
  input   [      7:0] AWID    ; //(I)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  input   [     31:0] AWADDR  ; //(I)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  input   [      7:0] AWLEN   ; //(I)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  input   [      2:0] AWSIZE  ; //(I)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  input   [      1:0] AWBURST ; //(I)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  input   [      1:0] AWLOCK  ; //(I)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  input               AWVALID ; //(I)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  output              AWREADY ; //(O)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////  
  input   [      7:0] WID     ; //(I)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  input   [ABN_C-1:0] WSTRB   ; //(I)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  input               WLAST   ; //(I)[WrData]Write last. This signal indicates the last transfer in a write burst.
  input               WVALID  ; //(I)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  output              WREADY  ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  input   [ADW_C-1:0] WDATA   ; //(I)[WrData]Write data.
  /////////////  
  output  [      7:0] BID     ; //(O)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  output              BVALID  ; //(O)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  input               BREADY  ; //(I)[WrResp]Response ready. This signal indicates that the master can accept a write response.
  /////////////  
  input   [      7:0] ARID    ; //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  input   [     31:0] ARADDR  ; //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  input   [      7:0] ARLEN   ; //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  input   [      2:0] ARSIZE  ; //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  input   [      1:0] ARBURST ; //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  input   [      1:0] ARLOCK  ; //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  input               ARVALID ; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
  output              ARREADY ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////  
  output  [      7:0] RID     ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  output  [      1:0] RRESP   ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  output              RLAST   ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  output              RVALID  ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  input               RREADY  ; //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
  output  [ADW_C-1:0] RDATA   ; //(O)[RdData]Read data.

  /////////////////////////////////////////////////////////
  //DDR Controner AXI4 Signal Define
  output  [      7:0] aid     ; //(O)[Addres]Address ID
  output  [     31:0] aaddr   ; //(O)[Addres]Address
  output  [      7:0] alen    ; //(O)[Addres]Address Brust Length
  output  [      2:0] asize   ; //(O)[Addres]Address Burst size
  output  [      1:0] aburst  ; //(O)[Addres]Address Burst type
  output  [      1:0] alock   ; //(O)[Addres]Address Lock type
  output              avalid  ; //(O)[Addres]Address Valid
  input               aready  ; //(I)[Addres]Address Ready
  output              atype   ; //(O)[Addres]Operate Type 0=Read, 1=Write
  output  [      7:0] wid     ; //(O)[Write]Data ID
  output  [ABN_C-1:0] wstrb   ; //(O)[Write]Data Strobes(Byte valid)
  output              wlast   ; //(O)[Write]Data Last
  output              wvalid  ; //(O)[Write]Data Valid
  input               wready  ; //(I)[Write]Data Ready
  output  [ADW_C-1:0] wdata   ; //(O)[Write]Data Data
  input   [      7:0] rid     ; //(I)[Read]Data ID
  input               rlast   ; //(I)[Read]Data Last
  input               rvalid  ; //(I)[Read]Data Valid
  output              rready  ; //(O)[Read]Data Ready
  input   [      1:0] rresp   ; //(I)[Read]Response
  input   [ADW_C-1:0] rdata   ; //(I)[Read]Data Data
  input   [      7:0] bid     ; //(I)[Answer]Response Write ID
  input               bvalid  ; //(I)[Answer]Response valid
  output              bready  ; //(O)[Answer]Response Ready

//1111111111111111111111111111111111111111111111111111111
//
//  Input£º
//  output£º
//***************************************************/

  /////////////////////////////////////////////////////////
  reg           OpType  ;

  wire          AWREADY =  OpType & aready  ; //(O)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  wire          ARREADY = ~OpType & aready  ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.

  /////////////////////////////////////////////////////////
  reg   OperateSel = 1'h0;

  always @( posedge SysClk) if (aready)
  begin
    if      (AWVALID ^ ARVALID)   OperateSel <= # TCo_C ~DDR_WRITE_FIRST  ;
    else if (AWVALID & ARVALID)   OperateSel <= # TCo_C ~OperateSel       ;
  end

  /////////////////////////////////////////////////////////
  reg   [1:0] OprateAva = 2'h3;

  always @( posedge SysClk or negedge Reset_N )
  begin
    if ( ! Reset_N )      OprateAva <= # TCo_C  2'h3;
    else
    begin
      case (OprateAva)
        2'h0:               OprateAva <= # TCo_C  2'h3;
        2'h1: if (ARREADY)  OprateAva <= # TCo_C  {AWVALID  , 1'h0   };
        2'h2: if (AWREADY)  OprateAva <= # TCo_C  {1'h0     , ARVALID};
        2'h3:
        begin
          case ({AWVALID , ARVALID})
            2'h0:   OprateAva  <= # TCo_C 2'h3;
            2'h1:   OprateAva  <= # TCo_C 2'h1;
            2'h2:   OprateAva  <= # TCo_C 2'h2;
            2'h3:   OprateAva  <= # TCo_C OperateSel ? 2'h2 : 2'h1;
          endcase
        end
      endcase
    end
  end

  /////////////////////////////////////////////////////////
  wire  [1:0]  AddrVal = {AWVALID , ARVALID} & OprateAva;

  always @( * )
  begin
    case (AddrVal)
      2'h0:   OpType  <= # TCo_C OperateSel;
      2'h1:   OpType  <= # TCo_C 1'h0;
      2'h2:   OpType  <= # TCo_C 1'h1;
      2'h3:   OpType  <= # TCo_C OperateSel;
    endcase
  end

//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//
//  Input£º
//  output£º
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  [      7:0] aid     = OpType ? AWID     : (~ARID) ; //(O)[Addres]Address ID
  wire  [     31:0] aaddr   = OpType ? AWADDR   : ARADDR  ; //(O)[Addres]Address
  wire  [      7:0] alen    = OpType ? AWLEN    : ARLEN   ; //(O)[Addres]Address Brust Length
  wire  [      2:0] asize   = OpType ? AWSIZE   : ARSIZE  ; //(O)[Addres]Address Burst size
  wire  [      1:0] aburst  = OpType ? AWBURST  : ARBURST ; //(O)[Addres]Address Burst type
  wire  [      1:0] alock   = OpType ? AWLOCK   : ARLOCK  ; //(O)[Addres]Address Lock type
  wire              avalid  = OpType ? AWVALID  : ARVALID ; //(O)[Addres]Address Valid
  wire              atype   = OpType                      ; //(O)[Addres]Operate Type 0=Read, 1=Write

  /////////////////////////////////////////////////////////
  wire  [      7:0] wid     = WID     ; //(O)[Write]Data ID
  wire  [ABN_C-1:0] wstrb   = WSTRB   ; //(O)[Write]Data Strobes(Byte valid)
  wire              wlast   = WLAST   ; //(O)[Write]Data Last
  wire              wvalid  = WVALID  ; //(O)[Write]Data Valid
  wire  [ADW_C-1:0] wdata   = WDATA   ; //(O)[Write]Data Data
                                      
  wire              WREADY  = wready  ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.

  /////////////////////////////////////////////////////////
  wire              bready  = BREADY  ; //(O)[Answer]Response Ready
                                      
  wire  [     7:0]  BID     = bid     ; //(O)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  wire              BVALID  = bvalid  ; //(O)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.

  /////////////////////////////////////////////////////////
  wire              rready  = RREADY  ; //(O)[Read]Data Ready
                                      
  wire  [     7:0]  RID     = (~rid)  ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  wire  [     1:0]  RRESP   = rresp   ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  wire              RLAST   = rlast   ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  wire              RVALID  = rvalid  ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  wire [ADW_C-1:0]  RDATA   = rdata   ; //(O)[RdData]Read data.

//22222222222222222222222222222222222222222222222222222




endmodule

/////////////////// Axi4FullDeplex ///////////////////////////