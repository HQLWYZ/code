/*----------------------------------------------------------*/
/*	file name:	Coincidence.v			                    */
/* date:		2025/02/27									*/
/* modified:	2026/04/20          						*/
/* version:		v1.0										*/
/* author:		Wang Shen									*/
/* email:		wangshen@pmo.ac.cn							*/
/* note1:		system clock = 50MHz						*/
/* note2:		ACD_side means ACD top2						*/
/* */
/*----------------------------------------------------------*/
module Coincidence(
	input			clk_in,
	input			rst_in,
    input           si_trb_1_busy_a_in_N,   //--------------all hits input and busy input
    input           si_trb_1_busy_b_in_N,
    input           si_trb_2_busy_a_in_N,
    input           si_trb_2_busy_b_in_N,
    input           acd_fee_top_hit_a_in_N,
    input           acd_fee_top_hit_b_in_N,
    input           acd_fee_sec_hit_a_in_N,
    input           acd_fee_sec_hit_b_in_N,
    input           acd_fee_sid_hit_a_in_N,
    input           acd_fee_sid_hit_b_in_N,
    input           csi_fee_hit_a_in_N,
    input           csi_fee_hit_b_in_N,
    input           cal_fee_1_hit_a_in_N,
    input           cal_fee_1_hit_b_in_N,
    input           cal_fee_2_hit_a_in_N,
    input           cal_fee_2_hit_b_in_N,
    input           cal_fee_3_hit_a_in_N,
    input           cal_fee_3_hit_b_in_N,
    input           cal_fee_4_hit_a_in_N,
    input           cal_fee_4_hit_b_in_N,
	input   [7:0]   logic_grp0_mux_in,    //--------------control register input
    input   [1:0]   logic_grp0_sel_in,     
	input   [5:0]   coincid_MIP1_div_in,
	input   [7:0]   logic_grp1_mux_in,
    input   [1:0]   logic_grp1_sel_in,
	input   [5:0]   coincid_MIP2_div_in,
	input   [7:0]   logic_grp2_mux_in,
    input   [1:0]   logic_grp2_sel_in,
	input   [7:0]   logic_grp3_mux_in,
    input   [1:0]   logic_grp3_sel_in,
	input   [7:0]   logic_grp4_mux_in,
    input   [1:0]   logic_grp4_sel_in,
	input   [5:0]   coincid_UBS_div_in,
	input   [1:0]   logic_burst_sel_in,
    input   [15:0]  hit_ab_sel_in,
	input   [15:0]  hit_mask_in,
	input   [1:0]   busy_ab_sel_in,
	input   [1:0]   busy_mask_in,
	input   [7:0]   acd_csi_hit_tim_diff_in, //default set 4us, e.g. 4us/20ns = 200 = 8'hC8
	input   [3:0]   acd_fee_top_hit_align_in,//default jitter is 40ns, 40ns/20ns = 2 = 4'h2
	input   [3:0]   acd_fee_sec_hit_align_in,
	input   [3:0]   acd_fee_sid_hit_align_in,
	input   [3:0]   csi_hit_align_in,	//default jitter is 200ns, 200ns/20ns = 10 = 4'h0a
	input   [3:0]   cal_fee_1_hit_align_in,
	input   [3:0]   cal_fee_2_hit_align_in,
	input   [3:0]   cal_fee_3_hit_align_in,
	input   [3:0]   cal_fee_4_hit_align_in,
    input   [15:0]  trg_match_win_in,//wait time for trigger windows
	input   [4:0]   logic_grp_oe_in,
    output          coincid_trg_out,
    output          logic_match_out,
    output	[12:0]	hit_syn_out,
	output	[1:0]	busy_syn_out,
    output          hit_start_out,
    output	[15:0]	coincid_MIP1_cnt_out,
    output	[15:0]	coincid_MIP2_cnt_out,
	output	[15:0]	coincid_GM1_cnt_out,
    output	[15:0]	coincid_GM2_cnt_out,
    output	[31:0]	coincid_UBS_cnt_out,
	output 	[15:0]	hit_sig_stus_out,
	output  [4:0]	W_logic_all_grp_result_out
	);
	

    reg             coincid_trg_sig;
    wire    [1:0]	W_busya_N, W_busyb_N;
    wire    [12:0]	W_hita_N, W_hitb_N;
    reg     [1:0]	busy_syn_tmp_r, busy_syn_r;
    reg     [12:0]	hit_syn_tmp_r, hit_syn_r;
    wire	        hit_start_r;

    wire    acd_fee_top_hit_syn, acd_fee_sec_hit_syn, acd_fee_sid_hit_syn, csi_fee_a_hit_syn, csi_fee_b_hit_syn,
			cal_fee_1a_hit_syn, cal_fee_1b_hit_syn, cal_fee_2a_hit_syn, cal_fee_2b_hit_syn, cal_fee_3a_hit_syn, cal_fee_3b_hit_syn, cal_fee_4a_hit_syn, cal_fee_4b_hit_syn;

    assign W_busya_N =  {si_trb_1_busy_a_in_N, si_trb_2_busy_a_in_N};
    assign W_busyb_N =  {si_trb_1_busy_b_in_N, si_trb_2_busy_b_in_N};

    assign W_hita_N =   {acd_fee_top_hit_a_in_N, acd_fee_sec_hit_a_in_N, acd_fee_sid_hit_a_in_N,
                                        csi_fee_hit_a_in_N, csi_fee_hit_b_in_N, 
                                        cal_fee_1_hit_a_in_N, cal_fee_1_hit_b_in_N, cal_fee_2_hit_a_in_N, cal_fee_2_hit_b_in_N, 
                                        cal_fee_3_hit_a_in_N, cal_fee_3_hit_b_in_N, cal_fee_4_hit_a_in_N, cal_fee_4_hit_b_in_N};
    assign W_hitb_N =   {acd_fee_top_hit_b_in_N, acd_fee_sec_hit_b_in_N, acd_fee_sid_hit_b_in_N,
                                        csi_fee_hit_a_in_N, csi_fee_hit_b_in_N, 
                                        cal_fee_1_hit_a_in_N, cal_fee_1_hit_b_in_N, cal_fee_2_hit_a_in_N, cal_fee_2_hit_b_in_N, 
                                        cal_fee_3_hit_a_in_N, cal_fee_3_hit_b_in_N, cal_fee_4_hit_a_in_N, cal_fee_4_hit_b_in_N};

	parameter   DEADTIME_UNIT_10US = 500; //500*20ns = 10us， 500=12'b0001_1111_0100


//synchonize the input of hit signal, if (ab_sel_in == 0) select  signal from channel A, 
always @(posedge clk_in or posedge rst_in)//two stage synchronizer, delay time {1CK, 2CK}, e.g. 20ns to 40ns
begin
	if (rst_in) begin
		busy_syn_tmp_r <= 2'b0;
		busy_syn_r <= 2'b0;
		hit_syn_tmp_r <= 13'b0;
		hit_syn_r <= 13'b0;
	end
	else begin  
			busy_syn_tmp_r <=  (~busy_mask_in) & (((~busy_ab_sel_in) & (~W_busya_N)) | (busy_ab_sel_in & (~W_busyb_N))) ;	//busy_ab_sel_in equal==0:select channel A; busy_ab_sel_in == 1: select hit channel B;					
			hit_syn_tmp_r <=   ((~hit_ab_sel_in[15:3]) & (~W_hita_N)) | (hit_ab_sel_in[15:3] & (~W_hitb_N))  ;	//hit_ab_sel_in equal==0:select channel A; hit_ab_sel_in == 1: select hit channel B; hit_syn_r is actived high																													
			busy_syn_r <= busy_syn_tmp_r;	
			hit_syn_r <= hit_syn_tmp_r;				       
	end
end

//-------------------------------------------------------//
//--            -----For simulation---------		   --//
//--                                                   --//
//-[Logic Optimization Start]-- [Logic Optimization End]-//
//--                                                   --//
//--                                                   --//
//-------------------------------------------------------//
// //ACD's hits are faster than CsI's, so different hit signals should be aligned. Default delay time is around 4us. After delay, ACD's hit will be late than CsI's hit.
// // [Logic Optimization Start]
// wire [7:0]  ACD_TOP_DELAY, ACD_SEC_DELAY, ACD_SID_DELAY;//this step: delay time = (DELAY bit+1)*40ns
// reg  [12:0] shift_reg;
// assign  ACD_TOP_DELAY = acd_csi_hit_tim_diff_in + acd_fee_top_hit_align_in;
// assign  ACD_SEC_DELAY = acd_csi_hit_tim_diff_in + acd_fee_sec_hit_align_in;
// assign  ACD_SID_DELAY = acd_csi_hit_tim_diff_in + acd_fee_sid_hit_align_in;


// // Define a unified write pointer (all channels write synchronously, so only one write pointer is needed)
// reg [7:0] wr_ptr;

// // Define a RAM with a depth of 256 and a width of 13-bit (corresponding to the 13 hit_syn_r signals)
// // The synthesis attribute (* ram_style = "distributed" *) can force the synthesis tool to use LUT RAM instead of flip-flops
// (* ram_style = "distributed" *) reg [12:0] delay_ram [0:255]; 

// // Define independent read pointers for each channel (read pointer = write pointer - respective delay amount)
// wire [7:0] rd_ptr_12 = wr_ptr - ACD_TOP_DELAY;
// wire [7:0] rd_ptr_11 = wr_ptr - ACD_SEC_DELAY;
// wire [7:0] rd_ptr_10 = wr_ptr - ACD_SID_DELAY;
// wire [7:0] rd_ptr_9  = wr_ptr - csi_hit_align_in;
// wire [7:0] rd_ptr_8  = wr_ptr - csi_hit_align_in;
// wire [7:0] rd_ptr_7  = wr_ptr - cal_fee_1_hit_align_in;
// wire [7:0] rd_ptr_6  = wr_ptr - cal_fee_1_hit_align_in;
// wire [7:0] rd_ptr_5  = wr_ptr - cal_fee_2_hit_align_in;
// wire [7:0] rd_ptr_4  = wr_ptr - cal_fee_2_hit_align_in;
// wire [7:0] rd_ptr_3  = wr_ptr - cal_fee_3_hit_align_in;
// wire [7:0] rd_ptr_2  = wr_ptr - cal_fee_3_hit_align_in;
// wire [7:0] rd_ptr_1  = wr_ptr - cal_fee_4_hit_align_in;
// wire [7:0] rd_ptr_0  = wr_ptr - cal_fee_4_hit_align_in;

// always @(posedge clk_in or posedge rst_in) begin
//     if (rst_in) begin
//         wr_ptr <= 8'b0;
//         shift_reg <= 13'b0;
//         // Note: RAM-based designs typically do not require initializing every bit inside the RAM
//         // because the read data will be valid once the write pointer starts running.
//     end 
//     else begin
//         // 1. Synchronous write: Combine the 13 bits and write them together into the RAM address pointed to by the current wr_ptr
//         delay_ram[wr_ptr] <= hit_syn_r;
        
//         // 2. Asynchronous read / Synchronous output: Fetch historical data from RAM based on respective delays and latch it into shift_reg
//         shift_reg[12] <= delay_ram[rd_ptr_12][12];
//         shift_reg[11] <= delay_ram[rd_ptr_11][11];
//         shift_reg[10] <= delay_ram[rd_ptr_10][10];
//         shift_reg[9]  <= delay_ram[rd_ptr_9][9];
//         shift_reg[8]  <= delay_ram[rd_ptr_8][8];
//         shift_reg[7]  <= delay_ram[rd_ptr_7][7];
//         shift_reg[6]  <= delay_ram[rd_ptr_6][6];
//         shift_reg[5]  <= delay_ram[rd_ptr_5][5];
//         shift_reg[4]  <= delay_ram[rd_ptr_4][4];
//         shift_reg[3]  <= delay_ram[rd_ptr_3][3];
//         shift_reg[2]  <= delay_ram[rd_ptr_2][2];
//         shift_reg[1]  <= delay_ram[rd_ptr_1][1];
//         shift_reg[0]  <= delay_ram[rd_ptr_0][0];
        
//         // 3. Update write pointer
//         wr_ptr <= wr_ptr + 1'b1;
//     end
// end
// =========================================================================
// [Logic Optimization End]
// These lines of code completely replace the original 13 always blocks and the 13 massive register arrays.
// ==

//-------------------------------------------------------//
//--            -----Final code---------		       --//
//--                                                   --//
//-[IP Core Optimization Start]-to [IP Core Optimization End]-//
//--                                                   --//
//--                                                   --//
//-------------------------------------------------------//

//ACD's hits are faster than CsI's, so different hit signals should be aligned. Default delay time is around 4us.
    wire [7:0]  ACD_TOP_DELAY, ACD_SEC_DELAY, ACD_SID_DELAY;
    reg  [12:0] shift_reg;
    assign  ACD_TOP_DELAY = acd_csi_hit_tim_diff_in + acd_fee_top_hit_align_in;
    assign  ACD_SEC_DELAY = acd_csi_hit_tim_diff_in + acd_fee_sec_hit_align_in;
    assign  ACD_SID_DELAY = acd_csi_hit_tim_diff_in + acd_fee_sid_hit_align_in;

    // =========================================================================
    // [优化核心: 基于 ISE Distributed Memory IP 的延时通道替换]
    // =========================================================================

    // 1. 统一的写指针 (由于 13 个信号是同一个时钟沿到达，共用一个写指针即可保证绝对同步)
    reg [7:0] wr_ptr;

    // 2. 各通道独立的读指针计算 (利用 8-bit wire 的自动溢出回卷特性，等效于 % 256)
    // 读地址 = 当前写地址 - 该通道需要的延迟节拍数
    wire [7:0] rd_ptr_12 = wr_ptr - ACD_TOP_DELAY;
    wire [7:0] rd_ptr_11 = wr_ptr - ACD_SEC_DELAY;
    wire [7:0] rd_ptr_10 = wr_ptr - ACD_SID_DELAY;
    wire [7:0] rd_ptr_9  = wr_ptr - csi_hit_align_in;
    wire [7:0] rd_ptr_8  = wr_ptr - csi_hit_align_in;
    wire [7:0] rd_ptr_7  = wr_ptr - cal_fee_1_hit_align_in;
    wire [7:0] rd_ptr_6  = wr_ptr - cal_fee_1_hit_align_in;
    wire [7:0] rd_ptr_5  = wr_ptr - cal_fee_2_hit_align_in;
    wire [7:0] rd_ptr_4  = wr_ptr - cal_fee_2_hit_align_in;
    wire [7:0] rd_ptr_3  = wr_ptr - cal_fee_3_hit_align_in;
    wire [7:0] rd_ptr_2  = wr_ptr - cal_fee_3_hit_align_in;
    wire [7:0] rd_ptr_1  = wr_ptr - cal_fee_4_hit_align_in;
    wire [7:0] rd_ptr_0  = wr_ptr - cal_fee_4_hit_align_in;

    // 3. 用于接收 Distributed Memory IP 核异步/同步读出的数据连线
    wire [12:0] ram_data_out;

    // 4. 写指针更新逻辑 (完全保留原有的递增逻辑逻辑)
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            wr_ptr <= 8'b0;
        end 
        else begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // =========================================================================
    // 5. 例化 13 个 深度为256、位宽为1 的双端口 Distributed Memory
    // 端口说明: 
    // clk  : 时钟
    // we   : 写使能 (1'b1，每个周期都把当前 hit 状态写进去)
    // a    : 写地址 (统一使用 wr_ptr)
    // d    : 写入数据 (对应的 hit_syn_r bit)
    // dpra : 读地址 (即 Dual Port Read Address，各自独立偏移)
	// spo  : 读出数据 (Single Port Output, 不使用)
    // dpo  : 读出数据 (Dual Port Output)
    // =========================================================================
    
    dist_ram_256x1 ram_inst_12 ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[12]), .dpra(rd_ptr_12), .spo(), .dpo(ram_data_out[12]) );
    dist_ram_256x1 ram_inst_11 ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[11]), .dpra(rd_ptr_11), .spo(), .dpo(ram_data_out[11]) );
    dist_ram_256x1 ram_inst_10 ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[10]), .dpra(rd_ptr_10), .spo(), .dpo(ram_data_out[10]) );
    dist_ram_256x1 ram_inst_9  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[9]),  .dpra(rd_ptr_9),  .spo(), .dpo(ram_data_out[9])  );
    dist_ram_256x1 ram_inst_8  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[8]),  .dpra(rd_ptr_8),  .spo(), .dpo(ram_data_out[8])  );
    dist_ram_256x1 ram_inst_7  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[7]),  .dpra(rd_ptr_7),  .spo(), .dpo(ram_data_out[7])  );
    dist_ram_256x1 ram_inst_6  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[6]),  .dpra(rd_ptr_6),  .spo(), .dpo(ram_data_out[6])  );
    dist_ram_256x1 ram_inst_5  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[5]),  .dpra(rd_ptr_5),  .spo(), .dpo(ram_data_out[5])  );
    dist_ram_256x1 ram_inst_4  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[4]),  .dpra(rd_ptr_4),  .spo(), .dpo(ram_data_out[4])  );
    dist_ram_256x1 ram_inst_3  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[3]),  .dpra(rd_ptr_3),  .spo(), .dpo(ram_data_out[3])  );
    dist_ram_256x1 ram_inst_2  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[2]),  .dpra(rd_ptr_2),  .spo(), .dpo(ram_data_out[2])  );
    dist_ram_256x1 ram_inst_1  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[1]),  .dpra(rd_ptr_1),  .spo(), .dpo(ram_data_out[1])  );
    dist_ram_256x1 ram_inst_0  ( .clk(clk_in), .we(1'b1), .a(wr_ptr), .d(hit_syn_r[0]),  .dpra(rd_ptr_0),  .spo(), .dpo(ram_data_out[0])  );

    // =========================================================================
    // 6. 输出打拍对齐 (保持原有时序逻辑)
    // 从 IP 核中读出的数据，在时钟沿打入 shift_reg，与你原代码的行为 100% 对齐。
    // =========================================================================
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            shift_reg <= 13'b0;
        end 
        else begin
            shift_reg <= ram_data_out;
        end
    end
// [Logic Optimization End]



	assign acd_fee_top_hit_syn = shift_reg[12];
	assign acd_fee_sec_hit_syn = shift_reg[11];
	assign acd_fee_sid_hit_syn = shift_reg[10];
	assign csi_fee_a_hit_syn = shift_reg[9];
	assign csi_fee_b_hit_syn = shift_reg[8];
	assign cal_fee_1a_hit_syn = shift_reg[7];
	assign cal_fee_1b_hit_syn = shift_reg[6];
	assign cal_fee_2a_hit_syn = shift_reg[5];
	assign cal_fee_2b_hit_syn = shift_reg[4];
	assign cal_fee_3a_hit_syn = shift_reg[3];
	assign cal_fee_3b_hit_syn = shift_reg[2];
	assign cal_fee_4a_hit_syn = shift_reg[1];
	assign cal_fee_4b_hit_syn = shift_reg[0];


//hit signal for start the coincidence process, set first hit signal from ECAL as the start signal
	assign	hit_start_r = (	  cal_fee_1a_hit_syn | cal_fee_1b_hit_syn | cal_fee_2a_hit_syn | cal_fee_2b_hit_syn
							| cal_fee_3a_hit_syn | cal_fee_3b_hit_syn | cal_fee_4a_hit_syn | cal_fee_4b_hit_syn);
	assign	hit_start_out = hit_start_r;/////////select the hit signal(T0) to start coincidence process

reg [7:0] 	trg_seed_win_cnt;
reg [2:0] 	trg_seed_state;
reg [12:0]	trg_seed_reg;
wire		acd_fee_top_hit_syn_seed,	
			acd_fee_sec_hit_syn_seed,
			acd_fee_sid_hit_syn_seed,
			csi_fee_hit_a_syn_seed,	csi_fee_hit_b_syn_seed,
			cal_fee_1a_hit_syn_seed, cal_fee_1b_hit_syn_seed,
			cal_fee_2a_hit_syn_seed, cal_fee_2b_hit_syn_seed,
			cal_fee_3a_hit_syn_seed, cal_fee_3b_hit_syn_seed,
			cal_fee_4a_hit_syn_seed, cal_fee_4b_hit_syn_seed;

//The windows for trigger seed, set CAL_HIT as trigger T0 reference.
//state:1: wait for hit_start_r; state:2: in seed window, collect all hit info; state:3: in trigger logic window, do nothing
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		trg_seed_state <= 3'b000;
		trg_seed_reg<= 13'b0;
	end
	else begin
		if	(trg_seed_state == 3'b000) begin
			trg_seed_win_cnt <= 8'b0;
			trg_seed_reg <= 13'b0;
			if (hit_start_r ) begin
				trg_seed_state <= 3'b001;
			end
		end
		else if (trg_seed_state == 3'b001) begin
			trg_seed_win_cnt <= trg_seed_win_cnt+ 1'b1;
			if(acd_fee_top_hit_syn)					//[TODO]: simulate when more than 2 syn signals are coming in same time!!!
				trg_seed_reg[12] <= 1'b1;
			if(acd_fee_sec_hit_syn)
				trg_seed_reg[11] <= 1'b1;
			if(acd_fee_sid_hit_syn)
				trg_seed_reg[10] <= 1'b1;
			if(csi_fee_a_hit_syn)
				trg_seed_reg[9] <= 1'b1;
			if(csi_fee_b_hit_syn)
				trg_seed_reg[8] <= 1'b1;
			if(cal_fee_1a_hit_syn)
				trg_seed_reg[7] <= 1'b1;
			if(cal_fee_1b_hit_syn)
				trg_seed_reg[6] <= 1'b1;
			if(cal_fee_2a_hit_syn)
				trg_seed_reg[5] <= 1'b1;
			if(cal_fee_2b_hit_syn)
				trg_seed_reg[4] <= 1'b1;
			if(cal_fee_3a_hit_syn)
				trg_seed_reg[3] <= 1'b1;
			if(cal_fee_3b_hit_syn)
				trg_seed_reg[2] <= 1'b1;
			if(cal_fee_4a_hit_syn)
				trg_seed_reg[1] <= 1'b1;
			if(cal_fee_4b_hit_syn)
				trg_seed_reg[0] <= 1'b1;
			if (trg_seed_win_cnt == trg_match_win_in[15:8]) begin   //HIGH END of trg_match_win_in[15:8]: find seed window MAX is 256*20ns=5.12us, typical 1500ns(8'd75)
				trg_seed_state <= 3'b010;
				trg_seed_win_cnt <= 8'b0;
			end
		end
		else if (trg_seed_state ==3'b010) begin
			trg_seed_win_cnt <= trg_seed_win_cnt+ 1'b1;
			if (trg_seed_win_cnt == trg_match_win_in[7:0]) begin   //LOW END of trg_match_win_in[7:0]: check trigger logic window MAX is 256*20ns=5.12us, typical 200ns(8'd10)
				trg_seed_state <= 3'b000;
				trg_seed_win_cnt <= 8'b0;
				trg_seed_reg <= 8'b0;
			end
		end
	end	
end


assign acd_fee_top_hit_syn_seed = trg_seed_reg[12];
assign acd_fee_sec_hit_syn_seed = trg_seed_reg[11];
assign acd_fee_sid_hit_syn_seed = trg_seed_reg[10];
assign csi_fee_hit_a_syn_seed = trg_seed_reg[9];
assign csi_fee_hit_b_syn_seed = trg_seed_reg[8];
assign cal_fee_1a_hit_syn_seed = trg_seed_reg[7];
assign cal_fee_1b_hit_syn_seed = trg_seed_reg[6];
assign cal_fee_2a_hit_syn_seed = trg_seed_reg[5];
assign cal_fee_2b_hit_syn_seed = trg_seed_reg[4];
assign cal_fee_3a_hit_syn_seed = trg_seed_reg[3];
assign cal_fee_3b_hit_syn_seed = trg_seed_reg[2];
assign cal_fee_4a_hit_syn_seed = trg_seed_reg[1];
assign cal_fee_4b_hit_syn_seed = trg_seed_reg[0];


//Five coincidence logic group.Logic group0~logic group4 means MIPS1, MIPS2, GM1, GM2, UBS respectively.
//Each logic group has two fee hit selection from 8 fee hit sources.
reg	logic_grp0_result_r, logic_grp1_result_r, logic_grp2_result_r, logic_grp3_result_r, logic_grp4_result_r;

//temporary registers for logic group cal fee hit selection
reg logic_grp0_fee_tmp1, logic_grp0_fee_tmp2;
reg logic_grp1_fee_tmp1, logic_grp1_fee_tmp2;
reg logic_grp2_fee_tmp1, logic_grp2_fee_tmp2;
reg logic_grp3_fee_tmp1, logic_grp3_fee_tmp2;
reg logic_grp4_fee_tmp1, logic_grp4_fee_tmp2;

//coincidence logic group0(MIPS1), fee hit selection
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp0_fee_tmp1 <= 1'b0;
		logic_grp0_fee_tmp2 <= 1'b0;
	end
	else begin
		case (logic_grp0_mux_in[3:0])////* synthesis parallel_case */
		4'b0000:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp0_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0001:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp0_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0010:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp0_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0011:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp0_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b0100:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp0_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0101:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp0_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0110:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp0_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0111:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp0_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1000:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp0_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1001:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp0_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b1010:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp0_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1011:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp0_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1100:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp0_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1101:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp0_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b1110:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp0_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1111:
			begin
				logic_grp0_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp0_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		default:
			begin
				logic_grp0_fee_tmp1 <= 1'b0;
				logic_grp0_fee_tmp2 <= 1'b0;
			end
		endcase
	end
end

//coincidence logic group1, fee hit selection
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp1_fee_tmp1 <= 1'b0;
		logic_grp1_fee_tmp2 <= 1'b0;
	end
	else
	begin
		case (logic_grp1_mux_in[3:0])////* synthesis parallel_case */
		4'b0000:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1a_hit_syn_seed | (hit_mask_in[7]);
				logic_grp1_fee_tmp2 <= cal_fee_3a_hit_syn_seed | (hit_mask_in[3]);
			end
		4'b0001:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1a_hit_syn_seed | (hit_mask_in[7]);
				logic_grp1_fee_tmp2 <= cal_fee_3b_hit_syn_seed | (hit_mask_in[2]);
			end
		4'b0010:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1a_hit_syn_seed | (hit_mask_in[7]);
				logic_grp1_fee_tmp2 <= cal_fee_4a_hit_syn_seed | (hit_mask_in[1]);
			end
		4'b0011:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1a_hit_syn_seed | (hit_mask_in[7]);
				logic_grp1_fee_tmp2 <= cal_fee_4b_hit_syn_seed | (hit_mask_in[0]);
			end
		4'b0100:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1b_hit_syn_seed | (hit_mask_in[6]);
				logic_grp1_fee_tmp2 <= cal_fee_3a_hit_syn_seed | (hit_mask_in[3]);
			end
		4'b0101:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1b_hit_syn_seed | (hit_mask_in[6]);
				logic_grp1_fee_tmp2 <= cal_fee_3b_hit_syn_seed | (hit_mask_in[2]);
			end
		4'b0110:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1b_hit_syn_seed | (hit_mask_in[6]);
				logic_grp1_fee_tmp2 <= cal_fee_4a_hit_syn_seed | (hit_mask_in[1]);
			end
		4'b0111:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_1b_hit_syn_seed | (hit_mask_in[6]);
				logic_grp1_fee_tmp2 <= cal_fee_4b_hit_syn_seed | (hit_mask_in[0]);
			end
		4'b1000:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2a_hit_syn_seed | (hit_mask_in[5]);
				logic_grp1_fee_tmp2 <= cal_fee_3a_hit_syn_seed | (hit_mask_in[3]);
			end	
		4'b1001:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2a_hit_syn_seed | (hit_mask_in[5]);
				logic_grp1_fee_tmp2 <= cal_fee_3b_hit_syn_seed | (hit_mask_in[2]);
			end	
		4'b1010:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2a_hit_syn_seed | (hit_mask_in[5]);
				logic_grp1_fee_tmp2 <= cal_fee_4a_hit_syn_seed | (hit_mask_in[1]);
			end
		4'b1011:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2a_hit_syn_seed | (hit_mask_in[5]);
				logic_grp1_fee_tmp2 <= cal_fee_4b_hit_syn_seed | (hit_mask_in[0]);
			end
		4'b1100:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2b_hit_syn_seed | (hit_mask_in[4]);
				logic_grp1_fee_tmp2 <= cal_fee_3a_hit_syn_seed | (hit_mask_in[3]);
			end
		4'b1101:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2b_hit_syn_seed | (hit_mask_in[4]);
				logic_grp1_fee_tmp2 <= cal_fee_3b_hit_syn_seed | (hit_mask_in[2]);
			end
		4'b1110:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2b_hit_syn_seed | (hit_mask_in[4]);
				logic_grp1_fee_tmp2 <= cal_fee_4a_hit_syn_seed | (hit_mask_in[1]);
			end
		4'b1111:
			begin
				logic_grp1_fee_tmp1 <= cal_fee_2b_hit_syn_seed | (hit_mask_in[4]);
				logic_grp1_fee_tmp2 <= cal_fee_4b_hit_syn_seed | (hit_mask_in[0]);
			end	
		default:
			begin
				logic_grp1_fee_tmp1 <= 1'b0;
				logic_grp1_fee_tmp2 <= 1'b0;
			end
		endcase
	end
end

//coincidence logic group2, fee hit selection
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp2_fee_tmp1 <= 1'b0;
		logic_grp2_fee_tmp2 <= 1'b0;
	end
	else
	begin
		case (logic_grp2_mux_in[3:0])////* synthesis parallel_case */
		4'b0000:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp2_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0001:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp2_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0010:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp2_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0011:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp2_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b0100:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp2_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0101:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp2_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0110:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp2_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0111:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp2_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1000:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp2_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1001:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp2_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end	
		4'b1010:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp2_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1011:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp2_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1100:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp2_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1101:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp2_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b1110:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp2_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1111:
			begin
				logic_grp2_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp2_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end	
		default:
			begin
				logic_grp2_fee_tmp1 <= 1'b0;
				logic_grp2_fee_tmp2 <= 1'b0;
			end
		endcase
	end
end

////coincidence logic group3, fee hit selection
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp3_fee_tmp1 <= 1'b0;
		logic_grp3_fee_tmp2 <= 1'b0;
	end
	else
	begin
		case (logic_grp3_mux_in[3:0])////* synthesis parallel_case */
		4'b0000:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp3_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0001:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp3_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0010:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp3_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0011:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp3_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b0100:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp3_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0101:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp3_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0110:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp3_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0111:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp3_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1000:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp3_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1001:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp3_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end	
		4'b1010:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp3_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1011:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp3_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1100:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp3_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1101:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp3_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b1110:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp3_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1111:
			begin
				logic_grp3_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp3_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end	
		default:
			begin
				logic_grp3_fee_tmp1 <= 1'b0;
				logic_grp3_fee_tmp2 <= 1'b0;
			end
		endcase
	end
end

////coincidence logic group4, fee hit selection
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp4_fee_tmp1 <= 1'b0;
		logic_grp4_fee_tmp2 <= 1'b0;
	end
	else
	begin
		case (logic_grp4_mux_in[3:0])////* synthesis parallel_case */
		4'b0000:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp4_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0001:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp4_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0010:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp4_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0011:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1a_hit_syn_seed & (~hit_mask_in[7]);
				logic_grp4_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b0100:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp4_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b0101:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp4_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b0110:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp4_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b0111:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_1b_hit_syn_seed & (~hit_mask_in[6]);
				logic_grp4_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1000:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp4_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1001:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp4_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end	
		4'b1010:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp4_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1011:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2a_hit_syn_seed & (~hit_mask_in[5]);
				logic_grp4_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end
		4'b1100:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp4_fee_tmp2 <= cal_fee_3a_hit_syn_seed & (~hit_mask_in[3]);
			end
		4'b1101:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp4_fee_tmp2 <= cal_fee_3b_hit_syn_seed & (~hit_mask_in[2]);
			end
		4'b1110:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp4_fee_tmp2 <= cal_fee_4a_hit_syn_seed & (~hit_mask_in[1]);
			end
		4'b1111:
			begin
				logic_grp4_fee_tmp1 <= cal_fee_2b_hit_syn_seed & (~hit_mask_in[4]);
				logic_grp4_fee_tmp2 <= cal_fee_4b_hit_syn_seed & (~hit_mask_in[0]);
			end	
		default:
			begin
				logic_grp4_fee_tmp1 <= 1'b0;
				logic_grp4_fee_tmp2 <= 1'b0;
			end
		endcase
	end
end



//coincidence logic group0, for MIPs trigger type1
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp0_result_r <= 1'b0;
	end
	else begin
		case (logic_grp0_sel_in)////* synthesis parallel_case */
		2'b00:
			logic_grp0_result_r <= ((logic_grp0_mux_in[7]&acd_fee_top_hit_syn_seed)|(logic_grp0_mux_in[5]&acd_fee_sid_hit_syn_seed)) 
									&((~logic_grp0_mux_in[6]) | acd_fee_sec_hit_syn_seed) 
									& ((logic_grp0_mux_in[4]==1'b0)? (csi_fee_hit_a_syn_seed | (hit_mask_in[9])): (csi_fee_hit_b_syn_seed | (hit_mask_in[8])))
									& ( logic_grp0_fee_tmp1 | logic_grp0_fee_tmp2); //Default logic for MIPs1 trigger
		2'b01:
			logic_grp0_result_r <= (acd_fee_top_hit_syn_seed|acd_fee_sid_hit_syn_seed) &acd_fee_sec_hit_syn_seed & csi_fee_hit_a_syn_seed & (  cal_fee_2a_hit_syn_seed | cal_fee_4a_hit_syn_seed); //Specific logic for MIPs1 trigger
		2'b10:
			logic_grp0_result_r <= acd_fee_top_hit_syn_seed;
		//2'b11:
            
		default:
			logic_grp0_result_r <= 1'b0;		
		endcase
	end	
end

//coincidence logic group1, for MIPs trigger type2
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp1_result_r <= 1'b0;
	end
	else begin
		case (logic_grp1_sel_in)////* synthesis parallel_case */
		2'b00:
			logic_grp1_result_r <=  logic_grp1_fee_tmp1 & logic_grp1_fee_tmp2;//Default logic for MIPs2 trigger
		2'b01:
			logic_grp1_result_r <=  cal_fee_2b_hit_syn_seed & cal_fee_4b_hit_syn_seed;//Specific logic for MIPs2 trigger
		//2'b10:
			
		//2'b11:
			
		default:
			logic_grp1_result_r <= 1'b0;		
		endcase
	end	
end

//coincidence logic group2, for Gamma trigger type1
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp2_result_r <= 1'b0;
	end
	else begin
		case (logic_grp2_sel_in)////* synthesis parallel_case */
		2'b00:
			logic_grp2_result_r <=  ((~(((logic_grp2_mux_in[7]&acd_fee_top_hit_syn_seed)|(logic_grp2_mux_in[5]&acd_fee_sid_hit_syn_seed))))
										&(~(logic_grp2_mux_in[6]&acd_fee_sec_hit_syn_seed)))
										&((logic_grp2_mux_in[4]==1'b0)?  (csi_fee_hit_a_syn_seed | (hit_mask_in[9])): (csi_fee_hit_b_syn_seed | (hit_mask_in[8])))
										& (  logic_grp2_fee_tmp1 | logic_grp2_fee_tmp2) ;//Default logic for GM1 trigger
		2'b01:
			logic_grp2_result_r <=  ((~((acd_fee_top_hit_syn_seed|acd_fee_sid_hit_syn_seed)))&(~acd_fee_sec_hit_syn_seed))& csi_fee_hit_a_syn_seed & (cal_fee_1a_hit_syn_seed | cal_fee_3a_hit_syn_seed) ;//Specific logic for GM1 trigger
		//2'b10:
		    
		//2'b11:
			
		default:
			logic_grp2_result_r <= 1'b0;		
		endcase
	end	
end

//coincidence logic group3, for Gamma trigger type2
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp3_result_r <= 1'b0;
	end
	else begin
		case (logic_grp3_sel_in)////* synthesis parallel_case */
		2'b00:
			logic_grp3_result_r <=  ((~(((logic_grp3_mux_in[7]&acd_fee_top_hit_syn_seed)|(logic_grp3_mux_in[5]&acd_fee_sid_hit_syn_seed))))
										|(~((~logic_grp3_mux_in[6]) | acd_fee_sec_hit_syn_seed)))
										&((logic_grp3_mux_in[4]==1'b0)?  (csi_fee_hit_a_syn_seed | (hit_mask_in[9])): (csi_fee_hit_b_syn_seed | (hit_mask_in[8])))
										& (  logic_grp3_fee_tmp1 | logic_grp3_fee_tmp2) ;//Default logic for GM2 trigger
		2'b01:
			logic_grp3_result_r <=  ((~((acd_fee_top_hit_syn_seed|acd_fee_sid_hit_syn_seed)))|(~acd_fee_sec_hit_syn_seed))& csi_fee_hit_a_syn_seed & (cal_fee_1a_hit_syn_seed | cal_fee_3a_hit_syn_seed) ;//Specific logic for GM2 trigger
		//2'b10:
			
		//2'b11:
			
		default:
			logic_grp3_result_r <= 1'b0;		
		endcase
	end	
end

//coincidence logic group4, for unbias trigger.
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		logic_grp4_result_r <= 1'b0;
	end
	else begin
		case (logic_grp4_sel_in)////* synthesis parallel_case */
		2'b00:
            logic_grp4_result_r <=  logic_grp4_fee_tmp1 | logic_grp4_fee_tmp2 ;//Default logic for UBS trigger
		2'b01:
			logic_grp4_result_r <=  cal_fee_1b_hit_syn_seed | cal_fee_3b_hit_syn_seed ;//Specific logic for UBS trigger
		//2'b10:
			
		//2'b11:
			
		default:
			logic_grp4_result_r <= 1'b0;		
		endcase
	end	
end


//
reg	[31:0]	coincid_UBS_cnt;
reg	[15:0]	 coincid_GM1_cnt, coincid_GM2_cnt, coincid_MIP1_cnt, coincid_MIP2_cnt;//////counter for the different coincide trigger source
reg	coincid_UBS_engine_enb_r, coincid_MIP1_engine_enb_r, coincid_MIP2_engine_enb_r; ////trigger logic enable after prescale (divider)
wire[4:0] W_coincid_engine_enb, W_logic_all_grp_result;
reg	[4:0] coincid_result_r, coincid_tag_raw_r;// result of coincidence
reg	coincid_trg_raw_r, coincid_tag_raw_enb_r;///coincide trigger signal before logic masked(enable)


////coincide trigger  counter
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		coincid_MIP1_cnt <= 16'b0;
        coincid_MIP2_cnt <= 16'b0;
		coincid_GM1_cnt <= 16'b0;
		coincid_GM2_cnt <= 16'b0;
		coincid_UBS_cnt <= 32'b0;
	end
	else if (coincid_tag_raw_enb_r) begin
		coincid_MIP1_cnt <= coincid_result_r[0]? (coincid_MIP1_cnt + 1) : coincid_MIP1_cnt ;
		coincid_MIP2_cnt <= coincid_result_r[1]? (coincid_MIP2_cnt + 1) : coincid_MIP2_cnt;
		coincid_GM1_cnt <= coincid_result_r[2]? (coincid_GM1_cnt + 1): coincid_GM1_cnt;
		coincid_GM2_cnt <= coincid_result_r[3]? (coincid_GM2_cnt + 1): coincid_GM2_cnt;
		coincid_UBS_cnt <= coincid_result_r[4]? (coincid_UBS_cnt + 1): coincid_UBS_cnt;
	end
end



////pre-scaler (divider) for the the trigger: mip1, mip2, unbias trigger.	
always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in) begin
		coincid_MIP1_engine_enb_r <= 1'b1;
		coincid_MIP2_engine_enb_r <= 1'b1;
		coincid_UBS_engine_enb_r <= 1'b1;
	end
	else begin
		////divider for MIP1 trigger, 1，2，4，8，16，32，64，128；
		case (coincid_MIP1_div_in) ////* synthesis parallel_case */
			6'b00_0000:  //no pre-scale
				coincid_MIP1_engine_enb_r <= 1'b1;			
			6'b00_0001: //2
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[0] == 1'b0);			
			6'b00_0010: //4
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[1:0] == 2'b00);			
			6'b00_0011: //8
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[2:0] == 3'b000);
			6'b00_0100: //16 
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[3:0] == 4'b0000);	
			6'b00_0101:  //32
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[4:0] == 5'b0_0000);		
			6'b00_0110:  //64
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[5:0] == 6'b00_0000);			
			6'b00_0111: //128
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[6:0] == 7'b000_0000);				
			default: begin//1
				coincid_MIP1_engine_enb_r <= 1'b1;
			end
		endcase
		////divider for MIP2 trigger,  1，2，4，8，16，32，64，128；
		case (coincid_MIP2_div_in) ////* synthesis parallel_case */
			6'b00_0000:  //no pre-scale
				coincid_MIP2_engine_enb_r <= 1'b1;			
			6'b00_0001: ////2
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[0] == 1'b0);			
			6'b00_0010: //4
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[1:0] == 2'b00);			
			6'b00_0011: //8
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[2:0] == 3'b000);
			6'b00_0100: //16 
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[3:0] == 4'b0000);	
			6'b00_0101:  //32
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[4:0] == 5'b0_0000);		
			6'b00_0110:  //64
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[5:0] == 6'b00_0000);			
			6'b00_0111: //128
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[6:0] == 7'b000_0000);			
			default: begin//1
				coincid_MIP2_engine_enb_r <= 1'b1;
			end
		endcase
		///divider for unbias trigger, 1，16，32，64，128，256，512，1024
		case (coincid_UBS_div_in) ////* synthesis parallel_case */
			6'b00_0000: //no divider
				coincid_UBS_engine_enb_r <= 1'b1;
			6'b00_0001://16
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[3:0] == 4'b0000);
			6'b00_0010://32
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[4:0] == 5'b0_0000);
			6'b00_0011://64
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[5:0] == 6'b00_0000);
			6'b00_0100://128
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[6:0] == 7'b000_0000);
			6'b00_0101://256
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[7:0] == 8'b0000_0000);
			6'b00_0110://512
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[8:0] == 9'b0_0000_0000);
			6'b00_0111://1024
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[9:0] == 10'b00_0000_0000);
			default://32
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[4:0] == 5'b0_0000);
		endcase
		end
end

///////
assign	W_coincid_engine_enb = {coincid_UBS_engine_enb_r, 1'b1, 1'b1, coincid_MIP2_engine_enb_r,
									 coincid_MIP1_engine_enb_r};//wire of all triggers after prescale
assign	W_logic_all_grp_result = {logic_grp4_result_r, logic_grp3_result_r, 
									logic_grp2_result_r, logic_grp1_result_r, logic_grp0_result_r};//wire of all triggers before prescale
assign	logic_match_out = |(W_logic_all_grp_result & logic_grp_oe_in);///the signal after trigger logic operation (no T0), for debug and test


///Main coincidence state machine
//two stage: 1, detect the selected signal which is for starting the coincidence process
//////////////2, wait for the time (trg_match_wait_time_in), make sure other hit signal is valid and filter the noise (0-400ns)
/////////////3, coincidence (400ns -TRG_MATCH_WIN)
//////////in flight logic, add one clock delay for the trigger signal
reg[2:0] c_state, n_state;
reg[7:0] trg_win_cnt;/////trigger match windows counter

parameter   IDLE = 0, 
            COINCIDENCE_STAGE = 1, 
            COINCIDENCE_RESULT = 2, 
            COINCIDENCE_TRIGGER_GEN = 3, 
			COINCIDENCE_END = 4;

always @(posedge clk_in or posedge rst_in)
begin
	if (rst_in)
		c_state <= IDLE;
	else 
		c_state <= n_state;	
end

always @(*)
begin
	n_state = IDLE; //default value
	case(c_state)
		IDLE: begin
			if (hit_start_r == 1'b1)   ///detect the hit_start signal 
				n_state = COINCIDENCE_STAGE;
			else 
				n_state = IDLE;			
		end
		COINCIDENCE_STAGE: begin
			if (trg_win_cnt >= trg_match_win_in[15:8])//coincidence windows 
				n_state = COINCIDENCE_RESULT;
			else
				n_state = COINCIDENCE_STAGE;			
		end

		 COINCIDENCE_RESULT: begin
		 	n_state = COINCIDENCE_TRIGGER_GEN;
		end

		 COINCIDENCE_TRIGGER_GEN: begin  //////generate the coincidence trigger signal
             n_state = COINCIDENCE_END;
		 end

		COINCIDENCE_END: begin
			if (hit_start_r == 1'b0)//wait for the hit start signal to invalid, to make sure the timing of the next trigger
				n_state = IDLE;
			else 
				n_state = COINCIDENCE_END;			
		end
		default: begin
			n_state = IDLE;			
		end
	endcase	
end


//coincidence process
always @(posedge clk_in or posedge rst_in)
begin
	   if (rst_in) begin
        coincid_trg_sig <= 1'b0;////the final result of the coincid trg
        coincid_trg_raw_r <= 1'b0;/////the coincide trigger before oe (mask)
        coincid_result_r <= 5'b0;////////the final result of the coincide 
        trg_win_cnt <= 8'b0;////counter of the match windows
        coincid_tag_raw_enb_r <= 1'b0;  //latch the coincid tag
    end
    else begin
        case(c_state) 
         IDLE: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 8'b0;
            coincid_tag_raw_enb_r <= 1'b0; 
         end
         COINCIDENCE_STAGE: begin
			coincid_trg_sig <= 1'b0;
			coincid_trg_raw_r <= 1'b0;
            trg_win_cnt <= trg_win_cnt + 1;            
            if (trg_win_cnt == {trg_match_win_in[15:8]}) //wait for other hit
			begin
            	coincid_result_r <= W_logic_all_grp_result;
				coincid_tag_raw_enb_r <= 1'b1;
			end
         end
		COINCIDENCE_RESULT: begin //
			coincid_tag_raw_enb_r <= 1'b0;
         end
         COINCIDENCE_TRIGGER_GEN: begin //generate the trigger signal, the delay between the output trigger and the start_hit must be fixed
			coincid_tag_raw_enb_r <= 1'b0;//
         	coincid_trg_sig <= |( (W_coincid_engine_enb & logic_grp_oe_in) & coincid_result_r);//coincide trigger after trigger selection
         	coincid_trg_raw_r <= |(W_coincid_engine_enb & coincid_result_r);//coincide trigger before trigger selection
         end
         COINCIDENCE_END: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 6'b0;
         end
         default: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 6'b0;
            coincid_tag_raw_enb_r <= 1'b0; 
         end
        endcase
    end
	
end


assign	coincid_trg_out=	coincid_trg_sig;
assign	coincid_MIP1_cnt_out = coincid_MIP1_cnt;
assign	coincid_MIP2_cnt_out = coincid_MIP2_cnt;
assign	coincid_GM1_cnt_out = coincid_GM1_cnt;
assign	coincid_GM2_cnt_out = coincid_GM2_cnt;
assign	coincid_UBS_cnt_out = coincid_UBS_cnt;
assign	hit_syn_out = hit_syn_r;
assign  busy_syn_out = busy_syn_r;
assign	hit_sig_stus_out = {3'b000, trg_seed_reg};//orig:shift_reg -- after trg_match_win_in[15:8], coincid_trg_sig = 1, so we use trg_seed_reg to transmit
assign	W_logic_all_grp_result_out = W_logic_all_grp_result;


endmodule