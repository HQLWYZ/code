/*----------------------------------------------------------*/
/* 															*/
/*	file name:	GroundTestGen.v			           			*/
/* 	date:		2025/03/21									*/
/* 	modified:	2026/01/02								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module GroundTestGen(
	input			clk_in,
	input			rst_in,
    input           ext_trg_test_in,  	//external trigger sources
    input           coincid_trg_in,     //conincided trigger signal from coincidence  module
    input   [7:0]   ext_trg_delay_in,   // external trigger delay register from configuration module
    input   [1:0]   ext_trg_oe_in,      // external trigger output enable signal from configuration module
    output          coincid_trg_test_out_N,
    output          ext_trg_syn_out
	);
	
parameter       TRG_PULSE_WIDTH = 25; 	//20ns*25 = 500ns

reg 	        ext_trg_syn_r;//synchronize external trigger
reg             ext_trg_tmp0_r, ext_trg_tmp1_r, ext_trg_tmp2_r, ext_trg_enb_r;
reg     [7:0]	ext_trg_delay_cnt;
wire            ext_trg_oe;

always @(posedge clk_in)
begin
    if (rst_in) begin
        ext_trg_tmp0_r <= 1'b0;
        ext_trg_tmp1_r <= 1'b0;
        ext_trg_tmp2_r <= 1'b0;
    end
    else begin
        ext_trg_tmp0_r <= ext_trg_test_in;//~ext_trg_test_in
        ext_trg_tmp1_r <= ext_trg_tmp0_r;
        ext_trg_tmp2_r <= ext_trg_tmp1_r;         
    end
end

//delay the ext trigger, and send the syn trigger (1 clock width)
always @(posedge clk_in)
begin
	if (rst_in) begin
		ext_trg_syn_r <= 1'b0;
		ext_trg_enb_r <= 1'b0;
		ext_trg_delay_cnt <= 8'b0;
	end
	else if ( (ext_trg_delay_cnt >= ext_trg_delay_in) & ext_trg_enb_r) begin
		ext_trg_syn_r <= 1'b1;
		ext_trg_enb_r <= 1'b0;
		ext_trg_delay_cnt <= 8'b0;
	end
	else if (ext_trg_enb_r) begin
		ext_trg_syn_r <= 1'b0;
		ext_trg_delay_cnt <= ext_trg_delay_cnt + 1;
	end	
	else if ( (~ext_trg_tmp2_r) & ext_trg_tmp1_r ) begin//leading edge of external trigger signal
		ext_trg_syn_r <= 1'b0;
		ext_trg_enb_r <= 1'b1;
		ext_trg_delay_cnt <= 8'b0;
	end	
	else begin
		ext_trg_syn_r <= 1'b0;
		ext_trg_enb_r <= 1'b0;
		ext_trg_delay_cnt <= 8'b0;
	end		
end

//expand the width of coincided trigger pulse to 500ns
reg     [4:0]   coincid_trg_width_cnt;
reg             coincid_trg_etd_r;
always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_trg_width_cnt <= 5'b0;
		coincid_trg_etd_r <= 1'b0;
	end
	else if (coincid_trg_etd_r) begin		
		if (coincid_trg_width_cnt == TRG_PULSE_WIDTH) begin
			coincid_trg_etd_r <= 1'b0;
			coincid_trg_width_cnt <= 5'b0;
		end
		else begin
			coincid_trg_width_cnt <= coincid_trg_width_cnt + 1;
		end
	end		
	else if(coincid_trg_in) begin
		coincid_trg_etd_r <= 1'b1;
		coincid_trg_width_cnt <= 5'b0;
	end
	else begin
		coincid_trg_width_cnt <= 5'b0;
		coincid_trg_etd_r <= 1'b0;
	end
end

assign ext_trg_oe = (ext_trg_oe_in == 2'b01)? 1'b1:1'b0;

assign  coincid_trg_test_out_N = ~coincid_trg_etd_r;
assign	ext_trg_syn_out     = ext_trg_syn_r & ext_trg_oe;

endmodule
