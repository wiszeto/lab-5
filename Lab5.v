`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2022 02:38:49 PM
// Design Name: 
// Module Name: Lab5
//////////////////////////////////////////////////////////////////////////////////


module Lab5(
    input RST,
    input INTR,
    input [31:0] IOBUS_IN,
    input clk,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR
    );
    
    //pc_mod ports
    wire reset;
    wire PCWrite;
    wire [1:0] pcSource;
    wire [31:0] jalr;
    wire [31:0] branch;
    wire [31:0] jal;
    wire [31:0] PC;
    
    //memory ports
    wire [31:0] ir; //mem out
    wire [31:0] d_out2; //mem dout2
    wire memRDEN1;
    wire memRDEN2;
    
    //reg_file ports
    wire [1:0] rf_wr_sel;
    wire [31:0] wd;
    wire regWrite;
    wire [31:0] rs1_out; //reg_file output
    wire [31:0] rs2_out; //reg_file output
    
    //ALU ports
    wire alu_srcA;
    wire [1:0] alu_srcB;
    wire [3:0] alu_fun;
    wire [31:0] result;
    wire [31:0] srcA;
    wire [31:0] srcB;
    
    //IMMED_GEN ports
    wire [31:0] U_type;
    wire [31:0] S_type;
    wire [31:0] I_type;
    wire [31:0] J_type;
    wire [31:0] B_type;
    
    //CSR
    wire [31:0] RD;
    wire [31:0] CSR_MEPC;
    wire [31:0] CSR_MTVEC;
    wire CSR_MIE;
    
    //FSM OUT
    wire csr_WE;
    wire int_taken;
    
  PC_MOD pc_mod(
        .clk(clk), 
        .clr(reset), 
        .pcWrite(PCWrite),
        .jalr(jalr), 
        .branch(branch), 
        .jal(jal),
        .mtvec(CSR_MTVEC),
        .mepc(CSR_MEPC), 
        .pcSource(pcSource), 
        .data_out(PC) );
  
   //The memory containing instruction in machine code 
   Memory OTTER_MEMORY ( 
        .MEM_CLK (clk), 
        .MEM_RDEN1 (memRDEN1), // from fsm
        .MEM_RDEN2 (memRDEN2), //  from fsm
        .MEM_WE2 (memWE2), // from fsm
        .MEM_ADDR1 (PC[15:2]), // 14-bit signal from pc 
        .MEM_ADDR2 (result), //from ALU 
        .MEM_DIN2 (rs2_out), // from reg_file
        .MEM_SIZE (ir[13:12]), //from mem_dout
        .MEM_SIGN (ir[14]), //from mem_dout
        .IO_IN (IOBUS_IN), //module input 
        .IO_WR (IOBUS_WR), //module output
        .MEM_DOUT1(ir), // 32-bit signal 
        .MEM_DOUT2 (d_out2));
        
  mux_4t1_nb  #(.n(32)) my_4t1_mux_reg_file  (
       .SEL   (rf_wr_sel), 
       .D0    (PC + 4), 
       .D1    (RD), //interupt
       .D2    (d_out2), 
       .D3    (result), //from ALU
       .D_OUT (wd) ); 
    
  RegFile my_regfile (
    .wd   (wd),
    .clk  (clk), 
    .en   (regWrite),
    .adr1 (ir[19:15]),
    .adr2 (ir[24:20]),
    .wa   (ir[11:7]),
    .rs1  (rs1_out), 
    .rs2  (rs2_out)  );
    
  assign IOBUS_OUT = rs2_out;
  
  //IMMED_GEN & BRANCH_ADDR_GEN
    //IMMED_GEN
        //U-type immediate
        assign U_type = {ir[31:12], 12'b000000000000};

        //I-type immediate
        assign I_type = {{21{ir[31]}} , ir[30:25], ir[24:20]};

        //S-type immediate
        assign S_type = {{21{ir[31]}}, ir[30:25], ir[11:7]};

        //J-type immediate
        assign J_type = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};

        //B-type immediate
        assign B_type = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    
  //BRANCH_ADDR_GEN
    //Jump and branching address
        assign jal = PC + J_type;
        assign jalr = rs1_out + I_type; 
        assign branch = PC + B_type;

  
  //ALU section
  mux_2t1_nb  #(.n(32)) my_2t1_mux_ALU  (
       .SEL   (alu_srcA), 
       .D0    (rs1_out), 
       .D1    (U_type), 
       .D_OUT (srcA) );
       
  mux_4t1_nb  #(.n(32)) my_4t1_mux_ALU  (
       .SEL   (alu_srcB), 
       .D0    (rs2_out), 
       .D1    (I_type), 
       .D2    (S_type), 
       .D3    (PC),
       .D_OUT (srcB));
        
  ALU ALU(.OP_1(srcA), 
       .OP_2(srcB), 
       .alu_fun(alu_fun), 
       .result(result));

//branch condition generator
assign br_eq = rs1_out == rs2_out;
assign br_lt = ($signed(rs1_out) < $signed(rs2_out));
assign br_ltu = rs1_out < rs2_out;

CSR csr(.CLK(clk), 
        .RST(RST), 
        .INT_TAKEN(int_taken),
        .ADDR(ir[31:20]),
        .PC(PC),
        .WD(rs1_out),
        .WR_EN(csr_WE),
        .RD(RD),
        .CSR_MEPC(CSR_MEPC),
        .CSR_MTVEC(CSR_MTVEC),
        .CSR_MIE(CSR_MIE) );
        
  CU_DCDR decoder(.br_eq(br_eq), 
       .int_taken(int_taken),
	   .br_lt(br_lt), 
	   .br_ltu(br_ltu),
       .opcode(ir[6:0]),
	   .func7(ir[30]),          
       .func3(ir[14:12]),    
       .alu_fun(alu_fun),
       .pcSource(pcSource),
       .alu_srcA(alu_srcA),
       .alu_srcB(alu_srcB), 
	   .rf_wr_sel(rf_wr_sel)   );

wire intr = CSR_MIE && INTR;

CU_FSM fsm(.intr(intr),
       .clk(clk),
       .RST(RST),
       .opcode(ir[6:0]),   
       .pcWrite(PCWrite),
       .regWrite(regWrite),
       .memWE2(memWE2),
       .memRDEN1(memRDEN1),
       .memRDEN2(memRDEN2),
       .reset(reset),
       .csr_WE(csr_WE),
       .int_taken(int_taken) );

assign IOBUS_ADDR = result;
    
endmodule
