/*----------------------------------------------------------*/
/*  file name:  TrgSciData.v                                */
/*  date:       2025/04/11                                  */
/*  modified:   2026/03/31 (Fixed High Priority Lint Issues)*/
/*  version:    v1.0                                        */
/*  author:     Wang Shen                                   */
/*  email:      wangshen@pmo.ac.cn                          */
/*  note:       system clock = 50MHz                        */
/*----------------------------------------------------------*/
//`include "crc16_ccitt.v"

module TrgSciData
(
    input           clk_in,
    input           rst_in,
    input           data_trans_enb_sig,
    input           fifo_rd_clk,
    input           fifo_rd_in,  
    input   [47:0]  pmu_time_tag_in,
    input   [15:0]  cmd_reg_in,
    input   [7:0]   logic_grp_oe_in,    //TrgModeOEReg
    input   [15:0]  hit_sig_stus_in,     //hit status when raw trigger generated
    input   [4:0]   W_logic_all_grp_result_in,
    input   [7:0]   trg_mode_mip1_in, 
    input   [7:0]   trg_mode_mip2_in,
    input   [7:0]   trg_mode_gm1_in,
    input   [7:0]   trg_mode_gm2_in,
    input   [7:0]   trg_mode_ubs_in,
    input   [15:0]  eff_trg_cnt_in,
    input           eff_trg_in,// trigger sources, when trigger happens, trigger sci-data will be written into the FIFO
    input           trg_sig_end_flag,
    input   [23:0]  trg_busy_time_cnt_in,
    output  [7:0]   fifo_data_out,
    output          fifo_prog_full_out,
    output          fifo_empty_out
);

reg     [223:0]     sci_data_reg;
reg     [15:0]      hit_sig_stus_reg;
reg     [15:0]      logic_grp_sel_reg;
reg     [15:0]      sel_bit_reg; //select which trigger settings was enabled
reg     [15:0]      frame_cnt_reg; 
wire    [15:0]      frame_length;
reg     [47:0]      time_code;
reg     [7:0]       pre_scale_1_reg;//[H: MIPS1_div, L: MIPS2_div]
reg     [7:0]       pre_scale_2_reg;//[H: UBS_div, L: backup]
reg     [7:0]       trg_logic_out_reg;
wire    [3:0]       module_tag, sci_data_type;
reg     [3:0]       sci_data_type_reg;
reg     [15:0]      eff_trg_cnt_reg;//count the time interval between two triggers, unit is 1us, max time interval is about 65ms

wire                fifo_prog_full;
wire                crc_rst;

parameter   TRG_TIME_TAG_UNIT_1US = 50; //50*20ns = 1us

//----------TBD, 20260312-------------
assign frame_length = 16'd24; 
assign module_tag = 4'h9;
assign sci_data_type = sci_data_type_reg;
//----------TBD, 20260312-------------

reg [15:0] trg_time_tag_cnt_reg;//count the time interval between two triggers, unit is 1us, max time interval is about 65ms


always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        time_code <= 48'd0;
    end 
    else begin
        time_code <= pmu_time_tag_in;
    end
end

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        sci_data_type_reg <= 4'd0;      
    end 
    else begin
        if(cmd_reg_in[7]) begin
            if(cmd_reg_in[4])
                sci_data_type_reg <= 4'h1; //coincidence trigger
            else if(cmd_reg_in[5])
                sci_data_type_reg <= 4'h2; //external trigger
            else if(cmd_reg_in[6])
                sci_data_type_reg <= 4'h3; //cycled trigger
            else
                sci_data_type_reg <= 4'h0; //invalid trigger
        end
        else
            sci_data_type_reg <= 4'h0; //invalid trigger
    end
end




reg  [23:0] trg_busy_time_cnt_delay;
reg  [23:0] trg_busy_time_cnt_reg;
reg [23:0] delay_d1;
reg [23:0] delay_d2;
reg [23:0] delay_d3;
reg [23:0] delay_d4;
reg [23:0] delay_d5;
reg [23:0] delay_d6;

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        delay_d1              <= 24'd0;
        delay_d2              <= 24'd0;
        delay_d3              <= 24'd0;
        delay_d4              <= 24'd0;
        delay_d5              <= 24'd0;
        delay_d6              <= 24'd0;
        trg_busy_time_cnt_delay <= 24'd0;
    end 
    else begin
        delay_d1              <= trg_busy_time_cnt_in; 
        delay_d2              <= delay_d1;             
        delay_d3              <= delay_d2;            
        delay_d4              <= delay_d3; 
        delay_d5              <= delay_d4;  
        delay_d6              <= delay_d5;          
        trg_busy_time_cnt_delay <= delay_d6;            
    end
end



reg[2:0] c_state, n_state;
reg [4:0] wr_fifo_cnt; //count the number of data written into the FIFO

wire [7:0]  sci_data_out;
wire fifo_empty, fifo_full;

reg [7:0] sci_data_in;
wire fifo_wr_in;
reg write_fifo_done;
wire [15:0] crc_in;
reg crc_en;
wire crc_rst_en;
wire[15:0] crc_out;
reg [15:0]  sum_reg;


reg [5:0] cycle_cnt;
reg [15:0] wait_time_tag_cnt;

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        cycle_cnt <= 6'd0;
        trg_time_tag_cnt_reg    <= 16'd0;
    end 
    else begin
        if (cycle_cnt == 6'd49) begin
            cycle_cnt <= 6'd0;       // 
            trg_time_tag_cnt_reg    <= trg_time_tag_cnt_reg + 1'b1; // 
        end 
        else begin
            cycle_cnt <= cycle_cnt + 1'b1;
        end
    end
end


always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
            eff_trg_cnt_reg <= 16'd0;
    end 
    else begin
            eff_trg_cnt_reg <= eff_trg_cnt_in-1'b1; //make sure the trigger id start from 0
    end
end



parameter   IDLE = 0, 
            WAIT_TIME_TAG = 1,
            TRIG_IN=2,
            TRIG_DATA_READY=3,
            WRITE_FIFO_START = 4, 
            WRITE_DONE = 5;

always @(posedge clk_in or posedge rst_in)
begin
    if (rst_in)
        c_state <= IDLE;
    else 
        c_state <= n_state; 
end

always @(c_state  or eff_trg_in or wr_fifo_cnt or fifo_full or data_trans_enb_sig or wait_time_tag_cnt)
begin
    n_state = IDLE; //default value
    case(c_state)
        IDLE: begin
            if (eff_trg_in & data_trans_enb_sig)   
                n_state = WAIT_TIME_TAG;
            else 
                n_state = IDLE;         
        end
        WAIT_TIME_TAG: begin
            if (wait_time_tag_cnt==16'd25)   //wait for the time tag to be updated, which means the time interval between two triggers is at least 1ms, then accept the next trigger
                n_state = TRIG_IN;
            else 
                n_state = WAIT_TIME_TAG;            
        end
        TRIG_IN: begin
                n_state = TRIG_DATA_READY;          
        end
        TRIG_DATA_READY: begin
            if (fifo_full == 1'b0)   
                n_state = WRITE_FIFO_START;
            else 
                n_state = TRIG_DATA_READY;          
        end
        WRITE_FIFO_START: begin
            if ((wr_fifo_cnt == 5'd31) && (fifo_full == 1'b0))   
                n_state = WRITE_DONE;
            else 
                n_state = WRITE_FIFO_START;         
        end
        WRITE_DONE: begin
                n_state = IDLE;
        end
        default: begin
                n_state = IDLE;
        end
    endcase 
end

////////////coincidence process
always @(posedge clk_in or posedge rst_in)
begin
    if (rst_in) begin
        sci_data_reg<= 224'd0;
        wr_fifo_cnt<= 5'b0;
        crc_en <= 1'b0;
        sum_reg <= 16'd0;
        frame_cnt_reg <= 16'd0;
        wait_time_tag_cnt <= 16'd0;
        trg_logic_out_reg<= 8'b0;
        pre_scale_1_reg<= 8'b0;
        pre_scale_2_reg<= 8'b0;
        hit_sig_stus_reg <= 16'b0;
        trg_busy_time_cnt_reg<=24'd0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            sum_reg <= 16'd0;
            crc_en <= 1'b0;
            wait_time_tag_cnt <= 16'd0;
            trg_logic_out_reg<= 8'b0;
            pre_scale_1_reg<= 8'b0;
            pre_scale_2_reg<= 8'b0;
            hit_sig_stus_reg <= 16'b0;
            trg_busy_time_cnt_reg<=24'd0;
         end
         WAIT_TIME_TAG: begin
            if(wait_time_tag_cnt==16'd25)
                wait_time_tag_cnt <= 16'd0;
            else if (wait_time_tag_cnt==16'd5) begin
                trg_logic_out_reg<= {3'b0, W_logic_all_grp_result_in}& logic_grp_oe_in;
                hit_sig_stus_reg <= hit_sig_stus_in;
                wait_time_tag_cnt <= wait_time_tag_cnt + 1'b1;
                trg_busy_time_cnt_reg<=trg_busy_time_cnt_delay;
            end
            else
                wait_time_tag_cnt <= wait_time_tag_cnt + 1'b1;
         end
         TRIG_IN: begin
            frame_cnt_reg <= frame_cnt_reg + 1'b1;
            wait_time_tag_cnt <= 16'd0;
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            sum_reg <= 16'd0;
            pre_scale_1_reg <= {trg_mode_mip1_in[3:0], trg_mode_mip2_in[3:0]};
            pre_scale_2_reg <= {trg_mode_ubs_in[3:0], 4'b0};
         end
        TRIG_DATA_READY: begin
            sci_data_reg<={16'hEB90, frame_cnt_reg, frame_length, time_code, pre_scale_1_reg, module_tag, sci_data_type,
                        8'b0, logic_grp_oe_in, hit_sig_stus_reg, 8'b0, trg_logic_out_reg, eff_trg_cnt_in, 
                        trg_busy_time_cnt_reg, pre_scale_2_reg, trg_time_tag_cnt_reg};
         end
         WRITE_FIFO_START: begin
            sci_data_reg<=(sci_data_reg<<8);
            wr_fifo_cnt<=wr_fifo_cnt+1'b1;
            
            if((wr_fifo_cnt == 5'd11) || (wr_fifo_cnt == 5'd13) || (wr_fifo_cnt == 5'd15) || (wr_fifo_cnt == 5'd17) 
            || (wr_fifo_cnt == 5'd19) || (wr_fifo_cnt == 5'd21) || (wr_fifo_cnt == 5'd23) || (wr_fifo_cnt == 5'd25))
                crc_en <= 1'b1;
            else
                crc_en <= 1'b0;
                
            if((wr_fifo_cnt[0] == 1'b0) && (wr_fifo_cnt <= 5'd26))
                sum_reg <= sum_reg + sci_data_reg[223:208];
            if(wr_fifo_cnt == 5'd28)   
                sum_reg <= sum_reg + crc_out;
         end
         WRITE_DONE: begin
            sci_data_reg<= 224'b0;
            wr_fifo_cnt<= 5'b0;
            crc_en <= 1'b0;
         end
         default: begin
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            crc_en <= 1'b0;
            sum_reg <= 16'd0;
            frame_cnt_reg <= 16'd0;
            trg_logic_out_reg<= 8'b0;
            pre_scale_1_reg<= 8'b0;
            pre_scale_2_reg<= 8'b0;
            end
        endcase
    end
end

assign fifo_wr_in = ((c_state == WRITE_FIFO_START) && (fifo_full == 1'b0)) ? 1'b1 : 1'b0;

assign crc_rst_en = (c_state == IDLE) ? 1'b1 : 1'b0;
assign crc_rst = rst_in | crc_rst_en;

always@(*)
    case(c_state)
        WRITE_FIFO_START:
            if(wr_fifo_cnt<=5'd27)
                sci_data_in = sci_data_reg[223:216];
            else if(wr_fifo_cnt==5'd28)
                sci_data_in = crc_out[15:8];
            else if(wr_fifo_cnt==5'd29) 
                sci_data_in = crc_out[7:0];
            else if(wr_fifo_cnt==5'd30)
                sci_data_in = sum_reg[15:8];
            else if(wr_fifo_cnt==5'd31)
                sci_data_in = sum_reg[7:0];
            else
                sci_data_in = 8'd0;
        default:
            sci_data_in = 8'd0;
    endcase

assign crc_in = sci_data_reg[223:208];

//crc_16    
crc16_ccitt crc16_ccitt_inst(
  .data_in(crc_in),
  .crc_en(crc_en),
  .crc_out(crc_out),
  .rst(crc_rst),
  .clk(clk_in)
);


wire fifo_wr_rst_n_sig = ~rst_in;
wire fifo_rd_rst_n_sig = ~rst_in;

// fifo_generator_0 fifo_generator_0_inst
// (
// 	.rst(rst_in),
// 	.wr_clk(clk_in),
// 	.rd_clk(fifo_rd_clk),
// 	.din(sci_data_in),
// 	.rd_en(fifo_rd_in),
// 	.wr_en(fifo_wr_in),
// 	.prog_full_thresh(9'h20),
// 	.dout(sci_data_out),
// 	.empty(fifo_empty),
// 	.full(fifo_full),
// 	.prog_full(fifo_prog_full)
// );
fifo fifo_inst
(
    .wr_clk(clk_in),
    .wr_rst_n(fifo_wr_rst_n_sig), 
    .wr_en(fifo_wr_in),
    .wr_data(sci_data_in),
    .full(fifo_full),
    .fifo_prog_full(fifo_prog_full),
    .rd_clk(fifo_rd_clk),
    .rd_rst_n(fifo_rd_rst_n_sig), 
    .rd_en(fifo_rd_in),
    .rd_data(sci_data_out),
    .empty(fifo_empty)
);

assign fifo_data_out = sci_data_out;
assign fifo_empty_out = fifo_empty;
assign fifo_prog_full_out = fifo_prog_full;

endmodule