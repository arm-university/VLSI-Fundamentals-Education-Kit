//---------------------------------------------------------
// nand2.sv
// Nathaniel Pinckney 08/06/07
//
// Model and testbench of NAND2 gate
//--------------------------------------------------------

module testbench();
    logic a, y;
    
    // The device under test
    inv dut(a, y);

	`include "testfixture.verilog"
    
endmodule

module inv(input  logic a,
             output logic y);
             
   assign #1 y = ~a;    
endmodule

