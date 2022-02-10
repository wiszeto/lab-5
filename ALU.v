`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2022 02:43:28 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0]OP_1,
    input [31:0]OP_2,
    input [3:0] alu_fun,
    output reg [31:0] result
    );
    
    always @ (*)
    begin
        case(alu_fun)
            0: result = OP_1 + OP_2; //add
            1: result = OP_1 << OP_2[4:0]; //shift left logic
            2: result = ($signed(OP_1) < $signed(OP_2)); //set if less than signed
            3: result = (OP_1 < OP_2); //set if less than unsigned
            4: result = OP_1 ^ OP_2; //XOR
            5: result = OP_1 >> OP_2[4:0]; //Shift right logic
            6: result = OP_1 | OP_2; //OR
            7: result =  OP_1 & OP_2; //AND
            8: result = OP_1 - OP_2; //substract
            9: result = OP_1; // load upper immediate 
            13: result = $signed(OP_1) >>> $signed(OP_2[4:0]); //shift right arithmetic
            default result = 'h0xdeadbeef;
        endcase
   end
    
endmodule
