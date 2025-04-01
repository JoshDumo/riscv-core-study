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
      /* verilator lint_off WIDTHTRUNC */
      assign rd = RAM[a[31:2]]; // word aligned
      /* verilator lint_on WIDTHTRUNC */
   endmodule

   // Data Memory
   module dmem(input logic clk, we, input logic [31:0] a, wd, output logic [31:0] rd);
      logic [31:0] RAM[63:0];
      /* verilator lint_off WIDTHTRUNC */
      assign rd = RAM[a[31:2]]; // word aligned
      always_ff @(posedge clk)
         if (we) RAM[a[31:2]] <= wd;
      /* verilator lint_on WIDTHTRUNC */
   endmodule

   // Register File
   module regfile(input logic clk, input logic we3, input logic [5:0] a1, a2, a3, input logic [31:0] wd3, output logic [31:0] rd1, rd2);
      logic [31:0] rf[31:0];
      // three ported register file
      // read two ports combinationally (A1/RD1, A2/RD2)
      // write third port on rising edge of clock (A3/WD3/WE3)
      // register 0 hardwired to 0
      always_ff @(posedge clk)
         /* verilator lint_off WIDTHTRUNC */
         if (we3) rf[a3] <= wd3;
            assign rd1 = (a1 != 0) ? rf[a1] : 0;
            assign rd2 = (a2 != 0) ? rf[a2] : 0;
         /* verilator lint_on WIDTHTRUNC */
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
      logic [31:0] PC, Instr, ReadData, SrcA, Result;
      logic RegWrite;
      // instantiate processor and memories
\TLV
   $reset = *reset;
   /controller
      $op[6:0] = /top/imem$instr[6:0];
      $funct3[2:0] = /top/imem$instr[14:12];
      $funct7b5 = /top/imem$instr[30];
      /maindec
         $controls[10:0] = /top/controller$op == 7'b0000011 ? 11'b1_00_1_0_01_0_00_0 : // lw
                           /top/controller$op == 7'b0100011 ? 11'b0_01_1_1_00_0_00_0 : // sw
                           /top/controller$op == 7'b0110011 ? 11'b1_xx_0_0_00_0_10_0 : // R–type
                           /top/controller$op == 7'b1100011 ? 11'b0_10_0_0_00_1_01_0 : // beq
                           /top/controller$op == 7'b0010011 ? 11'b1_00_1_0_00_0_10_0 : // I–type ALU
                           /top/controller$op == 7'b1101111 ? 11'b1_11_0_0_10_0_00_1 : // jal
                                                              11'bx_xx_x_x_xx_x_xx_x; // default
         $regwrite = $controls[10];
         *RegWrite = $regwrite;
         $immsrc[1:0] = $controls[9:8];
         $alusrc = $controls[7];
         $memwrite = $controls[6];
         *MemWrite = $memwrite;
         $resultsrc[1:0] = $controls[5:4];
         $branch = $controls[3];
         $aluop[1:0] = $controls[2:1];
         $jump = $controls[0];
      /aludec
         $opb5 = /top/controller$op[5];
         $rtypesub = /top/controller$funct7b5 & $opb5; // TRUE for R–type subtract
         $alucontrol[2:0] = /top/controller/maindec$aluop == 2'b00 ? 3'b000 : // addition
                       /top/controller/maindec$aluop == 2'b01 ? 3'b001 : // subtraction
                                (/top/controller$funct3 == 3'b000 ?
                                                   ($rtypesub == 1 ?
                                                   3'b001 : 3'b000) :
                                 /top/controller$funct3 == 3'b010 ? 3'b101 :
                                 /top/controller$funct3 == 3'b110 ? 3'b011 :
                                 /top/controller$funct3 == 3'b111 ? 3'b010 :
                                                                    3'bxxx);
      $pcsrc = /top/controller/maindec$branch & /top/datapath/alu$zero | /top/controller/maindec$jump;
   /datapath
      /pc
         $pc[31:0] = /top$reset ? 32'b0 : >>1$pcnext;
         // "Usual Next Address
         $pcplusfour[31:0] = /top$reset ? 32'b0 : ($pc + 32'd4);
         // Jump?
         $pctarget[31:0] = /top$reset ? 32'b0 : ($pc + /datapath/extender$immext);
         $pcnext[31:0] = /top/controller$pcsrc ? $pctarget : $pcplusfour;
\SV
   regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
\TLV
   /datapath
      /regfile
         $srca[31:0] = *SrcA;
         $writedata[31:0] = *WriteData;
      /extender
         $immext[31:0] = // I-type
                   /top/controller/maindec$immsrc == 2'b00 ? {{20{/top/imem$instr[31]}}, /top/imem$instr[31:20]} :
                   // S-type
                   /top/controller/maindec$immsrc == 2'b01 ? {{20{/top/imem$instr[31]}},/top/imem$instr[31:25], /top/imem$instr[11:7]} :
                   // B-type
                   /top/controller/maindec$immsrc == 2'b10 ? {{20{/top/imem$instr[31]}}, /top/imem$instr[7], /top/imem$instr[30:25], /top/imem$instr[11:8], 1'b0} :
                   // J-type 
                   /top/controller/maindec$immsrc == 2'b11 ? {{12{/top/imem$instr[31]}}, /top/imem$instr[19:12], /top/imem$instr[20], /top/imem$instr[30:21], 1'b0} :
                                      32'bx;
      /regfile
         $srcb[31:0] = /top/controller/maindec$alusrc == 1 ? /top/datapath/extender$immext : /top/datapath/regfile$writedata;
      /alu
         $condinvb[31:0] = /top/controller/aludec$alucontrol[0] ? ~/top/datapath/regfile$srcb : /top/datapath/regfile$srcb;
         $sum[31:0] = /top/datapath/regfile$srca + $condinvb + /top/controller/aludec$alucontrol[0];
         $aluresult[31:0] = /top/controller/aludec$alucontrol == 3'b000 ? $sum :            // add
                         /top/controller/aludec$alucontrol == 3'b001 ? $sum :            // subtract
                         /top/controller/aludec$alucontrol == 3'b010 ? (/top/datapath/regfile$srca & /top/datapath/regfile$srcb) : // and
                         /top/controller/aludec$alucontrol == 3'b011 ? (/top/datapath/regfile$srca | /top/datapath/regfile$srcb) : // or
                         /top/controller/aludec$alucontrol == 3'b101 ? $sum[31] :        // slt
                                                                32'bx;            //default
         $zero = $aluresult == 32'b0 ? 1 : 0; //zero flag
         //mux
         $result[31:0] = /top/controller/maindec$resultsrc[1] == 1 ? /datapath/pc$pcplusfour :
                     (/top/controller/maindec$resultsrc[0] == 1 ? /top/dmem$readdata : $aluresult);
         *Result = $result;
   /imem
      *PC = /top/datapath/pc$pc;
      $instr[31:0] = *Instr;
\SV   
   imem imem(PC, Instr);
\TLV
   /dmem
      *DataAdr = /top/datapath/alu$aluresult;
      $readdata[31:0] = *ReadData;
\SV
   dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
   endmodule
