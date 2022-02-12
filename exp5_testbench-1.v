`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 01/07/2020 12:59:51 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench file for Exp 5
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module otter_tb(); 

   reg RST; 
   reg intr; 
   reg clk; 
   reg [31:0] iobus_in; 
   wire [31:0] iobus_addr; 
   wire [31:0] iobus_out; 
   wire iobus_wr; 

Lab5  my_otter(
     .RST         (RST),
     .INTR        (intr),
     .clk         (clk),
     .IOBUS_IN    (iobus_in),
     .IOBUS_OUT   (iobus_out), 
     .IOBUS_ADDR  (iobus_addr), 
     .IOBUS_WR    (iobus_wr)   );
     
   //- Generate periodic clock signal    
   initial    
      begin       
         clk = 0;   //- init signal        
         forever  #10 clk = ~clk;    
      end                        
         
   initial        
   begin           
      RST=1;
      intr=0;
      iobus_in = 32'h0000FEED;  
    
      #40

      RST = 0;  

    end
        
 endmodule
