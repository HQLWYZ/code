`timescale 1ns/1ps
/*----------------------------------------------------------*/
/* 															*/
/*	file name:	tb_TrgTop.v			           			    */
/* 	date:		2025/03/11									*/
/* 	modified:	2026/01/07								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:	system clock = 50MHz                            */
/* 															*/
/*----------------------------------------------------------*/

module tb_TrgTop;

    //----------------------------------------------------------
    // 1. 参数与信号定义
    //----------------------------------------------------------
    parameter SYS_CLK_PERIOD = 20;  // 50MHz
    parameter RD_CLK_PERIOD  = 40;  // 25MHz (示例)

    // 输入信号寄存器
    reg         clk_in;
    reg         ctrl_rst_in;
    reg         pmu_busy_in;
    reg         wr_in;
    reg  [7:0]  wr_addr_in;
    reg  [15:0] data_in;
    reg         rd_in;
    reg  [7:0]  rd_addr_in;
    reg         fifo_rd_clk;
    reg         fifo_rd_in;
    reg         ext_trg_test_in;
    reg  [1:0]  ext_trg_enb_sig;
    
    // 命中与忙信号 (通常为低有效 _N)
    reg         si_trb_1_busy_a_in_N, si_trb_1_busy_b_in_N;
    reg         si_trb_2_busy_a_in_N, si_trb_2_busy_b_in_N;
    reg         acd_fee_top1_hit_a_in_N, acd_fee_top1_hit_b_in_N;
    reg         acd_fee_sec_hit_a_in_N,  acd_fee_sec_hit_b_in_N;
    reg         acd_fee_top2_hit_a_in_N, acd_fee_top2_hit_b_in_N;
    reg         csi_fee_hit_a_in_N,      csi_fee_hit_b_in_N;
    reg         cal_fee_1_hit_a_in_N,    cal_fee_1_hit_b_in_N;
    reg         cal_fee_2_hit_a_in_N,    cal_fee_2_hit_b_in_N;
    reg         cal_fee_3_hit_a_in_N,    cal_fee_3_hit_b_in_N;
    reg         cal_fee_4_hit_a_in_N,    cal_fee_4_hit_b_in_N;

    // 输出信号连线
    wire [7:0]  fifo_data_out;
    wire        fifo_empty_out;
    wire [15:0] mon_data_out;
    wire        trg_out_N_acd_a, trg_out_N_acd_b;
    wire        trg_out_N_CsI_track_a, trg_out_N_CsI_track_b;
    wire        trg_out_N_Si1_a, trg_out_N_Si1_b;
    wire        trg_out_N_Si2_a, trg_out_N_Si2_b;
    wire        trg_out_N_cal_fee_1_a, trg_out_N_cal_fee_1_b;
    wire        trg_out_N_cal_fee_2_a, trg_out_N_cal_fee_2_b;
    wire        trg_out_N_cal_fee_3_a, trg_out_N_cal_fee_3_b;
    wire        trg_out_N_cal_fee_4_a, trg_out_N_cal_fee_4_b;
    wire        trg_enb_sig;
    wire        fifo_prog_full_out;
    wire        data_trans_enb_sig;
    wire        cmd_rst_sig;

    //----------------------------------------------------------
    // 2. 实例化待测模块 (DUT)
    //----------------------------------------------------------
    TrgTop uut (
        .clk_in(clk_in),
        .ctrl_rst_in(ctrl_rst_in),
        .pmu_busy_in(pmu_busy_in),
        .wr_in(wr_in),
        .wr_addr_in(wr_addr_in),
        .data_in(data_in),
        .rd_in(rd_in),
        .rd_addr_in(rd_addr_in),
        .fifo_rd_clk(fifo_rd_clk),
        .fifo_rd_in(fifo_rd_in),
        .ext_trg_test_in(ext_trg_test_in),
        .ext_trg_enb_sig(ext_trg_enb_sig),
        .si_trb_1_busy_a_in_N(si_trb_1_busy_a_in_N),
        .si_trb_1_busy_b_in_N(si_trb_1_busy_b_in_N),
        .si_trb_2_busy_a_in_N(si_trb_2_busy_a_in_N),
        .si_trb_2_busy_b_in_N(si_trb_2_busy_b_in_N),
        .acd_fee_top1_hit_a_in_N(acd_fee_top1_hit_a_in_N),
        .acd_fee_top1_hit_b_in_N(acd_fee_top1_hit_b_in_N),
        .acd_fee_sec_hit_a_in_N(acd_fee_sec_hit_a_in_N),
        .acd_fee_sec_hit_b_in_N(acd_fee_sec_hit_b_in_N),
        .acd_fee_top2_hit_a_in_N(acd_fee_top2_hit_a_in_N),
        .acd_fee_top2_hit_b_in_N(acd_fee_top2_hit_b_in_N),
        .csi_fee_hit_a_in_N(csi_fee_hit_a_in_N),
        .csi_fee_hit_b_in_N(csi_fee_hit_b_in_N),
        .cal_fee_1_hit_a_in_N(cal_fee_1_hit_a_in_N),
        .cal_fee_1_hit_b_in_N(cal_fee_1_hit_b_in_N),
        .cal_fee_2_hit_a_in_N(cal_fee_2_hit_a_in_N),
        .cal_fee_2_hit_b_in_N(cal_fee_2_hit_b_in_N),
        .cal_fee_3_hit_a_in_N(cal_fee_3_hit_a_in_N),
        .cal_fee_3_hit_b_in_N(cal_fee_3_hit_b_in_N),
        .cal_fee_4_hit_a_in_N(cal_fee_4_hit_a_in_N),
        .cal_fee_4_hit_b_in_N(cal_fee_4_hit_b_in_N),
        .fifo_data_out(fifo_data_out),
        .fifo_empty_out(fifo_empty_out),
        .mon_data_out(mon_data_out),
        .trg_out_N_acd_a(trg_out_N_acd_a),
        .trg_out_N_acd_b(trg_out_N_acd_b),
        .trg_out_N_CsI_track_a(trg_out_N_CsI_track_a),
        .trg_out_N_CsI_track_b(trg_out_N_CsI_track_b),
        .trg_out_N_Si1_a(trg_out_N_Si1_a),
        .trg_out_N_Si1_b(trg_out_N_Si1_b),
        .trg_out_N_Si2_a(trg_out_N_Si2_a),
        .trg_out_N_Si2_b(trg_out_N_Si2_b),
        .trg_out_N_cal_fee_1_a(trg_out_N_cal_fee_1_a),
        .trg_out_N_cal_fee_1_b(trg_out_N_cal_fee_1_b),
        .trg_out_N_cal_fee_2_a(trg_out_N_cal_fee_2_a),
        .trg_out_N_cal_fee_2_b(trg_out_N_cal_fee_2_b),
        .trg_out_N_cal_fee_3_a(trg_out_N_cal_fee_3_a),
        .trg_out_N_cal_fee_3_b(trg_out_N_cal_fee_3_b),
        .trg_out_N_cal_fee_4_a(trg_out_N_cal_fee_4_a),
        .trg_out_N_cal_fee_4_b(trg_out_N_cal_fee_4_b),
        .trg_enb_sig(trg_enb_sig),
        .fifo_prog_full_out(fifo_prog_full_out),
        .data_trans_enb_sig(data_trans_enb_sig),
        .cmd_rst_sig(cmd_rst_sig)
    );

    //----------------------------------------------------------
    // 3. 时钟生成
    //----------------------------------------------------------
    initial clk_in = 0;
    always #(SYS_CLK_PERIOD/2) clk_in = ~clk_in;

    initial fifo_rd_clk = 0;
    always #(RD_CLK_PERIOD/2) fifo_rd_clk = ~fifo_rd_clk;

    //----------------------------------------------------------
    // 4. 辅助任务 (Tasks)
    //----------------------------------------------------------
    
    // 系统复位任务
    task sys_reset;
        begin
            ctrl_rst_in = 1;
            #(SYS_CLK_PERIOD * 10);
            ctrl_rst_in = 0;
            #(SYS_CLK_PERIOD * 5);
        end
    endtask

    // 写配置寄存器任务
    task write_config(input [7:0] addr, input [15:0] data);
        begin
            #100_000 
            wr_addr_in=8'd0;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd1;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd2;
            data_in=16'b0000_0000_0000_0001;
            #200 
            wr_addr_in=8'd3;
            data_in=16'b0000_0000_0101_0101;
            #200 
            wr_addr_in=8'd4;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd5;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd6;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd7;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd8;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd9;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd10;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd11;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd12;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd13;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd14;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd15;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd16;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd17;
            data_in=16'b0000_0000_0000_0101;
            #200 
            wr_addr_in=8'd18;
            data_in=16'b0000_0000_0000_0100;
            #200 
            wr_addr_in=8'd19;
            data_in=16'b0000_0000_0000_0101;
        end
    endtask

    // 模拟命中信号触发任务 (产生一个持续 100ns 的低脉冲)


    //----------------------------------------------------------
    // 5. 激励流程
    //----------------------------------------------------------
initial
    begin
        $dumpfile("./tb_TrgTop.vcd");
        $dumpvars(0,tb_TrgTop);
        #1_000_000 $finish;
end

    initial begin
        // 初始化信号

        
        ctrl_rst_in = 0;
        pmu_busy_in = 0;
        wr_in = 0; wr_addr_in = 0; data_in = 0;
        rd_in = 0; rd_addr_in = 0;
        fifo_rd_in = 0;
        ext_trg_test_in = 0;
        ext_trg_enb_sig = 2'b00;

        // 初始化所有低有效输入为 1 (不活跃)
        {si_trb_1_busy_a_in_N, si_trb_1_busy_b_in_N, si_trb_2_busy_a_in_N, si_trb_2_busy_b_in_N} = 4'hF;
        {acd_fee_top1_hit_a_in_N, acd_fee_top1_hit_b_in_N, acd_fee_sec_hit_a_in_N, acd_fee_sec_hit_b_in_N} = 4'hF;
        {acd_fee_top2_hit_a_in_N, acd_fee_top2_hit_b_in_N, csi_fee_hit_a_in_N, csi_fee_hit_b_in_N} = 4'hF;
        {cal_fee_1_hit_a_in_N, cal_fee_1_hit_b_in_N, cal_fee_2_hit_a_in_N, cal_fee_2_hit_b_in_N} = 4'hF;
        {cal_fee_3_hit_a_in_N, cal_fee_3_hit_b_in_N, cal_fee_4_hit_a_in_N, cal_fee_4_hit_b_in_N} = 4'hF;

        // 步骤 1: 复位
        sys_reset();

        // 步骤 2: 配置寄存器 (示例地址和数据)
        write_config(8'h01, 16'h0001); // 假设 0x01 是使能触发的寄存器
        write_config(8'h05, 16'h00C8); // 配置延迟或阈值参数
        
        #100;

        // 步骤 3: 模拟输入命中信号
        //trigger_hit_sim();

        // 步骤 4: 等待触发输出并观察


        // 步骤 5: 模拟 FIFO 读取
        #500;
        if (!fifo_empty_out) begin
            @(posedge fifo_rd_clk);
            fifo_rd_in = 1;
            #(RD_CLK_PERIOD * 10);
            fifo_rd_in = 0;
        end

        // 结束仿真
   
    end


initial//-----------TRB BUSY IN------
begin
repeat(3000)
	begin
	#620_000 si_trb_1_busy_a_in_N=0;
	#620_000 si_trb_1_busy_a_in_N=1;
	end
si_trb_1_busy_a_in_N=1'b1;
end
initial//-----------TRB BUSY IN------
begin
repeat(3000)
	begin
	#620_000 si_trb_1_busy_b_in_N=0;
	#620_000 si_trb_1_busy_b_in_N=1;
	end
si_trb_1_busy_b_in_N=1'b1;
end
initial//-----------TRB BUSY IN------
begin
    #100 si_trb_2_busy_a_in_N=1'b1;
repeat(3000)
	begin
	#520_000 si_trb_2_busy_a_in_N=0;
	#720_000 si_trb_2_busy_a_in_N=1;
	end
si_trb_2_busy_a_in_N=1'b1;
end
initial//-----------TRB BUSY IN------
begin
    #100 si_trb_2_busy_b_in_N=1'b1;
repeat(3000)
	begin
	#520_000 si_trb_2_busy_b_in_N=0;
	#720_000 si_trb_2_busy_b_in_N=1;
	end
si_trb_2_busy_b_in_N=1'b1;
end



initial//-----------HIT IN------
begin
    #100 acd_fee_top1_hit_a_in_N=1'b1;
repeat(3000)
	begin
	#159_800 acd_fee_top1_hit_a_in_N=0;
    #200    acd_fee_top1_hit_a_in_N=1;
	end
acd_fee_top1_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
    #100 acd_fee_top1_hit_b_in_N=1'b1;
repeat(3000)
	begin
	#159_800 acd_fee_top1_hit_b_in_N=0;
    #200    acd_fee_top1_hit_b_in_N=1;
	end
acd_fee_top1_hit_b_in_N=1'b1;
end

initial//-----------HIT IN------
begin
    #100 acd_fee_sec_hit_a_in_N=1'b1;
repeat(3000)
	begin
	#159_800 acd_fee_sec_hit_a_in_N=0;
	#200    acd_fee_sec_hit_a_in_N=1;
	end
acd_fee_sec_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
    #100 acd_fee_sec_hit_b_in_N=1'b1;
repeat(3000)
	begin
	#159_800 acd_fee_sec_hit_b_in_N=0;
	#200    acd_fee_sec_hit_b_in_N=1;
	end
acd_fee_sec_hit_b_in_N=1'b1;
end


initial//-----------HIT IN------
begin
    #100 acd_fee_top2_hit_a_in_N=1'b1;
repeat(3000)
	begin
	#159_810 acd_fee_top2_hit_a_in_N=0;
	#200    acd_fee_top2_hit_a_in_N=1;
	end
acd_fee_top2_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
    #100 acd_fee_top2_hit_b_in_N=1'b1;
repeat(3000)
	begin
	#159_810 acd_fee_top2_hit_b_in_N=0;
	#200    acd_fee_top2_hit_b_in_N=1;
	end
acd_fee_top2_hit_b_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200       csi_fee_hit_a_in_N=1;
	#159_800    csi_fee_hit_a_in_N=0;
	end
csi_fee_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        csi_fee_hit_b_in_N=1;
	#159_810    csi_fee_hit_b_in_N=0;
	end
csi_fee_hit_b_in_N=1'b1;
end


initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_1_hit_a_in_N=1;
	//#159_810    cal_fee_1_hit_a_in_N=0;
	end
cal_fee_1_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_1_hit_b_in_N=1;
	//#159_810    cal_fee_1_hit_b_in_N=0;
	end
cal_fee_1_hit_b_in_N=1'b1;
end

initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200        cal_fee_2_hit_a_in_N=1;
	#159_820    cal_fee_2_hit_a_in_N=0;
	end
cal_fee_2_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200      cal_fee_2_hit_b_in_N=1;
	//#159_820    cal_fee_2_hit_b_in_N=0;
	end
cal_fee_2_hit_b_in_N=1'b1;
end


initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200      cal_fee_3_hit_a_in_N=1;
	//#159_830    cal_fee_3_hit_a_in_N=0;
	end
cal_fee_3_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200      cal_fee_3_hit_b_in_N=1;
	//#159_830    cal_fee_3_hit_b_in_N=0;
	end
cal_fee_3_hit_b_in_N=1'b1;
end


initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200      cal_fee_4_hit_a_in_N=1;
	#159_840    cal_fee_4_hit_a_in_N=0;
	end
cal_fee_4_hit_a_in_N=1'b1;
end
initial//-----------HIT IN------
begin
repeat(3000)
	begin
	#200      cal_fee_4_hit_b_in_N=1;
	//#159_840    cal_fee_4_hit_b_in_N=0;
	end
cal_fee_4_hit_a_in_N=1'b1;
end

initial begin
    // 每隔 1ms (仿真时间) 打印一次进度，防止屏幕被刷屏
    forever begin
        #10000; 
        $display(">>> Simulation Progress: %t ns", $time);
    end
end

endmodule