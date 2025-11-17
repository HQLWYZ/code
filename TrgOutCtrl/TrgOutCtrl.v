/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgOutCtrl.v			           			*/
/* 	date:		2025/03/18									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:	    system clock = 50MHz                        */
/* 															*/
/*----------------------------------------------------------*/

module TrgOutCtrl(
    input			clk_in,
    input           rst_in,
    input           coincid_trg_in, //trigger sources
    input           ext_trg_syn_in, //trigger sources
    input           cycled_trg_in,  //trigger sources
    input	[1:0]	busy_syn_in,    //busy sources from detector
    input		    busy_ignore_in, //busy_ignore_out = 1: ignore the TRB busy signal; 
    input   [1:0]   logic_burst_sel_in, //burst mode select, in this case, dead time is 50us(default). [2'b11] means enable burst mode.
    input	    	pmu_busy_in,    //busy sources from PMU
    input           trg_enb_in, 
    input   [7:0]   trg_dead_time_in, //dead time for trigger signal 
    input   [15:0]  eff_trg_cnt_in, //equal to trigger id
    output          eff_trg_out,    //width = 1 clock, signal for the other modules
    output          trg_out_N_acd_a, trg_out_N_acd_b, //width = 400ns, 400us trigger signal with 1000us trigger id check signal
    output          trg_out_N_CsI_track_a, trg_out_N_CsI_track_b,
    output          trg_out_N_Si1_a, trg_out_N_Si1_b,trg_out_N_Si2_a, trg_out_N_Si2_b,
    output          trg_out_N_cal_fee_1_a, trg_out_N_cal_fee_1_b,trg_out_N_cal_fee_2_a, trg_out_N_cal_fee_2_b,
    output          trg_out_N_cal_fee_3_a, trg_out_N_cal_fee_3_b,trg_out_N_cal_fee_4_a, trg_out_N_cal_fee_4_b 	 
);

parameter   TRG_PULSE_WIDTH = 20; 	//20ns*20 = 400ns
parameter   CHK_PULSE_WIDTH = 50; 	// 20ns*50 = 1us
parameter   DEADTIME_UNIT_10MS = 500; //500*20ns = 10us， 500=12'b0001_1111_0100


///internal reg
reg                 trg_send_r;// trigger pulse output
reg	                daq_busy_r;
reg         [7:0]   trg_chksig_width_cnt;// trigger signal and TID check signal's width counter
reg         [19:0]  trg_dead_time_cnt;//[MAX]=20'b1111_1111_1111_1111_1111 = 1_048_575, about 20ns*1048575=20.97ms
reg                 coincid_trg_in_r;
wire                si_busy_sig;
reg         [19:0]  trg_dead_time_temp;//[MAX]=20'b1111_1111_1111_1111_1111 = 1_048_575, about 20ns*1048575=20.97ms   
wire        [19:0]  trg_dead_time_prodcut;
integer             i;
reg                 eff_trg_sig; //register the output signal


//------------>  state machine for generating trigger signal, which will be sent to the output of FPGA
reg[3:0] c_state, n_state;
parameter   IDLE = 0, 
            WAIT_DEAD_TIME = 1,
            CHECK_SI_BUSY = 2,
            IGNORE_SI_BUSY = 3,
            BURST_MODE = 4,
            WAIT_PMU_BUSY_WITH_SI_BUSY = 5,
            WAIT_PMU_BUSY_WITHOUT_SI_BUSY = 6,
            WAIT_TRG_WITH_SI_BUSY = 7,
            WAIT_TRG_WITHOUT_SI_BUSY = 8,
            SEND_TRG = 9, 
            SEND_TRG_CHK = 10; 

always @(posedge clk_in)
begin
	if (rst_in) 
		c_state <= IDLE;
	else 
		c_state <= n_state;
end

//IDLE:             detect the trigger source. If the selected trigger source is valid, start to send the trigger signal
//WAIT_DEAD_TIME:   select different dead time type.
//CHECK_SI_BUSY:    check the Si detector busy signal (normally in this case)
//IGNORE_SI_BUSY:   ignore the Si detector busy signal (in this case, the dead time is fixed to 850us)
//BURST_MODE:       burst mode, in this case, the dead time is fixed to 50us
//WAIT_PMU_BUSY_WITH_SI_BUSY:       check the PMU busy signal, if PMU is busy, then do not send the effective trigger signal.
//WAIT_PMU_BUSY_WITHOUT_SI_BUSY:    check the PMU busy signal, if PMU is busy, then do not send the effective trigger signal.
//WAIT_TRG_WITH_SI_BUSY:            wait trigger signal in.
//WAIT_TRG_WITHOUT_SI_BUSY:         wait trigger signal in.
//SEND_TRG:         send the trigger singal , the width is equal to 400ns
//SEND_TRG_CHK:     send the trigger id check signal ,if the trigger id is equal to 2^12

always @(c_state or trg_enb_in or cycled_trg_in or ext_trg_syn_in or coincid_trg_in or coincid_trg_in_r or
					trg_chksig_width_cnt or trg_dead_time_cnt or trg_dead_time_in or eff_trg_cnt_in or 
                    busy_syn_in or busy_ignore_in or pmu_busy_in or logic_burst_sel_in)
begin
	n_state = IDLE;
	case (c_state)
		IDLE: begin////wait for the valid trigger source
			if (trg_enb_in) 
				n_state = WAIT_DEAD_TIME;		
			else
				n_state = IDLE;
		end
        WAIT_DEAD_TIME: begin////select different dead time type
            if (logic_burst_sel_in == 2'b11) //burst mode
                n_state = BURST_MODE;
            else if(busy_ignore_in == 1'b1) //ignore Si busy signal
                n_state = IGNORE_SI_BUSY;
            else
                n_state = CHECK_SI_BUSY;
        end
        BURST_MODE: begin////burst mode, dead time is 50us[default],
            if ( trg_dead_time_cnt > {trg_dead_time_prodcut} )
                n_state = WAIT_PMU_BUSY_WITHOUT_SI_BUSY;
            else 
                n_state = BURST_MODE;
        end
        IGNORE_SI_BUSY: begin//ignore si busy,  dead time is fixed to 850us[default]
            if ( trg_dead_time_cnt > {trg_dead_time_prodcut} ) 
                n_state = WAIT_PMU_BUSY_WITHOUT_SI_BUSY;
            else 
                n_state = IGNORE_SI_BUSY;
        end
        CHECK_SI_BUSY: begin//wait for si busy signal to be free
            if ( ~si_busy_sig )  
                n_state = WAIT_PMU_BUSY_WITH_SI_BUSY;
            else 
                n_state = CHECK_SI_BUSY;
        end
        WAIT_PMU_BUSY_WITH_SI_BUSY: begin//wait for PMU busy signal to be free
            if ( ~pmu_busy_in )  
                n_state = WAIT_TRG_WITH_SI_BUSY;
            else 
                n_state = WAIT_PMU_BUSY_WITH_SI_BUSY;
        end
        WAIT_PMU_BUSY_WITHOUT_SI_BUSY: begin//wait for PMU busy signal to be free
            if ( ~pmu_busy_in )  
                n_state = WAIT_TRG_WITHOUT_SI_BUSY;
            else 
                n_state = WAIT_PMU_BUSY_WITHOUT_SI_BUSY;
        end
        WAIT_TRG_WITH_SI_BUSY: begin//wait for PMU busy signal to be free
			if (trg_enb_in&&(~pmu_busy_in)&&(~si_busy_sig)) 
				n_state = ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in)?  SEND_TRG : WAIT_TRG_WITH_SI_BUSY;//coincid_trg_in || ext_trg_syn_in || cycled_trg_in			
			else
				n_state = WAIT_TRG_WITH_SI_BUSY;
        end
        WAIT_TRG_WITHOUT_SI_BUSY: begin//wait for PMU busy signal to be free
			if (trg_enb_in&&(~pmu_busy_in)) 
				n_state = ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in)?  SEND_TRG : WAIT_TRG_WITHOUT_SI_BUSY;//coincid_trg_in || ext_trg_syn_in || cycled_trg_in			
			else
				n_state = WAIT_TRG_WITHOUT_SI_BUSY;
        end
        SEND_TRG: begin//////send the trigger signal
			if (trg_chksig_width_cnt >= (TRG_PULSE_WIDTH-1'b1) )begin
				if (eff_trg_cnt_in[11:0] == 12'b0000_0000_0000)// send the check pulse every 2^12 trigger 
					n_state = SEND_TRG_CHK;
				else
					n_state = IDLE;
			end
			else
				n_state = SEND_TRG;
		end
		SEND_TRG_CHK: begin //send the trigger id check signal
			if (trg_chksig_width_cnt >= (5'd9 + CHK_PULSE_WIDTH))
				n_state = IDLE;
			else 		
				n_state = SEND_TRG_CHK;		
		end	
        default: begin
            n_state = IDLE;
        end
    endcase
end

always @(posedge clk_in) begin
    if(rst_in)
        coincid_trg_in_r <= 1'b0;
    else
        coincid_trg_in_r <= coincid_trg_in;
end

always @(*)begin
    trg_dead_time_temp=0;
    for(i=0; i<20; i=i+1)begin
        if(DEADTIME_UNIT_10MS[i]==1'b1)
            trg_dead_time_temp = trg_dead_time_temp + (trg_dead_time_in << i);
    end
end

always @(posedge clk_in)
begin
    if (rst_in) begin
        trg_send_r <= 1'b0;
        eff_trg_sig <= 1'b0;
        daq_busy_r <= 1'b0;
        trg_chksig_width_cnt <= 8'b0;
        trg_dead_time_cnt <= 20'b0;
    end
    else begin
     case (c_state)
        IDLE: begin
            trg_chksig_width_cnt <= 8'b0;
            trg_dead_time_cnt <= 20'b0;
            trg_send_r <= 1'b0;
            eff_trg_sig <= 1'b0;
            daq_busy_r <= 1'b0;            
        end
        WAIT_DEAD_TIME: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            trg_dead_time_cnt <= 20'b0;
        end
        BURST_MODE: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            if ( trg_dead_time_cnt > {trg_dead_time_prodcut} ) begin  //{trg_dead_time, 16'b0101_0000_0000_0000} ) begin //
                trg_dead_time_cnt <= 20'b0;
                daq_busy_r <= 1'b0;  
            end
            else begin 
                trg_dead_time_cnt <= trg_dead_time_cnt + 1;
            end
        end
        IGNORE_SI_BUSY: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            if ( trg_dead_time_cnt > {trg_dead_time_prodcut} ) begin  //{trg_dead_time, 16'b0101_0000_0000_0000} ) begin //
                trg_dead_time_cnt <= 20'b0;
                daq_busy_r <= 1'b0;  
            end
            else begin 
                trg_dead_time_cnt <= trg_dead_time_cnt + 1;
            end
        end
        CHECK_SI_BUSY: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            trg_dead_time_cnt <= 20'b0;
        end
        WAIT_PMU_BUSY_WITH_SI_BUSY: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            trg_dead_time_cnt <= 20'b0;
        end
        WAIT_PMU_BUSY_WITHOUT_SI_BUSY: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            trg_dead_time_cnt <= 20'b0;
        end
        WAIT_TRG_WITH_SI_BUSY: begin
            if (trg_enb_in&&(~pmu_busy_in)&&(~si_busy_sig))  begin  //
                trg_send_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                eff_trg_sig <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                daq_busy_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in           
            end
            else begin
                trg_send_r <= 1'b0;
                eff_trg_sig <= 1'b0;
                daq_busy_r <= 1'b0;            
            end
        end    
        WAIT_TRG_WITHOUT_SI_BUSY: begin
            if (trg_enb_in&&(~pmu_busy_in))  begin  //
                trg_send_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                eff_trg_sig <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                daq_busy_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in           
            end
            else begin
                trg_send_r <= 1'b0;
                eff_trg_sig <= 1'b0;
                daq_busy_r <= 1'b0;            
            end
        end     
        SEND_TRG: begin///send the trigger signal
            eff_trg_sig <= 1'b0;//just one clock width
            daq_busy_r <= 1'b1;// it is busy     
            if (trg_chksig_width_cnt >= (TRG_PULSE_WIDTH-1'b1)) begin//the width of trigger is 400ns
                trg_send_r <= 1'b0;
                trg_chksig_width_cnt <= 8'b0;
                trg_dead_time_cnt <= 20'b0;
            end
            else begin
                trg_chksig_width_cnt <= trg_chksig_width_cnt + 1;
                trg_send_r <= 1'b1;
            end        
        end
        SEND_TRG_CHK: begin //send the check signal
            eff_trg_sig <= 1'b0; 
            trg_chksig_width_cnt <= trg_chksig_width_cnt + 1;
            trg_dead_time_cnt <= trg_dead_time_cnt + 1;
            if (trg_chksig_width_cnt >= (5'd9 + CHK_PULSE_WIDTH))//0.2us+1us
                trg_send_r <= 1'b0; 
            else if (trg_chksig_width_cnt >= 5'd9)//0.2us gap between the trigger signal and the trigger id check signal
                trg_send_r <= 1'b1;	// trigger id check signal
        end	        
        default: begin
            trg_send_r <= 1'b0;
            eff_trg_sig <= 1'b0;
            daq_busy_r <= 1'b0;
            trg_chksig_width_cnt <= 8'b0;
            trg_dead_time_cnt <= 20'b0;
        end
     endcase
    end
end

assign  trg_dead_time_prodcut = trg_dead_time_temp;
assign  si_busy_sig=busy_syn_in[1]||busy_syn_in[0];//Si1_busy || Si2_busy
assign  eff_trg_out = eff_trg_sig;
assign  trg_out_N_acd_a = ~trg_send_r;
assign  trg_out_N_acd_b = ~trg_send_r;
assign  trg_out_N_CsI_track_a = ~trg_send_r;
assign  trg_out_N_CsI_track_b = ~trg_send_r;
assign  trg_out_N_Si1_a = ~trg_send_r;   //////------xiugai bylxx
assign  trg_out_N_Si1_b = ~trg_send_r;
assign  trg_out_N_Si2_a = ~trg_send_r;
assign  trg_out_N_Si2_b = ~trg_send_r;
assign  trg_out_N_cal_fee_1_a = ~trg_send_r;
assign  trg_out_N_cal_fee_1_b = ~trg_send_r;
assign  trg_out_N_cal_fee_2_a = ~trg_send_r;
assign  trg_out_N_cal_fee_2_b = ~trg_send_r;
assign  trg_out_N_cal_fee_3_a = ~trg_send_r;
assign  trg_out_N_cal_fee_3_b = ~trg_send_r;
assign  trg_out_N_cal_fee_4_a = ~trg_send_r;
assign  trg_out_N_cal_fee_4_b = ~trg_send_r;

endmodule