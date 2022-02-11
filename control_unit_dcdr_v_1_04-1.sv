`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// CU_DCDR my_cu_dcdr(
//   .br_eq     (), 
//   .br_lt     (), 
//   .br_ltu    (),
//   .opcode    (),    //-  ir[6:0]
//   .func7     (),    //-  ir[30]
//   .func3     (),    //-  ir[14:12] 
//   .alu_fun   (),
//   .pcSource  (),
//   .alu_srcA  (),
//   .alu_srcB  (), 
//   .rf_wr_sel ()   );
//
// 
// Revision:
// Revision 1.00 - File Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed unneeded else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_DCDR(
    input br_eq, 
	input br_lt, 
	input br_ltu,
    input [6:0] opcode,   //-  ir[6:0]
	input func7,          //-  ir[30]
    input [2:0] func3,    //-  ir[14:12] 
    output logic [3:0] alu_fun,
    output logic [1:0] pcSource,
    output logic alu_srcA,
    output logic [1:0] alu_srcB, 
	output logic [1:0] rf_wr_sel   );
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;    
    func3_t FUNC3; //- define variable of new opcode type
    
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
       
    always_comb
    begin 
        //- schedule all values to avoid latch
		pcSource = 2'b00;  alu_srcB = 2'b00;    rf_wr_sel = 2'b00; 
		alu_srcA = 1'b0;   alu_fun  = 4'b0000;
		
		case(OPCODE)
			LUI:
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 1'b1; 
				alu_srcB = 2'b01;
				rf_wr_sel = 2'b11; 
			end
			
			JAL:
			begin
			    pcSource = 2'b11;
				rf_wr_sel = 2'b00; 
			end
			
			LOAD: 
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 1'b0; 
				alu_srcB = 2'b01; 
				rf_wr_sel = 2'b10; 
			end
			
			STORE:
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 1'b0; 
				alu_srcB = 2'b10; 
			end
			
			OP_IMM:
			begin
				case(FUNC3)
					3'b000: // instr: ADDI
					begin
						alu_fun = 4'b0000;
						alu_srcA = 1'b0; 
						alu_srcB = 2'b01;
						rf_wr_sel = 2'b11; 
					end
					
					default: 
					begin
						pcSource = 2'b00; 
						alu_fun = 4'b0000;
						alu_srcA = 1'b0; 
						alu_srcB = 2'b00; 
						rf_wr_sel = 2'b00; 
					end
				endcase
			end

			default:
			begin
				 pcSource = 2'b00; 
				 alu_srcB = 2'b00; 
				 rf_wr_sel = 2'b00; 
				 alu_srcA = 1'b0; 
				 alu_fun = 4'b0000;
			end
			endcase
    end

endmodule