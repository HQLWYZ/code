/*----------------------------------------------------------*/
/* 															*/
/*	file name:	ConfigReg.v				           			*/
/* 	date:		2025/03/06									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:													*/
/* 															*/
/*----------------------------------------------------------*/
`include "Default.v"
module ConfigReg(
	input			clk_in,
	input			rst_in,
    input           wr_in,
    input	[7:0]   wr_addr_in,
    input   [15:0]  data_in,
	output			trg_enb_out,
	output  	   	cmd_rst_out,
	output  	   	cycled_trg_bgn_out,

	output  [15:0]   ctrl_reg_out,
	output  [15:0]   cmd_reg_out,

    output  [1:0]   logic_grp0_sel_out,
	output  [5:0]   coincid_MIP1_div_out,
    output  [1:0]   logic_grp1_sel_out,
	output  [5:0]   coincid_MIP2_div_out,
    output  [1:0]   logic_grp2_sel_out,
    output  [1:0]   logic_grp3_sel_out,
    output  [1:0]   logic_grp4_sel_out,
	output  [5:0]   coincid_UBS_div_out,
	output  [1:0]   logic_burst_sel_out,
	output  reg[15:0]	trg_mode_mip1_reg, trg_mode_mip2_reg, trg_mode_gm1_reg,
	output	reg[15:0]	trg_mode_gm2_reg, trg_mode_ubs_reg, trg_mode_brst_reg,
	
	output  [15:0]  hit_ab_sel_out,
    output	[15:0]  hit_mask_out,
	output	[2:0]	hit_monit_fix_sel_out,
	output			busy_monit_fix_sel_out,
	output  [1:0]   busy_ab_sel_out,
    output  [1:0]   busy_mask_out,
    //output          busy_mask_set_out,//busy_mask_set_out = 1: ignore the TRB busy signal; 
    //output  [1:0]   busy_start_sel_out,
	output  [7:0]   acd_csi_hit_tim_diff_out, //default set 4us, e.g. 4us/20ns = 200
	output  [3:0]   acd_fee_top_hit_align_out,//default jitter is 40ns, 40ns/20ns = 2
	output  [3:0]   acd_fee_sec_hit_align_out,
	output  [3:0]   acd_fee_sid_hit_align_out,
	output  [3:0]   csi_hit_align_out,	//default jitter is 200ns, 200ns/20ns = 10 
	output  [3:0]   cal_fee_1_hit_align_out,
	output  [3:0]   cal_fee_2_hit_align_out,
	output  [3:0]   cal_fee_3_hit_align_out,
	output  [3:0]   cal_fee_4_hit_align_out,
    output  [7:0]   trg_match_win_out,//wait time for trigger windows
	output  [7:0]   trg_dead_time_out,//wait time for trigger windows
    output  [7:0]   logic_grp_oe_out,

    output  [7:0]   cycled_trg_period_out,
	output  [15:0]  cycled_trg_num_out,
	output  [7:0]   ext_trg_delay_out,
	output  [15:0]  config_received_out
	);
	
	reg		trg_enb_reg, cmd_rst_reg, cycled_trg_bgn_reg;
    reg     [15:0]	ctrl_reg, cmd_reg;
	reg     [15:0]	hit_ab_sel_reg, hit_mask_reg, busy_set_reg, hit_delay_win_reg;
	reg     [15:0]	hit_align_reg0, hit_align_reg1;
	reg     [15:0]	trg_match_win_reg, trg_dead_time_reg, trg_mode_oe_reg;
	reg     [15:0]	cycled_trg_period_reg, cycled_trg_num_reg;
	reg     [15:0]	ext_trg_delay_reg;

always @(posedge clk_in)
begin
    if (rst_in) begin    	
    	ctrl_reg <= `CTRL_REG;
		cmd_reg <= `CMD_REG;
		trg_mode_mip1_reg <= `TRG_MODE_MIP1_REG;
		trg_mode_mip2_reg <= `TRG_MODE_MIP2_REG;
		trg_mode_gm1_reg <= `TRG_MODE_GM1_REG; 
		trg_mode_gm2_reg <= `TRG_MODE_GM2_REG;
		trg_mode_ubs_reg <= `TRG_MODE_UBS_REG; 
		trg_mode_brst_reg <= `TRG_MODE_BRST_REG;
		hit_ab_sel_reg <= `HIT_AB_SEL_REG;
		hit_mask_reg <= `HIT_MASK_REG;
		busy_set_reg <= `BUSY_SET_REG;
		hit_delay_win_reg <= `HIT_DELAY_WIN_REG;
		hit_align_reg0 <= `HIT_ALIGN_REG_0;
		hit_align_reg1 <= `HIT_ALIGN_REG_1;
		trg_match_win_reg <= `TRG_MATCH_WIN_REG;
		trg_dead_time_reg <= `TRG_DEAD_TIME_REG;
		trg_mode_oe_reg <= `TRG_MODE_OE_REG;
		cycled_trg_period_reg <= `CYCLE_TRG_PERIOD_REG;
		cycled_trg_num_reg <= `CYCLE_TRG_NUM_REG;
		ext_trg_delay_reg <= `EXT_TRG_DELAY;
		cycled_trg_bgn_reg <= 1'b0;  
		cmd_rst_reg <= 1'b0;
		trg_enb_reg<=1'b0;  
	end
	else if (wr_in) begin
			case (wr_addr_in) //////* synthesis parallel_case */
				8'b0000_0000: begin
					ctrl_reg <= data_in;
					if(data_in==16'b0000_0000_0000_0001)
					   trg_enb_reg<=1'b1;
					else if(data_in==16'b0000_0000_0000_0000)
					   trg_enb_reg<=1'b0;   
				end
				8'b0000_0001: begin
					cmd_reg <= data_in;
					if(data_in==16'b0000_0000_0110_0000)
						cycled_trg_bgn_reg<=1'b1;
					else if(data_in==16'b0000_0000_0101_0101)
						cmd_rst_reg<=1'b1;
				end
				8'b0000_0010: trg_mode_mip1_reg <= data_in;
				8'b0000_0011: trg_mode_mip2_reg <= data_in;
				8'b0000_0100: trg_mode_gm1_reg <= data_in;
				8'b0000_0101: trg_mode_gm2_reg <= data_in;
				8'b0000_0110: trg_mode_ubs_reg <= data_in;
				8'b0000_0111: trg_mode_brst_reg <= data_in;
				8'b0000_1000: hit_ab_sel_reg <= data_in;
				8'b0000_1001: hit_mask_reg <= data_in;
				8'b0000_1010: busy_set_reg <= data_in;
				8'b0000_1011: hit_delay_win_reg <= data_in;
				8'b0000_1100: hit_align_reg0 <= data_in;
				8'b0000_1101: hit_align_reg1 <= data_in;
				8'b0000_1110: trg_match_win_reg <= data_in;
				8'b0000_1111: trg_dead_time_reg <= data_in;
				8'b0001_0000: trg_mode_oe_reg <= data_in;
				8'b0001_0001: cycled_trg_period_reg <= data_in;
				8'b0001_0010: cycled_trg_num_reg <= data_in;
				8'b0001_0011: ext_trg_delay_reg <= data_in;
			endcase
    end
end

reg 			wr_in_r;//wr_addr_in_r
reg 	[15:0]	config_received_cnt;

always @(posedge clk_in)
begin
    if (rst_in) begin
        wr_in_r <= 1'b0;
    end
    else begin
        wr_in_r <= wr_in;
    end
end

always @(posedge clk_in) //Count the number of configuration received
begin
	if (rst_in) begin
		config_received_cnt <= 16'b0;
	end
	else if (wr_in & ~wr_in_r) begin//leading edge of wr_addr_in
		config_received_cnt <= config_received_cnt+ 1'b1;
	end	

end

assign	trg_enb_out = trg_enb_reg;
assign	cmd_rst_out = cmd_rst_reg;
assign	cycled_trg_bgn_out = cycled_trg_bgn_reg;

assign	ctrl_reg_out = ctrl_reg[15:0];
assign	cmd_reg_out = cmd_reg[15:0];

assign	logic_grp0_sel_out 			= trg_mode_mip1_reg[7:6];//
assign	coincid_MIP1_div_out 		= trg_mode_mip1_reg[5:0];
assign	logic_grp1_sel_out 			= trg_mode_mip2_reg[7:6];//
assign	coincid_MIP2_div_out 		= trg_mode_mip2_reg[5:0];
assign	logic_grp2_sel_out 			= trg_mode_gm1_reg[7:6];//
assign	logic_grp3_sel_out 			= trg_mode_gm2_reg[7:6];//
assign	logic_grp4_sel_out 			= trg_mode_ubs_reg[7:6];
assign	coincid_UBS_div_out 		= trg_mode_ubs_reg[5:0];
assign	logic_burst_sel_out 		= trg_mode_brst_reg[7:6];
                      
assign	hit_ab_sel_out 				= hit_ab_sel_reg[15:0];
assign	hit_mask_out 				= hit_mask_reg[15:0];

assign	hit_monit_fix_sel_out 		= busy_set_reg[15:13]; 	//temperatory create this for fixed channel
assign	busy_monit_fix_sel_out 		= busy_set_reg[12];		//temperatory create this for fixed channel

assign	busy_ab_sel_out 			= busy_set_reg[7:6];
assign	busy_mask_out 				= busy_set_reg[5:4];
//assign	busy_mask_set_out 			= busy_set_reg[3];
//assign	busy_start_sel_out 			= busy_set_reg[1:0];
assign	acd_csi_hit_tim_diff_out 	= hit_delay_win_reg[7:0];
assign	acd_fee_top_hit_align_out 	= hit_align_reg0[15:12];//
assign	acd_fee_sec_hit_align_out 	= hit_align_reg0[11:8];
assign	acd_fee_sid_hit_align_out 	= hit_align_reg0[7:4];
assign	csi_hit_align_out 			= hit_align_reg0[3:0];//
assign	cal_fee_1_hit_align_out 	= hit_align_reg1[15:12];//
assign	cal_fee_2_hit_align_out 	= hit_align_reg1[11:8];
assign	cal_fee_3_hit_align_out 	= hit_align_reg1[7:4];
assign	cal_fee_4_hit_align_out 	= hit_align_reg1[3:0];

assign	trg_match_win_out 			= trg_match_win_reg[7:0];
assign	trg_dead_time_out 			= trg_dead_time_reg[7:0];
assign	logic_grp_oe_out 			= trg_mode_oe_reg[7:0];

assign	cycled_trg_period_out 		= cycled_trg_period_reg[7:0];
assign	cycled_trg_num_out 			= cycled_trg_num_reg[15:0];
assign	ext_trg_delay_out 			= ext_trg_delay_reg[7:0];
assign	config_received_out 		= config_received_cnt[15:0];


endmodule
