/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgMonData.v			           			*/
/* 	date:		2025/03/27									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module TrgMonData(
	input	        clk_in,
	input			rst_in_N,
    input           rd_in,  
    input   [7:0]   rd_addr_in,
    input   [15:0]  ctrl_reg_in,
    input   [15:0]  cmd_reg_in,
    input   [15:0]  trg_mode_mip1_in,
    input   [15:0]  trg_mode_mip2_in,
    input   [15:0]  trg_mode_gm1_in,
    input   [15:0]  trg_mode_gm2_in,
    input   [15:0]  trg_mode_ubs_in,
    input   [15:0]  trg_mode_brst_in,
    input   [15:0]  eff_trg_cnt_in,
    input   [15:0]  coincid_trg_cnt_in,
    input   [15:0]  hit_monit_fix_sel_in,
    input   [15:0]  hit_monit_sel_in,
    input   [15:0]  hit_monit_err_cnt_in,
    input   [15:0]  hit_start_cnt_in,
    input   [31:0]  hit_monit_cnt_0_in,
    input   [31:0]  hit_monit_cnt_1_in,
    input   [15:0]  busy_monit_fix_sel_in,
    input   [15:0]  busy_monit_err_cnt_in,
    input   [15:0]  busy_monit_cnt_in,
    input   [15:0]  coincid_MIP1_cnt_in,
    input   [15:0]  coincid_MIP2_cnt_in,
    input   [15:0]  coincid_GM1_cnt_in,
    input   [15:0]  coincid_GM2_cnt_in,
    input   [15:0]  coincid_UBS_cnt_in,
    input   [15:0]  logic_match_cnt_in,
    input   [15:0]  ext_trg_cnt_in,
    input   [15:0]  hit_ab_sel_in,
    input   [15:0]  busy_ab_sel_in,
    input   [15:0]  hit_mask_in,
    input   [15:0]  busy_mask_in,
    input   [15:0]  trg_match_win_in,
    input   [15:0]  trg_dead_time_in,
    input   [15:0]  config_received_in,
    input   [15:0]  ext_trg_delay_in,
    input   [15:0]  cycled_trg_period_in,
    output  [15:0]  mon_data_out
	);
	
reg         [15:0]	mon_data_reg;
wire        [15:0]	status_w, monit_hit_sel_w, hit_busy_ab_sel_w, hit_busy_mask_w;

always @(posedge clk_in or negedge rst_in_N)
begin
    if (!rst_in_N) begin    	
    	mon_data_reg <= 16'b0;
	end
	else if (rd_in) begin
			case (rd_addr_in) ///* synthesis parallel_case */
				//8'b0000_0000: 
				8'b0000_0010: mon_data_reg <= status_w;                 //from ConfigReg module
				8'b0000_0011: mon_data_reg <= trg_mode_mip1_in;        //from ConfigReg module
                8'b0000_0100: mon_data_reg <= trg_mode_mip2_in;         //from ConfigReg module
                8'b0000_0101: mon_data_reg <= trg_mode_gm1_in;          //from ConfigReg module
                8'b0000_0110: mon_data_reg <= trg_mode_gm2_in;          //from ConfigReg module
                8'b0000_0111: mon_data_reg <= trg_mode_ubs_in;          //from ConfigReg module
                8'b0000_1000: mon_data_reg <= trg_mode_brst_in;         //from ConfigReg module
                8'b0000_1001: mon_data_reg <= eff_trg_cnt_in;           //from HitTrgCount module
                8'b0000_1010: mon_data_reg <= coincid_trg_cnt_in;       //from HitTrgCount module
                8'b0000_1011: mon_data_reg <= monit_hit_sel_w;          //from HitTrgCount module
                8'b0000_1100: mon_data_reg <= hit_monit_err_cnt_in;     //from HitTrgCount module
                8'b0000_1101: mon_data_reg <= hit_start_cnt_in;         //from HitTrgCount module
                8'b0000_1110: mon_data_reg <= hit_monit_cnt_0_in[31:16];//from HitTrgCount module
                8'b0000_1111: mon_data_reg <= hit_monit_cnt_0_in[15:0]; //from HitTrgCount module
                8'b0001_0000: mon_data_reg <= hit_monit_cnt_1_in[31:16];//from HitTrgCount module
                8'b0001_0001: mon_data_reg <= hit_monit_cnt_1_in[15:0]; //from HitTrgCount module
                8'b0001_0010: mon_data_reg <= busy_monit_fix_sel_in;    //from HitTrgCount module
                8'b0001_0011: mon_data_reg <= busy_monit_err_cnt_in;    //from HitTrgCount module
                8'b0001_0100: mon_data_reg <= busy_monit_cnt_in;        //from HitTrgCount module
                8'b0001_0101: mon_data_reg <= coincid_MIP1_cnt_in;      //from Coincidence module
                8'b0001_0110: mon_data_reg <= coincid_MIP2_cnt_in;      //from Coincidence module
                8'b0001_0111: mon_data_reg <= coincid_GM1_cnt_in;       //from Coincidence module
                8'b0001_1000: mon_data_reg <= coincid_GM2_cnt_in;       //from Coincidence module
                8'b0001_1001: mon_data_reg <= coincid_UBS_cnt_in;       //from Coincidence module
                8'b0001_1010: mon_data_reg <= logic_match_cnt_in;       //from HitTrgCount module
                8'b0001_1011: mon_data_reg <= ext_trg_cnt_in;           //from HitTrgCount module
                8'b0001_1100: mon_data_reg <= hit_busy_ab_sel_w;        //from ConfigReg module
                8'b0001_1101: mon_data_reg <= hit_busy_mask_w;          //from ConfigReg module
                8'b0001_1110: mon_data_reg <= trg_match_win_in;         //from ConfigReg module
                8'b0001_1111: mon_data_reg <= trg_dead_time_in;         //from ConfigReg module
                8'b0010_0000: mon_data_reg <= config_received_in;       //from ConfigReg module
                8'b0010_0001: mon_data_reg <= ext_trg_delay_in;         //from ConfigReg module
                8'b0010_0010: mon_data_reg <= cycled_trg_period_in;      //from ConfigReg module
                8'b0010_0011: mon_data_reg <= 16'h5aa5;                 //backup 1
                8'b0010_0110: mon_data_reg <= 16'heb90;                 //backup 2
				default: ;
			endcase
    end
end




assign  status_w              = {ctrl_reg_in[7:0],cmd_reg_in[7:0]};       //from ConfigReg module(TBD)
assign  monit_hit_sel_w       = {hit_monit_fix_sel_in,hit_monit_sel_in};  //from HitTrgCount module
assign  hit_busy_ab_sel_w     = {hit_ab_sel_in,busy_ab_sel_in};           //from ConfigReg module
assign  hit_busy_mask_w       = {hit_mask_in,busy_mask_in};               //from ConfigReg module

assign  mon_data_out            = mon_data_reg;


endmodule
