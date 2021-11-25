// arm_multi.sv
// David_Harris@hmc.edu, Sarah_Harris@hmc.edu 25 December 2013
// Updated nboorstin@hmc.edu, vcortes@hmc.edu, kpezeshki@hmc.edu 4 January 2020
// Multi-cycle implementation of a subset of ARMv4 w/ 8-bit datapath
//  Instruction Register is replicated to hold 32-bit instructions
//  note that no sign extension is done because width is only 8 bits
//  Register set is reduced from 16 to 8.  R15/R7 is the program counter.

// 16 8-bit registers
// Data-processing instructions
//   ADD, SUB, AND, ORR
//   INSTR <cond> <S> <Rd>, <Rn>, #immediate
//   INSTR <cond> <S> <Rd>, <Rn>, <Rm>
//    Rd <- <Rn> INSTR <Rm>	    	if (S) Update Status Flags
//    Rd <- <Rn> INSTR immediate	if (S) Update Status Flags
//   Instr[31:28] = cond
//   Instr[27:26] = Op = 00
//   Instr[25:20] = Funct
//                  [25]:    1 for immediate, 0 for register
//                  [24:21]: 0100 (ADD) / 0010 (SUB) /
//                           0000 (AND) / 1100 (ORR)
//                  [20]:    S (1 = update CPSR status Flags)
//   Instr[19:16] = Rn
//   Instr[15:12] = Rd
//   Instr[11:8]  = 0000
//   Instr[7:0]   = immed_8  (for #immediate type) / 
//                  0000<Rm> (for register type)
//   
// Load/Store instructions
//   LDR, STR
//   INSTR <Rd>, [<Rn>, #offset]
//    LDR: Rd <- Mem[<Rn>+offset]
//    STR: Mem[<Rn>+offset] <- Rd
//   Instr[31:28] = cond
//   Instr[27:26] = Op = 01 
//   Instr[25:20] = Funct
//                  [25]:    0 (A)
//                  [24:21]: 1100 (P/U/B/W)
//                  [20]:    L (1 for LDR, 0 for STR)
//   Instr[19:16] = Rn
//   Instr[15:12] = Rd
//   Instr[11:0]  = imm (zero extended)
//
// Branch instruction (PC <= PC + offset, PC holds 8 bytes past Branch
//   B
//   INSTR <target>
//    PC <- PC + 8 + imm << 2
//   Instr[31:28] = cond
//   Instr[27:25] = Op = 10
//   Instr[25:24] = Funct
//                  [25]: 1 (Branch)
//                  [24]: 0 (link)
//   Instr[23:0]  = offset (sign extend, shift left 2)
//   Note: no Branch delay slot on ARM
//
// Other:
//   R15 reads as PC+8
//   Conditional Encoding (only Z and C flags supported)
//    cond  Meaning                       Flag
//    0000  Equal                         Z = 1
//    0001  Not Equal                     Z = 0
//    0010  Carry Set                     C = 1
//    0011  Carry Clear                   C = 0
//    1000  Unsigned Higher               C = 1 & Z = 0
//    1001  Unsigned Lower/Same           C = 0 | Z = 1
//    1110  Always                        any

// run 760
// Expect simulator to print "Simulation succeeded"
// when the value 7 is written to address 100 (0x64)

// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps 

module testbench();

  logic        ph1, ph2;
  logic        reset;

  logic [7:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device to be tested
  top dut(ph1, ph2, reset, WriteData, DataAdr, MemWrite);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      ph1 = 0; ph2 = 0; #1;
      ph1 = 1;          #4;
      ph1 = 0;          #1;
      ph2 = 1;          #4;
    end

  // check results
  always @(posedge ph2)
    begin
      if(MemWrite) begin
        if(DataAdr == 100 & WriteData == 7) begin
          $display("Simulation succeeded");
          $finish;
        end else if (DataAdr != 96) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule


module top(input  logic       ph1, ph2, reset, 
           output logic [7:0] WriteData, Adr, 
           output logic       MemWrite);

  logic [7:0] ReadData;
  
  // instantiate processor and shared memory
  arm arm(ph1, ph2, reset, MemWrite, Adr, 
          WriteData, ReadData);
  mem mem(ph1, ph2, MemWrite, Adr, WriteData, ReadData);
endmodule

module mem(input  logic       ph1, ph2, we,
           input  logic [7:0] a, wd,
           output logic [7:0] rd);

  logic [31:0]      mem[63:0];
  logic [31:0]      word;
  logic [1:0]       bytesel;
  logic [5:0]       wordadr;

  initial
      $readmemh("memfile.dat", mem);

  assign bytesel = a[1:0];
  assign wordadr = a[7:2];

  // read and write bytes from 32-bit word
  always_latch
    if (ph2 & we) 
      case (bytesel)
        2'b00: mem[wordadr][7:0]   <= wd;
        2'b01: mem[wordadr][15:8]  <= wd;
        2'b10: mem[wordadr][23:16] <= wd;
        2'b11: mem[wordadr][31:24] <= wd;
      endcase

   assign word = mem[wordadr];
   always_comb
     case (bytesel)
       2'b00: rd = word[7:0];
       2'b01: rd = word[15:8];
       2'b10: rd = word[23:16];
       2'b11: rd = word[31:24];
     endcase
endmodule

module arm(input  logic       ph1, ph2, reset,
           output logic       MemWrite,
           output logic [7:0] Adr, WriteData,
           input  logic [7:0] ReadData);

  logic [31:25] Instr;
  logic [4:0]   Funct;
  logic [1:0]   ALUFlags, FlagW;
  logic         PCWrite, RegWrite, ALUOp;
  logic [2:0]   Rd; 
  logic [3:0]   IRWrite;
  logic         AdrSrc, ALUSrcA, ImmSrc;
  logic [1:0]   RegSrc, ALUSrcB, ALUControl, ResultSrc;

  aludecoder ad(ALUOp, Funct, ALUControl, FlagW); 
  controller c(ph1, ph2, reset, Instr[31:25], Funct[0], Rd, ALUFlags, 
               FlagW, PCWrite, MemWrite, RegWrite, IRWrite,
               AdrSrc, RegSrc, ALUOp, ALUSrcA, ALUSrcB, ResultSrc,
               ImmSrc);
  datapath dp(ph1, ph2, reset, Adr, WriteData, ReadData, Instr, Funct, Rd, ALUFlags,
              PCWrite, RegWrite, IRWrite,
              AdrSrc, RegSrc, ALUSrcA, ALUSrcB, ResultSrc,
              ImmSrc, ALUControl);           
endmodule

module aludecoder(input logic        ALUOp,
                  input logic  [4:0] Funct,
                  output logic [1:0] ALUControl,
                  output logic [1:0] FlagW);           
                    
  always_comb
    if (ALUOp) begin                 // which Data-processing Instr?
      case(Funct[4:1]) 
  	    	4'b0100: ALUControl = 2'b00; // ADD
  	    	4'b0010: ALUControl = 2'b01; // SUB
        	4'b0000: ALUControl = 2'b10; // AND
  	    	4'b1100: ALUControl = 2'b11; // ORR
  	    	default: ALUControl = 2'bx;  // unimplemented
      endcase
      FlagW[1]      = Funct[0]; // update Z flag if S bit is set
      FlagW[0]      = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
    end else begin
      ALUControl = 2'b00; // add for non data-processing instructions
      FlagW      = 2'b00; // don't update Flags
    end                    
endmodule

module controller(input  logic         ph1, ph2,
                  input  logic         reset,
                  input  logic [31:25] Instr,
                  input  logic [0:0]   Funct,
                  input  logic [2:0]   Rd,
                  input  logic [1:0]   ALUFlags,
                  input  logic [1:0]   FlagW,
                  output logic         PCWrite,
                  output logic         MemWrite,
                  output logic         RegWrite,
                  output logic [3:0]   IRWrite,
                  output logic         AdrSrc,
                  output logic [1:0]   RegSrc,
                  output logic         ALUOp,
                  output logic         ALUSrcA,
                  output logic [1:0]   ALUSrcB,
                  output logic [1:0]   ResultSrc,
                  output logic         ImmSrc);
                  
  logic       PCS, NextPC, RegW, MemW;
  
  decoder dec(ph1, ph2, reset, Instr[27:26], Instr[25], Funct[0], Rd,
             PCS, NextPC, RegW, MemW, ALUOp,
             IRWrite, AdrSrc, ResultSrc, 
             ALUSrcA, ALUSrcB, ImmSrc, RegSrc);
  condlogic cl(ph1, ph2, reset, Instr[31:28], ALUFlags,
               FlagW, PCS, NextPC, RegW, MemW,
               PCWrite, RegWrite, MemWrite);
endmodule

module decoder(input  logic       ph1, ph2, reset,
               input  logic [1:0] Op,
               input  logic       Funct5, Funct0,
               input  logic [2:0] Rd,
               output logic       PCS, NextPC, RegW, MemW, ALUOp,
               output logic [3:0] IRWrite,
               output logic       AdrSrc,
               output logic [1:0] ResultSrc, 
               output logic       ALUSrcA, 
               output logic [1:0] ALUSrcB,  
               output logic       ImmSrc,
               output logic [1:0] RegSrc);

  logic        Branch;

  // Main FSM
  mainfsm fsm(ph1, ph2, reset, Op, Funct5, 
              Funct0, IRWrite, AdrSrc, 
              ALUSrcA, ALUSrcB, ResultSrc,
              NextPC, RegW, MemW, Branch, ALUOp);

  // PC Logic
  assign PCS  = ((Rd == 3'b111) & RegW) | Branch; 

  // Instr Decoder
  assign ImmSrc    = Op[1];
  assign RegSrc[0] = (Op == 2'b10); // read PC on Branch
  assign RegSrc[1] = (Op == 2'b01); // read Rd on STR
endmodule

module mainfsm(input  logic         ph1, ph2,
               input  logic         reset,
               input  logic [1:0]   Op,
               input  logic         Funct5, Funct0,
               output logic [3:0]   IRWrite,
               output logic         AdrSrc, ALUSrcA,
               output logic [1:0]   ALUSrcB, ResultSrc,
               output logic         NextPC, RegW, MemW, Branch, ALUOp);  
                
  logic [3:0] state, nextstate;
  logic [14:0] controls;
  
  // state register
  flopr #(4) statereg(ph1, ph2, reset, nextstate, state);
  
  // next state logic
  always_comb
    case(state)
      4'd0:  nextstate = 4'd1;
      4'd1:  nextstate = 4'd2;
      4'd2:  nextstate = 4'd3;
      4'd3:  nextstate = 4'd4;
      4'd4: case(Op)
                2'b00: 
                  if (Funct5)    nextstate = 4'd10;
                  else           nextstate = 4'd9;
                2'b01:           nextstate = 4'd5;
                2'b10:           nextstate = 4'd12;
                default:         nextstate = 4'd13;
              endcase
      4'd9:                      nextstate = 4'd11;
      4'd10:                     nextstate = 4'd11;
      4'd5: 
        if (Funct0)              nextstate = 4'd6;
        else                     nextstate = 4'd8;
      4'd6:                      nextstate = 4'd7;
      default:                   nextstate = 4'd0; 
    endcase
    
  // state-dependent output logic
  always_comb
    case(state)
      4'd0: 	controls = 15'b1000_0001_010_1110; // FETCH1
      4'd1: 	controls = 15'b1000_0010_010_1110; // FETCH2
      4'd2: 	controls = 15'b1000_0100_010_1110; // FETCH3
      4'd3: 	controls = 15'b1000_1000_010_1110; // FETCH4
      4'd4:  	controls = 15'b0000_0000_010_1100; // DECODE
      4'd5:  	controls = 15'b0000_0000_000_0010; // MEMADR
      4'd6:   	controls = 15'b0000_0000_100_0000; // MEMRD
      4'd7:   	controls = 15'b0001_0000_001_0000; // MEMWB
      4'd8:   	controls = 15'b0010_0000_100_0000; // MEMWR
      4'd9:		controls = 15'b0000_0000_000_0001; // EXECUTER
      4'd10:	controls = 15'b0000_0000_000_0011; // EXECUTEI
      4'd11:   	controls = 15'b0001_0000_000_0000; // ALUWB
      4'd12:  	controls = 15'b0100_0000_010_0010; // BRANCH
      default: 	controls = 15'bxxxx_xxxx_xxx_xxxx;
    endcase

  assign {NextPC, Branch, MemW, RegW, IRWrite,
          AdrSrc, ResultSrc,   
          ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule              

module condlogic(input  logic       ph1, ph2, reset,
                 input  logic [3:0] Cond,
                 input  logic [1:0] ALUFlags,
                 input  logic [1:0] FlagW,
                 input  logic       PCS, NextPC, RegW, MemW,
                 output logic       PCWrite, RegWrite, MemWrite);

  logic [1:0] FlagWrite;
  logic [1:0] Flags;
  logic       CondEx, CondExDelayed;

  flopenr #(1) flagreg1(ph1, ph2, reset, FlagWrite[1], ALUFlags[1], Flags[1]);
  flopenr #(1) flagreg0(ph1, ph2, reset, FlagWrite[0], ALUFlags[0], Flags[0]);

  // write controls are conditional
  condcheck cc(Cond, Flags, CondEx);
  flopr #(1)condreg(ph1, ph2, reset, CondEx, CondExDelayed);
  assign FlagWrite = FlagW & {2{CondEx}};
  assign RegWrite  = RegW  & CondExDelayed;
  assign MemWrite  = MemW  & CondExDelayed;
  assign PCWrite   = (PCS  & CondExDelayed) | NextPC;
endmodule    

module condcheck(input  logic [3:0] Cond,
                 input  logic [1:0] Flags,
                 output logic       CondEx);

  logic zero, carry;
  
  assign {zero, carry} = Flags;
                  
  always_comb
    case(Cond)
      4'b0000: CondEx = zero;             // EQ
      4'b0001: CondEx = ~zero;            // NE
      4'b0010: CondEx = carry;            // CS
      4'b0011: CondEx = ~carry;           // CC
      4'b1000: CondEx = carry & ~zero;    // HI
      4'b1001: CondEx = ~(carry & ~zero); // LS
      4'b1110: CondEx = 1'b1;             // Always
      default: CondEx = 1'bx;             // undefined
    endcase  
endmodule

module datapath(input  logic         ph1, ph2, reset,
                output logic [7:0]   Adr, WriteData,
                input  logic [7:0]   ReadData,
                output logic [31:25] Instruction,
                output logic [4:0]   Funct,
                output logic [2:0]   Rd,
                output logic [1:0]   ALUFlags,
                input  logic         PCWrite, RegWrite,
                input  logic [3:0]   IRWrite,
                input  logic         AdrSrc, 
                input  logic [1:0]   RegSrc, 
                input  logic         ALUSrcA,
                input  logic [1:0]   ALUSrcB, ResultSrc,
                input  logic         ImmSrc, 
                input  logic [1:0]   ALUControl);

  logic [31:0] Instr;
  logic [7:0]  PC;
  logic [7:0]  ExtImm, SrcA, SrcB, Result;
  logic [7:0]  Data, RD1, RD2, A, ALUResult, ALUOut;
  logic [2:0]  RA1, RA2;

  assign Instruction = Instr[31:25];
  assign Funct = Instr[24:20];
  assign Rd = Instr[14:12];

  // next PC logic
  flopenr #(8) pcreg(ph1, ph2, reset, PCWrite, Result, PC);
  
  // memory logic
  mux2 #(8)    adrmux(PC, ALUOut, AdrSrc, Adr);
  
  // instruction and data registers
  flopen  #(8) ir0(ph1, ph2, IRWrite[0], ReadData, Instr[7:0]);
  flopen  #(8) ir1(ph1, ph2, IRWrite[1], ReadData, Instr[15:8]);
  flopen  #(8) ir2(ph1, ph2, IRWrite[2], ReadData, Instr[23:16]);
  flopen  #(8) ir3(ph1, ph2, IRWrite[3], ReadData, Instr[31:24]);
  flop    #(8) datareg(ph1, ph2, ReadData, Data);
  
  // register file logic
  mux2 #(3)   ra1mux(Instr[18:16], 3'b111, RegSrc[0], RA1);
  mux2 #(3)   ra2mux(Instr[2:0], Instr[14:12], RegSrc[1], RA2);
  regfile     rf(ph1, ph2, RegWrite, RA1, RA2,
                 Instr[14:12], Result, 
                 RD1, RD2);
  flop  #(8)  srcareg(ph1, ph2, RD1, A);
  flop  #(8)  wdreg(ph1, ph2, RD2, WriteData);
  extend      ext(Instr[7:0], ImmSrc, ExtImm);

  // ALU logic
  mux2 #(8)  srcamux(A, PC, ALUSrcA, SrcA);
  mux4 #(8)  srcbmux(WriteData, ExtImm, 8'd4, 8'd1, ALUSrcB, SrcB);
  alu        alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);
  flop #(8)  aluoutreg(ph1, ph2, ALUResult, ALUOut);
  mux3 #(8)  resmux(ALUOut, Data, ALUResult, ResultSrc, Result);
endmodule

module regfile(input  logic        ph1, ph2, 
               input  logic        we3, 
               input  logic [2:0]  ra1, ra2, wa3, 
               input  logic [7:0]  wdr15,
               output logic [7:0]  rd1, rd2);

  logic [7:0] rf[6:0];
  logic [7:0] r1, r2;
  logic pc1, pc2;

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 15 reads PC+8 instead
  // only 3 bits of register address, so R7 and R15 are equivalent

  // write port
  always_latch
    if (ph2 & we3) rf[wa3] <= wdr15;	
    
  // read ports
  assign r1 = rf[ra1];
  assign r2 = rf[ra2];
  
  // special case of R7/15
  assign pc1 = (ra1 == 3'b111);
  assign pc2 = (ra2 == 3'b111);
  mux2 #(8) rd1mux(r1, wdr15, pc1, rd1);
  mux2 #(8) rd2mux(r2, wdr15, pc2, rd2);
endmodule

module extend(input  logic [7:0] Instr,
              input  logic       ImmSrc,
              output logic [7:0] ExtImm);
 
  mux2 #(8) extendmux(Instr, {Instr[5:0], 2'b00}, ImmSrc, ExtImm);
endmodule

module adder #(parameter WIDTH=8)
              (input  logic [WIDTH-1:0] a, b,
               output logic [WIDTH-1:0] y);
             
  assign y = a + b;
endmodule

module alu(input  logic [7:0] a, b,
           input  logic [1:0]  ALUControl,
           output logic [7:0] Result,
           output logic [1:0]  ALUFlags);

  logic        neg, zero, carry, overflow;
  logic [7:0] condinvb;
  logic [8:0] sum;

  assign condinvb = ALUControl[0] ? ~b : b;
  assign sum = a + condinvb + ALUControl[0];

  always_comb
    casex (ALUControl[1:0])
      2'b0?: Result = sum;
      2'b10: Result = a & b;
      2'b11: Result = a | b;
    endcase

  assign zero     = (Result == 8'b0);
  assign carry    = (ALUControl[1] == 1'b0) & sum[8];
  assign ALUFlags = {zero, carry};
endmodule


module flopenr #(parameter WIDTH = 8)
                (input  logic             ph1, ph2, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);

  logic [WIDTH-1:0] d2, zero;

  assign zero = 0;  
  mux3 #(WIDTH) enrmux(q, d, zero, {reset, en}, d2);
  flop #(WIDTH) f(ph1, ph2, d2, q);
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             ph1, ph2, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  logic [WIDTH-1:0] d2, zero;
  
  assign zero = 0;  
  mux2 #(WIDTH) rmux(d, zero, reset, d2);
  flop #(WIDTH) f(ph1, ph2, d2, q);
endmodule

module flopen #(parameter WIDTH = 8)
              (input  logic             ph1, ph2, en,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  logic [WIDTH-1:0] d2;
  
  mux2 #(WIDTH) enmux(q, d, en, d2);
  flop #(WIDTH) f(ph1, ph2, d2, q);
endmodule

module flop #(parameter WIDTH = 8)
            (input  logic             ph1, ph2, 
             input  logic [WIDTH-1:0] d, 
             output logic [WIDTH-1:0] q);

  logic [WIDTH-1:0] mid;
  
  latch #(WIDTH) master(ph2, d, mid);
  latch #(WIDTH) slave(ph1, mid, q);
endmodule

module latch #(parameter WIDTH = 8)
            (input  logic             ph,
             input  logic [WIDTH-1:0] d, 
             output logic [WIDTH-1:0] q);

  always_latch
    if (ph) q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module mux4 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2, d3,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0); 
endmodule
