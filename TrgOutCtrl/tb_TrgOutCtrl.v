//~ `New testbench
`timescale  1ns / 1ps

module tb_TrgOutCtrl;

// TrgOutCtrl Parameters
parameter PERIOD           = 20;
parameter TRG_PULSE_WIDTH  = 20;
parameter CHK_PULSE_WIDTH  = 50;
parameter IDLE             = 0 ;

// TrgOutCtrl Inputs
reg   clk_in                               = 0 ;
reg   rst_in_N                             = 0 ;
reg   coincid_trg_in                       = 0 ;
reg   ext_trg_syn_in                       = 0 ;
reg   cycled_trg_in                        = 0 ;
reg   trg_enb_in                           = 0 ;
reg   [7:0]  trg_dead_time_in              = 2 ;
reg   [15:0]  eff_trg_cnt_in               = 0 ;

// TrgOutCtrl Outputs
wire  eff_trg_out                          ;
wire  trg_out_N                            ;
wire  daq_busy_out                         ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in_N  =  1;
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

initial
begin
    #509_000 trg_enb_in=1;
end

initial
begin
    #500_000 eff_trg_cnt_in=1;
    #150_000 eff_trg_cnt_in=2;
    #150_000 eff_trg_cnt_in=20;
    #150_000 eff_trg_cnt_in=200;
    #150_000 eff_trg_cnt_in=2000;
    #150_000 eff_trg_cnt_in=4000;
    #150_000 eff_trg_cnt_in=4095;
    #150_000 eff_trg_cnt_in=4096;
    #150_000 eff_trg_cnt_in=4097;
end


TrgOutCtrl #(
    .TRG_PULSE_WIDTH ( TRG_PULSE_WIDTH ),
    .CHK_PULSE_WIDTH ( CHK_PULSE_WIDTH ),
    .IDLE            ( IDLE            ))
 u_TrgOutCtrl (
    .clk_in                  ( clk_in                   ),
    .rst_in_N                ( rst_in_N                 ),
    .coincid_trg_in          ( coincid_trg_in           ),
    .ext_trg_syn_in          ( ext_trg_syn_in           ),
    .cycled_trg_in           ( cycled_trg_in            ),
    .trg_enb_in              ( trg_enb_in               ),
    .trg_dead_time_in        ( trg_dead_time_in  [7:0]  ),
    .eff_trg_cnt_in          ( eff_trg_cnt_in    [15:0] ),

    .eff_trg_out             ( eff_trg_out              ),
    .trg_out_N               ( trg_out_N                ),
    .daq_busy_out            ( daq_busy_out             )
);



endmodule