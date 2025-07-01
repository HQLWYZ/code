`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 17:13:06
// Design Name: 
// Module Name: crc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//-----------------------------------------------------------------------------
// CRC-16/CCITT module for data[15:0] ,   crc[15:0]=1+x^5+x^12+x^16;
//-----------------------------------------------------------------------------
module crc16_ccitt(
  input [15:0] data_in,
  input crc_en,
  output [15:0] crc_out,
  input rst,
  input clk);

  reg [15:0] lfsr_q,lfsr_c;

  assign crc_out = lfsr_q;

  always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[12] ^ data_in[0] ^ data_in[4] ^ data_in[8] ^ data_in[11] ^ data_in[12];
    lfsr_c[1] = lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[13] ^ data_in[1] ^ data_in[5] ^ data_in[9] ^ data_in[12] ^ data_in[13];
    lfsr_c[2] = lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[14] ^ data_in[2] ^ data_in[6] ^ data_in[10] ^ data_in[13] ^ data_in[14];
    lfsr_c[3] = lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[3] ^ data_in[7] ^ data_in[11] ^ data_in[14] ^ data_in[15];
    lfsr_c[4] = lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[15] ^ data_in[4] ^ data_in[8] ^ data_in[12] ^ data_in[15];
    lfsr_c[5] = lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13];
    lfsr_c[6] = lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[13] ^ data_in[14];
    lfsr_c[7] = lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[11] ^ data_in[13] ^ data_in[14] ^ data_in[15];
    lfsr_c[8] = lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[15];
    lfsr_c[9] = lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[15] ^ data_in[4] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15];
    lfsr_c[10] = lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[14] ^ data_in[5] ^ data_in[9] ^ data_in[10] ^ data_in[13] ^ data_in[14];
    lfsr_c[11] = lfsr_q[6] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[6] ^ data_in[10] ^ data_in[11] ^ data_in[14] ^ data_in[15];
    lfsr_c[12] = lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[15] ^ data_in[0] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[15];
    lfsr_c[13] = lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[9] ^ data_in[1] ^ data_in[5] ^ data_in[8] ^ data_in[9];
    lfsr_c[14] = lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[10] ^ data_in[2] ^ data_in[6] ^ data_in[9] ^ data_in[10];
    lfsr_c[15] = lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[10] ^ lfsr_q[11] ^ data_in[3] ^ data_in[7] ^ data_in[10] ^ data_in[11];

  end

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_q <= {16{1'b1}};
    end
    else begin
      lfsr_q <= crc_en ? lfsr_c : lfsr_q;
    end
  end
endmodule
