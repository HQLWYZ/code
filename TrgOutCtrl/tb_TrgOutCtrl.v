//~ `New testbench
`timescale  1ns / 1ps
//`include "./TrgOutCtrl.v"

module tb_TrgOutCtrl;

// TrgOutCtrl Parameters
parameter PERIOD           = 20;
parameter TRG_PULSE_WIDTH  = 20;
parameter CHK_PULSE_WIDTH  = 50;
parameter IDLE             = 0 ;

// TrgOutCtrl Inputs
reg   clk_in                               = 0 ;
reg   rst_in                               = 1 ;
reg   coincid_trg_in                       = 0 ;
reg   ext_trg_syn_in                       = 0 ;
reg   cycled_trg_in                        = 0 ;
reg   trg_enb_in                           = 0 ;
reg   [7:0]  trg_dead_time_in              = 3 ;
reg   [15:0]  eff_trg_cnt_in               = 12 ;
reg   [1:0]  busy_syn_in                   = 0 ;   
reg   busy_ignore_in                        = 1 ; 
reg   [1:0]  logic_burst_sel_in             = 0 ;//2'b11: burst mode,
reg   pmu_busy_in                           = 0 ; 


// TrgOutCtrl Outputs
wire  eff_trg_out                          ;
//wire  trg_out_N                            ;
//wire  daq_busy_out                         ;
    wire          trg_out_N_acd_a, trg_out_N_acd_b; //width = 400ns, 400us trigger signal with 1000us trigger id check signal
    wire          trg_out_N_CsI_track_a, trg_out_N_CsI_track_b;
    wire          trg_out_N_Si1_a, trg_out_N_Si1_b,trg_out_N_Si2_a, trg_out_N_Si2_b;
    wire          trg_out_N_cal_fee_1_a, trg_out_N_cal_fee_1_b,trg_out_N_cal_fee_2_a, trg_out_N_cal_fee_2_b;
    wire          trg_out_N_cal_fee_3_a, trg_out_N_cal_fee_3_b,trg_out_N_cal_fee_4_a, trg_out_N_cal_fee_4_b ;


initial
begin
    $dumpfile("./tb_TrgOutCtrl.vcd");
    $dumpvars(0,tb_TrgOutCtrl);
    #2_000_000 $finish;
end

initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in  =  0;
end


initial//-----------coincid_trg_in------
begin
repeat(3000)
	begin
	#221_000 coincid_trg_in=1;
	#160 coincid_trg_in=0;
	end
coincid_trg_in=1'b1;
end

initial//-----------ext_trg_syn_in------
begin
repeat(3000)
	begin
	#210_000 ext_trg_syn_in=1;
	#260 ext_trg_syn_in=0;
	end
ext_trg_syn_in=1'b1;
end


initial//-----------cycled_trg_in------
begin
repeat(3000)
	begin
	#309_000 cycled_trg_in=1;
	#160 cycled_trg_in=0;
	end
cycled_trg_in=1'b1;
end

initial//-----------SI_BUSY_in[1]------
begin
repeat(3000)
	begin
	#209_000 busy_syn_in[1]=1;
	#60_000 busy_syn_in[1]=0;
	end
busy_syn_in[1]=1'b1;
end

initial//-----------SI_BUSY_in[0]------
begin
repeat(3000)
	begin
	#126_000 busy_syn_in[0]=1;
	#60_000 busy_syn_in[0]=0;
	end
busy_syn_in[0]=1'b1;
end

initial//-----------PMU_busy------
begin
repeat(3000)
	begin
	#240_000 pmu_busy_in=1;
	#160_000 pmu_busy_in=0;
	end
pmu_busy_in=1'b1;
end


initial
begin
    #59_000 trg_enb_in=1;
end

initial
begin
    #202_000 eff_trg_cnt_in=0;
    #150_000 eff_trg_cnt_in=1;
    #150_000 eff_trg_cnt_in=2048;
    #150_000 eff_trg_cnt_in=4095;
    #150_000 eff_trg_cnt_in=4096;
    #150_000 eff_trg_cnt_in=4097;
    #150_000 eff_trg_cnt_in=4098;
end


TrgOutCtrl #(
    .TRG_PULSE_WIDTH ( TRG_PULSE_WIDTH ),
    .CHK_PULSE_WIDTH ( CHK_PULSE_WIDTH ),
    .IDLE            ( IDLE            ))
 u_TrgOutCtrl (
    .clk_in                  ( clk_in                   ),
    .rst_in                ( rst_in                 ),
    .coincid_trg_in          ( coincid_trg_in           ),
    .ext_trg_syn_in          ( ext_trg_syn_in           ),
    .cycled_trg_in           ( cycled_trg_in            ),
    .busy_syn_in            ( busy_syn_in            ),    
    .busy_ignore_in         ( busy_ignore_in            ), 
    .logic_burst_sel_in     ( logic_burst_sel_in            ),
    .pmu_busy_in            ( pmu_busy_in            ),    
    .trg_enb_in              ( trg_enb_in               ),
    .trg_dead_time_in        ( trg_dead_time_in  [7:0]  ),
    .eff_trg_cnt_in          ( eff_trg_cnt_in    [15:0] ),
    .eff_trg_out             ( eff_trg_out              ),
    .trg_out_N_acd_a       ( trg_out_N_acd_a                ),
    .trg_out_N_acd_b       ( trg_out_N_acd_b                ),
    .trg_out_N_CsI_track_a ( trg_out_N_CsI_track_a                ),
    .trg_out_N_CsI_track_b ( trg_out_N_CsI_track_b                ),
    .trg_out_N_Si1_a ( trg_out_N_Si1_a                ),
    .trg_out_N_Si1_b( trg_out_N_Si1_b                ),
    .trg_out_N_Si2_a ( trg_out_N_Si2_a                ),
    .trg_out_N_Si2_b( trg_out_N_Si2_b                ),
    .trg_out_N_cal_fee_1_a ( trg_out_N_cal_fee_1_a                ),
    .trg_out_N_cal_fee_1_b( trg_out_N_cal_fee_1_b                ),
    .trg_out_N_cal_fee_2_a( trg_out_N_cal_fee_2_a                ),
    .trg_out_N_cal_fee_2_b( trg_out_N_cal_fee_2_b                ),
    .trg_out_N_cal_fee_3_a  ( trg_out_N_cal_fee_3_a                ),
    .trg_out_N_cal_fee_3_b  ( trg_out_N_cal_fee_3_b                ),
    .trg_out_N_cal_fee_4_a  ( trg_out_N_cal_fee_4_a                ),
    .trg_out_N_cal_fee_4_b ( trg_out_N_cal_fee_4_b)
);



endmodule