/*----------------------------------------------------------*/
/* 															*/
/*	file name:	fifo.v			                			*/
/* 	date:		2026/01/08 									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		system clock = 50MHz	                    */
/* 															*/
/*----------------------------------------------------------*/
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 7,       // 深度 2^7 = 128
    parameter DEPTH      = 128,
    parameter PROG_FULL_THRESH = 100 // 预设阈值：当数据达到100个时触发
)(
    // 写时钟域
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,
    output wire                  fifo_prog_full, // 新增输出

    // 读时钟域
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output wire [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    // --- 1. 内部信号 ---
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0]   wr_ptr_bin, rd_ptr_bin;
    wire [ADDR_WIDTH:0]  wr_ptr_gray, rd_ptr_gray;
    reg [ADDR_WIDTH:0]   wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    reg [ADDR_WIDTH:0]   rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    // --- 2. 写逻辑 ---
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) 
            wr_ptr_bin <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin + 1;
        end
    end
    assign wr_ptr_gray = (wr_ptr_bin >> 1) ^ wr_ptr_bin;

    // --- 3. 读逻辑 ---
    assign rd_data = mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n)
            rd_ptr_bin <= 0;
        else if (rd_en && !empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end
    assign rd_ptr_gray = (rd_ptr_bin >> 1) ^ rd_ptr_bin;

    // --- 4. 指针同步 (双触发器) ---
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) {rd_ptr_gray_sync1, rd_ptr_gray_sync2} <= 0;
        else {rd_ptr_gray_sync2, rd_ptr_gray_sync1} <= {rd_ptr_gray_sync1, rd_ptr_gray};
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) {wr_ptr_gray_sync1, wr_ptr_gray_sync2} <= 0;
        else {wr_ptr_gray_sync2, wr_ptr_gray_sync1} <= {wr_ptr_gray_sync1, wr_ptr_gray};
    end

    // --- 5. 满空标志 ---
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], 
                                   rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

    // --- 6. prog_full 逻辑 (关键新增) ---
    
    // a. 将同步到写时钟域的读指针(格雷码) 转回 二进制
    wire [ADDR_WIDTH:0] rd_ptr_bin_syncwr;
    generate
        genvar i;
        assign rd_ptr_bin_syncwr[ADDR_WIDTH] = rd_ptr_gray_sync2[ADDR_WIDTH];
        for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin : gray_to_bin
            assign rd_ptr_bin_syncwr[i] = rd_ptr_bin_syncwr[i+1] ^ rd_ptr_gray_sync2[i];
        end
    endgenerate

    // b. 计算当前 FIFO 深度 (写入指针 - 读指针)
    // 即使 wr_ptr_bin 翻转过一次，二进制减法依然能得出正确结果
    wire [ADDR_WIDTH:0] fifo_cnt = wr_ptr_bin - rd_ptr_bin_syncwr;

    // c. 产生 prog_full 信号
    // 建议使用时序逻辑以消除组合逻辑毛刺
    reg prog_full_reg;
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n)
            prog_full_reg <= 1'b0;
        else
            prog_full_reg <= (fifo_cnt >= PROG_FULL_THRESH);
    end
    assign fifo_prog_full = prog_full_reg;

endmodule