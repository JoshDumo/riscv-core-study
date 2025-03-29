\m5_TLV_version 1d: tl-x.org
\m5
   // This region contains M5 macro definitions. It will not appear
   // in the resulting TLV code (in the NAV-TLV tab).
   use(m5-1.0) // Use M5 libraries
\TLV flopr(#width, $clk, $reset, $d, $q)
   $q[m5_calc((#width)-1):0] = $reset ? #width'b0 : $d[m5_calc((#width)-1):0];

\TLV flopenr(#width, $clk, $reset, $en, $d, $q)
   $q[m5_calc((#width)-1):0] = $reset ? #width'b0 : 
                                        ($en ? $d[m5_calc((#width)-1):0] : #width'b0);
   
\TLV adder($a, $b, $y)
   $y = $a + $b;
   
\TLV extend($instr, $immsrc, $immext)
   $immext[31:0] = $immsrc[1:0] == 2'b00 ? {{20{instr[31]}}, instr[31:20]} :
                   $immsrc[1:0] == 2'b01 ? {{20{instr[31]}}, instr[31:25], instr[11:7]} :
                   $immsrc[1:0] == 2'b10 ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1’b0} :
                   $immsrc[1:0] == 2'b11 ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1’b0} :
                                           32'bx;

\TLV mux2(#width, $d0, $d1, $s, $y)
   $y[m5_calc((#width)-1):0] = $s ? $d1[m5_calc((#width)-1):0] : $d0[m5_calc((#width)-1):0];
   
\TLV mux3(#width, $d0, $d1, $d2, $s, $y)
   $y[m5_calc((#width)-1):0] = $s[1] ? $d2[m5_calc((#width)-1):0] :
                              ($s[0] ? $d1[m5_calc((#width)-1):0] : $d0[m5_calc((#width)-1):0]);   
   

\TLV alu()
   
\TLV riscvsingle($clk, $reset, $pc, $instr, $memwrite, $dataadr, $writedata, $readdata)
   $alusrc;
   $regwrite;
   $jump;
   $zero;
   $resultsrc;
   $immsrc;
   $alucontrol;
   
   m5+controller($inst[6:0], $inst[14;12], $zero, 
                 $resultsrc, $memwrite, $pcsrc, $alusrc,
                 $regwrite, $jump, $immsrc, $alucontrol)
   m5+datapath($clk, $reset, $resultsrc, $pcsrc, $alusrc,
               $regwrite, $immsrc, $alucontrol, $zero, $pc, 
               $instr, $aluresult, $writedata, $readdata)

\TLV controller()

\TLV datapath($clk, $reset, $resultsrc, $pcsrc, $alusrc, $regwrite, $immsrc, $alucontrol, $zero, $pc, $instr, $aluresult, $writedata, $readdata)
   $pcnext;
   $pcplusfour;
   $pctarget;
   $immext;
   $srca;
   $srcb;
   $result;
   // next PC logic
   m5+flopr(32, $clk, $reset, $pcnext, $pc)
   m5+adder($pc, 32'd4, $pcplusfour)
   m5+adder($pc, $immext, $pctarget)
   m5+mux2(32, $pcplusfour, $pctarget, $pcsrc, $pcnext)
   // register file logic
\SV
   regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
\TLV   
   m5+extend($instr[31:7], $immsrc, $immext)
   // ALU logic
   m5+mux2(32, $writedata, $immext, $alusrc, $srcb)
   m5+alu($srca, $srcb, $alucontrol, $aluresult, $zero)
   m5+mux3(32, $aluresult, $readdata, $pcplusfour, $resultsrc, $result)
   
\SV
   // Instruction Memory
   module imem(input logic [31:0] a,output logic [31:0] rd);
      logic [31:0] RAM[63:0];
      initial
         begin
            RAM[0]  = 32'h00500113;
            RAM[1]  = 32'h00C00193;
            RAM[2]  = 32'hFF718393;
            RAM[3]  = 32'h0023E233;
            RAM[4]  = 32'h0041F2B3;
            RAM[5]  = 32'h004282B3;
            RAM[6]  = 32'h02728863;
            RAM[7]  = 32'h0041A233;
            RAM[8]  = 32'h00020463;
            RAM[9]  = 32'h00000293;
            RAM[10] = 32'h0023A233;
            RAM[11] = 32'h005203B3;
            RAM[12] = 32'h402383B3;
            RAM[13] = 32'h0471AA23;
            RAM[14] = 32'h06002103;
            RAM[15] = 32'h005104B3;
            RAM[16] = 32'h008001EF;
            RAM[17] = 32'h00100113;
            RAM[18] = 32'h00910133;
            RAM[19] = 32'h0221A023;
            RAM[20] = 32'h00210063;
      end
      assign rd = RAM[a[31:2]]; // word aligned
   endmodule

   // Data Memory
   module dmem(input logic clk, we, input logic [31:0] a, wd, output logic [31:0] rd);
      logic [31:0] RAM[63:0];
      assign rd = RAM[a[31:2]]; // word aligned
      always_ff @(posedge clk)
         if (we) RAM[a[31:2]] <= wd;
   endmodule

   // Register File
   module regfile(input logic clk, input logic we3, input logic [5:0] a1, a2, a3, input logic [31:0] wd3, output logic [31:0] rd1, rd2);
      logic [31:0] rf[31:0];
      // three ported register file
      // read two ports combinationally (A1/RD1, A2/RD2)
      // write third port on rising edge of clock (A3/WD3/WE3)
      // register 0 hardwired to 0
      always_ff @(posedge clk)
         if (we3) rf[a3] <= wd3;
            assign rd1 = (a1 != 0) ? rf[a1] : 0;
            assign rd2 = (a2 != 0) ? rf[a2] : 0;
   endmodule

   // The main module (as required for Makerchip).
   // Testbench
   m5_makerchip_module
      logic [31:0] WriteData, DataAdr;
      logic MemWrite;
      // instantiate device to be tested
      dut dut(clk, reset, WriteData, DataAdr, MemWrite);
      // check results
      always @(negedge clk)
         begin
            if(MemWrite) begin
               if(DataAdr === 100 & WriteData === 25) begin
                  $display("Simulation succeeded");
                  $stop;
               end else if (DataAdr !== 96) begin
                  $display("Simulation failed");
                  $stop;
               end
            end
         end
   endmodule

   module dut(input logic clk, reset, output logic [31:0] WriteData, DataAdr, output logic MemWrite);
   logic [31:0] PC, Instr, ReadData;
      // instantiate processor and memories
\TLV
   $clk = *clk;
   $reset = *reset;
   $writedata = *WriteData;
   $dataadr = *DataAdr;
   $memwrite = *MemWrite;
   $pc = *PC;
   $instr = *Instr;
   $readdata = *ReadData;
   m5+riscvsingle($clk, $reset, $pc, $instr, $memwrite, $dataadr, $writedata, $readdata)
\SV   
   imem imem(PC, Instr);
   dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
   endmodule
