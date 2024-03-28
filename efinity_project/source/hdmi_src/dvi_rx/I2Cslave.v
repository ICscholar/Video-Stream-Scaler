// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


///////////////////////////////////////////////////////////////////////////////
//
//  Alacron Inc. - Confidential: All Rights Reserved
//  Copyright (C) 2003
//
//  Title       : I2C Slave Control Logic
//  File        : I2CSLAVE.v
//  Author      : Gabor Szakacs
//  Created     : 25-May-2004 - Adapted from I2CSLAVE.abl
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  Description :
// This code implements an I2C slave-only controller.
// Access to internal registers uses the sub-address
// protocol like a serial EEPROM.  No registers are
// implemented in this module, however the module
// provides a simple bus interface to external registers.
// GLS - 12/13/00

// I2C inputs are oversampled by clk_in, which should run
// at a minimum of 5 MHz for a 100 KHz I2C bus.  The
// debouncing on the inputs has been tested at up to 80 MHz.
// The I2C 7-bit device address is set by i2c_address.  Address
// 0x6A was selected for FastImage because it doesn't
// conflict with other devices on board.

// Because of limitations in Xilinx Abel, the I/O buffers
// for the I2C SDA and SCL signals were external to this
// macro.

// Three 8-bit buses are implemented for read data, write
// data and subaddress.  For a simple implementation where
// only one 8-bit register is required, the subaddress may
// be used as the register output using simple write and
// read protocol on the I2C bus.  In this case looping the
// subaddress output to the read data bus allows register
// read-back.

// For use with multiple internal registers, the subaddress
// provides the register address.  The rd_wr_out output indicates
// the direction of the current I2C bus transaction and may
// be used to enable read data onto an externally combined
// read/write data bus.  The wr_pulse_out signal can be used as
// an active-high latch enable or clock enable for the
// external registers.  It comes on for one period of clk_in
// and the subaddress and data are valid for at least one
// clk_in period before and after wr_pulse_out.

// A rd_pulse_out output goes high for one clk_in period at the
// beginning of each data byte read.  This indicates the
// time when external data is latched from the read data
// bus.  It may be used to create side-effects on read
// such as clearing sticky status bits.
//
///////////////////////////////////////////////////////////////////////////////
//
//  Modules Instantiated: none
//
///////////////////////////////////////////////////////////////////////////////
//
//  Modification History:
//
//  Added clock enable to slow down state logic with fast input clock
//  6/9/05 - GLS.
//
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 100 ps
module I2Cslave
(
  sda_out,
  sda_in,
  scl_in,
  sda_oe,
  rd_bus_7_0_in,
  clk_in,
  clr_in,
  subaddr_7_0_out,
  wr_bus_7_0_out,
  wr_pulse_out,
  rd_pulse_out,
  rd_wr_out
);

parameter [6:0] I2C_ADDR =  7'h3a;
// Inputs:

// I2C inputs (SDA is I/O externally)
output sda_out;
input scl_in;
input sda_in;
output sda_oe;
// 8-bit bus for reading registers
input [7:0] rd_bus_7_0_in;
// High-speed clock for state machine logic
input clk_in;
// Asynchronous reset can be grounded for synthesis
input clr_in;

// Outputs:

// 8-bit subaddress for register selection
output [7:0] subaddr_7_0_out;
reg [7:0] subaddr_7_0_out;
// 8-bit bus for writing registers
output [7:0] wr_bus_7_0_out;//edid_wdata
reg [7:0] wr_bus_7_0_out;
// I2C data output drive low signal (1 = drive SDA low)
reg drive_sda;
// Register write pulse.  On for one clk_in cycle.
output wr_pulse_out;
reg wr_pulse_out;
// Register read pulse.  On for one clk_in cycle.
output rd_pulse_out;
reg rd_pulse_out;
// Read / not Write.  For external bus drivers if necessary.
output rd_wr_out;
reg rd_wr_out;

// Internal Nodes:

// I2C input debounced nodes:
reg [3:0] sda_sr, scl_sr;
reg sda, scl;
// I2C edge detection nodes:
reg was_sda, was_scl;
// Delayed pulses for address increment:
reg rd_pls_dly, wr_pls_dly;
// I2C protocol state nodes:
reg i2c_start, i2c_stop;
reg [2:0] byte_count;
reg ack_cyc;
reg addr_byte, addr_ack, subad_byte, subad_ack, data_byte;
// Edge detection:
reg was_ack;
reg my_cyc;
// Input data shift register
reg [7:0] in_sr;
// Output data shift register
reg [7:0] out_sr;

// internal node for bidirectional SDA line:
wire sda_in;

//IBUF sda_ibuf (.I (sda_io), .O (sda_in));
//OBUFE sda_obuf (.I (1'b0), .E (drive_sda), .O (sda_io));
assign sda_oe = (drive_sda == 1'b1);
assign sda_out = (drive_sda == 1'b1) ? 1'b0 : 1'b1;
//assign sda_in = sda_in;
//parameter i2c_address = 7'h50 >> 1;	// 6A write, 6B read


wire [6:0] i2c_address = I2C_ADDR /* synthesis keep = 1 */;
/*
 probe_edid_addr probe_edid_addr_u(
	.probe (),
	.source (i2c_address));
*/
// Equations

// Debounce, then delay debounced signals for edge detection
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      sda_sr <= 4'b1111;  // Start up assuming quiescent state of inputs
      sda <= 1;
      was_sda <= 0;
      scl_sr <= 4'b1111;  // Start up assuming quiescent state of inputs
      scl <= 1;
      was_scl <= 0;
    end
  else
    begin
      sda_sr <= {sda_sr[2:0], sda_in};
      if (sda_sr == 4'b0000) sda <= 0;//连续检测到4个低电平说明SDA是低电平
      else if (sda_sr == 4'b1111) sda <= 1;//连续检测到4个高电平说明SDA是高电平
      was_sda <= sda;
      scl_sr <= {scl_sr[2:0], scl_in};
      if (scl_sr == 4'b0000) scl <= 0;//连续检测到4个低电平说明SCL是低电平
      else if (scl_sr == 4'b1111) scl <= 1;//连续检测到4个高电平说明SCL是高电平
      was_scl <= scl;
    end

// Detect start and stop conditions on I2C bus:
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      i2c_start <= 0;
      i2c_stop <= 0;
    end
  else
    begin//判断SDA的起始位与终止位
      if (scl & was_scl & !sda & was_sda) i2c_start <= 1; // Falling edge of SDA with SCL high
      else if (!scl & !was_scl) i2c_start <= 0; // Hold until SCL has fallen
      i2c_stop <= scl & was_scl & sda & !was_sda ; // Rising edge of SDA with SCL high
      // i2c_stop is only on for one clock cycle
    end

// Increment bit counter on falling edges of the
// SCL signal after the first in a packet.
// Count bit position within bytes:
always @ (posedge clk_in or posedge i2c_start)
  if (i2c_start)
    begin
      ack_cyc <= 0;
      byte_count <= 0;
    end
  else if (!scl & was_scl & !i2c_start)//下降沿
    begin//计数接收到的数据位数
      // ack_cyc is really bit 3 of byte_count, counting from 0 to 8
      {ack_cyc,byte_count} <= ack_cyc ? 4'd0 : {ack_cyc,byte_count} + 4'd1;
    end

// For edge detection of ack cycles:
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      was_ack <= 0;
    end
  else
    begin
      was_ack <= ack_cyc;
    end

always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      addr_byte <= 0;
      addr_ack <= 0;
      subad_byte <= 0;
      subad_ack <= 0;
      wr_pulse_out <= 0;
      rd_pulse_out <= 0;
    end
  else
    begin
      // addr_byte is on during the first byte transmitted after
      // a START condition.
      if (i2c_start) addr_byte <= 1;
      else if (ack_cyc) addr_byte <= 0;
      // addr_ack is on during acknowledge cycle of the address
      // byte.
      if (addr_byte & ack_cyc) addr_ack <= 1;
      else if (!ack_cyc) addr_ack <= 0;
      // subad_byte is on for the second byte of my write cycle.
      if (addr_ack & !ack_cyc & !rd_wr_out & my_cyc) subad_byte <= 1;
      else if (ack_cyc) subad_byte <= 0;
      // subad_ack is on during the acknowledge cycle of the
      // subaddress byte.
      if (subad_byte & ack_cyc) subad_ack <= 1;
      else if (!ack_cyc) subad_ack <= 0;
      // data_byte is on for my read or write data cycles.  This is
      // any read cycle after the address, or write cycles after
      // the subaddress.  It remains on until the I2C STOP event or
      // any NACK.
      if (addr_ack & !ack_cyc & rd_wr_out & my_cyc | subad_ack & !ack_cyc) data_byte <= 1;
      else if (i2c_stop | ack_cyc & scl & sda) data_byte <= 0;
      // wr_pulse_out is on for one clock cycle while the data
      // on the output bus is valid.
      wr_pulse_out <= data_byte & !ack_cyc & was_ack & !rd_wr_out;
      // rd_pulse_out is on for one clock cycle when external
      // read data is transfered into the output shift register
      // for transmission to the I2C bus.
      rd_pulse_out <= addr_ack & !ack_cyc & rd_wr_out & my_cyc     // First read cycle
                | data_byte & !ack_cyc & was_ack & rd_wr_out ; // Subsequent read cycles
    end

// wr_bus_7_0_out is loaded from the I2C input S/R at the
// end of each write data cycle.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      wr_bus_7_0_out <= 0;
    end
  else if (data_byte & ack_cyc & !was_ack & !rd_wr_out)
    begin
      wr_bus_7_0_out <= in_sr;
    end

// out_sr shifts data out to the I2C bus during read
// data cycles.  Transitions occur after the falling
// edge of SCL.  Fills with 1's from right.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      out_sr <= 8'b11111111;
    end
  else
    begin
       if (rd_pulse_out) out_sr <= rd_bus_7_0_in;
       else if (!scl & was_scl) out_sr <= {out_sr[6:0],1'b1};
    end

// Delayed pulses for incrementing subaddress:
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      wr_pls_dly <= 0;
      rd_pls_dly <= 0;
    end
  else
    begin
      wr_pls_dly <= wr_pulse_out;
      rd_pls_dly <= rd_pulse_out;
    end

// subaddr_7_0_out is loaded after the second byte of a write
// cycle has fully shifted in.  It increments after each
// read or write access.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      subaddr_7_0_out <= 0;
    end
  else
    begin
      if (subad_byte & ack_cyc) subaddr_7_0_out <= in_sr;
		else if (subad_byte & ack_cyc & i2c_stop) subaddr_7_0_out <= 8; // Added for HDCP
      // Leave Out this else clause for simple single register version
      // In this case subaddr_7_0_out becomes the register output and should be
      // wrapped back to rd_bus_7_0_in externally
      else if (wr_pls_dly | rd_pls_dly) subaddr_7_0_out <= subaddr_7_0_out + 8'd1;
    end

// Shift I2C data in after rising edge of SCL.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      in_sr <= 0;
    end
  else if (scl & !was_scl)//SCL上升沿把数据保存下来
    begin
      in_sr <= {in_sr[6:0],sda};
    end

// Read / not Write.  For external bus drivers if necessary.
// Latch the Read bit of the address cycle.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      rd_wr_out <= 0;
    end
  else if (addr_byte & ack_cyc)
    begin
      rd_wr_out <= in_sr[0];//由I2C的数据格式知，第0位是读写指示信号
    end

// Decode address.  My cycle if address upper 7 bits
// match with i2c_address defined above.
always @ (posedge clk_in or posedge i2c_start)
  if (i2c_start)
    begin
    end
  else if (addr_byte & ack_cyc)
    begin
      my_cyc <= (in_sr[7:1] == i2c_address);
    end

// I2C data output drive low signal (1 = drive SDA low)
// Invert this signal for T input of OBUFT or IOBUF
// or use it directly for OBUFE.
always @ (posedge clk_in or posedge clr_in)
  if (clr_in)
    begin
      drive_sda <= 0;
    end
  else
    begin
      drive_sda <= my_cyc & addr_ack      // Address acknowledge
           | my_cyc & !rd_wr_out & ack_cyc    // Write byte acknowledge
           | data_byte & rd_wr_out & !ack_cyc & !out_sr[7] ;  // Read Data
    end

endmodule // I2Cslave
