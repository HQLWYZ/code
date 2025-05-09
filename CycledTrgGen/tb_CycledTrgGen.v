//~ `New testbench
`timescale  1ns / 1ps

module tb_CycledTrgGen;

// CycledTrgGen Parameters
parameter PERIOD  = 20;


// CycledTrgGen Inputs
reg   clk_in                               = 0 ;
reg   rst_in_N                             = 0 ;
reg   [1:0]  cycled_trg_oe_in              = 0 ;
reg   cycled_trg_bgn_in                    = 0 ;
reg   [7:0]  cycled_trg_period_in          = 0 ;
reg   [15:0]  cycled_trg_num_in            = 0 ;


/////cycled_trg_oe_in = 2'b10: non-stop, to send the cycled trigger signal
///  cycled_trg_oe_in = 2'b01: just send the cycled signal when receiving the command.


// CycledTrgGen Outputs
wire  cycled_trg_out                       ;
wire  cycled_trg_end_out                   ;
wire  cycled_trg_1us_out                   ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in_N  =  1;
end


initial//-----------cycled_trg_oe_in------
begin
    #90_000 cycled_trg_oe_in=2'b10;  //90us
	#5_000_000 cycled_trg_oe_in=2'b01;//5ms
end

initial//-----------cycled_trg_bgn_in------
begin
    #91_000 cycled_trg_bgn_in=1;
	#2_000 cycled_trg_bgn_in=0;
    #5_000_000 cycled_trg_bgn_in=1;
    #4_000 cycled_trg_bgn_in=0;
end

initial//-----------cycled_trg_period_in------
begin
    #80_000 cycled_trg_period_in=8'd400;
	//#20_000 cycled_trg_period_in=0;
end

initial//-----------cycled_trg_num_in------
begin
    #80_000 cycled_trg_num_in=16'd20;
	//#20_000 cycled_trg_num_in=0;
end


CycledTrgGen  u_CycledTrgGen (
    .clk_in                  ( clk_in                       ),
    .rst_in_N                ( rst_in_N                     ),
    .cycled_trg_oe_in        ( cycled_trg_oe_in      [1:0]  ),
    .cycled_trg_bgn_in       ( cycled_trg_bgn_in            ),
    .cycled_trg_period_in    ( cycled_trg_period_in  [7:0]  ),
    .cycled_trg_num_in       ( cycled_trg_num_in     [15:0] ),

    .cycled_trg_out          ( cycled_trg_out               ),
    .cycled_trg_end_out      ( cycled_trg_end_out           ),
    .cycled_trg_1us_out      ( cycled_trg_1us_out           )
);



endmodule