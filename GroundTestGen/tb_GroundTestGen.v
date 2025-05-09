//~ `New testbench
`timescale  1ns / 1ps

module tb_GroundTestGen;

// GroundTestGen Parameters
parameter PERIOD           = 20;
parameter TRG_PULSE_WIDTH  = 20;

// GroundTestGen Inputs
reg   clk_in                               = 0 ;
reg   rst_in_N                             = 0 ;
reg   ext_trg_test_in_N                    = 0 ;
reg   trg_in_N                             = 0 ;
reg   coincid_trg_in                       = 0 ;
reg   daq_busy_in                          = 0 ;
reg   logic_match_in                       = 0 ;
reg   [7:0]  ext_trg_delay_in              = 0 ;
reg   ext_trg_oe_in                        = 0 ;

// GroundTestGen Outputs
wire  logic_match_out_N                    ;
wire  daq_busy_out_N                       ;
wire  coincid_trg_test_out_N               ;
wire  trg_test_out_N                       ;
wire  ext_trg_syn_out                      ;
wire  ext_trg_raw_1us_out                  ;


initial
begin
    forever #(PERIOD/2)  clk_in=~clk_in;
end

initial
begin
    #(PERIOD*2) rst_in_N  =  1;
end


initial//
begin
    #90_000 ext_trg_test_in_N=1;  //90us
	#100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
	#100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
    #100_000 ext_trg_test_in_N=0;//
    #100_000 ext_trg_test_in_N=1;//
end

initial//
begin
    #90_000 trg_in_N=1;  //90us
	#8_000_000 trg_in_N=0;//
end


initial//
begin
    #90_000 coincid_trg_in=1;  //90us
    #30_000 coincid_trg_in=0;//
    #60_000 coincid_trg_in=1;//
    #30_000 coincid_trg_in=0;//
    #20_000 coincid_trg_in=1;//
    #30_000 coincid_trg_in=0;//


end


initial//
begin
    #90_000 daq_busy_in=1;  //90us
	#4_000_000 daq_busy_in=0;//
end

initial//
begin
    #90_000 logic_match_in=1;  //90us
	#6_000_000 logic_match_in=0;//
end

initial//
begin
    #10_000 ext_trg_delay_in=8'd15;  //90us

end

initial//
begin
    #90_000 ext_trg_oe_in=1;  //90us
	#1_000_000 ext_trg_oe_in=0;//
    #1_000_000 ext_trg_oe_in=1;//
	#1_000_000 ext_trg_oe_in=0;//
    #1_000_000 ext_trg_oe_in=1;//
	#1_000_000 ext_trg_oe_in=0;//
    #1_000_000 ext_trg_oe_in=1;//
    #1_000_000 ext_trg_oe_in=0;//
    #1_000_000 ext_trg_oe_in=1;//
end

GroundTestGen #(
    .TRG_PULSE_WIDTH ( TRG_PULSE_WIDTH ))
 u_GroundTestGen (
    .clk_in                  ( clk_in                        ),
    .rst_in_N                ( rst_in_N                      ),
    .ext_trg_test_in_N       ( ext_trg_test_in_N             ),
    .trg_in_N                ( trg_in_N                      ),
    .coincid_trg_in          ( coincid_trg_in                ),
    .daq_busy_in             ( daq_busy_in                   ),
    .logic_match_in          ( logic_match_in                ),
    .ext_trg_delay_in        ( ext_trg_delay_in        [7:0] ),
    .ext_trg_oe_in           ( ext_trg_oe_in                 ),

    .logic_match_out_N       ( logic_match_out_N             ),
    .daq_busy_out_N          ( daq_busy_out_N                ),
    .coincid_trg_test_out_N  ( coincid_trg_test_out_N        ),
    .trg_test_out_N          ( trg_test_out_N                ),
    .ext_trg_syn_out         ( ext_trg_syn_out               ),
    .ext_trg_raw_1us_out     ( ext_trg_raw_1us_out           )
);



endmodule