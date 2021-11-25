//---------------------------------------------------------
// nand2.sv
// Nathaniel Pinckney 08/06/07
//
// Model and testbench of NAND2 gate
//--------------------------------------------------------

module testbench();
    logic a, b, y;
    
    // The device under test
    nand2 dut(a, b, y);

	`include "testfixture.verilog"
    
endmodule

module nand2(input  logic a,
             input  logic b,
             output logic y);
             
   assign #1 y = ~(a & b);    
endmodule

