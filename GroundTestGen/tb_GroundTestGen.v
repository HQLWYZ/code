//~ `New testbench
`timescale  1ns / 1ps

module tb_GroundTestGen;

initial
    begin
        $dumpfile("./tb_GroundTestGen.vcd");
        $dumpvars(0,tb_GroundTestGen);
        #2_000_000 $finish;
end
// GroundTestGen Parameters
parameter PERIOD           = 20;
parameter TRG_PULSE_WIDTH  = 20;

// GroundTestGen Inputs
reg   clk_in                               = 0 ;
reg   rst_in                             = 1 ;
reg   ext_trg_test_in                    = 0 ;
reg   coincid_trg_in                       = 0 ;
reg   logic_match_in                       = 0 ;
reg   [7:0]  ext_trg_delay_in              = 0 ;
reg   [1:0]  ext_trg_oe_in                        = 0 ;

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
    #(PERIOD*2) rst_in  =  0;
end


initial//
begin
    #90_000 ext_trg_test_in=1;  //90us
	#100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
	#100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
    #100_000 ext_trg_test_in=0;//
    #100_000 ext_trg_test_in=1;//
end




initial//
begin
    #90_000 coincid_trg_in=1;  //90us
    #300 coincid_trg_in=0;//
    #60_000 coincid_trg_in=1;//
    #300 coincid_trg_in=0;//
    #20_000 coincid_trg_in=1;//
    #300 coincid_trg_in=0;//


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
    #90_000 ext_trg_oe_in=2'b01;  //90us
	#1_000_000 ext_trg_oe_in=2'b00;//
    #1_000_000 ext_trg_oe_in=2'b01;//
	#1_000_000 ext_trg_oe_in=2'b00;//
    #1_000_000 ext_trg_oe_in=2'b01;//
	#1_000_000 ext_trg_oe_in=2'b11;//
    #1_000_000 ext_trg_oe_in=2'b01;//
    #1_000_000 ext_trg_oe_in=2'b00;//
    #1_000_000 ext_trg_oe_in=2'b01;//
end

GroundTestGen #(
    .TRG_PULSE_WIDTH ( TRG_PULSE_WIDTH ))
 u_GroundTestGen (
    .clk_in                  ( clk_in                        ),
    .rst_in                ( rst_in                      ),
    .ext_trg_test_in       ( ext_trg_test_in             ),
    .coincid_trg_in          ( coincid_trg_in                ),
    .ext_trg_delay_in        ( ext_trg_delay_in        [7:0] ),
    .ext_trg_oe_in           ( ext_trg_oe_in            [1:0]   ),
    .coincid_trg_test_out_N  ( coincid_trg_test_out_N        ),

    .ext_trg_syn_out         ( ext_trg_syn_out               )

);



endmodule