/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgMonData.v			           			*/
/* 	date:		2025/03/27									*/
/* 	modified:	2026/01/07								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module TrgMonData(
	input	        clk_in,
	input			rst_in,
    input           rd_in,  
    input   [7:0]   rd_addr_in,
    input   [15:0]  ctrl_reg_in,//[7:0]
    input   [15:0]  cmd_reg_in,//[7:0]
    input   [15:0]  trg_mode_mip1_in,
    input   [15:0]  trg_mode_mip2_in,
    input   [15:0]  trg_mode_gm1_in,
    input   [15:0]  trg_mode_gm2_in,
    input   [15:0]  trg_mode_ubs_in,
    input   [15:0]  trg_mode_brst_in,
    input   [15:0]  eff_trg_cnt_in,
    input   [15:0]  coincid_trg_cnt_in,
    input   [15:0]  hit_monit_fix_sel_in,//[7:0]
    input   [15:0]  hit_monit_sel_in,//[7:0]
    input   [15:0]  hit_monit_err_cnt_in,
    input   [15:0]  hit_start_cnt_in,
    input   [31:0]  hit_monit_cnt_0_in,
    input   [31:0]  hit_monit_cnt_1_in,
    input   [15:0]  busy_monit_fix_sel_in,//[7:0]
    input   [15:0]  busy_monit_err_cnt_in,//NO means
    input   [15:0]  busy_monit_cnt_in,
    input   [15:0]  coincid_MIP1_cnt_in,
    input   [15:0]  coincid_MIP2_cnt_in,
    input   [15:0]  coincid_GM1_cnt_in,
    input   [15:0]  coincid_GM2_cnt_in,
    input   [31:0]  coincid_UBS_cnt_in,
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
	input	[7:0]	logic_grp_oe_in,
    output  [15:0]  mon_data_out
	);
	
reg         [15:0]	mon_data_reg;
wire        [15:0]	status_w, monit_hit_sel_w, hit_busy_ab_sel_w, hit_busy_mask_w;
reg         [15:0]  status_w_r, trg_mode_mip1_in_r, trg_mode_mip2_in_r, trg_mode_gm1_in_r, trg_mode_gm2_in_r,
trg_mode_ubs_in_r, trg_mode_brst_in_r, eff_trg_cnt_in_r, coincid_trg_cnt_in_r, monit_hit_sel_w_r, hit_monit_err_cnt_in_r,
hit_start_cnt_in_r, hit_monit_cnt_0_in_r1, hit_monit_cnt_0_in_r0, hit_monit_cnt_1_in_r1, hit_monit_cnt_1_in_r0, 
busy_monit_fix_sel_in_r, busy_monit_err_cnt_in_r, busy_monit_cnt_in_r, coincid_MIP1_cnt_in_r, coincid_MIP2_cnt_in_r,
coincid_GM1_cnt_in_r, coincid_GM2_cnt_in_r, coincid_UBS_cnt_in_r1, coincid_UBS_cnt_in_r0, logic_match_cnt_in_r, ext_trg_cnt_in_r,
hit_busy_ab_sel_w_r, hit_busy_mask_w_r, trg_match_win_in_r, trg_dead_time_in_r, config_received_in_r, ext_trg_delay_in_r, cycled_trg_period_in_r, logic_grp_oe_in_r;                

reg rd_in_r;
always@(posedge clk_in)
    if(rst_in)	
		rd_in_r <= 1'b0;
	else
		rd_in_r <= rd_in;

always@(posedge clk_in)
    if(rst_in)
    begin
        status_w_r <= 16'd0;
        trg_mode_mip1_in_r <= 16'd0;
        trg_mode_mip2_in_r <= 16'd0;
        trg_mode_gm1_in_r <= 16'd0;
        trg_mode_gm2_in_r <= 16'd0;
        trg_mode_ubs_in_r <= 16'd0;
        trg_mode_brst_in_r <= 16'd0;
        eff_trg_cnt_in_r <= 16'd0;
        coincid_trg_cnt_in_r <= 16'd0;
        monit_hit_sel_w_r <= 16'd0;
        hit_monit_err_cnt_in_r <= 16'd0;
        hit_start_cnt_in_r <= 16'd0;
        hit_monit_cnt_0_in_r1 <= 16'd0;
        hit_monit_cnt_0_in_r0 <= 16'd0;
        hit_monit_cnt_1_in_r1 <= 16'd0;
        hit_monit_cnt_1_in_r0 <= 16'd0; 
        busy_monit_fix_sel_in_r <= 16'd0;
        busy_monit_err_cnt_in_r <= 16'd0; 
        busy_monit_cnt_in_r <= 16'd0;
        coincid_MIP1_cnt_in_r <= 16'd0; 
        coincid_MIP2_cnt_in_r <= 16'd0;
        coincid_GM1_cnt_in_r <= 16'd0; 
        coincid_GM2_cnt_in_r <= 16'd0;
        coincid_UBS_cnt_in_r1 <= 16'd0;
        coincid_UBS_cnt_in_r0 <= 16'd0;
        logic_match_cnt_in_r <= 16'd0;
        ext_trg_cnt_in_r <= 16'd0;
        hit_busy_ab_sel_w_r <= 16'd0;
        hit_busy_mask_w_r <= 16'd0;
        trg_match_win_in_r <= 16'd0;
        trg_dead_time_in_r <= 16'd0;
        config_received_in_r <= 16'd0;
        ext_trg_delay_in_r <= 16'd0;
        cycled_trg_period_in_r <= 16'd0;
		logic_grp_oe_in_r <= 16'd0;
    end
    else
        //if(store_en)
		if(rd_in & ~rd_in_r & (rd_addr_in == 8'b0001_1001))
        begin//
            status_w_r <= status_w;
            trg_mode_mip1_in_r <= trg_mode_mip1_in;
            trg_mode_mip2_in_r <= trg_mode_mip2_in;
            trg_mode_gm1_in_r <= trg_mode_gm1_in;
            trg_mode_gm2_in_r <= trg_mode_gm2_in;
            trg_mode_ubs_in_r <= trg_mode_ubs_in;
            trg_mode_brst_in_r <= trg_mode_brst_in;
            eff_trg_cnt_in_r <= eff_trg_cnt_in;
            coincid_trg_cnt_in_r <= coincid_trg_cnt_in;
            monit_hit_sel_w_r <= monit_hit_sel_w;
            hit_monit_err_cnt_in_r <= hit_monit_err_cnt_in;
            hit_start_cnt_in_r <= hit_start_cnt_in;
            hit_monit_cnt_0_in_r1 <= hit_monit_cnt_0_in[31:16];
            hit_monit_cnt_0_in_r0 <= hit_monit_cnt_0_in[15:0];
            hit_monit_cnt_1_in_r1 <= hit_monit_cnt_1_in[31:16];
            hit_monit_cnt_1_in_r0 <= hit_monit_cnt_1_in[15:0]; 
            busy_monit_fix_sel_in_r <= busy_monit_fix_sel_in;
            busy_monit_err_cnt_in_r <= busy_monit_err_cnt_in; 
            busy_monit_cnt_in_r <= busy_monit_cnt_in;
            coincid_MIP1_cnt_in_r <= coincid_MIP1_cnt_in; 
            coincid_MIP2_cnt_in_r <= coincid_MIP2_cnt_in;
            coincid_GM1_cnt_in_r <= coincid_GM1_cnt_in; 
            coincid_GM2_cnt_in_r <= coincid_GM2_cnt_in;
            coincid_UBS_cnt_in_r1 <= coincid_UBS_cnt_in[31:16];
            coincid_UBS_cnt_in_r0 <= coincid_UBS_cnt_in[15:0];
            logic_match_cnt_in_r <= logic_match_cnt_in;
            ext_trg_cnt_in_r <= ext_trg_cnt_in;
            hit_busy_ab_sel_w_r <= hit_busy_ab_sel_w;
            hit_busy_mask_w_r <= hit_busy_mask_w;
            trg_match_win_in_r <= trg_match_win_in;
            trg_dead_time_in_r <= trg_dead_time_in;
            config_received_in_r <= config_received_in;
            ext_trg_delay_in_r <= ext_trg_delay_in;
            cycled_trg_period_in_r <= cycled_trg_period_in;
			logic_grp_oe_in_r <= {8'd0, logic_grp_oe_in};
        end
            
always @(posedge clk_in)
begin
    if (rst_in) begin    	
    	mon_data_reg <= 16'b0;
	end
	else if (rd_in) begin
			case (rd_addr_in) ///* synthesis parallel_case */
				//8'b0000_0000: 
				8'b0001_1001: mon_data_reg <= status_w_r;                 //from ConfigReg module
				8'b0001_1010: mon_data_reg <= trg_mode_mip1_in_r;        //from ConfigReg module
                8'b0001_1011: mon_data_reg <= trg_mode_mip2_in_r;         //from ConfigReg module
                8'b0001_1100: mon_data_reg <= trg_mode_gm1_in_r;          //from ConfigReg module
                8'b0001_1101: mon_data_reg <= trg_mode_gm2_in_r;          //from ConfigReg module
                8'b0001_1110: mon_data_reg <= trg_mode_ubs_in_r;          //from ConfigReg module
                8'b0001_1111: mon_data_reg <= trg_mode_brst_in_r;         //from ConfigReg module
                8'b0010_0000: mon_data_reg <= eff_trg_cnt_in_r;           //from HitTrgCount module
                8'b0010_0001: mon_data_reg <= coincid_trg_cnt_in_r;       //from HitTrgCount module
                8'b0010_0010: mon_data_reg <= monit_hit_sel_w_r;          //from HitTrgCount module
                8'b0010_0011: mon_data_reg <= hit_monit_err_cnt_in_r;     //from HitTrgCount module
                8'b0010_0100: mon_data_reg <= hit_start_cnt_in_r;         //from HitTrgCount module
                8'b0010_0101: mon_data_reg <= hit_monit_cnt_0_in_r1;    //from HitTrgCount module
                8'b0010_0110: mon_data_reg <= hit_monit_cnt_0_in_r0;    //from HitTrgCount module
                8'b0010_0111: mon_data_reg <= hit_monit_cnt_1_in_r1;    //from HitTrgCount module
                8'b0010_1000: mon_data_reg <= hit_monit_cnt_1_in_r0;    //from HitTrgCount module
                8'b0010_1001: mon_data_reg <= busy_monit_fix_sel_in_r;    //from HitTrgCount module
                8'b0010_1010: mon_data_reg <= busy_monit_err_cnt_in_r;    //from HitTrgCount module
                8'b0010_1011: mon_data_reg <= busy_monit_cnt_in_r;        //from HitTrgCount module
                8'b0010_1100: mon_data_reg <= coincid_MIP1_cnt_in_r;      //from Coincidence module
                8'b0010_1101: mon_data_reg <= coincid_MIP2_cnt_in_r;      //from Coincidence module
                8'b0010_1110: mon_data_reg <= coincid_GM1_cnt_in_r;       //from Coincidence module
                8'b0010_1111: mon_data_reg <= coincid_GM2_cnt_in_r;       //from Coincidence module
                8'b0011_0000: mon_data_reg <= coincid_UBS_cnt_in_r1;       //from Coincidence module
                8'b0011_0001: mon_data_reg <= coincid_UBS_cnt_in_r0;       //from Coincidence module
                8'b0011_0010: mon_data_reg <= logic_match_cnt_in_r;       //from HitTrgCount module
                8'b0011_0011: mon_data_reg <= ext_trg_cnt_in_r;           //from HitTrgCount module
                8'b0011_0100: mon_data_reg <= hit_busy_ab_sel_w_r;        //from ConfigReg module
                8'b0011_0101: mon_data_reg <= hit_busy_mask_w_r;          //from ConfigReg module
                8'b0011_0110: mon_data_reg <= trg_match_win_in_r;         //from ConfigReg module
                8'b0011_0111: mon_data_reg <= trg_dead_time_in_r;         //from ConfigReg module
                8'b0011_1000: mon_data_reg <= config_received_in_r;       //from ConfigReg module
                8'b0011_1001: mon_data_reg <= ext_trg_delay_in_r;         //from ConfigReg module
                8'b0011_1010: mon_data_reg <= cycled_trg_period_in_r;      //from ConfigReg module
                8'b0011_1011: mon_data_reg <= logic_grp_oe_in_r;                 //backup 
				default: ;
			endcase
    end
end


assign  status_w              = {ctrl_reg_in[7:0],cmd_reg_in[7:0]};                 //from ConfigReg module
assign  monit_hit_sel_w       = {hit_monit_fix_sel_in[7:0],hit_monit_sel_in[7:0]};  //from HitTrgCount module
assign  hit_busy_ab_sel_w     = {hit_ab_sel_in[15:8],busy_ab_sel_in[7:0]};           //from ConfigReg module
assign  hit_busy_mask_w       = {hit_mask_in[9:0],busy_mask_in[5:0]};               //from ConfigReg module
assign  mon_data_out            = mon_data_reg;

endmodule
