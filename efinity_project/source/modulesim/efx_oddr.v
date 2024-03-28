/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2016 Efinix Inc. All rights reserved.
//
// Efinix ODDR:
//
// This is a double-data rate output register with clock-enable 
// and programmable set/reset
// All of the data and control inputs are invertable
// the set/reset pin can be sync or async, set or reset
//
// It can be configured to accept data on opposite clock edges
// or the same clock edge.
//
//
// *******************************
// Revisions:
// 0.0 Initial rev
// *******************************
/////////////////////////////////////////////////////////////////////////////

module EFX_ODDR # 
(
 parameter CLK_POLARITY = 1'b1, // 0 falling edge, 1 rising edge
 parameter CE_POLARITY  = 1'b1, // 0 negative, 1 positive
 parameter SR_POLARITY  = 1'b1, // 0 negative, 1 positive
 parameter SR_SYNC      = 1'b0, // 0 async, 1 sync
 parameter SR_VALUE     = 1'b0, // 0 reset, 1 set
 parameter D0_POLARITY  = 1'b1, // 0 invert
 parameter D1_POLARITY  = 1'b1, // 0 invert
 parameter DDR_CLK_EDGE = 1'b1  // 0 opposite edge, 1 same edge
)
(
 input 	D0, // data 0 input
 input 	D1, // data 1 input
 input 	CE, // clock-enable
 input 	CLK, // clock
 input 	SR, // asyc/sync set/reset
 output Q    // data output
 );
   // Create nets for optional control inputs
   // allows us to assign to them without getting warning
   // for coercing input to inout
   wire     CE_net;
   wire     SR_net;

   // Default values for optional control signals
   assign (weak0, weak1) CE_net = CE_POLARITY ? 1'b1 : 1'b0;
   assign (weak0, weak1) SR_net = SR_POLARITY ? 1'b0 : 1'b1;

   // Now assign the input
   assign CE_net = CE;
   assign SR_net = SR;
   
   // Internal signals
   wire d0_int;
   wire d1_int;
   wire ce_int;
   wire ce1_int;
   wire clk_int;
   wire sr_int;
   wire sync_sr_int;
   wire sync_sr1_int;
   wire async_sr_int;
   reg 	q0_int = 1'b0;
   reg 	q1_pre = 1'b0;
   reg 	q1_int = 1'b0;
     
   // Check parameters and set internal signals appropriately
   
   // Check clock polarity
   assign clk_int = CLK_POLARITY ? CLK : ~CLK;
   
   // Check clock-enable polarity
   assign ce_int = CE_POLARITY ? CE_net : ~CE_net;
   
   // Check set/reset polarity
   assign sr_int = SR_POLARITY ? SR_net : ~SR_net;
   
   // Check data polarity
   assign d0_int = D0_POLARITY ? D0 : ~D0;
   assign d1_int = D1_POLARITY ? D1 : ~D1;
   
   // Decide if set/reset is sync or async
   assign sync_sr_int = SR_SYNC ? sr_int : 1'b0;
   assign async_sr_int = SR_SYNC ? 1'b0 : sr_int;
   
   // Actual FF guts, everything is positive logic
   // Capture both D0 & D1 on clk
   always @(posedge async_sr_int or posedge clk_int)
     // Only one of async/sync sr will be valid
     if (async_sr_int) begin 
		q0_int <= SR_VALUE;
		q1_pre <= SR_VALUE;
     end
     else if (ce_int) begin
		if (sync_sr_int) begin
		   q0_int <= SR_VALUE;
		   q1_pre <= SR_VALUE;
		end
		else begin
		   q0_int <= d0_int;
		   q1_pre <= d1_int;
		end
     end

   // If in DDR_CLK_EDGE is same edge we need
   // to ignore the sync controls on the second
   // register because the data capture was
   // already synchronized to the positive clk edge
   assign ce1_int = DDR_CLK_EDGE ? 1'b1 : ce_int;
   assign sync_sr1_int = DDR_CLK_EDGE ? 1'b0 : sync_sr_int;

   // Capture either q1 or q1_pre on negedge clk
   always @(posedge async_sr_int or negedge clk_int)
     // Only one of async/sync sr will be valid
     if (async_sr_int)
       q1_int <= SR_VALUE;
     else if (ce1_int)
       if (sync_sr1_int)
		 q1_int <= SR_VALUE;
       else
		 q1_int <= DDR_CLK_EDGE ? q1_pre : d1_int;

   // output q0_int on high-clock q1_int on low-clock
   assign Q = clk_int ? q0_int : q1_int;
   
endmodule // EFX_ODDR

//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2016 Efinix Inc. All rights reserved.
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
/////////////////////////////////////////////////////////////////////////////
