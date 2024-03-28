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

efx_ddr3_axi_1 u_efx_ddr3_axi_1(
.clk ( clk ),
.core_clk ( core_clk ),
.twd_clk ( twd_clk ),
.tdqss_clk ( tdqss_clk ),
.tac_clk ( tac_clk ),
.reset_n ( reset_n ),
.reset ( reset ),
.cs ( cs ),
.ras ( ras ),
.cas ( cas ),
.we ( we ),
.cke ( cke ),
.addr ( addr ),
.ba ( ba ),
.odt ( odt ),
.shift ( shift ),
.shift_sel ( shift_sel ),
.shift_ena ( shift_ena ),
.cal_ena ( cal_ena ),
.cal_done ( cal_done ),
.cal_pass ( cal_pass ),
.cal_fail_log ( cal_fail_log ),
.cal_shift_val ( cal_shift_val ),
.o_dm_hi ( o_dm_hi ),
.o_dm_lo ( o_dm_lo ),
.i_dqs_hi ( i_dqs_hi ),
.i_dqs_lo ( i_dqs_lo ),
.i_dqs_n_hi ( i_dqs_n_hi ),
.i_dqs_n_lo ( i_dqs_n_lo ),
.o_dqs_hi ( o_dqs_hi ),
.o_dqs_lo ( o_dqs_lo ),
.o_dqs_n_hi ( o_dqs_n_hi ),
.o_dqs_n_lo ( o_dqs_n_lo ),
.o_dqs_oe ( o_dqs_oe ),
.o_dqs_n_oe ( o_dqs_n_oe ),
.i_dq_hi ( i_dq_hi ),
.i_dq_lo ( i_dq_lo ),
.o_dq_hi ( o_dq_hi ),
.o_dq_lo ( o_dq_lo ),
.o_dq_oe ( o_dq_oe ),
.wr_datamask ( wr_datamask ),
.rd_data ( rd_data ),
.wr_data ( wr_data ),
.rd_ack ( rd_ack ),
.rd_valid ( rd_valid ),
.rd_en ( rd_en ),
.rd_addr_en ( rd_addr_en ),
.rd_addr ( rd_addr ),
.rd_busy ( rd_busy ),
.wr_ack ( wr_ack ),
.wr_addr_en ( wr_addr_en ),
.wr_en ( wr_en ),
.wr_addr ( wr_addr ),
.wr_busy ( wr_busy )
);
