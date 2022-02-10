`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2022 03:20:02 PM
// Design Name: 
// Module Name: PC_MOD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC_MOD(
    input clk,
    input clr,
    input pcWrite,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    input [1:0]pcSource,
    output [31:0] data_out
);

wire ground;
wire [31:0]mux_out;
wire [31:0]added;


//4 by 1 mux. Decides the address that goes in the PC module
mux_4t1_nb #(32) pc_data_in(.SEL(pcSource),
                            .D0(data_out + 4), 
                            .D1(jal),
                            .D2(branch),
                            .D3(jalr), 
                            .D_OUT(mux_out));

//This is the program counter(PC) module. It is a register that is 32 bit wide.
reg_nb_sclr #(32) PC(.clk(clk), 
                     .data_in(mux_out), 
                     .clr(clr), 
                     .ld(pcWrite),
                     .data_out(data_out));
endmodule
