/*----------------------------------------------------------*/
/* 															*/
/*	file name:	Coincidence.v	--	--	           			*/
/* 	date:		2025/02/27									*/
/* 	modified:	2025/05/20									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz						*/
/* 															*/
/*----------------------------------------------------------*/
module Coincidence(
	input			clk_in,
	input			rst_in,

    //--------------all hits input and busy input
    input           si_trb_1_busy_a_in_N,
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

    //--------------control register input    
    input   [1:0]   logic_grp0_sel_in,
	input   [5:0]   coincid_MIP1_div_in,
    input   [1:0]   logic_grp1_sel_in,
	input   [5:0]   coincid_MIP2_div_in,
    input   [1:0]   logic_grp2_sel_in,
    input   [1:0]   logic_grp3_sel_in,
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
    input   [15:0]   trg_match_win_in,//wait time for trigger windows
	input   [4:0]   logic_grp_oe_in,

    output          coincid_trg_out,
    output          logic_match_out,
    output	[7:0]	hit_syn_out,
	output	[1:0]	busy_syn_out,
    output          hit_start_out,
	//output          busy_start_out,
    output	[15:0]	coincid_MIP1_cnt_out,
    output	[15:0]	coincid_MIP2_cnt_out,
	output	[15:0]	coincid_GM1_cnt_out,
    output	[15:0]	coincid_GM2_cnt_out,
    output	[15:0]	coincid_UBS_cnt_out,
    output          coincid_trg_raw_1us_out,
    output  [4:0]   coincid_tag_raw_out,
	output  [23:0]  trg_busy_time_cnt_out,
	output			trg_busy_timer_rdy_out,
	output [15:0]	hit_sig_stus_out,
	output          si_busy_tmp
	);
	

    reg             coincid_trg_sig, coincid_trg_raw_1us_sig;
    wire    [1:0]	W_busya_N, W_busyb_N;
    wire    [7:0]	W_hita_N, W_hitb_N;
    reg     [1:0]	busy_syn_tmp_r, busy_syn_r;
    reg     [7:0]	hit_syn_tmp_r, hit_syn_r;
    wire	        hit_start_r;
	//wire	        busy_start_r;

    wire    acd_fee_top_hit_syn, acd_fee_sec_hit_syn, acd_fee_sid_hit_syn, csi_fee_hit_syn, cal_fee_1_hit_syn, cal_fee_2_hit_syn, cal_fee_3_hit_syn, cal_fee_4_hit_syn;

    assign W_busya_N =  {si_trb_1_busy_a_in_N, si_trb_2_busy_a_in_N};
    assign W_busyb_N =  {si_trb_1_busy_b_in_N, si_trb_2_busy_b_in_N};

    assign W_hita_N =   {acd_fee_top_hit_a_in_N, acd_fee_sec_hit_a_in_N, 
                                        acd_fee_sid_hit_a_in_N, csi_fee_hit_a_in_N, 
                                        cal_fee_1_hit_a_in_N, cal_fee_2_hit_a_in_N, 
                                        cal_fee_3_hit_a_in_N, cal_fee_4_hit_a_in_N};
    assign W_hitb_N =   {acd_fee_top_hit_b_in_N, acd_fee_sec_hit_b_in_N, 
                                        acd_fee_sid_hit_b_in_N, csi_fee_hit_b_in_N, 
                                        cal_fee_1_hit_b_in_N, cal_fee_2_hit_b_in_N, 
                                        cal_fee_3_hit_b_in_N, cal_fee_4_hit_b_in_N};

    parameter   SI_DEAD_TIME_SET_NUM = 24'd50000; //20ns per cnt, set 1ms = 50000


//synchonize the input of hit signal, if (ab_sel_in == 0) select  signal from channel A, 
//if mask==0010 for channel ABCD, so the C channel will be masked
always @(posedge clk_in)//two stage synchronizer, delay time {1CK, 2CK}, e.g. 20ns to 40ns
begin
	if (rst_in) begin
		busy_syn_tmp_r <= 2'b0;
		busy_syn_r <= 2'b0;
		hit_syn_tmp_r <= 8'b0;
		hit_syn_r <= 8'b0;
	end
	else begin  
			busy_syn_tmp_r <=   (~busy_mask_in) & (((~busy_ab_sel_in) & (~W_busya_N)) | (busy_ab_sel_in & (~W_busyb_N))) ;						
			hit_syn_tmp_r <=   (~hit_mask_in) & (((~hit_ab_sel_in) & (~W_hita_N)) | (hit_ab_sel_in & (~W_hitb_N)))  ;		
			//hit_syn_tmp_r <=	~W_hita_N;			
																														//hit_ab_sel_in equal==0:select channel A
																														// hit_ab_sel_in == 1: select hit channel B
																														//hit_syn_r is actived high
			busy_syn_r <= busy_syn_tmp_r;	
			hit_syn_r <= hit_syn_tmp_r;				       
	end
end



    assign	hit_start_out = hit_start_r;/////////select the hit signal(T0) to start coincidence process
    //assign  busy_start_out = busy_start_r;////W_busy_start[busy_start_sel_in];/////select the busy signal(T0) to start coincidence process
    assign  si_busy_tmp = busy_syn_r[0]|busy_syn_r[1];


	//ADC's hits are faster than CsI's, so different hit signals should be aligned. Default delay time is around 4us.
	
	wire [7:0] 	ACD_TOP_DELAY, ACD_SEC_DELAY, ACD_SID_DELAY;//this step: delay time = (DELAY bit+1)*40ns
	reg	[7:0]	shift_reg;
	assign  ACD_TOP_DELAY =acd_csi_hit_tim_diff_in+ acd_fee_top_hit_align_in;
	assign  ACD_SEC_DELAY =acd_csi_hit_tim_diff_in+ acd_fee_sec_hit_align_in;
	assign  ACD_SID_DELAY =acd_csi_hit_tim_diff_in+ acd_fee_sid_hit_align_in;
	reg [7:0] wr_ptr_7, wr_ptr_6, wr_ptr_5, wr_ptr_4, wr_ptr_3, wr_ptr_2, wr_ptr_1, wr_ptr_0; // write pointer
	reg [255:0] buffer_7, buffer_6, buffer_5, buffer_4, buffer_3, buffer_2, buffer_1, buffer_0;//ring buffer depth = 256

//Align the hit signal of ACD_TOP
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_7<=8'b0;
		buffer_7<=256'b0;
		shift_reg[7]<=1'b0;     
	end 
	else begin
		buffer_7[wr_ptr_7] <= hit_syn_r[7];//write current input signal to buffer current write pointer position
		shift_reg[7] <= buffer_7[(wr_ptr_7 - ACD_TOP_DELAY) % 256];//read pointer = write pointer - delay value
		wr_ptr_7 <= (wr_ptr_7 == 255) ? 0 : wr_ptr_7 + 1;//update write pointer
	end
end

//Align the hit signal of ACD_SEC
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_6<=8'b0;
		buffer_6<=256'b0;
		shift_reg[6]<=1'b0;     
	end 
	else begin
		buffer_6[wr_ptr_6] <= hit_syn_r[6];//write current input signal to buffer current write pointer position
		shift_reg[6] <= buffer_6[(wr_ptr_6 - ACD_SEC_DELAY) % 256];//read pointer = write pointer - delay value
		wr_ptr_6 <= (wr_ptr_6 == 255) ? 0 : wr_ptr_6 + 1;//update write pointer
	end
end

//Align the hit signal of ACD_SID
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_5<=8'b0;
		buffer_5<=256'b0;
		shift_reg[5]<=1'b0;     
	end 
	else begin
		buffer_5[wr_ptr_5] <= hit_syn_r[5];//write current input signal to buffer current write pointer position
		shift_reg[5] <= buffer_5[(wr_ptr_5 - ACD_SID_DELAY) % 256];//read pointer = write pointer - delay value
		wr_ptr_5 <= (wr_ptr_5 == 255) ? 0 : wr_ptr_5 + 1;//update write pointer
	end
end

//Align the hit signal of CSI
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_4<=8'b0;
		buffer_4<=256'b0;
		shift_reg[4]<=1'b0;     
	end 
	else begin
		buffer_4[wr_ptr_4] <= hit_syn_r[4];//write current input signal to buffer current write pointer position
		shift_reg[4] <= buffer_4[(wr_ptr_4 - csi_hit_align_in) % 256];//read pointer = write pointer - delay value
		wr_ptr_4 <= (wr_ptr_4 == 255) ? 0 : wr_ptr_4 + 1;//update write pointer
	end
end

//Align the hit signal of CAL_1
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_3<=8'b0;
		buffer_3<=256'b0;
		shift_reg[3]<=1'b0;     
	end 
	else begin
		buffer_3[wr_ptr_3] <= hit_syn_r[3];//write current input signal to buffer current write pointer position
		shift_reg[3] <= buffer_3[(wr_ptr_3 - cal_fee_1_hit_align_in) % 256];//read pointer = write pointer - delay value
		wr_ptr_3 <= (wr_ptr_3 == 255) ? 0 : wr_ptr_3 + 1;//update write pointer
	end
end

//Align the hit signal of CAL_2
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_2<=8'b0;
		buffer_2<=256'b0;
		shift_reg[2]<=1'b0;     
	end 
	else begin
		buffer_2[wr_ptr_2] <= hit_syn_r[2];//write current input signal to buffer current write pointer position
		shift_reg[2] <= buffer_2[(wr_ptr_2 - cal_fee_2_hit_align_in) % 256];//read pointer = write pointer - delay value
		wr_ptr_2 <= (wr_ptr_2 == 255) ? 0 : wr_ptr_2 + 1;//update write pointer
	end
end

//Align the hit signal of CAL_3
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_1<=8'b0;
		buffer_1<=256'b0;
		shift_reg[1]<=1'b0;     
	end 
	else begin
		buffer_1[wr_ptr_1] <= hit_syn_r[1];//write current input signal to buffer current write pointer position
		shift_reg[1] <= buffer_1[(wr_ptr_1 - cal_fee_3_hit_align_in) % 256];//read pointer = write pointer - delay value
		wr_ptr_1 <= (wr_ptr_1 == 255) ? 0 : wr_ptr_1 + 1;//update write pointer
	end
end

//Align the hit signal of CAL_4
always @(posedge clk_in)
begin
	if (rst_in) begin
		wr_ptr_0<=8'b0;
		buffer_0<=256'b0;
		shift_reg[0]<=1'b0;     
	end 
	else begin
		buffer_0[wr_ptr_0] <= hit_syn_r[0];//write current input signal to buffer current write pointer position
		shift_reg[0] <= buffer_0[(wr_ptr_0 - cal_fee_4_hit_align_in) % 256];//read pointer = write pointer - delay value
		wr_ptr_0 <= (wr_ptr_0 == 255) ? 0 : wr_ptr_0 + 1;//update write pointer
	end
end

	assign acd_fee_top_hit_syn = shift_reg[7];
	assign acd_fee_sec_hit_syn = shift_reg[6];
	assign acd_fee_sid_hit_syn = shift_reg[5];
	assign csi_fee_hit_syn = shift_reg[4];
	assign cal_fee_1_hit_syn = shift_reg[3];
	assign cal_fee_2_hit_syn = shift_reg[2];
	assign cal_fee_3_hit_syn = shift_reg[1];
	assign cal_fee_4_hit_syn = shift_reg[0];

//hit signal for start the coincidence process, set first hit signal as the start signal

	assign	hit_start_r = (acd_fee_top_hit_syn | acd_fee_sec_hit_syn | acd_fee_sid_hit_syn | csi_fee_hit_syn 
							| cal_fee_1_hit_syn | cal_fee_2_hit_syn | cal_fee_3_hit_syn | cal_fee_4_hit_syn);

	//assign	busy_start_r = busy_syn_r[0] | busy_syn_r[1];//////select the busy

reg [7:0] 	trg_seed_win_cnt;
reg [2:0] 	trg_seed_state;
reg [7:0]	trg_seed_reg;
wire		acd_fee_top_hit_syn_seed,	
			acd_fee_sec_hit_syn_seed,
			acd_fee_sid_hit_syn_seed,
			csi_fee_hit_syn_seed,
			cal_fee_1_hit_syn_seed,
			cal_fee_2_hit_syn_seed,
			cal_fee_3_hit_syn_seed,
			cal_fee_4_hit_syn_seed;

//create trigger seed, modified by shen, 2025-05-20
always @(posedge clk_in)
begin
	if (rst_in) begin
		trg_seed_state <= 3'b000;
		trg_seed_reg<= 8'b0;
	end
	else begin
		if	(trg_seed_state == 3'b000) begin
			trg_seed_win_cnt <= 8'b0;
			trg_seed_reg <= 8'b0;
			if (hit_start_r ) begin
				trg_seed_state <= 3'b001;
			end
		end
		else if (trg_seed_state == 3'b001) begin
			trg_seed_win_cnt <= trg_seed_win_cnt+ 1'b1;
			if(acd_fee_top_hit_syn)
				trg_seed_reg[7] <= 1'b1;
			if(acd_fee_sec_hit_syn)
				trg_seed_reg[6] <= 1'b1;
			if(acd_fee_sid_hit_syn)
				trg_seed_reg[5] <= 1'b1;
			if(csi_fee_hit_syn)
				trg_seed_reg[4] <= 1'b1;
			if(cal_fee_1_hit_syn)	
				trg_seed_reg[3] <= 1'b1;
			if(cal_fee_2_hit_syn)	
				trg_seed_reg[2] <= 1'b1;
			if(cal_fee_3_hit_syn)
				trg_seed_reg[1] <= 1'b1;
			if(cal_fee_4_hit_syn)
				trg_seed_reg[0] <= 1'b1;
			if (trg_seed_win_cnt == trg_match_win_in[15:8]) begin   //HIGH END of trg_match_win_in[15:8]: find seed window MAX is 256*20ns=5.12us, typical 800ns(8'd40)
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

assign acd_fee_top_hit_syn_seed = trg_seed_reg[7];
assign acd_fee_sec_hit_syn_seed = trg_seed_reg[6];
assign acd_fee_sid_hit_syn_seed = trg_seed_reg[5];
assign csi_fee_hit_syn_seed = trg_seed_reg[4];
assign cal_fee_1_hit_syn_seed = trg_seed_reg[3];
assign cal_fee_2_hit_syn_seed = trg_seed_reg[2];
assign cal_fee_3_hit_syn_seed = trg_seed_reg[1];
assign cal_fee_4_hit_syn_seed = trg_seed_reg[0];

//there are 9 logic group. Five of them using coincidence logic. in each group, we can use one of the logic in the group
reg	logic_grp0_result_r, logic_grp1_result_r, logic_grp2_result_r, logic_grp3_result_r, logic_grp4_result_r;

//coincidence logic group0, for MIPs trigger type1
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_grp0_result_r <= 1'b0;
	end
	else begin
		//////select the logic in group0
		case (logic_grp0_sel_in)////* synthesis parallel_case */
		2'b00:
			logic_grp0_result_r <= acd_fee_top_hit_syn_seed  & csi_fee_hit_syn_seed; //used for Trg_Delay_timer test.
		2'b01:
			logic_grp0_result_r <= acd_fee_top_hit_syn_seed & acd_fee_sec_hit_syn_seed & csi_fee_hit_syn_seed &(  cal_fee_2_hit_syn_seed | cal_fee_4_hit_syn_seed);
		2'b10:
			logic_grp0_result_r <= acd_fee_top_hit_syn_seed;
		2'b11:
            logic_grp0_result_r <= acd_fee_top_hit_syn_seed | acd_fee_sec_hit_syn_seed | csi_fee_hit_syn_seed | cal_fee_2_hit_syn_seed;//used in shanghai test
		default:
			logic_grp0_result_r <= 1'b0;		
		endcase
	end	
end

/////coincidence logic group1, for MIPs trigger type2
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_grp1_result_r <= 1'b0;
	end
	else begin
		//////select the logic in group0
		case (logic_grp1_sel_in)////* synthesis parallel_case */
		//2'b00:

		2'b01:
			logic_grp1_result_r <=  cal_fee_2_hit_syn_seed & cal_fee_4_hit_syn_seed;
		2'b10:
			logic_grp1_result_r <= acd_fee_top_hit_syn_seed  & csi_fee_hit_syn_seed;
		//2'b11:
			
		default:
			logic_grp1_result_r <= 1'b0;		
		endcase
	end	
end

/////coincidence logic group2, for Gamma trigger type1
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_grp2_result_r <= 1'b0;
	end
	else begin
		//////select the logic in group0
		case (logic_grp2_sel_in)////* synthesis parallel_case */
		//2'b00:

		2'b01:
			logic_grp2_result_r <=  ((~acd_fee_top_hit_syn_seed)&(~acd_fee_sec_hit_syn_seed))& csi_fee_hit_syn_seed & (cal_fee_1_hit_syn_seed | cal_fee_3_hit_syn_seed) ;
		2'b10:
		    logic_grp2_result_r <= acd_fee_top_hit_syn_seed  & csi_fee_hit_syn_seed & cal_fee_2_hit_syn_seed;	
		//2'b11:
			
		default:
			logic_grp2_result_r <= 1'b0;		
		endcase
	end	
end

/////coincidence logic group3, for Gamma trigger type2
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_grp3_result_r <= 1'b0;
	end
	else begin
		//////select the logic in group0
		case (logic_grp3_sel_in)////* synthesis parallel_case */
		//2'b00:

		2'b01:
			logic_grp3_result_r <=  ((~acd_fee_top_hit_syn_seed)|(~acd_fee_sec_hit_syn_seed))& csi_fee_hit_syn_seed & (cal_fee_1_hit_syn_seed | cal_fee_3_hit_syn_seed) ;
		//2'b10:
			
		//2'b11:
			
		default:
			logic_grp3_result_r <= 1'b0;		
		endcase
	end	
end

/////coincidence logic group4, for unbias trigger.
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_grp4_result_r <= 1'b0;
	end
	else begin
		//////select the logic in group0
		case (logic_grp4_sel_in)////* synthesis parallel_case */
		//2'b00:
            //logic_grp4_result_r <= hit_start_r;/
		2'b01:
			logic_grp4_result_r <=  cal_fee_1_hit_syn_seed | cal_fee_3_hit_syn_seed ;
		//2'b10:
			
		//2'b11:
			
		default:
			logic_grp4_result_r <= 1'b0;		
		endcase
	end	
end


//
reg[15:0]	coincid_UBS_cnt, coincid_GM1_cnt, coincid_GM2_cnt, coincid_MIP1_cnt, coincid_MIP2_cnt;//////counter for the different coincide trigger source
reg	coincid_UBS_engine_enb_r, coincid_MIP1_engine_enb_r, coincid_MIP2_engine_enb_r; ////trigger logic enable after prescale (divider)
wire[4:0] W_coincid_engine_enb, W_logic_all_grp_result;
reg[4:0] coincid_result_stp0_r, coincid_result_r, coincid_tag_raw_r;// result of coincidence
reg	coincid_trg_raw_r, coincid_tag_raw_enb_r;///coincide trigger signal before logic masked(enable)
reg si_fix_dead_time_cnt_start_tag;
reg[23:0]	dead_time_cnt;


////coincide trigger  counter
always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_MIP1_cnt <= 16'b0;
        coincid_MIP2_cnt <= 16'b0;
		coincid_GM1_cnt <= 16'b0;
		coincid_GM2_cnt <= 16'b0;
		coincid_UBS_cnt <= 16'b0;
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
always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_MIP1_engine_enb_r <= 1'b1;
		coincid_MIP2_engine_enb_r <= 1'b1;
		coincid_UBS_engine_enb_r <= 1'b1;
	end
	else begin
		////divider for MIP trigger, 512, 256, 128, 64, 32, 4,2,1
		case (coincid_MIP1_div_in) ////* synthesis parallel_case */
			6'b00_0000:  //no pre-scale
				coincid_MIP1_engine_enb_r <= 1'b1;			
			6'b00_0001: ////2
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[0] == 1'b0);			
			6'b00_0010: //4
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[1:0] == 2'b00);			
			6'b00_0011: //32
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[4:0] == 5'b0_0000);			
			6'b00_0100: //64
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[5:0] == 6'b00_0000);			
			6'b00_0101:  //128
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[6:0] == 7'b000_0000);			
			6'b00_0110:  //256
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[7:0] == 8'b0000_0000);			
			6'b00_0111: //512
				coincid_MIP1_engine_enb_r <= (coincid_MIP1_cnt[8:0] == 9'b0_0000_0000);			
			default: begin//1
				coincid_MIP1_engine_enb_r <= 1'b1;
			end
		endcase
		////divider for MIP2 trigger, 512, 256, 128, 64, 32, 4,2,1
		case (coincid_MIP2_div_in) ////* synthesis parallel_case */
			6'b00_0000:  //no pre-scale
				coincid_MIP2_engine_enb_r <= 1'b1;			
			6'b00_0001: ////2
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[0] == 1'b0);			
			6'b00_0010: //4
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[1:0] == 2'b00);			
			6'b00_0011: //32
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[4:0] == 5'b0_0000);			
			6'b00_0100: //64
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[5:0] == 6'b00_0000);			
			6'b00_0101:  //128
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[6:0] == 7'b000_0000);			
			6'b00_0110:  //256
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[7:0] == 8'b0000_0000);			
			6'b00_0111: //512
				coincid_MIP2_engine_enb_r <= (coincid_MIP2_cnt[8:0] == 9'b0_0000_0000);			
			default: begin//1
				coincid_MIP2_engine_enb_r <= 1'b1;
			end
		endcase
		///divider for unbias trigger, 2048,1024,512,256, 128,64,32,1
		case (coincid_UBS_div_in) ////* synthesis parallel_case */
			6'b00_0000: //no divider
				coincid_UBS_engine_enb_r <= 1'b1;
			6'b00_0001://32
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[4:0] == 5'b0_0000);
			6'b00_0010://64
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[5:0] == 6'b00_0000);
			6'b00_0011://128
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[6:0] == 7'b000_0000);
			6'b00_0100://256
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[7:0] == 8'b0000_0000);
			6'b00_0101://512
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[8:0] == 9'b0_0000_0000);
			6'b00_0110://1024
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[9:0] == 10'b00_0000_0000);
			6'b00_0111://2048
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[10:0] == 11'b000_0000_0000);
			default://1024
				coincid_UBS_engine_enb_r <= (coincid_UBS_cnt[9:0] == 10'b00_0000_0000);
		endcase
		end
end

///////
assign	W_coincid_engine_enb = {coincid_UBS_engine_enb_r, 1'b1, 1'b1, coincid_MIP2_engine_enb_r,
																	 coincid_MIP1_engine_enb_r};////combine all the enable for different engine
assign	W_logic_all_grp_result = {logic_grp4_result_r, logic_grp3_result_r, 
																			logic_grp2_result_r, logic_grp1_result_r, logic_grp0_result_r};////combine the results of all the logic engine
assign	logic_match_out = |(W_logic_all_grp_result & logic_grp_oe_in);///the signal after trigger logic operation (no T0), for debug and test


///coincidence process
//two stage: 1, detect the selected signal which is for starting the coincidence process
//////////////2, wait for the time (trg_match_wait_time_in), make sure other hit signal is valid and filter the noise (0-400ns)
/////////////3, coincidence (400ns -TRG_MATCH_WIN)
//////////in flight logic, add one clock delay for the trigger signal
reg[2:0] c_state, n_state;
reg[7:0] trg_win_cnt;/////trigger match windows counter

parameter   IDLE = 0, 
            COINCIDENCE_STAGE = 1, 
            COINCIDENCE_RESULT = 2, 
            COINCIDENCE_FIX_BUSY_GEN = 3, 
            COINCIDENCE_AUTO_BUSY_GEN = 4, 
            COINCIDENCE_BURST_GEN = 5, 
            COINCIDENCE_END = 6;

always @(posedge clk_in)
begin
	if (rst_in)
		c_state <= IDLE;
	else 
		c_state <= n_state;	
end


always @(c_state or hit_start_r or trg_win_cnt  or trg_match_win_in or logic_burst_sel_in or busy_mask_in or dead_time_cnt)
begin
	n_state = IDLE; //default value
	case(c_state)
		IDLE: begin
			if (hit_start_r)   ///detect the hit_start signal 
				n_state = COINCIDENCE_STAGE;
			else 
				n_state = IDLE;			
		end
		COINCIDENCE_STAGE: begin
			if (trg_win_cnt >= trg_match_win_in[15:8])//////coincidence windows
				n_state = COINCIDENCE_RESULT;
			//else if (trg_win_cnt < trg_match_win_in ) begin
			//	if (!hit_start_r)  //it is a noise
			//		n_state = IDLE;
			//	else
			//		n_state = COINCIDENCE_STAGE;
			//end
			else
				n_state = COINCIDENCE_STAGE;			
		end
		COINCIDENCE_RESULT: begin
            if(|logic_burst_sel_in)
			    n_state = COINCIDENCE_BURST_GEN;
            else if(busy_mask_in==2'b11) 
                n_state = COINCIDENCE_FIX_BUSY_GEN;
            else 
                n_state = COINCIDENCE_AUTO_BUSY_GEN; 
		end

		COINCIDENCE_FIX_BUSY_GEN: begin  //////generate the coincidence trigger signal, check Si-Tracker Status
            if(dead_time_cnt == SI_DEAD_TIME_SET_NUM)
                n_state = COINCIDENCE_END;
            else
                n_state = COINCIDENCE_FIX_BUSY_GEN;
		end

		COINCIDENCE_AUTO_BUSY_GEN: begin  //////generate the coincidence trigger signal, check Si-Tracker Status
            n_state = COINCIDENCE_END;
		end

		COINCIDENCE_BURST_GEN: begin  //////generate the coincidence trigger signal, check Si-Tracker Status
            n_state = COINCIDENCE_END;
		end

		COINCIDENCE_END: begin
			if (!hit_start_r)//////////wait for the hit start signal to invalid, to make sure the timing of the next trigger
				n_state = IDLE;
			else 
				n_state = COINCIDENCE_END;			
		end
		default: begin
			n_state = IDLE;			
		end
	endcase	
end


////////////coincidence process
always @(posedge clk_in)
begin
	   if (rst_in) begin
        coincid_trg_sig <= 1'b0;////the final result of the coincid trg
        coincid_trg_raw_r <= 1'b0;/////the coincide trigger before oe (mask)
        coincid_result_stp0_r <= 5'b0;///the coincide result after the wait window
        coincid_result_r <= 5'b0;////////the final result of the coincide 
        trg_win_cnt <= 8'b0;////counter of the match windows
        coincid_tag_raw_enb_r <= 1'b0;  //latch the coincid tag
        si_fix_dead_time_cnt_start_tag<=1'b0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_stp0_r <= 5'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 8'b0;
            coincid_tag_raw_enb_r <= 1'b0; 
            si_fix_dead_time_cnt_start_tag<=1'b0;
         end
         COINCIDENCE_STAGE: begin
         		coincid_trg_sig <= 1'b0;
         		coincid_trg_raw_r <= 1'b0;
            trg_win_cnt <= trg_win_cnt + 1;           
            if (trg_win_cnt == {trg_match_win_in[15:8]}) //wait for other hit
            	coincid_result_stp0_r <= W_logic_all_grp_result;
           // else if (trg_win_cnt < { trg_match_win_in[15:8]}) begin
           //     if (!hit_start_r) //the width of the T0 signal less than expected, it is a noise
           //         trg_win_cnt <= 6'b0;
           // end
         end
         COINCIDENCE_RESULT: begin //
         	coincid_tag_raw_enb_r <= 1'b1;////latch the coincidence tag, please attention the timing, normally LOGIC OR, e.g.logic_judge_mode_in=1'b0
			coincid_result_r <=  coincid_result_stp0_r ;
         end
         COINCIDENCE_FIX_BUSY_GEN: begin //generate the trigger signal, the delay between the output trigger and the start_hit must be fixed
			coincid_tag_raw_enb_r <= 1'b0;//
            si_fix_dead_time_cnt_start_tag<=1'b1;
         	coincid_trg_sig <= |( (W_coincid_engine_enb & logic_grp_oe_in) & coincid_result_r);//coincide trigger after mask
         	coincid_trg_raw_r <= |(W_coincid_engine_enb & coincid_result_r);//coincide trigger before mask
         end
         COINCIDENCE_AUTO_BUSY_GEN: begin //generate the trigger signal, the delay between the output trigger and the start_hit must be fixed
			coincid_tag_raw_enb_r <= 1'b0;//
         	coincid_trg_sig <= (|( (W_coincid_engine_enb & logic_grp_oe_in) & coincid_result_r)) & (~si_busy_tmp);//coincide trigger after mask
         	coincid_trg_raw_r <= (|(W_coincid_engine_enb & coincid_result_r))& (~si_busy_tmp);//coincide trigger before mask
         end
         COINCIDENCE_BURST_GEN: begin //generate the trigger signal, the delay between the output trigger and the start_hit must be fixed
			coincid_tag_raw_enb_r <= 1'b0;//
         	coincid_trg_sig <= |( (W_coincid_engine_enb & logic_grp_oe_in) & coincid_result_r);//coincide trigger after mask
         	coincid_trg_raw_r <= |(W_coincid_engine_enb & coincid_result_r);//coincide trigger before mask
         end
         COINCIDENCE_END: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_stp0_r <= 5'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 6'b0;
            si_fix_dead_time_cnt_start_tag<=1'b0;
         end
         default: begin
            coincid_trg_sig <= 1'b0;
            coincid_trg_raw_r <= 1'b0;
            coincid_result_stp0_r <= 5'b0;
            coincid_result_r <= 5'b0;
            trg_win_cnt <= 6'b0;
            coincid_tag_raw_enb_r <= 1'b0; 
            si_fix_dead_time_cnt_start_tag<=1'b0;
         end
        endcase
    end
	
end


//SI_DEAD_TIME_SET_NUM
always @(posedge clk_in)
begin
	if (rst_in) begin
		dead_time_cnt <= 24'd0;//23'd0
	end
	else if (si_fix_dead_time_cnt_start_tag ) begin // start count
        dead_time_cnt<= dead_time_cnt + 1'b1;
    end
	else if (dead_time_cnt == SI_DEAD_TIME_SET_NUM + 2) begin // re-triggerable //dead_time_cnt == SI_DEAD_TIME_SET_NUM
        dead_time_cnt <= 24'd0;
	end
end


////latch the coincidence tag
always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_tag_raw_r <= 5'b0;
	end
	else if (coincid_tag_raw_enb_r) begin
		coincid_tag_raw_r <= W_coincid_engine_enb & coincid_result_r;////tag the coincidence result before "disable"(oe)
	end
end

////////expand the width of the coincid_trigger_raw_r to 1000ns
reg[5:0]	coincid_trg_raw_expd_cnt;
always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_trg_raw_1us_sig <= 1'b0;
		coincid_trg_raw_expd_cnt <= 6'b0;
	end
	else if (coincid_trg_raw_r) begin // re-triggerable
		coincid_trg_raw_1us_sig <= 1'b1;
		coincid_trg_raw_expd_cnt <= 6'b0;
	end
	else if (coincid_trg_raw_1us_sig && (coincid_trg_raw_expd_cnt < 6'b01_1001)) begin //less than 1us
		coincid_trg_raw_expd_cnt <= coincid_trg_raw_expd_cnt + 1;
		coincid_trg_raw_1us_sig <= 1'b1;
	end
	else if (coincid_trg_raw_expd_cnt >= 6'b01_1001) begin//expand to about 1us width
		coincid_trg_raw_expd_cnt <= 6'b0;
		coincid_trg_raw_1us_sig <= 1'b0;
	end
end

////////trigger dead time counter
// [TBD] consider the busy signal from PMU
// [TBD] consider if no busy signal from Si-detector
reg[23:0]	trg_busy_time_cnt;
reg[3:0]	work_state;
reg	coincid_trg_sig_r,si_busy_tmp_r;
reg		trg_busy_timer_rdy;
//si_busy_tmp


always @(posedge clk_in)
begin
	if (rst_in) begin
		coincid_trg_sig_r <= 1'b0;
		si_busy_tmp_r <= 1'b0;
	end
	else begin
		coincid_trg_sig_r <= coincid_trg_sig;
		si_busy_tmp_r <= si_busy_tmp;	
	end
end


reg[2:0] busy_c_state, busy_n_state;

parameter   BUSY_IDLE = 0, 
			BUSY_COUNTER_START = 1, 
			BUSY_COUNTER_STOP = 2, 

			BUSY_END = 6;

always @(posedge clk_in)
begin
	if (rst_in)
		busy_c_state <= BUSY_IDLE;
	else 
		busy_c_state <= busy_n_state;	
end



always @(busy_c_state or  coincid_trg_sig or coincid_trg_sig_r or si_busy_tmp or si_busy_tmp_r)
begin
	busy_n_state = BUSY_IDLE; //default value
	case(busy_c_state)
		BUSY_IDLE: begin
			if (coincid_trg_sig&&(~coincid_trg_sig_r))   ///detect the coincid_trg_sig start signal
				busy_n_state = BUSY_COUNTER_START;
			else 
				busy_n_state = IDLE;			
		end
		BUSY_COUNTER_START: begin
			if ((~si_busy_tmp)&&si_busy_tmp_r)//
				busy_n_state = BUSY_COUNTER_STOP;
			else
				busy_n_state = BUSY_COUNTER_START;			
		end
		BUSY_COUNTER_STOP: begin
				busy_n_state = BUSY_IDLE;			
		end
		default: begin
			busy_n_state = BUSY_IDLE;			
		end
	endcase	
end


always @(posedge clk_in)
begin
	if (rst_in) begin
		trg_busy_time_cnt <= 24'b0;
		trg_busy_timer_rdy <= 1'b0;
	end
	else  begin //
		case(busy_c_state) 
			BUSY_IDLE: begin
				trg_busy_time_cnt <= 24'b0;
				trg_busy_timer_rdy <= 1'b0;
			end
			BUSY_COUNTER_START: begin
				trg_busy_time_cnt <= trg_busy_time_cnt + 1'b1;
			end
			BUSY_COUNTER_STOP: begin
				//trg_busy_time_cnt <= 24'b0;
				trg_busy_timer_rdy <= 1'b1;
			end
			default: begin
				trg_busy_time_cnt <= 24'b0;
				trg_busy_timer_rdy <= 1'b0;
			end
		endcase

	end
end

assign	coincid_trg_out=	coincid_trg_sig;
assign	coincid_trg_raw_1us_out=	coincid_trg_raw_1us_sig;
assign	coincid_tag_raw_out = coincid_tag_raw_r;
assign	coincid_MIP1_cnt_out = coincid_MIP1_cnt;
assign	coincid_MIP2_cnt_out = coincid_MIP2_cnt;
assign	coincid_GM1_cnt_out = coincid_GM1_cnt;
assign	coincid_GM2_cnt_out = coincid_GM2_cnt;
assign	coincid_UBS_cnt_out = coincid_UBS_cnt;
assign	hit_syn_out = hit_syn_r;
assign  busy_syn_out = busy_syn_r;

assign	trg_busy_time_cnt_out = trg_busy_time_cnt;
assign	trg_busy_timer_rdy_out = trg_busy_timer_rdy;
assign	hit_sig_stus_out = {8'b0000_0000, trg_seed_reg};//orig:shift_reg -- after trg_match_win_in[15:8], coincid_trg_sig = 1, so we use trg_seed_reg to transmit


endmodule