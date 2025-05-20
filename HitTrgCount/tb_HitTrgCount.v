//~ `New testbench
`timescale  1ns / 1ps

module tb_HitTrgCount;

// HitTrgCount Parameters
parameter PERIOD           = 20;
parameter HIT_WIDTH        = 4;
parameter BUSY_WIDTH       = 4;
parameter MONIT_HIT_0_IDLE   = 0;
parameter MONIT_HIT_1_IDLE   = 0;
parameter MONIT_BUSY_IDLE  = 0;

// HitTrgCount Inputs
reg   clk_in                               = 0 ;
reg   rst_in                             = 0 ;
reg   [7:0]  hit_syn_in                    = 0 ;
reg   [1:0]  busy_syn_in                   = 0 ;
reg   hit_start_in                         = 0 ;
reg   update_end_in                        = 0 ;
reg   eff_trg_in                           = 0 ;
reg   coincid_trg_in                       = 0 ;
reg   logic_match_in                       = 0 ;
reg   ext_trg_syn_in                       = 0 ;
reg   [2:0]  hit_monit_fix_sel_in          = 0 ;
reg   busy_monit_fix_sel_in                = 0 ;

// HitTrgCount Outputs
wire  [2:0]  hit_monit_sel_out             ;
wire  [7:0]  hit_monit_err_cnt_out         ;
wire  [7:0]  busy_monit_err_cnt_out        ;
wire  [31:0]  hit_monit_cnt_0_out          ;
wire  [31:0]  hit_monit_cnt_1_out          ;
wire  [15:0]  busy_monit_cnt_out           ;
wire  [15:0]  hit_start_cnt_out            ;
wire  [15:0]  logic_match_cnt_out          ;
wire  [15:0]  eff_trg_cnt_out              ;
wire  [15:0]  coincid_trg_cnt_out          ;
wire  [15:0]  ext_trg_cnt_out              ;
wire  [7:0]  trg_delay_timer_out              ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in  =  1;
    #(PERIOD*2) rst_in  =  0;
end


initial//-----------HIT[7] IN------
begin
repeat(3000)
	begin
	#800_000 hit_syn_in[7]=1;
	#160 hit_syn_in[7]=0;
	end
hit_syn_in[7]=1'b1;
end

initial//-----------HIT[4] IN------
begin
repeat(3000)
	begin
	#803_000 hit_syn_in[4]=1;
	#160 hit_syn_in[4]=0;
	end
hit_syn_in[4]=1'b1;
end

initial//-----------HIT[0] IN------
begin
repeat(3000)
	begin
	#8_000 hit_syn_in[0]=1;
	#160 hit_syn_in[0]=0;
	end
hit_syn_in[0]=1'b1;
end

initial//-----------HIT[1] IN------
begin
repeat(3000)
	begin
	#9_000 hit_syn_in[1]=1;
	#160 hit_syn_in[1]=0;
	end
hit_syn_in[1]=1'b1;
end


initial//-----------BUSY[0] IN------
begin
repeat(3000)
	begin
	#8_000 busy_syn_in[0]=1;
	#160 busy_syn_in[0]=0;
	end
busy_syn_in[0]=1'b1;
end

initial//-----------BUSY[1] IN------
begin
repeat(3000)
	begin
	#90_000 busy_syn_in[1]=1;
	#160 busy_syn_in[1]=0;
	end
busy_syn_in[1]=1'b1;
end


initial//-----------hit start IN------
begin
repeat(3000)
	begin
	#9_000 hit_start_in=0;
	#4_000 hit_start_in=1;
    #9_000 hit_start_in=0;
	#4_000 hit_start_in=1;
	end
hit_start_in=1'b1;
end


initial//-----------update_end_in IN------each 1ms per cnt
begin
repeat(3000)
	begin
	#990_000 update_end_in=1;
	#10_000 update_end_in=0;
	end
update_end_in=1;
end


initial
begin
    #3_000_000 hit_monit_fix_sel_in = 3'b000;
    #3_000_000 hit_monit_fix_sel_in = 3'b001;
end

initial
begin
    #3_000_000 busy_monit_fix_sel_in = 1'b0;
    #3_000_000 busy_monit_fix_sel_in = 1'b1;
end

HitTrgCount #(
    .HIT_WIDTH       ( HIT_WIDTH       ),
    .BUSY_WIDTH      ( BUSY_WIDTH      ),
    .MONIT_HIT_0_IDLE  ( MONIT_HIT_0_IDLE  ),
    .MONIT_HIT_1_IDLE  ( MONIT_HIT_1_IDLE  ),
    .MONIT_BUSY_IDLE ( MONIT_BUSY_IDLE ))
 u_HitTrgCount (
    .clk_in                  ( clk_in                         ),
    .rst_in                ( rst_in                       ),
    .hit_syn_in              ( hit_syn_in              [7:0]  ),
    .busy_syn_in             ( busy_syn_in             [1:0]  ),
    .hit_start_in            ( hit_start_in                   ),
    .update_end_in           ( update_end_in                  ),
    .eff_trg_in              ( eff_trg_in                     ),
    .coincid_trg_in          ( coincid_trg_in                 ),
    .logic_match_in          ( logic_match_in                 ),
    .ext_trg_syn_in          ( ext_trg_syn_in                 ),
    .hit_monit_fix_sel_in    ( hit_monit_fix_sel_in    [2:0]  ),
    .busy_monit_fix_sel_in   ( busy_monit_fix_sel_in          ),

    .hit_monit_sel_out       ( hit_monit_sel_out       [2:0]  ),
    .hit_monit_err_cnt_out   ( hit_monit_err_cnt_out   [7:0]  ),
    .busy_monit_err_cnt_out  ( busy_monit_err_cnt_out  [7:0]  ),
    .hit_monit_cnt_0_out     ( hit_monit_cnt_0_out     [31:0] ),
    .hit_monit_cnt_1_out     ( hit_monit_cnt_1_out     [31:0] ),
    .busy_monit_cnt_out      ( busy_monit_cnt_out      [15:0] ),
    .hit_start_cnt_out       ( hit_start_cnt_out       [15:0] ),
    .logic_match_cnt_out     ( logic_match_cnt_out     [15:0] ),
    .eff_trg_cnt_out         ( eff_trg_cnt_out         [15:0] ),
    .coincid_trg_cnt_out     ( coincid_trg_cnt_out     [15:0] ),
    .ext_trg_cnt_out         ( ext_trg_cnt_out         [15:0] ),
    .trg_delay_timer_out       (  trg_delay_timer_out    [7:0]  )
);



endmodule