//~ `New testbench
`timescale  1ns / 1ps

module tb_HitTrgCount;


initial
    begin
        $dumpfile("./tb_HitTrgCount.vcd");
        $dumpvars(0,tb_HitTrgCount);
        #3_000_000 $finish;
end

// HitTrgCount Parameters
parameter PERIOD           = 20;
parameter HIT_WIDTH        = 8;
parameter MONIT_HIT_0_IDLE   = 0;
parameter MONIT_HIT_1_IDLE   = 0;
parameter MONIT_BUSY_IDLE  = 0;

// HitTrgCount Inputs
reg   clk_in                               = 0 ;
reg   rst_in                             = 0 ;
reg   rd_in                             = 0 ;
reg   [12:0]  hit_syn_in                    = 0 ;
reg   [1:0]  busy_syn_in                   = 0 ;
reg   hit_start_in                         = 0 ;
reg   eff_trg_in                           = 0 ;
reg   coincid_trg_in                       = 0 ;
reg   logic_match_in                       = 0 ;
reg   ext_trg_syn_in                       = 0 ;
reg   [3:0]  hit_monit_fix_sel_in          = 7 ;
reg   busy_monit_fix_sel_in                = 1 ;

// HitTrgCount Outputs
wire  [7:0]  hit_monit_sel_out             ;
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
wire  [7:0]   trg_delay_timer_out              ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in  =  1;
    #(PERIOD*2) rst_in  =  0;
end

initial//-----------rd in------
begin
repeat(3000)
	begin
	#180_000 rd_in=1;
	#1_60 rd_in=0;
	#180_000 rd_in=1;
	#1_60 rd_in=0;
    #180_000 rd_in=1;
	#1_60 rd_in=0;
	end
rd_in=1'b1;
end


initial//-----------HIT[12] IN------
begin
repeat(3000)
	begin
	#80_000 hit_syn_in[12]=1;
	#160 hit_syn_in[12]=0;
	end
hit_syn_in[12]=1'b1;
end

initial//-----------HIT[9] IN------
begin
repeat(3000)
	begin
	#83_000 hit_syn_in[9]=1;
	#160 hit_syn_in[9]=0;
	end
hit_syn_in[9]=1'b1;
end

initial//-----------HIT[7] IN------
begin
repeat(3000)
	begin
	#80_000 hit_syn_in[7]=1;
	#60 hit_syn_in[7]=0;
	end
hit_syn_in[7]=1'b1;
end

initial//-----------HIT[4] IN------
begin
repeat(3000)
	begin
	#83_000 hit_syn_in[4]=1;
	#360 hit_syn_in[4]=0;
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

initial//-----------logic_match_in------
begin
repeat(3000)
	begin
	#19_000 logic_match_in=0;
	#4_000 logic_match_in=1;
    #9_000 logic_match_in=0;
	#4_000 logic_match_in=1;
	end
logic_match_in=1'b1;
end

initial//-----------eff_trg_in------
begin
repeat(3000)
	begin
	#29_000 eff_trg_in=1;
	#20 eff_trg_in=0;
    #9_000 eff_trg_in=1;
	#20 eff_trg_in=0;
	end
eff_trg_in=1'b0;
end

initial//-----------coincid_trg_in------
begin
repeat(3000)
	begin
	#39_000 coincid_trg_in=0;
	#4_000 coincid_trg_in=1;
    #9_000 coincid_trg_in=0;
	#4_000 coincid_trg_in=1;
	end
coincid_trg_in=1'b1;
end

initial//-----------ext_trg_syn_in------
begin
repeat(3000)
	begin
	#49_000 ext_trg_syn_in=0;
	#4_000 ext_trg_syn_in=1;
    #9_000 ext_trg_syn_in=0;
	#4_000 ext_trg_syn_in=1;
	end
ext_trg_syn_in=1'b1;
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
    .MONIT_HIT_0_IDLE  ( MONIT_HIT_0_IDLE  ),
    .MONIT_HIT_1_IDLE  ( MONIT_HIT_1_IDLE  ))
 u_HitTrgCount (
    .clk_in                  ( clk_in                         ),
    .rst_in                ( rst_in                       ),
    .rd_in                  ( rd_in                       ),
    .hit_syn_in              ( hit_syn_in              [12:0]  ),
    .busy_syn_in             ( busy_syn_in             [1:0]  ),
    .hit_start_in            ( hit_start_in                   ),
    .eff_trg_in              ( eff_trg_in                     ),
    .coincid_trg_in          ( coincid_trg_in                 ),
    .logic_match_in          ( logic_match_in                 ),
    .ext_trg_syn_in          ( ext_trg_syn_in                 ),
    .hit_monit_fix_sel_in    ( hit_monit_fix_sel_in    [3:0]  ),
    .busy_monit_fix_sel_in   ( busy_monit_fix_sel_in          ),

    .hit_monit_sel_out       ( hit_monit_sel_out       [7:0]  ),//OK
    .hit_monit_err_cnt_out   ( hit_monit_err_cnt_out   [7:0]  ),//OK
    .busy_monit_err_cnt_out  ( busy_monit_err_cnt_out  [7:0]  ),//OK
    .hit_monit_cnt_0_out     ( hit_monit_cnt_0_out     [31:0] ),//OK
    .hit_monit_cnt_1_out     ( hit_monit_cnt_1_out     [31:0] ),//OK
    .busy_monit_cnt_out      ( busy_monit_cnt_out      [15:0] ),//OK
    .hit_start_cnt_out       ( hit_start_cnt_out       [15:0] ),//OK
    .logic_match_cnt_out     ( logic_match_cnt_out     [15:0] ),//OK
    .eff_trg_cnt_out         ( eff_trg_cnt_out         [15:0] ),//OK
    .coincid_trg_cnt_out     ( coincid_trg_cnt_out     [15:0] ),//OK
    .ext_trg_cnt_out         ( ext_trg_cnt_out         [15:0] ),//OK
    .trg_delay_timer_out       (  trg_delay_timer_out    [7:0]  )//OK
);



endmodule