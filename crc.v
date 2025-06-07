//-----------------------------------------------------------------------------
// CRC-16/USB module for data[7:0] ,   crc[15:0]=1+x^2+x^15+x^16;
//-----------------------------------------------------------------------------
module crc_16(
  input [7:0] crc_data_in,
  input crc_en,
  output [15:0] crc_out,
  input rst,
  input clk
);

  wire[7:0] data_in;
  assign data_in={crc_data_in[0],crc_data_in[1],crc_data_in[2],crc_data_in[3],crc_data_in[4],crc_data_in[5],crc_data_in[6],crc_data_in[7]};

  reg [15:0] lfsr_q,lfsr_c;

  //assign crc_out = lfsr_q;
  assign crc_out = {lfsr_q[0],lfsr_q[1],lfsr_q[2],lfsr_q[3],lfsr_q[4],lfsr_q[5],lfsr_q[6],lfsr_q[7],
  lfsr_q[8],lfsr_q[9],lfsr_q[10],lfsr_q[11],lfsr_q[12],lfsr_q[13],lfsr_q[14],lfsr_q[15]} ^ 16'hFFFF;

  always @(*) begin
    lfsr_c[0] = lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    lfsr_c[1] = lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    lfsr_c[2] = lfsr_q[8] ^ lfsr_q[9] ^ data_in[0] ^ data_in[1];
    lfsr_c[3] = lfsr_q[9] ^ lfsr_q[10] ^ data_in[1] ^ data_in[2];
    lfsr_c[4] = lfsr_q[10] ^ lfsr_q[11] ^ data_in[2] ^ data_in[3];
    lfsr_c[5] = lfsr_q[11] ^ lfsr_q[12] ^ data_in[3] ^ data_in[4];
    lfsr_c[6] = lfsr_q[12] ^ lfsr_q[13] ^ data_in[4] ^ data_in[5];
    lfsr_c[7] = lfsr_q[13] ^ lfsr_q[14] ^ data_in[5] ^ data_in[6];
    lfsr_c[8] = lfsr_q[0] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[6] ^ data_in[7];
    lfsr_c[9] = lfsr_q[1] ^ lfsr_q[15] ^ data_in[7];
    lfsr_c[10] = lfsr_q[2];
    lfsr_c[11] = lfsr_q[3];
    lfsr_c[12] = lfsr_q[4];
    lfsr_c[13] = lfsr_q[5];
    lfsr_c[14] = lfsr_q[6];
    lfsr_c[15] = lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
  end

  always @(posedge clk or negedge rst) begin
    if(!rst) begin
      lfsr_q <= {16{1'b1}};
    end
    else begin
      lfsr_q <= crc_en ? lfsr_c : lfsr_q;
    end
  end
endmodule

//-----------------------------------------------------------------------------
// CRC-8 module for data[7:0] ,   crc[7:0]=1+x+x^2+x^8;
//-----------------------------------------------------------------------------
module crc_8(
  input [7:0] data_in,
  input crc_en,
  output [7:0] crc_out,
  input rst,
  input clk);

  reg [7:0] lfsr_q,lfsr_c;

  assign crc_out = lfsr_q;

  always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[0] ^ data_in[6] ^ data_in[7];
    lfsr_c[1] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ data_in[0] ^ data_in[1] ^ data_in[6];
    lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[6] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6];
    lfsr_c[3] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[7] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
    lfsr_c[4] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ data_in[2] ^ data_in[3] ^ data_in[4];
    lfsr_c[5] = lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ data_in[3] ^ data_in[4] ^ data_in[5];
    lfsr_c[6] = lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ data_in[4] ^ data_in[5] ^ data_in[6];
    lfsr_c[7] = lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[5] ^ data_in[6] ^ data_in[7];

  end // always

  always @(posedge clk or negedge rst) begin
    if(!rst) begin
      lfsr_q <= {8{1'b0}};
    end
    else begin
      lfsr_q <= crc_en ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc