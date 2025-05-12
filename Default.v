/*----------------------------------------------------------*/
/* 															*/
/*	file name:	Default.v				           			*/
/* 	date:		2025/03/06									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:													*/
/* 															*/
/*----------------------------------------------------------*/

`timescale	1ns / 1ns
`define	CTRL_REG                16'b0000_0000_0000_0000  // control register default value[2:0]
`define	CMD_REG                 16'b0000_0000_0000_0000
`define TRG_MODE_MIP1_REG       16'b0000_0000_0000_0000 // trigger mode register0 value
`define TRG_MODE_MIP2_REG       16'b0000_0000_0000_0000 // trigger mode register1 value
`define TRG_MODE_GM1_REG        16'b0000_0000_0000_0000 // trigger mode register2 value
`define TRG_MODE_GM2_REG        16'b0000_0000_0000_0000 // trigger mode register3 value[6:0]
`define TRG_MODE_UBS_REG        16'b0000_0000_0000_0000 // trigger mode register4 value
`define TRG_MODE_BRST_REG       16'b0000_0000_0000_0000 // trigger mode register4 value
`define HIT_AB_SEL_REG          16'b0000_0000_0000_0000
`define HIT_MASK_REG            16'b0000_0000_0000_0000
`define BUSY_SET_REG            16'b0000_0000_0000_0000
`define HIT_DELAY_WIN_REG       16'b0000_0000_0000_0000
`define HIT_ALIGN_REG_0         16'b0000_0000_0000_0000
`define HIT_ALIGN_REG_1         16'b0000_0000_0000_0000
`define TRG_MATCH_WIN_REG       16'b0000_0000_0000_0000
`define TRG_DEAD_TIME_REG       16'b0000_0000_0000_0000
`define TRG_MODE_OE_REG         16'b0000_0000_0000_0000
`define CYCLE_TRG_PERIOD_REG    16'b0000_0000_0000_0000
`define CYCLE_TRG_NUM_REG       16'b0000_0000_0000_0000
`define EXT_TRG_DELAY           16'b0000_0000_0000_0000