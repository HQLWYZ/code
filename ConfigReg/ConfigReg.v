/*----------------------------------------------------------*/
/* file name:  ConfigReg.v                                 */
/* date:       2025/03/06                                  */
/* modified:   2026/04/20                                   */
/* version:    v1.0                                        */
/* author:     Wang Shen                                   */
/* email:      wangshen@pmo.ac.cn                          */
/* note1:      system clock = 50MHz                        */
/*----------------------------------------------------------*/

module ConfigReg(
    input           clk_in,
    input           rst_in,
    input           wr_in,
    input   [7:0]   wr_addr_in,
    input   [15:0]  data_in,
    
    // --- Direct Outputs ---
    output          trg_enb_out,
    output          data_trans_enb_out,
    output          cmd_rst_out,
    output          cycled_trg_bgn_out,
    output  [15:0]  config_received_out,
    
    // --- TMR Combinational Outputs (Pure output declarations) ---
    output  [15:0]  ctrl_reg_out,
    output  [15:0]  cmd_reg_out,
    
    output  [7:0]   logic_grp0_mux_out,
    output  [1:0]   logic_grp0_sel_out,
    output  [5:0]   coincid_MIP1_div_out,
    
    output  [7:0]   logic_grp1_mux_out,
    output  [1:0]   logic_grp1_sel_out,
    output  [5:0]   coincid_MIP2_div_out,
    
    output  [7:0]   logic_grp2_mux_out,
    output  [1:0]   logic_grp2_sel_out,
    
    output  [7:0]   logic_grp3_mux_out,
    output  [1:0]   logic_grp3_sel_out,
    
    output  [7:0]   logic_grp4_mux_out,
    output  [1:0]   logic_grp4_sel_out,
    output  [5:0]   coincid_UBS_div_out,
    
    output  [1:0]   logic_burst_sel_out,
    
    output  [15:0]  trg_mode_mip1_out, 
    output  [15:0]  trg_mode_mip2_out, 
    output  [15:0]  trg_mode_gm1_out,
    output  [15:0]  trg_mode_gm2_out, 
    output  [15:0]  trg_mode_ubs_out, 
    output  [15:0]  trg_mode_brst_out,
    
    output  [15:0]  hit_ab_sel_out,
    output  [15:0]  hit_mask_out,
    output  [3:0]   hit_monit_fix_sel_out,
    output          busy_monit_fix_sel_out,
    output  [1:0]   busy_ab_sel_out,
    output  [1:0]   busy_mask_out,
    output          busy_ignore_out,
    
    output  [7:0]   acd_csi_hit_tim_diff_out, 
    output  [3:0]   acd_fee_top_hit_align_out,
    output  [3:0]   acd_fee_sec_hit_align_out,
    output  [3:0]   acd_fee_sid_hit_align_out,
    output  [3:0]   csi_hit_align_out,
    output  [3:0]   cal_fee_1_hit_align_out,
    output  [3:0]   cal_fee_2_hit_align_out,
    output  [3:0]   cal_fee_3_hit_align_out,
    output  [3:0]   cal_fee_4_hit_align_out,
    
    output  [15:0]  trg_match_win_out,
    output  [7:0]   trg_dead_time_out,
    output  [7:0]   logic_grp_oe_out,
    output  [7:0]   cycled_trg_period_out,
    output  [15:0]  cycled_trg_num_out,
    output  [7:0]   ext_trg_delay_out
);

    `define CTRL_REG                16'b0000_0000_0000_0000  // control register default value[2:0]
    `define CMD_REG                 16'b0000_0000_0000_1101
    `define TRG_MODE_MIP1_REG       16'b0000_0000_0000_1101 // trigger mode register0 value
    `define TRG_MODE_MIP2_REG       16'b0000_0000_0000_1101 // trigger mode register1 value
    `define TRG_MODE_GM1_REG        16'b0000_0000_0000_1101 // trigger mode register2 value
    `define TRG_MODE_GM2_REG        16'b0000_0000_0000_1101 // trigger mode register3 value[6:0]
    `define TRG_MODE_UBS_REG        16'b0000_0000_0000_1101 // trigger mode register4 value
    `define TRG_MODE_BRST_REG       16'b0000_0000_0000_1101 // trigger mode register4 value
    `define HIT_AB_SEL_REG          16'b0000_0000_0000_1101
    `define HIT_MASK_REG            16'b0000_0000_0000_1101
    `define BUSY_SET_REG            16'b1111_1111_1111_1101
    `define HIT_DELAY_WIN_REG       16'b0000_0000_0000_1101
    `define HIT_ALIGN_REG_0         16'b0000_0000_0000_1101
    `define HIT_ALIGN_REG_1         16'b0000_0000_0000_1101
    `define TRG_MATCH_WIN_REG       16'b0000_0000_0000_1101
    `define TRG_DEAD_TIME_REG       16'b0000_0000_0000_1101 //default: 50us
    `define TRG_MODE_OE_REG         16'b0000_0000_0000_1101
    `define CYCLE_TRG_PERIOD_REG    16'b0000_0000_0000_1101
    `define CYCLE_TRG_NUM_REG       16'b0000_0000_0000_1101
    `define EXT_TRG_DELAY           16'b0000_0000_0000_1101
    
    // =========================================================================
    // 1. Non-TMR Internal Registers
    // =========================================================================
    reg trg_enb_reg, data_trans_enb_reg, cmd_rst_reg, cycled_trg_bgn_reg;

    // =========================================================================
    // 2. TMR Internal Registers (with synthesis attributes to prevent optimization)
    // =========================================================================
    (* preserve = "true" *) reg [15:0] ctrl_reg_A;
    (* preserve = "true" *) reg [15:0] ctrl_reg_B;
    (* preserve = "true" *) reg [15:0] ctrl_reg_C;
    (* preserve = "true" *) reg [15:0] cmd_reg_A;
    (* preserve = "true" *) reg [15:0] cmd_reg_B;
    (* preserve = "true" *) reg [15:0] cmd_reg_C;
    
    (* preserve = "true" *) reg [15:0] trg_mode_mip1_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_mip1_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_mip1_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_mip2_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_mip2_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_mip2_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_gm1_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_gm1_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_gm1_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_gm2_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_gm2_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_gm2_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_ubs_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_ubs_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_ubs_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_brst_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_brst_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_brst_reg_C;
    
    (* preserve = "true" *) reg [15:0] hit_ab_sel_reg_A;
    (* preserve = "true" *) reg [15:0] hit_ab_sel_reg_B;
    (* preserve = "true" *) reg [15:0] hit_ab_sel_reg_C;
    (* preserve = "true" *) reg [15:0] hit_mask_reg_A;
    (* preserve = "true" *) reg [15:0] hit_mask_reg_B;
    (* preserve = "true" *) reg [15:0] hit_mask_reg_C;
    (* preserve = "true" *) reg [15:0] busy_set_reg_A;
    (* preserve = "true" *) reg [15:0] busy_set_reg_B;
    (* preserve = "true" *) reg [15:0] busy_set_reg_C;
    (* preserve = "true" *) reg [15:0] hit_delay_win_reg_A;
    (* preserve = "true" *) reg [15:0] hit_delay_win_reg_B;
    (* preserve = "true" *) reg [15:0] hit_delay_win_reg_C;
    (* preserve = "true" *) reg [15:0] hit_align_reg0_A;
    (* preserve = "true" *) reg [15:0] hit_align_reg0_B;
    (* preserve = "true" *) reg [15:0] hit_align_reg0_C;
    (* preserve = "true" *) reg [15:0] hit_align_reg1_A;
    (* preserve = "true" *) reg [15:0] hit_align_reg1_B;
    (* preserve = "true" *) reg [15:0] hit_align_reg1_C;
    
    (* preserve = "true" *) reg [15:0] trg_match_win_reg_A;
    (* preserve = "true" *) reg [15:0] trg_match_win_reg_B;
    (* preserve = "true" *) reg [15:0] trg_match_win_reg_C;
    (* preserve = "true" *) reg [15:0] trg_dead_time_reg_A;
    (* preserve = "true" *) reg [15:0] trg_dead_time_reg_B;
    (* preserve = "true" *) reg [15:0] trg_dead_time_reg_C;
    (* preserve = "true" *) reg [15:0] trg_mode_oe_reg_A;
    (* preserve = "true" *) reg [15:0] trg_mode_oe_reg_B;
    (* preserve = "true" *) reg [15:0] trg_mode_oe_reg_C;
    
    (* preserve = "true" *) reg [15:0] cycled_trg_period_reg_A;
    (* preserve = "true" *) reg [15:0] cycled_trg_period_reg_B;
    (* preserve = "true" *) reg [15:0] cycled_trg_period_reg_C;
    (* preserve = "true" *) reg [15:0] cycled_trg_num_reg_A;
    (* preserve = "true" *) reg [15:0] cycled_trg_num_reg_B;
    (* preserve = "true" *) reg [15:0] cycled_trg_num_reg_C;
    (* preserve = "true" *) reg [15:0] ext_trg_delay_reg_A;
    (* preserve = "true" *) reg [15:0] ext_trg_delay_reg_B;
    (* preserve = "true" *) reg [15:0] ext_trg_delay_reg_C;

    // =========================================================================
    // 3. Majority Voter Wires (W_ prefix)
    // =========================================================================
    wire [15:0] W_ctrl_reg            = (ctrl_reg_A & ctrl_reg_B) | (ctrl_reg_B & ctrl_reg_C) | (ctrl_reg_A & ctrl_reg_C);
    wire [15:0] W_cmd_reg             = (cmd_reg_A & cmd_reg_B) | (cmd_reg_B & cmd_reg_C) | (cmd_reg_A & cmd_reg_C);
    
    wire [15:0] W_trg_mode_mip1_reg   = (trg_mode_mip1_reg_A & trg_mode_mip1_reg_B) | (trg_mode_mip1_reg_B & trg_mode_mip1_reg_C) | (trg_mode_mip1_reg_A & trg_mode_mip1_reg_C);
    wire [15:0] W_trg_mode_mip2_reg   = (trg_mode_mip2_reg_A & trg_mode_mip2_reg_B) | (trg_mode_mip2_reg_B & trg_mode_mip2_reg_C) | (trg_mode_mip2_reg_A & trg_mode_mip2_reg_C);
    wire [15:0] W_trg_mode_gm1_reg    = (trg_mode_gm1_reg_A  & trg_mode_gm1_reg_B)  | (trg_mode_gm1_reg_B  & trg_mode_gm1_reg_C)  | (trg_mode_gm1_reg_A  & trg_mode_gm1_reg_C);
    wire [15:0] W_trg_mode_gm2_reg    = (trg_mode_gm2_reg_A  & trg_mode_gm2_reg_B)  | (trg_mode_gm2_reg_B  & trg_mode_gm2_reg_C)  | (trg_mode_gm2_reg_A  & trg_mode_gm2_reg_C);
    wire [15:0] W_trg_mode_ubs_reg    = (trg_mode_ubs_reg_A  & trg_mode_ubs_reg_B)  | (trg_mode_ubs_reg_B  & trg_mode_ubs_reg_C)  | (trg_mode_ubs_reg_A  & trg_mode_ubs_reg_C);
    wire [15:0] W_trg_mode_brst_reg   = (trg_mode_brst_reg_A & trg_mode_brst_reg_B) | (trg_mode_brst_reg_B & trg_mode_brst_reg_C) | (trg_mode_brst_reg_A & trg_mode_brst_reg_C);
    
    wire [15:0] W_hit_ab_sel_reg      = (hit_ab_sel_reg_A & hit_ab_sel_reg_B) | (hit_ab_sel_reg_B & hit_ab_sel_reg_C) | (hit_ab_sel_reg_A & hit_ab_sel_reg_C);
    wire [15:0] W_hit_mask_reg        = (hit_mask_reg_A & hit_mask_reg_B) | (hit_mask_reg_B & hit_mask_reg_C) | (hit_mask_reg_A & hit_mask_reg_C);
    wire [15:0] W_busy_set_reg        = (busy_set_reg_A & busy_set_reg_B) | (busy_set_reg_B & busy_set_reg_C) | (busy_set_reg_A & busy_set_reg_C);
    wire [15:0] W_hit_delay_win_reg   = (hit_delay_win_reg_A & hit_delay_win_reg_B) | (hit_delay_win_reg_B & hit_delay_win_reg_C) | (hit_delay_win_reg_A & hit_delay_win_reg_C);
    wire [15:0] W_hit_align_reg0      = (hit_align_reg0_A & hit_align_reg0_B) | (hit_align_reg0_B & hit_align_reg0_C) | (hit_align_reg0_A & hit_align_reg0_C);
    wire [15:0] W_hit_align_reg1      = (hit_align_reg1_A & hit_align_reg1_B) | (hit_align_reg1_B & hit_align_reg1_C) | (hit_align_reg1_A & hit_align_reg1_C);
    
    wire [15:0] W_trg_match_win_reg   = (trg_match_win_reg_A & trg_match_win_reg_B) | (trg_match_win_reg_B & trg_match_win_reg_C) | (trg_match_win_reg_A & trg_match_win_reg_C);
    wire [15:0] W_trg_dead_time_reg   = (trg_dead_time_reg_A & trg_dead_time_reg_B) | (trg_dead_time_reg_B & trg_dead_time_reg_C) | (trg_dead_time_reg_A & trg_dead_time_reg_C);
    wire [15:0] W_trg_mode_oe_reg     = (trg_mode_oe_reg_A & trg_mode_oe_reg_B) | (trg_mode_oe_reg_B & trg_mode_oe_reg_C) | (trg_mode_oe_reg_A & trg_mode_oe_reg_C);
    
    wire [15:0] W_cycled_trg_period_reg = (cycled_trg_period_reg_A & cycled_trg_period_reg_B) | (cycled_trg_period_reg_B & cycled_trg_period_reg_C) | (cycled_trg_period_reg_A & cycled_trg_period_reg_C);
    wire [15:0] W_cycled_trg_num_reg  = (cycled_trg_num_reg_A & cycled_trg_num_reg_B) | (cycled_trg_num_reg_B & cycled_trg_num_reg_C) | (cycled_trg_num_reg_A & cycled_trg_num_reg_C);
    wire [15:0] W_ext_trg_delay_reg   = (ext_trg_delay_reg_A & ext_trg_delay_reg_B) | (ext_trg_delay_reg_B & ext_trg_delay_reg_C) | (ext_trg_delay_reg_A & ext_trg_delay_reg_C);

    // =========================================================================
    // 4. Register Write Logic (Config Reception)
    // =========================================================================
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            trg_enb_reg <= 1'b0;
            data_trans_enb_reg <= 1'b0;  
            
            ctrl_reg_A <= `CTRL_REG; ctrl_reg_B <= `CTRL_REG; ctrl_reg_C <= `CTRL_REG;
            cmd_reg_A <= `CMD_REG; cmd_reg_B <= `CMD_REG; cmd_reg_C <= `CMD_REG;
            
            trg_mode_mip1_reg_A <= `TRG_MODE_MIP1_REG; trg_mode_mip1_reg_B <= `TRG_MODE_MIP1_REG; trg_mode_mip1_reg_C <= `TRG_MODE_MIP1_REG;
            trg_mode_mip2_reg_A <= `TRG_MODE_MIP2_REG; trg_mode_mip2_reg_B <= `TRG_MODE_MIP2_REG; trg_mode_mip2_reg_C <= `TRG_MODE_MIP2_REG;
            trg_mode_gm1_reg_A  <= `TRG_MODE_GM1_REG;  trg_mode_gm1_reg_B  <= `TRG_MODE_GM1_REG;  trg_mode_gm1_reg_C  <= `TRG_MODE_GM1_REG;
            trg_mode_gm2_reg_A  <= `TRG_MODE_GM2_REG;  trg_mode_gm2_reg_B  <= `TRG_MODE_GM2_REG;  trg_mode_gm2_reg_C  <= `TRG_MODE_GM2_REG;
            trg_mode_ubs_reg_A  <= `TRG_MODE_UBS_REG;  trg_mode_ubs_reg_B  <= `TRG_MODE_UBS_REG;  trg_mode_ubs_reg_C  <= `TRG_MODE_UBS_REG;
            trg_mode_brst_reg_A <= `TRG_MODE_BRST_REG; trg_mode_brst_reg_B <= `TRG_MODE_BRST_REG; trg_mode_brst_reg_C <= `TRG_MODE_BRST_REG;
            
            hit_ab_sel_reg_A <= `HIT_AB_SEL_REG; hit_ab_sel_reg_B <= `HIT_AB_SEL_REG; hit_ab_sel_reg_C <= `HIT_AB_SEL_REG;
            hit_mask_reg_A <= `HIT_MASK_REG; hit_mask_reg_B <= `HIT_MASK_REG; hit_mask_reg_C <= `HIT_MASK_REG;
            busy_set_reg_A <= `BUSY_SET_REG; busy_set_reg_B <= `BUSY_SET_REG; busy_set_reg_C <= `BUSY_SET_REG;
            hit_delay_win_reg_A <= `HIT_DELAY_WIN_REG; hit_delay_win_reg_B <= `HIT_DELAY_WIN_REG; hit_delay_win_reg_C <= `HIT_DELAY_WIN_REG;
            hit_align_reg0_A <= `HIT_ALIGN_REG_0; hit_align_reg0_B <= `HIT_ALIGN_REG_0; hit_align_reg0_C <= `HIT_ALIGN_REG_0;
            hit_align_reg1_A <= `HIT_ALIGN_REG_1; hit_align_reg1_B <= `HIT_ALIGN_REG_1; hit_align_reg1_C <= `HIT_ALIGN_REG_1;
            
            trg_match_win_reg_A <= `TRG_MATCH_WIN_REG; trg_match_win_reg_B <= `TRG_MATCH_WIN_REG; trg_match_win_reg_C <= `TRG_MATCH_WIN_REG;
            trg_dead_time_reg_A <= `TRG_DEAD_TIME_REG; trg_dead_time_reg_B <= `TRG_DEAD_TIME_REG; trg_dead_time_reg_C <= `TRG_DEAD_TIME_REG;
            trg_mode_oe_reg_A <= `TRG_MODE_OE_REG; trg_mode_oe_reg_B <= `TRG_MODE_OE_REG; trg_mode_oe_reg_C <= `TRG_MODE_OE_REG;
            
            cycled_trg_period_reg_A <= `CYCLE_TRG_PERIOD_REG; cycled_trg_period_reg_B <= `CYCLE_TRG_PERIOD_REG; cycled_trg_period_reg_C <= `CYCLE_TRG_PERIOD_REG;
            cycled_trg_num_reg_A <= `CYCLE_TRG_NUM_REG; cycled_trg_num_reg_B <= `CYCLE_TRG_NUM_REG; cycled_trg_num_reg_C <= `CYCLE_TRG_NUM_REG;
            ext_trg_delay_reg_A <= `EXT_TRG_DELAY; ext_trg_delay_reg_B <= `EXT_TRG_DELAY; ext_trg_delay_reg_C <= `EXT_TRG_DELAY;
        end
        else if (wr_in) begin
            case (wr_addr_in) // synthesis parallel_case
                8'b0000_0010: begin
                    ctrl_reg_A <= data_in; ctrl_reg_B <= data_in; ctrl_reg_C <= data_in;
                    if(data_in==16'b0000_0000_0000_0001) trg_enb_reg<=1'b1;
                    else if(data_in==16'b0000_0000_0000_0000) trg_enb_reg<=1'b0; 
                    if(data_in==16'b0000_0000_0000_0010) data_trans_enb_reg<=1'b1;
                    else if(data_in==16'b0000_0000_0000_0011) data_trans_enb_reg<=1'b0; 
                end
                8'b0000_0011: begin cmd_reg_A <= data_in; cmd_reg_B <= data_in; cmd_reg_C <= data_in; end
                
                8'b0000_0100: begin trg_mode_mip1_reg_A <= data_in; trg_mode_mip1_reg_B <= data_in; trg_mode_mip1_reg_C <= data_in; end
                8'b0000_0101: begin trg_mode_mip2_reg_A <= data_in; trg_mode_mip2_reg_B <= data_in; trg_mode_mip2_reg_C <= data_in; end
                8'b0000_0110: begin trg_mode_gm1_reg_A <= data_in; trg_mode_gm1_reg_B <= data_in; trg_mode_gm1_reg_C <= data_in; end
                8'b0000_0111: begin trg_mode_gm2_reg_A <= data_in; trg_mode_gm2_reg_B <= data_in; trg_mode_gm2_reg_C <= data_in; end
                8'b0000_1000: begin trg_mode_ubs_reg_A <= data_in; trg_mode_ubs_reg_B <= data_in; trg_mode_ubs_reg_C <= data_in; end
                8'b0000_1001: begin trg_mode_brst_reg_A <= data_in; trg_mode_brst_reg_B <= data_in; trg_mode_brst_reg_C <= data_in; end
                
                8'b0000_1010: begin hit_ab_sel_reg_A <= data_in; hit_ab_sel_reg_B <= data_in; hit_ab_sel_reg_C <= data_in; end
                8'b0000_1011: begin hit_mask_reg_A <= data_in; hit_mask_reg_B <= data_in; hit_mask_reg_C <= data_in; end
                8'b0000_1100: begin busy_set_reg_A <= data_in; busy_set_reg_B <= data_in; busy_set_reg_C <= data_in; end
                8'b0000_1101: begin hit_delay_win_reg_A <= data_in; hit_delay_win_reg_B <= data_in; hit_delay_win_reg_C <= data_in; end
                8'b0000_1110: begin hit_align_reg0_A <= data_in; hit_align_reg0_B <= data_in; hit_align_reg0_C <= data_in; end
                8'b0000_1111: begin hit_align_reg1_A <= data_in; hit_align_reg1_B <= data_in; hit_align_reg1_C <= data_in; end
                
                8'b0001_0000: begin trg_match_win_reg_A <= data_in; trg_match_win_reg_B <= data_in; trg_match_win_reg_C <= data_in; end
                8'b0001_0001: begin trg_dead_time_reg_A <= data_in; trg_dead_time_reg_B <= data_in; trg_dead_time_reg_C <= data_in; end
                8'b0001_0010: begin trg_mode_oe_reg_A <= data_in; trg_mode_oe_reg_B <= data_in; trg_mode_oe_reg_C <= data_in; end
                8'b0001_0011: begin cycled_trg_period_reg_A <= data_in; cycled_trg_period_reg_B <= data_in; cycled_trg_period_reg_C <= data_in; end
                8'b0001_0100: begin cycled_trg_num_reg_A <= data_in; cycled_trg_num_reg_B <= data_in; cycled_trg_num_reg_C <= data_in; end
                8'b0001_0101: begin ext_trg_delay_reg_A <= data_in; ext_trg_delay_reg_B <= data_in; ext_trg_delay_reg_C <= data_in; end
                
                default: ; 
            endcase
        end
    end

    // =========================================================================
    // 5. Counters & Internal Flags Logic
    // =========================================================================
    reg [5:0] cmd_rst_cnt;
    

    always @(posedge clk_in or posedge rst_in)
        if(rst_in) begin
            cmd_rst_reg <= 1'b0;
            cmd_rst_cnt <= 6'b0;
        end
        else if(cmd_rst_cnt == 6'd50) begin
            cmd_rst_cnt <= 6'd0;
            cmd_rst_reg <= 1'b0;
        end
        else if(cmd_rst_reg)
            cmd_rst_cnt <= cmd_rst_cnt + 1;
        else if(wr_in & (wr_addr_in == 8'b0000_0011) & (data_in==16'b0000_0000_0101_0101))
            cmd_rst_reg <= 1'b1;  
        
    reg [5:0] cycled_trg_bgn_cnt;
    
    always @(posedge clk_in or posedge rst_in)
        if(rst_in) begin
            cycled_trg_bgn_reg <= 1'b0;
            cycled_trg_bgn_cnt <= 6'd0;
        end
        else if(cycled_trg_bgn_cnt == 6'd50) begin
            cycled_trg_bgn_cnt <= 6'd0;
            cycled_trg_bgn_reg <= 1'b0;
        end
        else if(cycled_trg_bgn_reg)
            cycled_trg_bgn_cnt <= cycled_trg_bgn_cnt + 1;
        else if(wr_in & (wr_addr_in == 8'b0000_0011) & (data_in[15:4]==12'b0000_0000_1100))
            cycled_trg_bgn_reg <= 1'b1;

    reg wr_in_r;
    reg [15:0] config_received_cnt;
    
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) wr_in_r <= 1'b0;
        else wr_in_r <= wr_in;
    end
    
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) config_received_cnt <= 16'b0;
        else if (~wr_in & wr_in_r & (wr_addr_in >= 8'h02) & (wr_addr_in <= 8'h15))
            config_received_cnt <= config_received_cnt + 1'b1;
    end

    // =========================================================================
    // 6. Combinational Output Assignments 
    // (Direct mapping from TMR Voters to output ports)
    // =========================================================================
    assign trg_enb_out                = trg_enb_reg;
    assign data_trans_enb_out         = data_trans_enb_reg;
    assign cmd_rst_out                = cmd_rst_reg;
    assign cycled_trg_bgn_out         = cycled_trg_bgn_reg;
    assign config_received_out        = config_received_cnt;

    assign ctrl_reg_out               = W_ctrl_reg;
    assign cmd_reg_out                = W_cmd_reg;
    
    assign logic_grp0_mux_out         = W_trg_mode_mip1_reg[15:8];
    assign logic_grp0_sel_out         = W_trg_mode_mip1_reg[7:6];
    assign coincid_MIP1_div_out       = W_trg_mode_mip1_reg[5:0];
    
    assign logic_grp1_mux_out         = W_trg_mode_mip2_reg[15:8];
    assign logic_grp1_sel_out         = W_trg_mode_mip2_reg[7:6];
    assign coincid_MIP2_div_out       = W_trg_mode_mip2_reg[5:0];
    
    assign logic_grp2_mux_out         = W_trg_mode_gm1_reg[15:8];
    assign logic_grp2_sel_out         = W_trg_mode_gm1_reg[7:6];
    
    assign logic_grp3_mux_out         = W_trg_mode_gm2_reg[15:8];
    assign logic_grp3_sel_out         = W_trg_mode_gm2_reg[7:6];
    
    assign logic_grp4_mux_out         = W_trg_mode_ubs_reg[15:8];
    assign logic_grp4_sel_out         = W_trg_mode_ubs_reg[7:6];
    assign coincid_UBS_div_out        = W_trg_mode_ubs_reg[5:0];
    
    assign logic_burst_sel_out        = W_trg_mode_brst_reg[7:6];
    
    assign trg_mode_mip1_out          = W_trg_mode_mip1_reg;
    assign trg_mode_mip2_out          = W_trg_mode_mip2_reg;
    assign trg_mode_gm1_out           = W_trg_mode_gm1_reg;
    assign trg_mode_gm2_out           = W_trg_mode_gm2_reg;
    assign trg_mode_ubs_out           = W_trg_mode_ubs_reg;
    assign trg_mode_brst_out          = W_trg_mode_brst_reg;
    
    assign hit_ab_sel_out             = W_hit_ab_sel_reg;
    assign hit_mask_out               = W_hit_mask_reg;
    assign hit_monit_fix_sel_out      = W_busy_set_reg[15:12];
    assign busy_monit_fix_sel_out     = W_busy_set_reg[11];
    assign busy_ab_sel_out            = W_busy_set_reg[7:6];
    assign busy_mask_out              = W_busy_set_reg[5:4];
    assign busy_ignore_out            = W_busy_set_reg[3];
    
    assign acd_csi_hit_tim_diff_out   = W_hit_delay_win_reg[7:0];
    assign acd_fee_top_hit_align_out  = W_hit_align_reg0[15:12];
    assign acd_fee_sec_hit_align_out  = W_hit_align_reg0[11:8];
    assign acd_fee_sid_hit_align_out  = W_hit_align_reg0[7:4];
    assign csi_hit_align_out          = W_hit_align_reg0[3:0];
    assign cal_fee_1_hit_align_out    = W_hit_align_reg1[15:12];
    assign cal_fee_2_hit_align_out    = W_hit_align_reg1[11:8];
    assign cal_fee_3_hit_align_out    = W_hit_align_reg1[7:4];
    assign cal_fee_4_hit_align_out    = W_hit_align_reg1[3:0];
    
    assign trg_match_win_out          = W_trg_match_win_reg;
    assign trg_dead_time_out          = W_trg_dead_time_reg[7:0];
    assign logic_grp_oe_out           = W_trg_mode_oe_reg[7:0];
    assign cycled_trg_period_out      = W_cycled_trg_period_reg[7:0];
    assign cycled_trg_num_out         = W_cycled_trg_num_reg;
    assign ext_trg_delay_out          = W_ext_trg_delay_reg[7:0];

endmodule