/*----------------------------------------------------------*/
/* 															*/
/*	file name:	ResetGen.v			           			    */
/* 	date:		2025/03/11									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:	system clock = 25MHz                            */
/* 															*/
/*----------------------------------------------------------*/

module ResetGen(
	input			clk_in,
	input			ctrl_rst_in, //from FPGA:high 
    input           cmd_rst_in,//from ConfigReg:high
    output          rst_logic_out_N,//"rst_logic_out_N": reset other modules,except ConfigReg 
    output          rst_intf_out_N//"rst_intf_out_N": reset the modules of ConfigReg 
	);
	
reg     [16:0]	    pulse_width_cnt;////use to counter the width of the "ctrl_rst_in", and fliter the short width pulse
reg     bp_rst_syn0_r, bp_rst_syn1_r;
wire    W_ctrl_rst_valid;

parameter   PULSE_WIDTH_200US = 5000; //200us
parameter   PULSE_WIDTH_2_5MS = 62500; //2.5ms

// synchronize the "ctrl_rst_in"
always @(posedge clk_in)
begin 
	bp_rst_syn0_r <= ctrl_rst_in;
	bp_rst_syn1_r <= bp_rst_syn0_r;
end

always @(posedge clk_in)
begin
	if (!bp_rst_syn1_r) begin //if the reset from the backplane is "low", 
		pulse_width_cnt <= 17'b0;
	end
	else begin
		pulse_width_cnt <= pulse_width_cnt + 1'b1;
	end
end

reg	pulse_width_flag00_r/* synthesis syn_preserve=1 */, pulse_width_flag01_r/* synthesis syn_preserve=1 */, pulse_width_flag02_r/* synthesis syn_preserve=1 */;
reg	pulse_width_flag10_r/* synthesis syn_preserve=1 */, pulse_width_flag11_r/* synthesis syn_preserve=1 */, pulse_width_flag12_r/* synthesis syn_preserve=1 */;
always @(posedge clk_in)
begin
	if (!bp_rst_syn1_r) begin
		pulse_width_flag00_r <= 1'b0;
		pulse_width_flag01_r <= 1'b0;
		pulse_width_flag02_r <= 1'b0;
		pulse_width_flag10_r <= 1'b0;
		pulse_width_flag11_r <= 1'b0;
		pulse_width_flag12_r <= 1'b0;
	end
	else begin
		if (pulse_width_cnt == PULSE_WIDTH_200US) begin// the pulse width of ctrl_rst_in is larger than 200us
			pulse_width_flag00_r <= 1'b1;
			pulse_width_flag01_r <= 1'b1;
			pulse_width_flag02_r <= 1'b1;
		end
		else if (pulse_width_cnt == PULSE_WIDTH_2_5MS) begin /// the pulse width of ctrl_rst_in is large than 2.5ms
			pulse_width_flag10_r <= pulse_width_flag00_r;
			pulse_width_flag11_r <= pulse_width_flag01_r;
			pulse_width_flag12_r <= pulse_width_flag02_r;
		end
		else if ((pulse_width_cnt < PULSE_WIDTH_200US) || (pulse_width_cnt > PULSE_WIDTH_2_5MS)) begin
			pulse_width_flag00_r <= 1'b0;
			pulse_width_flag01_r <= 1'b0;
			pulse_width_flag02_r <= 1'b0;
		end
	end
end

assign W_ctrl_rst_valid =  (pulse_width_flag10_r & pulse_width_flag11_r) 
                        | (pulse_width_flag10_r & pulse_width_flag12_r)
                        | (pulse_width_flag11_r & pulse_width_flag12_r) ;///tmr for the reset signal
assign	rst_logic_out_N = ~(W_ctrl_rst_valid | cmd_rst_in);
assign	rst_intf_out_N = ~W_ctrl_rst_valid;



endmodule