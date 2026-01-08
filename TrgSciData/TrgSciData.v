/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgSciData.v			           			*/
/* 	date:		2025/04/11									*/
/* 	modified:	2026/01/08								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/
//`include "crc16_ccitt.v"

module TrgSciData
(
	input	        clk_in,
	input			rst_in,
	input           data_trans_enb_sig,
	input           fifo_rd_clk,
    input           fifo_rd_in,  
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
    output  [7:0]   fifo_data_out,
    output          fifo_prog_full_out,
    output          fifo_empty_out
);

reg [223:0]     sci_data_reg;
reg [15:0]      logic_grp_sel_reg;
reg [15:0]      sel_bit_reg; //select which trigger settings was enabled
reg  [15:0]     frame_cnt_reg; 
wire [15:0]     frame_length;
wire [47:0]     time_code;
wire [7:0]      sci_data_tag;
wire [3:0]      module_tag, sci_data_type;

assign frame_length = 16'd32, time_code = 48'h00_0000; 
assign sci_data_tag = 8'h00, module_tag = 4'h0,  sci_data_type = 4'h0;

reg [23:0] trg_busy_time_cnt_reg;



//generate trg_logic_out_reg
reg [7:0]   trg_logic_out_reg;
reg [5:0]   coincid_div_reg;

always @(posedge clk_in)
begin
	if (rst_in) begin
        trg_logic_out_reg<= 8'b0;
        coincid_div_reg<= 6'b0;
	end
	else  begin 
        if(W_logic_all_grp_result_in[4]&& eff_trg_in)   begin
            trg_logic_out_reg<= 8'b0001_0000;
            coincid_div_reg<=trg_mode_ubs_in[5:0];
        end
        else if(W_logic_all_grp_result_in[3]&& eff_trg_in) begin
            trg_logic_out_reg<= 8'b0000_1000;
            coincid_div_reg<=trg_mode_gm2_in[5:0];
        end
        else if(W_logic_all_grp_result_in[2]&& eff_trg_in)  begin
            trg_logic_out_reg<= 8'b0000_0100;
            coincid_div_reg<=trg_mode_gm1_in[5:0];
        end
        else if(W_logic_all_grp_result_in[1]&& eff_trg_in) begin
            trg_logic_out_reg<= 8'b0000_0010;
            coincid_div_reg<=trg_mode_mip2_in[5:0];
        end
        else if(W_logic_all_grp_result_in[0]&& eff_trg_in) begin
            trg_logic_out_reg<= 8'b0000_0001;
            coincid_div_reg<=trg_mode_mip1_in[5:0];
        end
        else    begin
            trg_logic_out_reg<= 8'b0000_0000;
            coincid_div_reg<= 6'b0;
        end
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

parameter   IDLE = 0, 
            TRIG_IN=1,
            WRITE_FIFO_START = 2, 
            WRITE_DONE = 3;

always @(posedge clk_in)
begin
	if (rst_in)
		c_state <= IDLE;
	else 
		c_state <= n_state;	
end

always @(c_state or eff_trg_in or wr_fifo_cnt or fifo_full or data_trans_enb_sig)
begin
	n_state = IDLE; //default value
	case(c_state)
		IDLE: begin
			if (eff_trg_in & data_trans_enb_sig)   
				n_state = TRIG_IN;
			else 
				n_state = IDLE;			
		end
        TRIG_IN: begin
			if (~fifo_full)   
				n_state = WRITE_FIFO_START;
			else 
				n_state = TRIG_IN;			
		end
		WRITE_FIFO_START: begin
			if ((wr_fifo_cnt ==5'd31) && (!fifo_full))   
				n_state = WRITE_DONE;
			else 
				n_state = WRITE_FIFO_START;			
		end
        WRITE_DONE: begin
				n_state = IDLE;
		
		end
	endcase	
end

////////////coincidence process
always @(posedge clk_in)
begin
	if (rst_in) begin
        sci_data_reg<= 224'd0;
        wr_fifo_cnt<= 5'b0;
        crc_en <= 1'b0;
        sum_reg <= 16'd0;
        frame_cnt_reg <= 16'd0;
        trg_busy_time_cnt_reg <= 24'd0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            sum_reg <= 16'd0;
            trg_busy_time_cnt_reg<= trg_busy_time_cnt_reg+1'b1;
         end

         TRIG_IN: begin
            frame_cnt_reg <= frame_cnt_reg + 1'b1;
            trg_busy_time_cnt_reg<= trg_busy_time_cnt_reg+1'b1;
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            sci_data_reg<={16'hEB90, frame_cnt_reg, frame_length, time_code, sci_data_tag, module_tag, sci_data_type,
                        8'b0, logic_grp_oe_in, hit_sig_stus_in, 8'b0, trg_logic_out_reg, eff_trg_cnt_in, 
                        trg_busy_time_cnt_reg, 2'b0, coincid_div_reg, 16'b0};
            sum_reg <= 16'd0;
         end

         WRITE_FIFO_START: begin
            sci_data_reg<=(sci_data_reg<<8);
            wr_fifo_cnt<=wr_fifo_cnt+1'b1;
            trg_busy_time_cnt_reg<= trg_busy_time_cnt_reg+1'b1;
            if((wr_fifo_cnt == 5'd11) | (wr_fifo_cnt == 5'd13) | (wr_fifo_cnt == 5'd15) | (wr_fifo_cnt == 5'd17) 
            | (wr_fifo_cnt == 5'd19) | (wr_fifo_cnt == 5'd21) | (wr_fifo_cnt == 5'd23) | (wr_fifo_cnt == 5'd25))
                crc_en <= 1'b1;
            else
                crc_en <= 1'b0;
            if((wr_fifo_cnt[0] == 1'b0) & (wr_fifo_cnt <= 5'd26))
                sum_reg <= sum_reg + sci_data_reg[223:208];
            if(wr_fifo_cnt == 5'd28)   
                sum_reg <= sum_reg + crc_out;
         end
         WRITE_DONE: begin
            sci_data_reg<= 224'b0;
            wr_fifo_cnt<= 5'b0;
            crc_en <= 1'b0;
            trg_busy_time_cnt_reg<= trg_busy_time_cnt_reg+1'b1;
         end
         default: begin
            sci_data_reg<= 224'd0;
            wr_fifo_cnt<= 5'b0;
            crc_en <= 1'b0;
            sum_reg <= 16'd0;
            frame_cnt_reg <= 16'd0;
            trg_busy_time_cnt_reg <= 24'd0;
            end
        endcase
    end
end

assign fifo_wr_in = ((c_state == WRITE_FIFO_START) && (~fifo_full))? 1'b1:1'b0;

assign crc_rst_en = (c_state == IDLE)? 1'b1:1'b0;
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

// fifo_generator_0 fifo_generator_0_inst
// (
// //	.rst(rst_in),
// 	.wr_clk(clk_in),
// 	.rd_clk(fifo_rd_clk),
// 	.din(sci_data_in),
// 	.rd_en(fifo_rd_in),
// 	.wr_en(fifo_wr_in),
// 	.prog_full_thresh(9'h14),
// 	.dout(sci_data_out),
// 	.empty(fifo_empty),
// 	.full(fifo_full),
// 	.prog_full(fifo_prog_full)
// );

fifo fifo_inst
(
    .wr_clk(clk_in),
    .wr_rst_n(~rst_in),
    .wr_en(fifo_wr_in),
    .wr_data(sci_data_in),
    .full(fifo_full),
    .fifo_prog_full(fifo_prog_full),
    .rd_clk(fifo_rd_clk),
    .rd_rst_n(~rst_in),
    .rd_en(fifo_rd_in),
    .rd_data(sci_data_out),
    .empty(fifo_empty)
);


assign fifo_data_out = sci_data_out;
assign fifo_empty_out = fifo_empty;
assign fifo_prog_full_out = fifo_prog_full;

endmodule
