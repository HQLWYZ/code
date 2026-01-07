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
	input			ctrl_rst_in, 	//from FPGA:high 
    input           cmd_rst_in,		//from ConfigReg:high
    output          rst_logic_out,	//"rst_logic_out": reset other modules,except ConfigReg 
    output          rst_intf_out	//"rst_intf_out": reset the modules of ConfigReg 
	);
	

assign	rst_logic_out = ctrl_rst_in | cmd_rst_in;
assign	rst_intf_out = ctrl_rst_in;


endmodule