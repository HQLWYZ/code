/*----------------------------------------------------------*/
/* 															*/
/*	file name:	ResetGen.v			           			    */
/* 	date:		2025/03/11									*/
/* 	modified:	2026/01/07								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:	system clock = 50MHz                            */
/* 															*/
/*----------------------------------------------------------*/

module ResetGen(
	input           clk_in,         // 
    input			ctrl_rst_in, 	//from FPGA:high 
    input           cmd_rst_in,		//from ConfigReg:high
    output          rst_logic_out,	//"rst_logic_out": reset other modules,except ConfigReg 
    output          rst_intf_out	//"rst_intf_out": reset all modules 
	);
	
reg rst_logic_reg;
reg rst_intf_reg;

always @(posedge clk_in) begin
    rst_logic_reg <= ctrl_rst_in | cmd_rst_in;
    rst_intf_reg  <= ctrl_rst_in;
end

assign rst_logic_out = rst_logic_reg;
assign rst_intf_out  = rst_intf_reg;

endmodule