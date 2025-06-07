/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgSciData.v			           			*/
/* 	date:		2025/04/11									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module TrgSciData
(
	input	        clk_in,
	input			rst_in,
	input           data_trans_enb_sig,
	input           fifo_rd_clk,
    input           fifo_rd_in,  
    //----select one mode that drive the trigger signal
    input   [7:0]  trg_mode_mip1_in, 
    input   [7:0]  trg_mode_mip2_in,
    input   [7:0]  trg_mode_gm1_in,
    input   [7:0]  trg_mode_gm2_in,
    input   [7:0]  trg_mode_ubs_in,
    input   [7:0]  trg_mode_brst_in,
    input   [15:0]  hit_sig_stus_in, //hit status when raw trigger generated, new
    input   [15:0]  eff_trg_cnt_in,
    input   [23:0]  trg_busy_time_cnt_in,
    input   [7:0]   trg_delay_timer_in,
    input           trg_busy_timer_rdy_in,
    input           eff_trg_in,// trigger sources, when trigger happens, trigger sci-data will be written into the FIFO
    output  [7:0]  fifo_data_out,
    output          fifo_empty_out
);

reg [143:0]  sci_data_reg;
reg [15:0]  logic_grp_sel_reg;
reg [15:0]  sel_bit_reg; //select which trigger settings was enabled


always @(posedge clk_in or negedge rst_in)
begin
	if (!rst_in) begin
        sel_bit_reg<= 16'b0;
	end
	else  begin 
        sel_bit_reg[15:14] <= trg_mode_mip1_in[7:6];
        sel_bit_reg[13:12] <= trg_mode_mip2_in[7:6];
        sel_bit_reg[11:10] <= trg_mode_gm1_in[7:6];
        sel_bit_reg[9:8] <= trg_mode_gm2_in[7:6];
        sel_bit_reg[7:6] <= trg_mode_ubs_in[7:6];
        sel_bit_reg[5:4] <= trg_mode_brst_in[7:6];
	end
end

always @(posedge clk_in or negedge rst_in) //select which trigger settings was enabled
begin
	if (!rst_in) begin
        logic_grp_sel_reg<= 16'b0;
	end
	else  begin 
       casex (sel_bit_reg)
            16'b01xx_xxxx_xxxx_xxxx: logic_grp_sel_reg <= {8'b1000_0000, trg_mode_mip1_in};
            16'bxx01_xxxx_xxxx_xxxx: logic_grp_sel_reg <= {8'b0100_0000, trg_mode_mip2_in}; 
            16'bxxxx_01xx_xxxx_xxxx: logic_grp_sel_reg <= {8'b0010_0000, trg_mode_gm1_in};
            16'bxxxx_xx01_xxxx_xxxx: logic_grp_sel_reg <= {8'b0001_0000, trg_mode_gm2_in};
            16'bxxxx_xxxx_01xx_xxxx: logic_grp_sel_reg <= {8'b0000_1000, trg_mode_ubs_in};
            16'bxxxx_xxxx_xx01_xxxx: logic_grp_sel_reg <= {8'b0000_0100, trg_mode_brst_in};
        default: logic_grp_sel_reg <= 16'b0;
    endcase
	end
end

reg[2:0] c_state, n_state;
reg [4:0] wr_fifo_cnt; //count the number of data written into the FIFO

wire [7:0]  sci_data_out;
wire fifo_empty, fifo_full;

reg [7:0] sci_data_in;
wire fifo_wr_in;
reg write_fifo_done;
reg crc_en;
wire crc_rst_en;
wire[15:0] crc_out;

parameter  IDLE = 0, 
            WRITE_FIFO_START = 1, 
            WRITE_DONE = 2;

always @(posedge clk_in or negedge rst_in)
begin
	if (!rst_in)
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
				n_state = WRITE_FIFO_START;
			else 
				n_state = IDLE;			
		end
		WRITE_FIFO_START: begin
			if ((wr_fifo_cnt ==5'd19) && (!fifo_full))   
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
always @(posedge clk_in or negedge rst_in)
begin
	if (!rst_in) begin
        sci_data_reg<= 144'b0;
        wr_fifo_cnt<= 5'b0;
        crc_en <= 1'b0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            sci_data_reg<= 144'b0;
            wr_fifo_cnt<= 5'b0;
            sci_data_reg<={16'hEB90, 16'h0000, logic_grp_sel_reg, hit_sig_stus_in, 16'h0000, eff_trg_cnt_in, trg_busy_time_cnt_in, 
            trg_delay_timer_in, 16'h000000};
         end
         WRITE_FIFO_START: begin
            if(~fifo_full) begin
                sci_data_reg<=(sci_data_reg<<8);
                wr_fifo_cnt<=wr_fifo_cnt+1'b1;
                if((wr_fifo_cnt >= 5'd1) && (wr_fifo_cnt <= 5'd16))
                    crc_en <= 1'b1;
                else
                    crc_en <= 1'b0;
            end
            else
            begin
                crc_en <= 1'b0;
            end
         end
         WRITE_DONE: begin
            sci_data_reg<= 144'b0;
            wr_fifo_cnt<= 5'b0;
            crc_en <= 1'b0;
         end
         default: begin
            sci_data_reg<= 144'b0;
            wr_fifo_cnt<= 5'b0;
         end
        endcase
    end
end

assign fifo_wr_in = ((c_state == WRITE_FIFO_START) && (~fifo_full))? 1'b1:1'b0;

assign crc_rst_en = (c_state == IDLE)? 1'b1:1'b0;
assign crc_rst = ~(~rst_in | crc_rst_en);

always@(*)
    case(c_state)
        WRITE_FIFO_START:
            if(wr_fifo_cnt<=5'd17)
                sci_data_in = sci_data_reg[143:136];
            else if(wr_fifo_cnt==5'd18)
                sci_data_in = crc_out[15:8];
            else if(wr_fifo_cnt==5'd19) 
                sci_data_in = crc_out[7:0];
            else
                sci_data_in = 8'd0;
        default:
            sci_data_in = 8'd0;
    endcase

//crc_16	
crc_16 crc_16_inst(
  .crc_data_in(sci_data_in),
  .crc_en(crc_en),
  .crc_out(crc_out),
  .rst(crc_rst),
  .clk(clk_in)
);

fifo_generator_0 fifo_generator_0_inst
(
	.wr_clk(clk_in),
	.rd_clk(fifo_rd_clk),
	.din(sci_data_in),
	.rd_en(fifo_rd_in),
	.wr_en(fifo_wr_in),
	.dout(sci_data_out),
	.empty(fifo_empty),
	.full(fifo_full)
);

assign fifo_data_out = sci_data_out;
assign fifo_empty_out = fifo_empty;

endmodule
