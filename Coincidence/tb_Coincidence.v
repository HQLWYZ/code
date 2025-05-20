//~ `New testbench

`timescale  1ns / 1ps

module tb_Coincidence;

// Coincidence Parameters
parameter PERIOD                = 20       ;
parameter SI_DEAD_TIME_SET_NUM  = 24'd15000;
parameter IDLE                  = 0        ;

// Coincidence Inputs
reg   clk_in                               = 1'b0 ;
reg   rst_in                             = 1'b0 ;
reg   si_trb_1_busy_a_in_N                 = 1'b1 ;
reg   si_trb_1_busy_b_in_N                 = 1'b1 ;
reg   si_trb_2_busy_a_in_N                 = 1'b1 ;
reg   si_trb_2_busy_b_in_N                 = 1'b1 ;
reg   acd_fee_top_hit_a_in_N               = 1'b1 ;
reg   acd_fee_top_hit_b_in_N               = 1'b1 ;
reg   acd_fee_sec_hit_a_in_N               = 1'b1 ;
reg   acd_fee_sec_hit_b_in_N               = 1'b1 ;
reg   acd_fee_sid_hit_a_in_N               = 1'b1 ;
reg   acd_fee_sid_hit_b_in_N               = 1'b1 ;
reg   csi_fee_hit_a_in_N                   = 1'b1 ;
reg   csi_fee_hit_b_in_N                   = 1'b1 ;
reg   cal_fee_1_hit_a_in_N                 = 1'b1 ;
reg   cal_fee_1_hit_b_in_N                 = 1'b1 ;
reg   cal_fee_2_hit_a_in_N                 = 1'b1 ;
reg   cal_fee_2_hit_b_in_N                 = 1'b1 ;
reg   cal_fee_3_hit_a_in_N                 = 1'b1 ;
reg   cal_fee_3_hit_b_in_N                 = 1'b1 ;
reg   cal_fee_4_hit_a_in_N                 = 1'b1 ;
reg   cal_fee_4_hit_b_in_N                 = 1'b1 ;
reg   [15:0]  hit_mask_in                  = 16'b0000_0000_0000_0000 ;
reg   [15:0]  hit_ab_sel_in                = 16'b0000_0000_0000_0000 ;
reg   [1:0]  busy_mask_in                  = 2'b00 ;
reg   [1:0]  busy_ab_sel_in                = 2'b00 ;
reg   [1:0]  busy_start_sel_in             = 2'b01 ;
reg   [7:0]   acd_csi_hit_tim_diff_in       = 8'b11 ; //default set 4us, e.g. 4us/40ns = 100 = 8'h64
reg   [3:0]   acd_fee_top_hit_align_in      = 4'b01 ;//default jitter is 40ns, 40ns/40ns = 1 = 4'h1
reg   [3:0]   acd_fee_sec_hit_align_in      = 4'b10 ;
reg   [3:0]   acd_fee_sid_hit_align_in      = 4'b01 ;
reg   [3:0]   csi_hit_align_in	            = 4'b01 ;//default jitter is 200ns, 200ns/40ns = 5 = 4'h5, at least 1'b1
reg   [3:0]   cal_fee_1_hit_align_in        = 4'b01 ;//at least 1'b1
reg   [3:0]   cal_fee_2_hit_align_in        = 4'b01 ;//at least 1'b1
reg   [3:0]   cal_fee_3_hit_align_in        = 4'b01 ;//at least 1'b1
reg   [3:0]   cal_fee_4_hit_align_in        = 4'b01 ;//at least 1'b1
reg   [4:0]  logic_grp_oe_in               = 5'b00001 ;
reg   [1:0]  logic_grp0_sel_in             = 2'b01 ;//Trigger type: MIP1
reg   [1:0]  logic_grp1_sel_in             = 2'b00 ;//Trigger type: MIP2
reg   [1:0]  logic_grp2_sel_in             = 2'b00 ;//Trigger type: GM1
reg   [1:0]  logic_grp3_sel_in             = 2'b00 ;//Trigger type: GM2
reg   [1:0]  logic_grp4_sel_in             = 2'b00 ;//Trigger type: UBS
reg   [1:0]  logic_burst_sel_in            = 2'b00 ;//Trigger type: Burst
reg   [15:0]  trg_match_win_in             = 16'b0010_1000_0001_0100 ;// MSB:40, LSB:20
reg   [5:0]  coincid_UBS_div_in            = 6'b00_0001 ;
reg   [5:0]  coincid_MIP1_div_in           = 6'b00_0010 ;
reg   [5:0]  coincid_MIP2_div_in           = 6'b00_0001 ;

// Coincidence Outputs
wire  coincid_trg_out                      ;
wire  logic_match_out                      ;
wire  [7:0]  hit_syn_out                  ;
wire  [1:0]	busy_syn_out                ;     
wire  hit_start_out                        ;
wire  busy_start_out                        ;
wire  [15:0]  coincid_UBS_cnt_out          ;
wire  [15:0]  coincid_MIP1_cnt_out          ;
wire  [15:0]  coincid_MIP2_cnt_out           ;
wire  coincid_trg_raw_1us_out              ;
wire  [4:0] coincid_tag_raw_out                  ;


initial//-----------BUSY IN------
begin
repeat(3000)
	begin
	#620_000 si_trb_1_busy_a_in_N=0;
	#620_000 si_trb_1_busy_a_in_N=1;
	end
si_trb_1_busy_a_in_N=1'b1;
end


initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#159_800 acd_fee_top_hit_a_in_N=0;
	#200    acd_fee_top_hit_a_in_N=1;

	end
acd_fee_top_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#159_800 acd_fee_sec_hit_a_in_N=0;
	#200    acd_fee_sec_hit_a_in_N=1;
	end
acd_fee_sec_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#159_800 acd_fee_sid_hit_a_in_N=0;
	#200    acd_fee_sid_hit_a_in_N=1;
	end
acd_fee_sid_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        csi_fee_hit_a_in_N=1;
	#159_800    csi_fee_hit_a_in_N=0;
	end
csi_fee_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_1_hit_a_in_N=1;
	#159_800    cal_fee_1_hit_a_in_N=0;
	end
cal_fee_1_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_2_hit_a_in_N=1;
	#159_800    cal_fee_2_hit_a_in_N=0;
	end
cal_fee_2_hit_a_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_3_hit_a_in_N=1;
	#159_800    cal_fee_3_hit_a_in_N=0;
	end
cal_fee_3_hit_a_in_N=1'b1;
end


initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_4_hit_a_in_N=1;
	#159_800    cal_fee_4_hit_a_in_N=0;
	end
cal_fee_4_hit_a_in_N=1'b1;
end





initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in  =  1;
    #(PERIOD*2) rst_in  =  0;
    //#(PERIOD*2) rst_in  =  1;
end


Coincidence #(
    .SI_DEAD_TIME_SET_NUM ( SI_DEAD_TIME_SET_NUM ),
    .IDLE                 ( IDLE                 ))
 u_Coincidence (
    .clk_in                   ( clk_in                          ),
    .rst_in                 ( rst_in                        ),
    .si_trb_1_busy_a_in_N     ( si_trb_1_busy_a_in_N            ),
    .si_trb_1_busy_b_in_N     ( si_trb_1_busy_b_in_N            ),
    .si_trb_2_busy_a_in_N     ( si_trb_2_busy_a_in_N            ),
    .si_trb_2_busy_b_in_N     ( si_trb_2_busy_b_in_N            ),
    .acd_fee_top_hit_a_in_N   ( acd_fee_top_hit_a_in_N          ),
    .acd_fee_top_hit_b_in_N   ( acd_fee_top_hit_b_in_N          ),
    .acd_fee_sec_hit_a_in_N   ( acd_fee_sec_hit_a_in_N          ),
    .acd_fee_sec_hit_b_in_N   ( acd_fee_sec_hit_b_in_N          ),
    .acd_fee_sid_hit_a_in_N   ( acd_fee_sid_hit_a_in_N          ),
    .acd_fee_sid_hit_b_in_N   ( acd_fee_sid_hit_b_in_N          ),
    .csi_fee_hit_a_in_N       ( csi_fee_hit_a_in_N              ),
    .csi_fee_hit_b_in_N       ( csi_fee_hit_b_in_N              ),
    .cal_fee_1_hit_a_in_N     ( cal_fee_1_hit_a_in_N            ),
    .cal_fee_1_hit_b_in_N     ( cal_fee_1_hit_b_in_N            ),
    .cal_fee_2_hit_a_in_N     ( cal_fee_2_hit_a_in_N            ),
    .cal_fee_2_hit_b_in_N     ( cal_fee_2_hit_b_in_N            ),
    .cal_fee_3_hit_a_in_N     ( cal_fee_3_hit_a_in_N            ),
    .cal_fee_3_hit_b_in_N     ( cal_fee_3_hit_b_in_N            ),
    .cal_fee_4_hit_a_in_N     ( cal_fee_4_hit_a_in_N            ),
    .cal_fee_4_hit_b_in_N     ( cal_fee_4_hit_b_in_N            ),
    .logic_grp0_sel_in      ( logic_grp0_sel_in     [1:0]       ),
    .coincid_MIP1_div_in    ( coincid_MIP1_div_in     [5:0]       ),
    .logic_grp1_sel_in      ( logic_grp1_sel_in     [1:0]       ),
    .coincid_MIP2_div_in    ( coincid_MIP2_div_in     [5:0]       ),
    .logic_grp2_sel_in      ( logic_grp2_sel_in     [1:0]       ),
    .logic_grp3_sel_in      ( logic_grp3_sel_in     [1:0]       ),
    .logic_grp4_sel_in      ( logic_grp4_sel_in     [1:0]       ),
    .coincid_UBS_div_in     ( coincid_UBS_div_in     [5:0]       ), 
    .logic_burst_sel_in     ( logic_burst_sel_in     [1:0]),
    .hit_ab_sel_in          ( hit_ab_sel_in          [15:0] ),
    .hit_mask_in            ( hit_mask_in            [15:0] ),  
    .busy_ab_sel_in         ( busy_ab_sel_in         [1:0]  ),
    .busy_mask_in           ( busy_mask_in           [1:0]  ),
    .acd_csi_hit_tim_diff_in    ( acd_csi_hit_tim_diff_in    [7:0]  ),
    .acd_fee_top_hit_align_in   ( acd_fee_top_hit_align_in   [3:0]  ),
    .acd_fee_sec_hit_align_in   ( acd_fee_sec_hit_align_in   [3:0]  ),
    .acd_fee_sid_hit_align_in   ( acd_fee_sid_hit_align_in   [3:0]  ),
    .csi_hit_align_in           ( csi_hit_align_in           [3:0]  ),
    .cal_fee_1_hit_align_in     ( cal_fee_1_hit_align_in     [3:0]  ),
    .cal_fee_2_hit_align_in     ( cal_fee_2_hit_align_in     [3:0]  ),
    .cal_fee_3_hit_align_in     ( cal_fee_3_hit_align_in     [3:0]  ), 
    .cal_fee_4_hit_align_in     ( cal_fee_4_hit_align_in     [3:0]  ),
    .trg_match_win_in       ( trg_match_win_in           [15:0] ),
    .logic_grp_oe_in        ( logic_grp_oe_in            [7:0]  ),

    .coincid_trg_out          ( coincid_trg_out                 ),
    .logic_match_out          ( logic_match_out                 ),
    .hit_syn_out              ( hit_syn_out              [7:0] ),
    .busy_syn_out              ( busy_syn_out              [1:0] ),
    .hit_start_out            ( hit_start_out                   ),
   // .busy_start_out            ( busy_start_out                   ),
    .coincid_UBS_cnt_out      ( coincid_UBS_cnt_out      [15:0] ),
    .coincid_MIP1_cnt_out      ( coincid_MIP1_cnt_out      [15:0] ),
    .coincid_MIP2_cnt_out       ( coincid_MIP2_cnt_out       [15:0] ),
    .coincid_trg_raw_1us_out  ( coincid_trg_raw_1us_out         ),
    .coincid_tag_raw_out      ( coincid_tag_raw_out  [4:0]           )
);



endmodule