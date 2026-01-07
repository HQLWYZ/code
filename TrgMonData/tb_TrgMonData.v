//~ `New testbench
`timescale  1ns / 1ps

module tb_TrgMonData;

// TrgMonData Parameters
parameter PERIOD  = 10;

initial
    begin
        $dumpfile("./tb_TrgMonData.vcd");
        $dumpvars(0,tb_TrgMonData);
        #3_000_000 $finish;
end

// TrgMonData Inputs
reg   clk_in                               = 0 ;
reg   rst_in                             = 0 ;
reg   rd_in                                = 0 ;
reg   [7:0]  rd_addr_in                    = 0 ;
reg   [15:0]  ctrl_reg_in                  = 0 ;
reg   [15:0]  cmd_reg_in                   = 0 ;
reg   [15:0]  trg_mode_mip1_in            = 0 ;
reg   [15:0]  trg_mode_mip2_in             = 0 ;
reg   [15:0]  trg_mode_gm1_in              = 0 ;
reg   [15:0]  trg_mode_gm2_in              = 0 ;
reg   [15:0]  trg_mode_ubs_in              = 0 ;
reg   [15:0]  trg_mode_brst_in             = 0 ;
reg   [15:0]  eff_trg_cnt_in               = 0 ;
reg   [15:0]  coincid_trg_cnt_in           = 0 ;
reg   [15:0]  hit_monit_fix_sel_in         = 0 ;
reg   [15:0]  hit_monit_sel_in             = 0 ;
reg   [15:0]  hit_monit_err_cnt_in         = 0 ;
reg   [15:0]  hit_start_cnt_in             = 0 ;
reg   [31:0]  hit_monit_cnt_0_in           = 0 ;
reg   [31:0]  hit_monit_cnt_1_in           = 0 ;
reg   [15:0]  busy_monit_fix_sel_in        = 0 ;
reg   [15:0]  busy_monit_err_cnt_in        = 0 ;
reg   [15:0]  busy_monit_cnt_in            = 0 ;
reg   [15:0]  coincid_MIP1_cnt_in          = 0 ;
reg   [15:0]  coincid_MIP2_cnt_in          = 0 ;
reg   [15:0]  coincid_GM1_cnt_in           = 0 ;
reg   [15:0]  coincid_GM2_cnt_in           = 0 ;
reg   [31:0]  coincid_UBS_cnt_in           = 0 ;
reg   [15:0]  logic_match_cnt_in           = 0 ;
reg   [15:0]  ext_trg_cnt_in               = 0 ;
reg   [15:0]  hit_ab_sel_in                = 0 ;
reg   [15:0]  busy_ab_sel_in               = 0 ;
reg   [15:0]  hit_mask_in                  = 0 ;
reg   [15:0]  busy_mask_in                 = 0 ;
reg   [15:0]  trg_match_win_in             = 0 ;
reg   [15:0]  trg_dead_time_in             = 0 ;
reg   [15:0]  config_received_in           = 0 ;
reg   [15:0]  ext_trg_delay_in             = 0 ;
reg   [15:0]  cycled_trg_period_in          = 0 ;
reg   [7:0]  logic_grp_oe_in          = 0 ;

// TrgMonData Outputs
wire  [15:0]  mon_data_out                 ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in  =  1;
    #(PERIOD*2) rst_in  =  0;
end


initial//
begin
    #100_100     rd_in=1;  //100.1us
	#10_000_000 rd_in=0;//10ms
end

initial//
begin
    #100_000    rd_addr_in=8'd25;  //100us
	#100_000    rd_addr_in=8'd26;  //100us
    #100_000    rd_addr_in=8'd27;  //100us
    #100_000    rd_addr_in=8'd28;  //100us
    #100_000    rd_addr_in=8'd29;  //100us
    #100_000    rd_addr_in=8'd30;  //100us
    #100_000    rd_addr_in=8'd31;  //100us
    #100_000    rd_addr_in=8'd32;  //100us
    #100_000    rd_addr_in=8'd33;  //100us
    #100_000    rd_addr_in=8'd34;  //100us
    #100_000    rd_addr_in=8'd35;  //100us
    #100_000    rd_addr_in=8'd36;  //100us
    #100_000    rd_addr_in=8'd37;  //100us
    #100_000    rd_addr_in=8'd38;  //100us
    #100_000    rd_addr_in=8'd39;  //100us
    #100_000    rd_addr_in=8'd40;  //100us
    #100_000    rd_addr_in=8'd41;  //100us
    #100_000    rd_addr_in=8'd42;  //100us
    #100_000    rd_addr_in=8'd43;  //100us
    #100_000    rd_addr_in=8'd44;  //100us
    #100_000    rd_addr_in=8'd45;  //100us
    #100_000    rd_addr_in=8'd46;  //100us
    #100_000    rd_addr_in=8'd47;  //100us
    #100_000    rd_addr_in=8'd48;  //100us
    #100_000    rd_addr_in=8'd49;  //100us
    #100_000    rd_addr_in=8'd50;  //100us
    #100_000    rd_addr_in=8'd51;  //100us
    #100_000    rd_addr_in=8'd52;  //100us
    #100_000    rd_addr_in=8'd53;  //100us
    #100_000    rd_addr_in=8'd54;  //100us
    #100_000    rd_addr_in=8'd55;  //100us
    #100_000    rd_addr_in=8'd56;  //100us
    #100_000    rd_addr_in=8'd57;  //100us
    #100_000    rd_addr_in=8'd58;  //100us
    #100_000    rd_addr_in=8'd59;  //100us
    #100_000    rd_addr_in=8'd60;  //100us
    #100_000    rd_addr_in=8'd61;  //100us
    #100_000    rd_addr_in=8'd62;  //100us

end

initial//
begin
    ctrl_reg_in                  = 16'h3553 ;
    cmd_reg_in                   = 16'h0003 ;
    trg_mode_mip1_in            = 16'h3553 ;
    trg_mode_mip2_in             = 16'h0003 ;
    trg_mode_gm1_in              = 16'h3553 ;
    trg_mode_gm2_in              = 16'h3553 ;
    trg_mode_ubs_in              = 16'h3553 ;
    trg_mode_brst_in             = 16'h0003 ;
    eff_trg_cnt_in               = 16'h3553 ;
    coincid_trg_cnt_in           = 16'h3553 ;
    hit_monit_fix_sel_in         = 16'h3553 ;
    hit_monit_sel_in             = 16'h3553 ;
    hit_monit_err_cnt_in         = 16'h0003 ;
    hit_start_cnt_in             = 16'h3553 ;
    hit_monit_cnt_0_in           = 32'h84353553 ;
    hit_monit_cnt_1_in           = 32'h09a23553 ;
    busy_monit_fix_sel_in        = 16'h0003 ;
    busy_monit_err_cnt_in        = 16'h3553 ;
    busy_monit_cnt_in            = 16'h0003 ;
    coincid_MIP1_cnt_in          = 16'h3553 ;
    coincid_MIP2_cnt_in          = 16'h3553 ;
    coincid_GM1_cnt_in           = 16'h3553 ;
    coincid_GM2_cnt_in           = 16'h3553 ;
    coincid_UBS_cnt_in           = 32'h33330003 ;
    logic_match_cnt_in           = 16'h3553 ;
    ext_trg_cnt_in               = 16'h3553 ;
    hit_ab_sel_in                = 16'h3553 ;
    busy_ab_sel_in               = 16'h3553 ;
    hit_mask_in                  = 16'h0003 ;
    busy_mask_in                 = 16'h3553 ;
    trg_match_win_in             = 16'h0003 ;
    trg_dead_time_in             = 16'h3553 ;
    config_received_in           = 16'h0003 ;
    ext_trg_delay_in             = 16'h3553 ;
    cycled_trg_period_in          = 16'h0003 ;
    logic_grp_oe_in                  = 8'h13 ;
end


TrgMonData  u_TrgMonData (
    .clk_in                  ( clk_in                        ),
    .rst_in                ( rst_in                      ),
    .rd_in                   ( rd_in                         ),
    .rd_addr_in              ( rd_addr_in             [7:0]  ),
    .ctrl_reg_in             ( ctrl_reg_in            [15:0] ),
    .cmd_reg_in              ( cmd_reg_in             [15:0] ),
    .trg_mode_mip1_in        ( trg_mode_mip1_in       [15:0] ),
    .trg_mode_mip2_in        ( trg_mode_mip2_in       [15:0] ),
    .trg_mode_gm1_in         ( trg_mode_gm1_in        [15:0] ),
    .trg_mode_gm2_in         ( trg_mode_gm2_in        [15:0] ),
    .trg_mode_ubs_in         ( trg_mode_ubs_in        [15:0] ),
    .trg_mode_brst_in        ( trg_mode_brst_in       [15:0] ),
    .eff_trg_cnt_in          ( eff_trg_cnt_in         [15:0] ),
    .coincid_trg_cnt_in      ( coincid_trg_cnt_in     [15:0] ),
    .hit_monit_fix_sel_in    ( hit_monit_fix_sel_in   [15:0] ),
    .hit_monit_sel_in        ( hit_monit_sel_in       [15:0] ),
    .hit_monit_err_cnt_in    ( hit_monit_err_cnt_in   [15:0] ),
    .hit_start_cnt_in        ( hit_start_cnt_in       [15:0] ),
    .hit_monit_cnt_0_in      ( hit_monit_cnt_0_in     [31:0] ),
    .hit_monit_cnt_1_in      ( hit_monit_cnt_1_in     [31:0] ),
    .busy_monit_fix_sel_in   ( busy_monit_fix_sel_in  [15:0] ),
    .busy_monit_err_cnt_in   ( busy_monit_err_cnt_in  [15:0] ),
    .busy_monit_cnt_in       ( busy_monit_cnt_in      [15:0] ),
    .coincid_MIP1_cnt_in     ( coincid_MIP1_cnt_in    [15:0] ),
    .coincid_MIP2_cnt_in     ( coincid_MIP2_cnt_in    [15:0] ),
    .coincid_GM1_cnt_in      ( coincid_GM1_cnt_in     [15:0] ),
    .coincid_GM2_cnt_in      ( coincid_GM2_cnt_in     [15:0] ),
    .coincid_UBS_cnt_in      ( coincid_UBS_cnt_in     [31:0] ),
    .logic_match_cnt_in      ( logic_match_cnt_in     [15:0] ),
    .ext_trg_cnt_in          ( ext_trg_cnt_in         [15:0] ),
    .hit_ab_sel_in           ( hit_ab_sel_in          [15:0] ),
    .busy_ab_sel_in          ( busy_ab_sel_in         [15:0] ),
    .hit_mask_in             ( hit_mask_in            [15:0] ),
    .busy_mask_in            ( busy_mask_in           [15:0] ),
    .trg_match_win_in        ( trg_match_win_in       [15:0] ),
    .trg_dead_time_in        ( trg_dead_time_in       [15:0] ),
    .config_received_in      ( config_received_in     [15:0] ),
    .ext_trg_delay_in        ( ext_trg_delay_in       [15:0] ),
    .cycled_trg_period_in     ( cycled_trg_period_in    [15:0] ),
    .logic_grp_oe_in          ( logic_grp_oe_in      [15:0] ),
    .mon_data_out            ( mon_data_out           [15:0] )
);



endmodule