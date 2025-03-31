\m5_TLV_version 1d: tl-x.org
\m5
   // This region contains M5 macro definitions. It will not appear
   // in the resulting TLV code (in the NAV-TLV tab).
   use(m5-1.0) // Use M5 libraries
   
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
   
   /controller
      $immsrc[1:0] = 2'b0;
      $pcsrc = 0;
      $alusrc = 0;
      $alucontrol[2:0] = 3'b0;
      $zero = 0;
      $resultsrc[1:0] = 2'b0;
   /datapath
      $pc = *PC;
      $dataadr = *DataAdr;
      $memwrite = *MemWrite;
      $instr[31:0] = *Instr;
      $readdata = *ReadData;
      /pc
         /datapath$pc = /top$reset ? 32'b0 : >>1$pcnext;
         // "Usual Next Address
         $pcplusfour = /datapath$pc + 32'd4;
         // Jump?
         $pctarget = /datapath$pc + /datapath/extender$immext;
         $pcnext = /top/controller$pcsrc ? $pctarget : $pcplusfour;
\SV
   regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
\TLV
   /datapath
      $srca = *SrcA;
      $srcb = 0;
      $writedata = *WriteData;
      /extender
         $immext[31:0] = // I-type
                   /top/controller$immsrc == 2'b00 ? {{20{/datapath$instr[31]}}, /datapath$instr[31:20]} :
                   // S-type
                   /top/controller$immsrc == 2'b01 ? {{20{/datapath$instr[31]}}, /datapath$instr[31:25], /datapath$instr[11:7]} :
                   // B-type
                   /top/controller$immsrc == 2'b10 ? {{20{/datapath$instr[31]}}, /datapath$instr[7], /datapath$instr[30:25], /datapath$instr[11:8], 1'b0} :
                   // J-type 
                   /top/controller$immsrc == 2'b11 ? {{12{/datapath$instr[31]}}, /datapath$instr[19:12], /datapath$instr[20], /datapath$instr[30:21], 1'b0} :
                                      32'bx;
      $srcb = /top/controller$alusrc ? /extender$immext : /datapath$writedata;
      /alu
         $condinvb = /top/controller$alucontrol[0] ? !/datapath$srcb : /datapath$srcb;
         $sum[31:0] = /datapath$srca + $condinvb + /top/controller$alucontrol[0];
         $aluresult[31:0] = /top/controller$alucontrol == 3'b000 ? $sum :            // add
                         /top/controller$alucontrol == 3'b001 ? $sum :            // subtract
                         /top/controller$alucontrol == 3'b010 ? (/datapath$srca & /datapath$srcb) : // and
                         /top/controller$alucontrol == 3'b011 ? (/datapath$srca | /datapath$srcb) : // or
                         /top/controller$alucontrol == 3'b101 ? $sum[31] :        // slt
                                                                32'bx;            //default
         /top/controller$zero = $aluresult == 32'b0 ? 1 : 0; //zero flag
         //mux
         $result[31:0] = /top/controller$resultsrc[1] == 1 ? /datapath/pc$pcplusfour :
                     (/top/controller$resultsrc[0] == 1 ? /datapath$readdata : $aluresult);

\SV   
   imem imem(PC, Instr);
   dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
   endmodule
