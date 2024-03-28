// =============================================================================
// Generated by efx_ipmgr
// Version: 2023.1.150
// IP Version: 5.2
// =============================================================================

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////

localparam PACK_TYPE = 1;
localparam tLPX_NS = 60;
localparam tINIT_NS = 100000;
localparam NUM_DATA_LANE = 4;
localparam HS_BYTECLK_MHZ = 125;
localparam CLOCK_FREQ_MHZ = 100;
localparam DPHY_CLOCK_MODE = "Continuous";
localparam PIXEL_FIFO_DEPTH = 8192;
localparam tLP_EXIT_NS = 100;
localparam tCLK_ZERO_NS = 280;
localparam tCLK_TRAIL_NS = 100;
localparam tCLK_PRE_NS = 10;
localparam tCLK_POST_NS = 100;
localparam tCLK_PREPARE_NS = 50;
localparam tWAKEUP_NS = 1000;
localparam tHS_ZERO_NS = 200;
localparam tHS_TRAIL_NS = 65;
localparam tHS_EXIT_NS = 120;
localparam tHS_PREPARE_NS = 50;
localparam BTA_TIMEOUT_NS = 100000;
localparam tD_TERM_EN_NS = 35;
localparam tHS_PREPARE_ZERO_NS = 145;
localparam ENABLE_V_LPM_BTA = 1'b0;
localparam PACKET_SEQUENCES = 1;
localparam HS_CMD_WDATAFIFO_DEPTH = 512;
localparam LP_CMD_WDATAFIFO_DEPTH = 512;
localparam LP_CMD_RDATAFIFO_DEPTH = 2048;
localparam MAX_HRES = 1920;
localparam ENABLE_BIDIR = 1'b1;
localparam ENABLE_EOTP = 1'b0;
