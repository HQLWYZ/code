/*----------------------------------------------------------*/
/* 															*/
/*	file name:	HitTrgCount.v			           			*/
/* 	date:		2025/03/13									*/
/* 	modified:	2026/01/03								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:		system clock = 50MHz                        */
/* 															*/
/*----------------------------------------------------------*/

module HitTrgCount(
	input			clk_in,
	input			rst_in, 	
	input			rd_in,			
	input	[12:0]	hit_syn_in,				// hit signals after synchronization, from Coincidence module
	input	[1:0]	busy_syn_in,			// busy signals after synchronization, from Coincidence module
	input			hit_start_in,			// hit start signal, the fastest signal from the ECAL, from Coincidence module
	input			eff_trg_in,				// effective trigger signal, from TrgOutCtrl module
	input			coincid_trg_in,			//from Coincidence module
	input			logic_match_in,			//from Coincidence module
	input			ext_trg_syn_in,			//from GroundTestGen module
	input	[3:0]	hit_monit_fix_sel_in,	// Selected hit signal for monitoring
	input			busy_monit_fix_sel_in,	// Selected busy signal for monitoring
	output	[7:0]	hit_monit_sel_out,		// Which hit signal is monitored
	output	[7:0]	hit_monit_err_cnt_out,	// Hit signal width error count
	output	[7:0]	busy_monit_err_cnt_out,	// Busy signal width error count
	output	[31:0]	hit_monit_cnt_0_out,	// Hit count of the selected hit channel 0[from the fixed hit signal] 
	output	[31:0]	hit_monit_cnt_1_out,	// Hit count of the selected hit channel 1
	output	[15:0]	busy_monit_cnt_out,		// Busy count of the selected busy channel
	output	[15:0]	hit_start_cnt_out, 		// Hit start count
	output	[15:0]	logic_match_cnt_out, 	// Logic match count
	output	[15:0]	eff_trg_cnt_out, 		// Effective trigger count
	output	[15:0]	coincid_trg_cnt_out, 	// Coincidence trigger count
	output	[15:0]	ext_trg_cnt_out,		// External trigger count
	output 	[7:0]	trg_delay_timer_out 	// time delay count between acd_fee_top_hit_in and csi_fee_hit_in, e.g. hit_syn_in[7] and hit_syn_in[4], before synchronization
	);


parameter   HIT_WIDTH = 8; 		// STD:160ns, [120ns to 200ns], detect range of hit pulse width [80ns to 240ns]

wire	[12:0] 		W_hit_pulse;
wire	[12:0] 		W_hit_pulse_F;
wire	[1:0] 		W_busy_pulse;
wire				W_update_end_pulse;
reg		[3:0]		hit_monit_sel_r;
reg		[31:0]		hit_monit_cnt_0;
reg		[31:0]		hit_monit_cnt_1;
reg		[15:0]		hit_start_cnt; 
reg		[15:0]		coincid_trg_cnt;
reg		[15:0]		logic_match_cnt; 
reg		[15:0]		ext_trg_cnt;
reg		[7:0]		hit_monit_err_cnt;
reg		[15:0] 		eff_trg_cnt;
reg		[15:0]		busy_monit_cnt;
reg		[7:0]		trg_delay_timer_cnt;



//------>>  Effictive trigger counter----------
//tmr for the effective trigger signal, eff_trg_cnt act as trigger id, so the eff_trg_cnt must be TMR

reg[15:0]	eff_trg_cnt0/* synthesis syn_preserve=1 */, eff_trg_cnt1/* synthesis syn_preserve=1 */, eff_trg_cnt2/* synthesis syn_preserve=1 */;
wire	W_eff_trg_cnt_terr;
wire[15:0]	W_eff_trg_cnt;
assign	W_eff_trg_cnt_terr = !((eff_trg_cnt0 == eff_trg_cnt1) && (eff_trg_cnt0 == eff_trg_cnt2));
assign	W_eff_trg_cnt = (eff_trg_cnt0 & eff_trg_cnt1) | (eff_trg_cnt0 & eff_trg_cnt2) | (eff_trg_cnt1 & eff_trg_cnt2);

always @(posedge clk_in) ////for good timing
begin
	if (rst_in)
		eff_trg_cnt <= 16'd0;
	else
		eff_trg_cnt <= W_eff_trg_cnt;
end
	
//eff_trg_cnt is TMR,eff_trg_cnt is equal to trigger id
always @(posedge clk_in)
begin
    if (rst_in) begin
        eff_trg_cnt0 <= 16'd0;
        eff_trg_cnt1 <= 16'd0;
        eff_trg_cnt2 <= 16'd0;
    end
    else if (eff_trg_in)begin
        eff_trg_cnt0 <= eff_trg_cnt0 + 1;
        eff_trg_cnt1 <= eff_trg_cnt1 + 1;
        eff_trg_cnt2 <= eff_trg_cnt2 + 1;
    end
    else if (W_eff_trg_cnt_terr) begin
    	eff_trg_cnt0 <= W_eff_trg_cnt;
    	eff_trg_cnt1 <= W_eff_trg_cnt;
    	eff_trg_cnt2 <= W_eff_trg_cnt;
    end    	
end



//----->>  Detect the leading edge of 13 hit signals and 2 busy signals
reg		[12:0] 	hit_tmp_r;
reg		[1:0]	busy_tmp_r;
reg		rd_in_r;

always @(posedge clk_in)
begin
	if (rst_in)
		rd_in_r <= 1'b0;
	else 
		rd_in_r <= rd_in;	
end

always @(posedge clk_in)
begin
	if (rst_in)
		hit_tmp_r <= 13'b0;
	else 
		hit_tmp_r <= hit_syn_in;	
end

always @(posedge clk_in)
begin
	if (rst_in)
		busy_tmp_r <= 2'b0;
	else 
		busy_tmp_r <= busy_syn_in;	
end

assign W_hit_pulse = hit_syn_in & (~hit_tmp_r);  
assign W_busy_pulse = busy_syn_in & (~busy_tmp_r);  


assign W_hit_pulse_F = (~hit_syn_in) & hit_tmp_r;  



//----->> 	Count the hit signal
////monitor the selected hit signal 
///check the width of the hit select hit signal, if the width is between [120ns to 200ns], the logic will think it is a right pulse

always @(posedge clk_in)	//Which hit signal is monitored
begin
    if (rst_in) begin            
        hit_monit_sel_r <= 4'b0;
    end
    else begin
        if ((~rd_in & rd_in_r)&&(hit_monit_sel_r<=4'd11)) begin //falling edge of rd_in
            hit_monit_sel_r <= hit_monit_sel_r + 1'b1;
        end
		else if ((~rd_in & rd_in_r)&&(hit_monit_sel_r==4'd12)) begin //falling edge of rd_in
			hit_monit_sel_r <= 4'b0;
		end
    end
end

//count the selected hit signal 0
always @(posedge clk_in)
begin
	if (rst_in)
		hit_monit_cnt_0 <= 32'b0;
	else if (W_hit_pulse[hit_monit_fix_sel_in])
		hit_monit_cnt_0 <= hit_monit_cnt_0 + 1;	
end

//count the selected hit signal 1
always @(posedge clk_in)
begin
	if (rst_in)
		hit_monit_cnt_1 <= 32'b0;
	else if (W_hit_pulse[hit_monit_sel_r])
		hit_monit_cnt_1 <= hit_monit_cnt_1 + 1;	
end

//count the selected busy signal
always @(posedge clk_in)
begin
	if (rst_in)
		busy_monit_cnt <= 16'b0;
	else if (W_busy_pulse[busy_monit_fix_sel_in])
		busy_monit_cnt <= busy_monit_cnt + 1;	
end


// Monitoring the width of hit signal 0 [fixed hit signal]
reg		[3:0]	hit_monit_width_cnt_0; // max value= 16, clk=50Mhz, the width of hit is 320ns
reg				hit_monit_err_r_0;

reg [3:0] c_hit_0_monit_state, n_hit_0_monit_state;  //monitor the hit signal
parameter 	MONIT_HIT_0_IDLE = 0, 
			MONIT_HIT_0_CNT = 1, 
			MONIT_HIT_0_WIDTH_CHECK = 2;

always @(posedge clk_in)
begin
	if (rst_in)
		c_hit_0_monit_state <= MONIT_HIT_0_IDLE;
	else 
		c_hit_0_monit_state <= n_hit_0_monit_state;
end

always @(c_hit_0_monit_state or W_hit_pulse[hit_monit_fix_sel_in]   or hit_syn_in[hit_monit_fix_sel_in]
				 or hit_monit_width_cnt_0 or hit_monit_fix_sel_in)
begin
	n_hit_0_monit_state = MONIT_HIT_0_IDLE;
	case (c_hit_0_monit_state)
		MONIT_HIT_0_IDLE: begin
			if ( (W_hit_pulse[hit_monit_fix_sel_in])  ) //leading edge of hit signal, if the hit is alway equal to 1 or 0, no error detected////////(hit_syn_in[hit_monit_sel_r]) 
				n_hit_0_monit_state = MONIT_HIT_0_CNT;
			else 
				n_hit_0_monit_state = MONIT_HIT_0_IDLE;
			end
		MONIT_HIT_0_CNT: begin
			if ( ~hit_syn_in[hit_monit_fix_sel_in] ) //falling edge of hit signal, if the hit is alway equal to 1 or 0, no error detected////////(hit_syn_in[hit_monit_sel_r]) 
				n_hit_0_monit_state = MONIT_HIT_0_WIDTH_CHECK;
			else 
				n_hit_0_monit_state = MONIT_HIT_0_CNT;
			end
		MONIT_HIT_0_WIDTH_CHECK: begin
				n_hit_0_monit_state = MONIT_HIT_0_IDLE;
			end
		endcase
end

always @(posedge clk_in)
begin
    if (rst_in) begin
        hit_monit_width_cnt_0 <= 4'b0;
        hit_monit_err_r_0 <= 1'b0;// flag of the error of hit pulse width, hit_monit_err_r
    end
    else begin
        case (c_hit_0_monit_state) 
         MONIT_HIT_0_IDLE: begin
            hit_monit_err_r_0 <= 1'b0;
            hit_monit_width_cnt_0 <= 4'b0;
         end
         MONIT_HIT_0_CNT: begin   // 	
			hit_monit_width_cnt_0 <= hit_monit_width_cnt_0 + 1;
         end
		MONIT_HIT_0_WIDTH_CHECK: begin
			if( (hit_monit_width_cnt_0 < (HIT_WIDTH - 4)) || (hit_monit_width_cnt_0 > (HIT_WIDTH + 4)) ) begin//[80ns to 240ns]
				hit_monit_err_r_0 <= 1'b1;
				hit_monit_width_cnt_0 <= 4'b0;
			end
         end
         default: begin
            hit_monit_width_cnt_0 <= 4'b0;
            hit_monit_err_r_0 <= 1'b0;  
         end
        endcase
    end
end




//---------------->>  monitor the width of hit signal 1, selected by hit_monit_sel_r
reg		[3:0]	hit_monit_width_cnt_1; // max value= 16, clk=50Mhz, the width of hit is 320ns
reg				hit_monit_err_r_1;

reg [3:0] c_hit_1_monit_state, n_hit_1_monit_state;  //monitor the hit signal
parameter 	MONIT_HIT_1_IDLE = 0, 
			MONIT_HIT_1_CNT = 1,
			MONIT_HIT_1_WIDTH_CHECK = 2;

always @(posedge clk_in)
begin
	if (rst_in)
		c_hit_1_monit_state <= MONIT_HIT_1_IDLE;
	else 
		c_hit_1_monit_state <= n_hit_1_monit_state;
end

always @(c_hit_1_monit_state or W_hit_pulse[hit_monit_sel_r]   or hit_syn_in[hit_monit_sel_r]
				 or hit_monit_width_cnt_1 or hit_monit_sel_r)
begin
	n_hit_1_monit_state = MONIT_HIT_1_IDLE;
	case (c_hit_1_monit_state)
		MONIT_HIT_1_IDLE: begin
			if ( (W_hit_pulse[hit_monit_sel_r])  ) //leading edge of hit signal, if the hit is alway equal to 1 or 0, no error detected////////(hit_syn_in[hit_monit_sel_r]) 
				n_hit_1_monit_state = MONIT_HIT_1_CNT;
			else 
				n_hit_1_monit_state = MONIT_HIT_1_IDLE;
			end
		MONIT_HIT_1_CNT: begin
			if ( ~hit_syn_in[hit_monit_sel_r] ) //falling edge of hit signal, if the hit is alway equal to 1 or 0, no error detected////////(hit_syn_in[hit_monit_sel_r]) 
				n_hit_1_monit_state = MONIT_HIT_1_WIDTH_CHECK;
			else 
				n_hit_1_monit_state = MONIT_HIT_1_CNT;
			end
		MONIT_HIT_1_WIDTH_CHECK: begin
				n_hit_1_monit_state = MONIT_HIT_1_IDLE;
			end
		endcase
end

always @(posedge clk_in)
begin
    if (rst_in) begin
        hit_monit_width_cnt_1 <= 4'b0;
        hit_monit_err_r_1 <= 1'b0;// flag of the error of hit pulse width, hit_monit_err_r
    end
    else begin
        case (c_hit_1_monit_state) 
         MONIT_HIT_1_IDLE: begin
            hit_monit_err_r_1 <= 1'b0;
            hit_monit_width_cnt_1 <= 4'b0;
         end
         MONIT_HIT_1_CNT: begin   // 	
			hit_monit_width_cnt_1 <= hit_monit_width_cnt_1 + 1;
         end
		MONIT_HIT_1_WIDTH_CHECK: begin
			if( (hit_monit_width_cnt_1 < (HIT_WIDTH - 4)) || (hit_monit_width_cnt_1 > (HIT_WIDTH + 4)) ) begin//[80ns to 240ns]
				hit_monit_err_r_1 <= 1'b1;
				hit_monit_width_cnt_1 <= 4'b0;
			end
         end
         default: begin
            hit_monit_width_cnt_1 <= 4'b0;
            hit_monit_err_r_1 <= 1'b0;  
         end
        endcase
    end
end




//------>>	Hit width error counter; when the "hit_monit_sel_r" point to next hit signal, the counter will be cleared
always @(posedge clk_in) 
begin
    if (rst_in) begin
        hit_monit_err_cnt <= 8'b0;
    end
    else if(hit_monit_err_r_0||hit_monit_err_r_1) begin// when the counter is full, stop counting
        hit_monit_err_cnt <= (hit_monit_err_cnt == 8'b1111_1111)? hit_monit_err_cnt:(hit_monit_err_cnt + 1);
    end
end


//------>>	Count the hit_start signal, monitor the hit_start signal
reg	hit_start_tmp_r;
always @(posedge clk_in)
begin
	if (rst_in) begin
		hit_start_tmp_r <= 1'b0;
		hit_start_cnt <= 16'b0;
	end
	else begin
		hit_start_tmp_r <= hit_start_in;
		if (hit_start_in & (~hit_start_tmp_r) )  //detect the rising edge of the hit signal
			hit_start_cnt <= hit_start_cnt + 1;
	end
end

//------>>	monitor the coincidence trigger signal, coincidence trigger counter, coincid_trg_in is one clock width
reg	coincid_trg_tmp_r;
always @(posedge clk_in) 
begin
    if (rst_in) begin
        coincid_trg_cnt <= 16'b0;
        coincid_trg_tmp_r <= 1'b0;
    end
    else begin
    	coincid_trg_tmp_r <= coincid_trg_in;
    	if(~coincid_trg_tmp_r & coincid_trg_in)   //if(coincid_trg_tmp_r)
    		coincid_trg_cnt <= coincid_trg_cnt + 1;
    end
end

//------>>	logic_match  pulse counter
reg	logic_match_tmp_r;//use a register to buffer the logic match pulse to get better timing
always @(posedge clk_in)
begin
	if (rst_in) begin
		logic_match_tmp_r <= 1'b0;
		logic_match_cnt <= 16'b0;
	end
	else begin
		logic_match_tmp_r <= logic_match_in;
		if ( logic_match_in & (~logic_match_tmp_r) ) ///rising edge of logic_match_pul
			logic_match_cnt <= logic_match_cnt + 1;
	end
end

//------>>	external trigger counter
reg	ext_trg_syn_tmp_r;//use a register to buffer the logic match pulse to get better timing
always @(posedge clk_in)
begin
	if (rst_in) begin
		ext_trg_syn_tmp_r <= 1'b0;
		ext_trg_cnt <= 16'b0;
	end
	else begin
		ext_trg_syn_tmp_r <= ext_trg_syn_in;
		if ( ext_trg_syn_in & (~ext_trg_syn_tmp_r) ) ///rising edge of external trigger signal
			ext_trg_cnt <= ext_trg_cnt + 1;
	end
end

//------>>	hit delay timer counter, W_hit_pulse[12], W_hit_pulse[9] are the leading edge signals from acd_fee_top_hit_in and csi_fee_hit_in_A, respectively
reg [1:0]	work_state;
always @(posedge clk_in)
begin
	if (rst_in) begin
		trg_delay_timer_cnt <= 8'b0;
		work_state <= 2'b0;
	end
	else begin
		if(work_state == 2'b00) begin
			if (W_hit_pulse[12] ) begin
				work_state <= 2'b01;
				trg_delay_timer_cnt <= 8'b0;
			end
		end
		else if (work_state == 2'b01) begin
			trg_delay_timer_cnt <= trg_delay_timer_cnt+1'b1;
			if (W_hit_pulse[9] ) begin
				work_state <= 2'b10;
			end
		end
		else if (work_state == 2'b10) begin
				work_state <= 2'b00;
		end
	end
end

assign	hit_start_cnt_out = hit_start_cnt;
assign	hit_monit_err_cnt_out = hit_monit_err_cnt;
assign	logic_match_cnt_out = logic_match_cnt;
assign	coincid_trg_cnt_out = coincid_trg_cnt;
assign	hit_monit_sel_out = { hit_monit_fix_sel_in,  hit_monit_sel_r};
assign	hit_monit_cnt_0_out = hit_monit_cnt_0;
assign	hit_monit_cnt_1_out = hit_monit_cnt_1;
assign	ext_trg_cnt_out = ext_trg_cnt;
assign	eff_trg_cnt_out = eff_trg_cnt;
assign	busy_monit_err_cnt_out = 8'b0; 
assign	busy_monit_cnt_out = busy_monit_cnt;
assign	trg_delay_timer_out = trg_delay_timer_cnt; 



endmodule