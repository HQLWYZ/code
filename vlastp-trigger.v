/*--------------------------------------------------------------*/
/* 															    */
/* File name:	vlastp_trigger_top.v		   	            	*/
/* Serial number:	    KX-12A-XX-XXX-XX.v		   	            */
/* File created:		2025/02/13              			    */
/* File modified:		20xx/xx/xx		                	    */
/* Version:		v1.0									    	*/
/* Author:		Wang Shen								    	*/
/* Institute:	Purple Mountain Observatory			        	*/
/* Length:		                                    	    	*/
/* Note:		1. 		                            	    	*/
/* 				2.	                        				    */
/* 															    */
/* Timeline:	1. 2月24号一周，和空间中心讨论接口		          */
/* 				2. 3月底前，完成代码               				 */
/*      		3. 		                            	    	*/
/* 				4.	                        				    */
/* 															    */
/*--------------------------------------------------------------*/

module vlastp_trigger_top (
    input           clk_i,        
    input           rstn_i,       
    input           busy_i,//电控软件“忙”信号
    input           ext_trig_i,//外触发输入
    input   [7:0]   trg_cmd_data_i, //解析卫星指令，读出触发相关命令
    input           trg_stus_fifo_rd_i,//触发状态信息读指令
    input           trg_sci_fifo_rd_i,//触发科学数据包读指令
   //以下是Si忙信号
    input           si_trb_1_buys_a_i,//径迹Si死时间较大，输出busy信号
    input           si_trb_1_buys_b_i,
    input           si_trb_2_buys_a_i,
    input           si_trb_2_buys_b_i,
    //以下是击中信号
    input           acd_fee_top_hit_a_i,//a表示主份备份信号，b表示备份备份信号，下同
    input           acd_fee_top_hit_b_i,
    input           acd_fee_sec_hit_a_i,
    input           acd_fee_sec_hit_b_i,
    input           acd_fee_sid_hit_a_i,
    input           acd_fee_sid_hit_b_i,
    input           csi_fee_hit_a_i,
    input           csi_fee_hit_b_i,
    input           cal_fee_1_hit_a_i,//cal探测器包含主备份，其中fee1和fee3是主份，fee2和fee4是备份
    input           cal_fee_1_hit_b_i,//fee1和fee2负责13个csi bar， fee3和fee4负责12和csi bar
    input           cal_fee_2_hit_a_i,
    input           cal_fee_2_hit_b_i,
    input           cal_fee_3_hit_a_i,
    input           cal_fee_3_hit_b_i,
    input           cal_fee_4_hit_a_i,
    input           cal_fee_4_hit_b_i,
    //以下是输出信号
    output  [7:0]   trg_cmd_addr_o,//触发命令地址
    output  [7:0]   trg_sci_fifo_data_o,//输出科学数据包，与每次的触发命令同步更新
    output  [7:0]   trg_stus_fifo_data_o,//触发状态信息，每4s更新一次
    output          logic_trg_o//触发输出
);



/*----------------------------------------------------------*/
/* 		Synchronize rxd signal										*/
/*----------------------------------------------------------*/
rxd_syn	inst_rxd_syn(
	.clk(clk),
	.rstn(rstn),
	.rxd_in(rxd_in),
	.rxd_syn_out(rxd_syn_sig)
	);   

/*----------------------------------------------------------*/
/* 		command distributer									*/
/*----------------------------------------------------------*/
cmd_distri	inst_cmd_distri(
	.clk(clk),
	.rstn(rstn),
	.rxd_in(rxd_in),
	.rxd_syn_out(rxd_syn_sig)
	);   


endmodule