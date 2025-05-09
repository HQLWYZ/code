//~ `New testbench
`timescale  1ns / 1ps

module tb_ConfigReg;

// ConfigReg Parameters
parameter PERIOD  = 20;


// ConfigReg Inputs
reg   clk_in                               = 0 ;
reg   rst_in_N                             = 0 ;
reg   wr_in                                = 0 ;
reg   [7:0]  wr_addr_in                    = 8'b0000_0000 ;
reg   [15:0]  data_in                      = 15'b0000_0000_0000_0000 ;

// ConfigReg Outputs
wire  trg_enb_out                          ;
wire  cmd_rst_out                          ;
wire  cycled_trg_bgn_out                   ;
wire  [1:0]  logic_grp0_sel_out            ;
wire  [5:0]  coincid_MIP1_div_out          ;
wire  [1:0]  logic_grp1_sel_out            ;
wire  [5:0]  coincid_MIP2_div_out          ;
wire  [1:0]  logic_grp2_sel_out            ;
wire  [1:0]  logic_grp3_sel_out            ;
wire  [1:0]  logic_grp4_sel_out            ;
wire  [5:0]  coincid_UBS_div_out           ;
wire  [1:0]  logic_burst_sel_out           ;
wire  [15:0]  hit_ab_sel_out               ;
wire  [15:0]  hit_mask_out                 ;
wire  [1:0]  busy_ab_sel_out               ;
wire  [1:0]  busy_mask_out                 ;
wire  busy_mask_set_out                    ;
wire  [1:0]  busy_start_sel_out            ;
wire  [7:0]  acd_csi_hit_tim_diff_out      ;
wire  [3:0]  acd_fee_top_hit_align_out     ;
wire  [3:0]  acd_fee_sec_hit_align_out     ;
wire  [3:0]  acd_fee_sid_hit_align_out     ;
wire  [3:0]  csi_hit_align_out             ;
wire  [3:0]  cal_fee_1_hit_align_out       ;
wire  [3:0]  cal_fee_2_hit_align_out       ;
wire  [3:0]  cal_fee_3_hit_align_out       ;
wire  [3:0]  cal_fee_4_hit_align_out       ;
wire  [7:0]  trg_match_win_out             ;
wire  [7:0]  trg_dead_time_out             ;
wire  [7:0]  logic_grp_oe_out              ;
wire  [7:0]  cycle_trg_period_out          ;
wire  [15:0]  cycle_trg_num_out            ;
wire  [7:0]  ext_trg_delay_out             ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in_N  =  1;
end

initial//-----------wr_data------
begin
    #100_000 
    wr_addr_in=8'd0;
    data_in=16'b0000_0000_0000_0101;
	#200 
    wr_addr_in=8'd1;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd2;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd3;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd4;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd5;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd6;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd7;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd8;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd9;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd10;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd11;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd12;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd13;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd14;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd15;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd16;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd17;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd18;
    data_in=16'b0000_0000_0000_0101;
    #200 
    wr_addr_in=8'd19;
    data_in=16'b0000_0000_0000_0101;
end

initial//-----------wr_in------
begin
    #90_000 wr_in=1'b1;
	#100_000_000 wr_in=1'b0;
end


ConfigReg  u_ConfigReg (
    .clk_in                     ( clk_in                            ),
    .rst_in_N                   ( rst_in_N                          ),
    .wr_in                      ( wr_in                             ),
    .wr_addr_in                 ( wr_addr_in                 [7:0]  ),
    .data_in                    ( data_in                    [15:0] ),

    .trg_enb_out                ( trg_enb_out                       ),
    .cmd_rst_out                ( cmd_rst_out                       ),
    .cycled_trg_bgn_out         ( cycled_trg_bgn_out                ),
    .logic_grp0_sel_out         ( logic_grp0_sel_out         [1:0]  ),
    .coincid_MIP1_div_out       ( coincid_MIP1_div_out       [5:0]  ),
    .logic_grp1_sel_out         ( logic_grp1_sel_out         [1:0]  ),
    .coincid_MIP2_div_out       ( coincid_MIP2_div_out       [5:0]  ),
    .logic_grp2_sel_out         ( logic_grp2_sel_out         [1:0]  ),
    .logic_grp3_sel_out         ( logic_grp3_sel_out         [1:0]  ),
    .logic_grp4_sel_out         ( logic_grp4_sel_out         [1:0]  ),
    .coincid_UBS_div_out        ( coincid_UBS_div_out        [5:0]  ),
    .logic_burst_sel_out        ( logic_burst_sel_out        [1:0]  ),
    .hit_ab_sel_out             ( hit_ab_sel_out             [15:0] ),
    .hit_mask_out               ( hit_mask_out               [15:0] ),
    .busy_ab_sel_out            ( busy_ab_sel_out            [1:0]  ),
    .busy_mask_out              ( busy_mask_out              [1:0]  ),
    .busy_mask_set_out          ( busy_mask_set_out                 ),
    .busy_start_sel_out         ( busy_start_sel_out         [1:0]  ),
    .acd_csi_hit_tim_diff_out   ( acd_csi_hit_tim_diff_out   [7:0]  ),
    .acd_fee_top_hit_align_out  ( acd_fee_top_hit_align_out  [3:0]  ),
    .acd_fee_sec_hit_align_out  ( acd_fee_sec_hit_align_out  [3:0]  ),
    .acd_fee_sid_hit_align_out  ( acd_fee_sid_hit_align_out  [3:0]  ),
    .csi_hit_align_out          ( csi_hit_align_out          [3:0]  ),
    .cal_fee_1_hit_align_out    ( cal_fee_1_hit_align_out    [3:0]  ),
    .cal_fee_2_hit_align_out    ( cal_fee_2_hit_align_out    [3:0]  ),
    .cal_fee_3_hit_align_out    ( cal_fee_3_hit_align_out    [3:0]  ),
    .cal_fee_4_hit_align_out    ( cal_fee_4_hit_align_out    [3:0]  ),
    .trg_match_win_out          ( trg_match_win_out          [7:0]  ),
    .trg_dead_time_out          ( trg_dead_time_out          [7:0]  ),
    .logic_grp_oe_out           ( logic_grp_oe_out           [7:0]  ),
    .cycle_trg_period_out       ( cycle_trg_period_out       [7:0]  ),
    .cycle_trg_num_out          ( cycle_trg_num_out          [15:0] ),
    .ext_trg_delay_out          ( ext_trg_delay_out          [7:0]  )
);

//nitial
//begin

//    $finish;
//end

endmodule