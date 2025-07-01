/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgTop.v			           			*/
/* 	date:		2025/04/21									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module TrgTop(
	input	        clk_in,
    input			ctrl_rst_in,    //to ResetGen module
    input           wr_in,          //to ConFigReg module
    input	[7:0]   wr_addr_in,     //to ConFigReg module
    input   [15:0]  data_in,        //to ConFigReg module
    input           rd_in,          //to TrgMonData module
    input   [7:0]   rd_addr_in,     //to TrgMonData module
//	input 			store_en,       //when starting to transmit, store the transient register value 
	input           fifo_rd_clk,    //to TrgSciData module
    input           fifo_rd_in,     //to TrgSciData module
    input           ext_trg_test_in, //to GroundTestGen module
    input    [1:0]  ext_trg_enb_sig,
    input           si_trb_1_busy_a_in_N,   //to Coincidence module
    input           si_trb_1_busy_b_in_N,
    input           si_trb_2_busy_a_in_N,
    input           si_trb_2_busy_b_in_N,
    input           acd_fee_top_hit_a_in_N,
    input           acd_fee_top_hit_b_in_N,
    input           acd_fee_sec_hit_a_in_N,
    input           acd_fee_sec_hit_b_in_N,
    input           acd_fee_sid_hit_a_in_N,
    input           acd_fee_sid_hit_b_in_N,
    input           csi_fee_hit_a_in_N,
    input           csi_fee_hit_b_in_N,
    input           cal_fee_1_hit_a_in_N,
    input           cal_fee_1_hit_b_in_N,
    input           cal_fee_2_hit_a_in_N,
    input           cal_fee_2_hit_b_in_N,
    input           cal_fee_3_hit_a_in_N,
    input           cal_fee_3_hit_b_in_N,
    input           cal_fee_4_hit_a_in_N,
    input           cal_fee_4_hit_b_in_N,   //to Coincidence module
    output  [7:0]   fifo_data_out,          //from TrgSciData module
    output          fifo_empty_out,         //from TrgSciData module
    output  [15:0]  mon_data_out,       //from TrgMonData module    
    output			trg_out_N_acd_a,//trig to acd(primary A)
    output			trg_out_N_acd_b,//trig to acd(backup B)
    output			trg_out_N_CsI_track_a,//trig to CsI_track(primary A)
    output			trg_out_N_CsI_track_b,//trig to CsI_track(backup B)
  //  output			trg_out_N_CsI_cal_a,//trig to CsI_cal(primary A)
 //   output			trg_out_N_CsI_cal_b,//trig to CsI_cal(backup B)
    output			trg_out_N_Si1_a,//trig to Si(primary A)
    output			trg_out_N_Si1_b,//trig to Si(backup B)
	 output			trg_out_N_Si2_a, 
    output			trg_out_N_Si2_b,
    output          trg_out_N_cal_fee_1_a, trg_out_N_cal_fee_1_b,trg_out_N_cal_fee_2_a, trg_out_N_cal_fee_2_b,
    output          trg_out_N_cal_fee_3_a, trg_out_N_cal_fee_3_b,trg_out_N_cal_fee_4_a, trg_out_N_cal_fee_4_b,
    
    output          trg_enb_sig,
    output          fifo_prog_full_out,
    output          data_trans_enb_sig,
    output          cmd_rst_sig
	
);
	
wire	[1:0]   logic_grp0_sel_sig;
wire	[5:0]   coincid_MIP1_div_sig;
wire	[1:0]   logic_grp1_sel_sig;
wire	[5:0]   coincid_MIP2_div_sig;
wire	[1:0]   logic_grp2_sel_sig;
wire	[1:0]   logic_grp3_sel_sig;
wire	[1:0]   logic_grp4_sel_sig;
wire	[5:0]   coincid_UBS_div_sig;
wire	[1:0]   logic_burst_sel_sig;
wire    [15:0]  trg_mode_mip1_sig;
wire    [15:0]  trg_mode_mip2_sig;
wire    [15:0]  trg_mode_gm1_sig;
wire    [15:0]  trg_mode_gm2_sig;
wire    [15:0]  trg_mode_ubs_sig;
wire    [15:0]  trg_mode_brst_sig;
wire			coincid_trg_test_sig;
wire	[15:0]  hit_ab_sel_sig;
wire	[15:0]  hit_mask_sig;
wire	[1:0]   busy_ab_sel_sig;
wire	[1:0]   busy_mask_sig;
wire	[7:0]   acd_csi_hit_tim_diff_sig; //default set 4us, e.g. 4us/20ns = 200 = 8'hC8
wire	[3:0]   acd_fee_top_hit_align_sig;//default jitter is 20ns, 40ns/20ns = 2 = 4'h2
wire	[3:0]   acd_fee_sec_hit_align_sig;
wire	[3:0]   acd_fee_sid_hit_align_sig;
wire	[3:0]   csi_hit_align_sig;	//default jitter is 200ns, 200ns/20ns = 10 = 4'h0a
wire	[3:0]   cal_fee_1_hit_align_sig;
wire	[3:0]   cal_fee_2_hit_align_sig;
wire	[3:0]   cal_fee_3_hit_align_sig;
wire	[3:0]   cal_fee_4_hit_align_sig;
wire	[15:0]   trg_match_win_sig;//wait time for trigger windows
wire	[7:0]   logic_grp_oe_sig;

wire 			coincid_trg_sig;
wire			logic_match_sig;
wire	[7:0]	hit_syn_sig;
wire	[1:0]	busy_syn_sig;
wire			hit_start_sig;
wire	[15:0]	coincid_MIP1_cnt_sig;
wire	[15:0]	coincid_MIP2_cnt_sig;
wire	[15:0]	coincid_GM1_cnt_sig;
wire	[15:0]	coincid_GM2_cnt_sig;
wire	[15:0]	coincid_UBS_cnt_sig;
wire          	coincid_trg_raw_1us_sig;
wire    [4:0]   coincid_tag_raw_sig;
wire    [23:0]  trg_busy_time_cnt_sig;
wire			trg_busy_timer_rdy_sig;
wire    [15:0]	hit_sig_stus_sig;
wire            si_busy_tmp;

//wire			trg_enb_sig;
wire  	   		cycled_trg_bgn_sig;
wire    [15:0]  ctrl_reg_sig;
wire    [15:0]  cmd_reg_sig;
wire    [7:0]   cycle_trg_period_sig;
wire    [15:0]  cycle_trg_num_sig;
wire    [7:0]   ext_trg_delay_sig;
wire    [15:0]  config_received_sig;

wire	[1:0]   cycled_trg_oe_sig;
wire  	[7:0]	cycled_trg_period_sig;
wire  	[15:0]	cycled_trg_num_sig;
wire          	cycled_trg_sig;
wire          	cycled_trg_end_sig;
wire	        cycled_trg_1us_sig;
wire          	daq_busy_sig;
wire          	ext_trg_oe_sig;
wire          	trg_test_sig;
wire          	ext_trg_syn_sig;
wire          	ext_trg_raw_1us_sig;
wire			update_end_sig;
wire			eff_trg_sig;
wire	[2:0]	hit_monit_fix_sel_sig;
wire			busy_monit_fix_sel_sig;
wire	[2:0]	hit_monit_sel_sig;
wire	[7:0]	hit_monit_err_cnt_sig;
wire	[7:0]	busy_monit_err_cnt_sig;
wire	[31:0]	hit_monit_cnt_0_sig;
wire	[31:0]	hit_monit_cnt_1_sig;
wire	[15:0]	busy_monit_cnt_sig;
wire	[15:0]	hit_start_cnt_sig;
wire	[15:0]	logic_match_cnt_sig;
wire	[15:0]	eff_trg_cnt_sig;
wire	[15:0]	coincid_trg_cnt_sig;
wire	[15:0]	ext_trg_cnt_sig;
wire    [7:0]   trg_delay_timer_sig;
wire    		rst_logic_sig, rst_intf_sig;
wire    [7:0]   trg_dead_time_sig;

ConfigReg ConfigReg_inst(
	.clk_in(clk_in),
	.rst_in(rst_intf_sig),
    .wr_in(wr_in),
    .wr_addr_in(wr_addr_in),
    .data_in(data_in),
	.trg_enb_out(trg_enb_sig),//enable or disable trigger output
	.data_trans_enb_out(data_trans_enb_sig),//enable or disable science and teldata transmission
	.cmd_rst_out(cmd_rst_sig),
	.cycled_trg_bgn_out(cycled_trg_bgn_sig),
    .ctrl_reg_out(ctrl_reg_sig),
    .cmd_reg_out(cmd_reg_sig),
    .logic_grp0_sel_out(logic_grp0_sel_sig),
	.coincid_MIP1_div_out(coincid_MIP1_div_sig),
    .logic_grp1_sel_out(logic_grp1_sel_sig),
	.coincid_MIP2_div_out(coincid_MIP2_div_sig),
    .logic_grp2_sel_out(logic_grp2_sel_sig),
    .logic_grp3_sel_out(logic_grp3_sel_sig),
    .logic_grp4_sel_out(logic_grp4_sel_sig),
	.coincid_UBS_div_out(coincid_UBS_div_sig),
	.logic_burst_sel_out(logic_burst_sel_sig),
	.trg_mode_mip1_reg(trg_mode_mip1_sig),
	.trg_mode_mip2_reg(trg_mode_mip2_sig),
	.trg_mode_gm1_reg(trg_mode_gm1_sig),
	.trg_mode_gm2_reg(trg_mode_gm2_sig),
	.trg_mode_ubs_reg(trg_mode_ubs_sig),
	.trg_mode_brst_reg(trg_mode_brst_sig),
	.hit_ab_sel_out(hit_ab_sel_sig),
    .hit_mask_out(hit_mask_sig),
    .hit_monit_fix_sel_out(hit_monit_fix_sel_sig),
    .busy_monit_fix_sel_out(busy_monit_fix_sel_sig),
	.busy_ab_sel_out(busy_ab_sel_sig),
    .busy_mask_out(busy_mask_sig),
    //.busy_mask_set_out(busy_set_reg),
    //.busy_start_sel_out(busy_start_sig),
	.acd_csi_hit_tim_diff_out(acd_csi_hit_tim_diff_sig), 
	.acd_fee_top_hit_align_out(acd_fee_top_hit_align_sig),
	.acd_fee_sec_hit_align_out(acd_fee_sec_hit_align_sig),
	.acd_fee_sid_hit_align_out(acd_fee_sid_hit_align_sig),
	.csi_hit_align_out(csi_hit_align_sig),	
	.cal_fee_1_hit_align_out(cal_fee_1_hit_align_sig),
	.cal_fee_2_hit_align_out(cal_fee_2_hit_align_sig),
	.cal_fee_3_hit_align_out(cal_fee_3_hit_align_sig),
	.cal_fee_4_hit_align_out(cal_fee_4_hit_align_sig),
    .trg_match_win_out(trg_match_win_sig),
	.trg_dead_time_out(trg_dead_time_sig),
    .logic_grp_oe_out(logic_grp_oe_sig),
    .cycled_trg_period_out(cycled_trg_period_sig),
	.cycled_trg_num_out(cycled_trg_num_sig),
	.ext_trg_delay_out(ext_trg_delay_sig),
	.config_received_out(config_received_sig)
	);

//---------- TRIG ----------
Coincidence Coincidence_inst(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig),
    .si_trb_1_busy_a_in_N(si_trb_1_busy_a_in_N),
    .si_trb_1_busy_b_in_N(si_trb_1_busy_b_in_N),
    .si_trb_2_busy_a_in_N(si_trb_2_busy_a_in_N),
    .si_trb_2_busy_b_in_N(si_trb_2_busy_b_in_N),
    .acd_fee_top_hit_a_in_N(acd_fee_top_hit_a_in_N),
    .acd_fee_top_hit_b_in_N(acd_fee_top_hit_b_in_N),
    .acd_fee_sec_hit_a_in_N(acd_fee_sec_hit_a_in_N),
    .acd_fee_sec_hit_b_in_N(acd_fee_sec_hit_b_in_N),
    .acd_fee_sid_hit_a_in_N(acd_fee_sid_hit_a_in_N),
    .acd_fee_sid_hit_b_in_N(acd_fee_sid_hit_b_in_N),
    .csi_fee_hit_a_in_N(csi_fee_hit_a_in_N),
    .csi_fee_hit_b_in_N(csi_fee_hit_b_in_N),
    .cal_fee_1_hit_a_in_N(cal_fee_1_hit_a_in_N),
    .cal_fee_1_hit_b_in_N(cal_fee_1_hit_b_in_N),
    .cal_fee_2_hit_a_in_N(cal_fee_2_hit_a_in_N),
    .cal_fee_2_hit_b_in_N(cal_fee_2_hit_b_in_N),
    .cal_fee_3_hit_a_in_N(cal_fee_3_hit_a_in_N),
    .cal_fee_3_hit_b_in_N(cal_fee_3_hit_b_in_N),
    .cal_fee_4_hit_a_in_N(cal_fee_4_hit_a_in_N),
    .cal_fee_4_hit_b_in_N(cal_fee_4_hit_b_in_N),
    .logic_grp0_sel_in(logic_grp0_sel_sig),
	.coincid_MIP1_div_in(coincid_MIP1_div_sig),
    .logic_grp1_sel_in(logic_grp1_sel_sig),
	.coincid_MIP2_div_in(coincid_MIP2_div_sig),
    .logic_grp2_sel_in(logic_grp2_sel_sig),
    .logic_grp3_sel_in(logic_grp3_sel_sig),
    .logic_grp4_sel_in(logic_grp4_sel_sig),
	.coincid_UBS_div_in(coincid_UBS_div_sig),
	.logic_burst_sel_in(logic_burst_sel_sig),
    .hit_ab_sel_in(hit_ab_sel_sig),
	.hit_mask_in(hit_mask_sig),
	.busy_ab_sel_in(busy_ab_sel_sig),
	.busy_mask_in(busy_mask_sig),
	.acd_csi_hit_tim_diff_in(acd_csi_hit_tim_diff_sig), 
	.acd_fee_top_hit_align_in(acd_fee_top_hit_align_sig),
	.acd_fee_sec_hit_align_in(acd_fee_sec_hit_align_sig),
	.acd_fee_sid_hit_align_in(acd_fee_sid_hit_align_sig),
	.csi_hit_align_in(csi_hit_align_sig),	
	.cal_fee_1_hit_align_in(cal_fee_1_hit_align_sig),
	.cal_fee_2_hit_align_in(cal_fee_2_hit_align_sig),
	.cal_fee_3_hit_align_in(cal_fee_3_hit_align_sig),
	.cal_fee_4_hit_align_in(cal_fee_4_hit_align_sig),
    .trg_match_win_in(trg_match_win_sig),
	.logic_grp_oe_in(logic_grp_oe_sig[4:0]),
    .coincid_trg_out(coincid_trg_sig),
    .logic_match_out(logic_match_sig),
    .hit_syn_out(hit_syn_sig),
	.busy_syn_out(busy_syn_sig),
    .hit_start_out(hit_start_sig),
	//.busy_start_out(busy_start_sig),
    .coincid_MIP1_cnt_out(coincid_MIP1_cnt_sig),
    .coincid_MIP2_cnt_out(coincid_MIP2_cnt_sig),
	.coincid_GM1_cnt_out(coincid_GM1_cnt_sig),
    .coincid_GM2_cnt_out(coincid_GM2_cnt_sig),
    .coincid_UBS_cnt_out(coincid_UBS_cnt_sig),
    .coincid_trg_raw_1us_out(coincid_trg_raw_1us_sig),
    .coincid_tag_raw_out(coincid_tag_raw_sig),
	.trg_busy_time_cnt_out(trg_busy_time_cnt_sig),
	.trg_busy_timer_rdy_out(trg_busy_timer_rdy_sig),
	.hit_sig_stus_out(hit_sig_stus_sig),
	.si_busy_tmp(si_busy_tmp)
	);

CycledTrgGen CycledTrgGen_inst(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig),
    .cycled_trg_oe_in(2'b11),
    .cycled_trg_bgn_in(cycled_trg_bgn_sig),
    .cycled_trg_period_in(cycled_trg_period_sig),
    .cycled_trg_num_in(cycled_trg_num_sig),
    .cycled_trg_out(cycled_trg_sig),
    .cycled_trg_end_out(cycled_trg_end_sig),
    .cycled_trg_1us_out(cycled_trg_1us_sig)
	);

GroundTestGen GroundTestGen_inst(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig),
    .ext_trg_test_in(ext_trg_test_in),
    //.trg_in_N(trg_in_N),
    .coincid_trg_in(coincid_trg_sig),
    //.daq_busy_in(daq_busy_sig),
    //.logic_match_in(logic_match_sig),
    .ext_trg_delay_in(ext_trg_delay_sig),
    .ext_trg_oe_in(ext_trg_enb_sig),
    //.logic_match_out_N(logic_match_sig),
    //.daq_busy_out_N(daq_busy_sig),
    .coincid_trg_test_out_N(coincid_trg_test_sig),
    //.trg_test_out_N(trg_test_sig),
    .ext_trg_syn_out(ext_trg_syn_sig),
    .ext_trg_raw_1us_out(ext_trg_raw_1us_sig)
);

TrgOutCtrl TrgOutCtrl_inst(
    .clk_in(clk_in),
    .rst_in(rst_logic_sig),
    .coincid_trg_in(coincid_trg_sig),
    .ext_trg_syn_in(ext_trg_syn_sig),
    .cycled_trg_in(cycled_trg_sig),
    .trg_enb_in(trg_enb_sig),//start work and generate trigger
    .trg_dead_time_in(trg_dead_time_sig),
    .eff_trg_cnt_in(eff_trg_cnt_sig),
    .eff_trg_out(eff_trg_sig),
    .trg_out_N_acd_a(trg_out_N_acd_a),//trig to acd(primary A)
    .trg_out_N_acd_b(trg_out_N_acd_b),//trig to acd(backup B)
    .trg_out_N_CsI_track_a(trg_out_N_CsI_track_a),//trig to CsI_track(primary A)
    .trg_out_N_CsI_track_b(trg_out_N_CsI_track_b),//trig to CsI_track(backup B)
    //.trg_out_N_CsI_cal_a(trg_out_N_CsI_cal_a),//trig to CsI_cal(primary A)
    //.trg_out_N_CsI_cal_b(trg_out_N_CsI_cal_b),//trig to CsI_cal(backup B)
    .trg_out_N_Si1_a(trg_out_N_Si1_a),//trig to Si(primary A)
    .trg_out_N_Si1_b(trg_out_N_Si1_b), 
	 .trg_out_N_Si2_a(trg_out_N_Si2_a),
	 .trg_out_N_Si2_b(trg_out_N_Si2_b),
	 .trg_out_N_cal_fee_1_a(trg_out_N_cal_fee_1_a), 
	 .trg_out_N_cal_fee_1_b(trg_out_N_cal_fee_1_b),
	 .trg_out_N_cal_fee_2_a(trg_out_N_cal_fee_2_a), 
	 .trg_out_N_cal_fee_2_b(trg_out_N_cal_fee_2_b),
    .trg_out_N_cal_fee_3_a(trg_out_N_cal_fee_3_a), 
	 .trg_out_N_cal_fee_3_b(trg_out_N_cal_fee_3_b),
	 .trg_out_N_cal_fee_4_a(trg_out_N_cal_fee_4_a), 
	 .trg_out_N_cal_fee_4_b(trg_out_N_cal_fee_4_b) 
	 
);

HitTrgCount HitTrgCount_inst(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig), 
	.hit_syn_in(hit_syn_sig),
	.busy_syn_in(busy_syn_sig),
	.hit_start_in(hit_start_sig),
	.update_end_in(update_end_sig),
	.eff_trg_in(eff_trg_sig),
	.coincid_trg_in(coincid_trg_sig),
	.logic_match_in(logic_match_sig),
	.ext_trg_syn_in(ext_trg_syn_sig),
	.hit_monit_fix_sel_in(hit_monit_fix_sel_sig),	
	.busy_monit_fix_sel_in(busy_monit_fix_sel_sig),	
	.hit_monit_sel_out(hit_monit_sel_sig),		
	.hit_monit_err_cnt_out(hit_monit_err_cnt_sig),	
	.busy_monit_err_cnt_out(busy_monit_err_cnt_sig),	
	.hit_monit_cnt_0_out(hit_monit_cnt_0_sig),	
	.hit_monit_cnt_1_out(hit_monit_cnt_1_sig),	
	.busy_monit_cnt_out(busy_monit_cnt_sig),		
	.hit_start_cnt_out(hit_start_cnt_sig), 		
	.logic_match_cnt_out(logic_match_cnt_sig), 	
	.eff_trg_cnt_out(eff_trg_cnt_sig), 		
	.coincid_trg_cnt_out(coincid_trg_cnt_sig), 	
	.ext_trg_cnt_out(ext_trg_cnt_sig),
	.trg_delay_timer_out(trg_delay_timer_sig)			
	);

TrgMonData TrgMonData_inst(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig),
    .rd_in(rd_in),  
    .rd_addr_in(rd_addr_in),
//    .store_en(store_en),
    .ctrl_reg_in(ctrl_reg_sig),
    .cmd_reg_in(cmd_reg_sig),
    .trg_mode_mip1_in(trg_mode_mip1_sig),
    .trg_mode_mip2_in(trg_mode_mip2_sig),
    .trg_mode_gm1_in(trg_mode_gm1_sig),
    .trg_mode_gm2_in(trg_mode_gm2_sig),
    .trg_mode_ubs_in(trg_mode_ubs_sig),
    .trg_mode_brst_in(trg_mode_brst_sig),
    .eff_trg_cnt_in(eff_trg_cnt_sig),
    .coincid_trg_cnt_in(coincid_trg_cnt_sig),
    .hit_monit_fix_sel_in({13'b0_0000_0000_0000, hit_monit_fix_sel_sig}), 
    .hit_monit_sel_in({13'b0_0000_0000_0000, hit_monit_sel_sig}),
    .hit_monit_err_cnt_in({8'b0000_0000, hit_monit_err_cnt_sig}),
    .hit_start_cnt_in(hit_start_cnt_sig),
    .hit_monit_cnt_0_in(hit_monit_cnt_0_sig),
    .hit_monit_cnt_1_in(hit_monit_cnt_1_sig),
    .busy_monit_fix_sel_in({15'b000_0000_0000_0000, busy_monit_fix_sel_sig}),
    .busy_monit_err_cnt_in({8'b0000_0000, busy_monit_err_cnt_sig}),
    .busy_monit_cnt_in(busy_monit_cnt_sig),
    .coincid_MIP1_cnt_in(coincid_MIP1_cnt_sig),
    .coincid_MIP2_cnt_in(coincid_MIP2_cnt_sig),
    .coincid_GM1_cnt_in(coincid_GM1_cnt_sig),
    .coincid_GM2_cnt_in(coincid_GM2_cnt_sig),
    .coincid_UBS_cnt_in(coincid_UBS_cnt_sig),
    .logic_match_cnt_in(logic_match_cnt_sig),
    .ext_trg_cnt_in(ext_trg_cnt_sig),
    .hit_ab_sel_in(hit_ab_sel_sig),
    .busy_ab_sel_in({14'b00_0000_0000_0000, busy_ab_sel_sig}),
    .hit_mask_in(hit_mask_sig),
    .busy_mask_in({14'b00_0000_0000_0000, busy_mask_sig}),
    .trg_match_win_in(trg_match_win_sig),
    .trg_dead_time_in({8'b0000_0000, trg_dead_time_sig}),
    .config_received_in(config_received_sig),
    .ext_trg_delay_in({8'b0000_0000, ext_trg_delay_sig}),
    .cycled_trg_period_in({8'b0000_0000, cycled_trg_period_sig}),
	.logic_grp_oe_in(logic_grp_oe_sig),
    .mon_data_out(mon_data_out)
	);

TrgSciData TrgSciData_inst
(
	.clk_in(clk_in),
	.rst_in(rst_logic_sig),
	.data_trans_enb_sig(data_trans_enb_sig),
	.fifo_rd_clk(fifo_rd_clk),
    .fifo_rd_in(fifo_rd_in),  
    .trg_mode_mip1_in(trg_mode_mip1_sig[7:0]),
    .trg_mode_mip2_in(trg_mode_mip2_sig[7:0]),
    .trg_mode_gm1_in(trg_mode_gm1_sig[7:0]),
    .trg_mode_gm2_in(trg_mode_gm2_sig[7:0]),
    .trg_mode_ubs_in(trg_mode_ubs_sig[7:0]),
    .trg_mode_brst_in(trg_mode_brst_sig[7:0]),
    .hit_sig_stus_in(hit_sig_stus_sig), 
    .eff_trg_cnt_in(eff_trg_cnt_sig),
    .trg_busy_time_cnt_in(trg_busy_time_cnt_sig),
    .trg_delay_timer_in(trg_delay_timer_sig),
    .trg_busy_timer_rdy_in(trg_busy_timer_rdy_sig),
    .eff_trg_in(eff_trg_sig),
    .fifo_data_out(fifo_data_out),
    .fifo_prog_full_out(fifo_prog_full_out),
    .fifo_empty_out(fifo_empty_out)
);

ResetGen inst_ResetGen(
	.clk_in(clk_in),
	.ctrl_rst_in(ctrl_rst_in),
    .cmd_rst_in(cmd_rst_sig),
    .rst_logic_out(rst_logic_sig),
    .rst_intf_out(rst_intf_sig)
	);

endmodule
