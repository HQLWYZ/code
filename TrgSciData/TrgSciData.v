/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgSciData.v			           			*/
/* 	date:		2025/04/11									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/

module TrgSciData(
	input	        clk_in,
	input			rst_in_N,
    input           fifo_rd_in,  
    //----select one mode that drive the trigger signal
    input   [15:0]  trg_mode_mip1_in,
    input   [15:0]  trg_mode_mip2_in,
    input   [15:0]  trg_mode_gm1_in,
    input   [15:0]  trg_mode_gm2_in,
    input   [15:0]  trg_mode_ubs_in,
    input   [15:0]  trg_mode_brst_in,
    input   [15:0]  hit_sig_stus_in, //hit status when raw trigger generated, new
    input   [15:0]  eff_trg_cnt_in,
    input   [23:0]  trg_busy_time_cnt_in,
    input           trg_busy_timer_rdy_in,
    input           coincid_trg_in,// trigger sources, when trigger happens, trigger sci-data will be written into the FIFO
    output  [15:0]  fifo_data_out,
    output          fifo_empty_out,
    output          fifo_full_out
	);
	

reg [255:0]  sci_data_reg;
reg [15:0]  logic_grp_sel_reg;
reg [15:0]  sel_bit_reg; //select which trigger settings was enabled


always @(posedge clk_in or negedge rst_in_N)
begin
	if (!rst_in_N) begin
        sel_bit_reg<= 16'b0;
	end
	else  begin //
        sel_bit_reg[15:14] <= trg_mode_mip1_in[7:6];
        sel_bit_reg[13:12] <= trg_mode_mip2_in[7:6];
        sel_bit_reg[11:10] <= trg_mode_gm1_in[7:6];
        sel_bit_reg[9:8] <= trg_mode_gm2_in[7:6];
        sel_bit_reg[7:6] <= trg_mode_ubs_in[7:6];
        sel_bit_reg[5:4] <= trg_mode_brst_in[7:6];
	end
end

always @(posedge clk_in or negedge rst_in_N) //select which trigger settings was enabled
begin
	if (!rst_in_N) begin
        logic_grp_sel_reg<= 16'b0;
	end
	else  begin 
       case (sel_bit_reg)
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
reg [7:0] wr_fifo_cnt; //count the number of data written into the FIFO


wire [15:0]  sci_data_out;
wire fifo_empty, fifo_full;

reg [15:0] sci_data_in;
reg fifo_wr_in;
reg write_fifo_done;


parameter   IDLE = 0, 
            TRIGGER_IN = 1, 
            //SET_PARAMETERS = 2, 
            WRITE_FIFO_START = 3, 
            WRITE_DONE = 4;

always @(posedge clk_in or negedge rst_in_N)
begin
	if (!rst_in_N)
		c_state <= IDLE;
	else 
		c_state <= n_state;	
end

always @(c_state or coincid_trg_in or wr_fifo_cnt)
begin
	n_state = IDLE; //default value
	case(c_state)
		IDLE: begin
			if (coincid_trg_in)   //
				n_state = TRIGGER_IN;
			else 
				n_state = IDLE;			
		end
		WRITE_FIFO_START: begin
			if (wr_fifo_cnt ==8'd16)   //
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
always @(posedge clk_in or negedge rst_in_N)
begin
	if (!rst_in_N) begin
        sci_data_reg<= 256'b0;
        fifo_wr_in<= 1'b0;
        wr_fifo_cnt<= 8'b0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            sci_data_reg<= 256'b0;
            fifo_wr_in<= 1'b0;
            wr_fifo_cnt<= 8'b0;
         end
         WRITE_FIFO_START: begin
            sci_data_reg<={184'b0, logic_grp_sel_reg, hit_sig_stus_in, eff_trg_cnt_in,trg_busy_time_cnt_in};
            fifo_wr_in<=1'b1;
            if(~fifo_full) begin
                sci_data_reg<=(sci_data_reg<<16);
                sci_data_in<=sci_data_reg[255:240];
                wr_fifo_cnt<=wr_fifo_cnt+1'b1;
            end
         end
         WRITE_DONE: begin
            sci_data_reg<= 256'b0;
            fifo_wr_in<= 1'b0;
            wr_fifo_cnt<= 8'b0;
         end
         default: begin
            sci_data_reg<= 256'b0;
            fifo_wr_in<= 1'b0;
            wr_fifo_cnt<= 8'b0;
         end
        endcase
    end
	
end


sci_fifo inst_sci_fifo(
	.clk(clk_in),
	.din(sci_data_in),
	.rd_en(fifo_rd_in),
	.rst(rst_in_N),
	.wr_en(fifo_wr_in),
	.dout(sci_data_out),
	.empty(fifo_empty),
	.full(fifo_full)
    );

assign fifo_data_out = sci_data_out;
assign fifo_empty_out = fifo_empty;
assign fifo_full_out = fifo_full;

endmodule
