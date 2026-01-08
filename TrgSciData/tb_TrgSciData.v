//~ `New testbench
`timescale  1ns / 1ps

module tb_TrgSciData;
// TrgSciData Parameters
parameter PERIOD  = 10;

initial
    begin
        $dumpfile("./tb_TrgSciData.vcd");
        $dumpvars(0,tb_TrgSciData);
        #3_000_000 $finish;
end

// TrgSciData Inputs
reg   clk_in                               = 0 ;
reg   rst_in                             = 0 ;
reg   data_trans_enb_sig                     = 0 ;
reg   fifo_rd_clk                           = 0 ;
reg   fifo_rd_in                            = 0 ;
reg   [7:0]   logic_grp_oe_sig = 0 ;
reg   [15:0]  hit_sig_stus_in = 0 ;
reg   [4:0]   W_logic_all_grp_result_in = 0 ;
reg   [7:0] trg_mode_mip1_in                           = 0 ;
reg   [7:0]  trg_mode_mip2_in = 0 ;
reg   [7:0]  trg_mode_gm1_in = 0 ;
reg   [7:0]  trg_mode_gm2_in = 0 ;
reg   [7:0]  trg_mode_ubs_in = 0 ;
reg   [15:0]  eff_trg_cnt_in = 0 ;
reg           eff_trg_in = 0 ;// trigger sources, when trigger happens, trigger sci-data will be written into the FIFO



// TrgSciData Outputs
wire  [7:0]  fifo_data_out;
wire          fifo_prog_full_out;
wire          fifo_empty_out;


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
    #400_100        fifo_rd_in=1;  //100.1us
	#10_000_000     fifo_rd_in=0;//10ms
end

initial
begin
    forever #(PERIOD)  fifo_rd_clk=~fifo_rd_clk;
end


initial//
begin
    #100_000        data_trans_enb_sig=1;  //100.1us
	#10_000_000     data_trans_enb_sig=0;//10ms
end


initial//
begin
    #100_000        eff_trg_in=1;  //100.1us
	#20     eff_trg_in=0;//10ms
    #100_000        eff_trg_in=1;  //100.1us
	#20     eff_trg_in=0;//10ms
end


initial//
begin
    #100_000     
        logic_grp_oe_sig=8'b0000_1001;  //100.1us
        hit_sig_stus_in=16'b0000_1001_0110_1111;
        W_logic_all_grp_result_in=5'b10100;
        trg_mode_mip1_in=8'b0000_0011;
        trg_mode_mip2_in=8'b0000_0101;
        trg_mode_gm1_in=8'b0000_0111;
        trg_mode_gm2_in=8'b0001_0001;
        trg_mode_ubs_in=8'b0010_0001;
        //trg_mode_brst_in=8'b0000_1111;
        eff_trg_cnt_in=16'h1234;
        
    #100_000     
        logic_grp_oe_sig=8'b0000_1001;  //100.1us
        hit_sig_stus_in=16'b0000_1001_0110_1111;
        W_logic_all_grp_result_in=5'b10100;
        trg_mode_mip1_in=8'b0000_0011;
        trg_mode_mip2_in=8'b0000_0101;
        trg_mode_gm1_in=8'b0000_0111;
        trg_mode_gm2_in=8'b0001_0001;
        trg_mode_ubs_in=8'b0010_0001;
        //trg_mode_brst_in=8'b0000_1111;
        eff_trg_cnt_in=16'h1244;
        

end




TrgSciData  u_TrgSciData (
    .clk_in                  ( clk_in                        ),
    .rst_in                ( rst_in                      ),
	.data_trans_enb_sig(data_trans_enb_sig),
	.fifo_rd_clk(fifo_rd_clk),
    .fifo_rd_in(fifo_rd_in),  
    .logic_grp_oe_sig(logic_grp_oe_sig),
    .hit_sig_stus_in(hit_sig_stus_in),
    .W_logic_all_grp_result_in(W_logic_all_grp_result_in),
    .trg_mode_mip1_in(trg_mode_mip1_in[7:0]),
    .trg_mode_mip2_in(trg_mode_mip2_in[7:0]),
    .trg_mode_gm1_in(trg_mode_gm1_in[7:0]),
    .trg_mode_gm2_in(trg_mode_gm2_in[7:0]),
    .trg_mode_ubs_in(trg_mode_ubs_in[7:0]),
    .eff_trg_cnt_in(eff_trg_cnt_in),
    .eff_trg_in(eff_trg_in),
    .fifo_data_out(fifo_data_out),
    .fifo_prog_full_out(fifo_prog_full_out),
    .fifo_empty_out(fifo_empty_out)
);




endmodule