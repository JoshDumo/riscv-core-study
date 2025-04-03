\m5_TLV_version 1d: tl-x.org
\m5
   // This region contains M5 macro definitions. It will not appear
   // in the resulting TLV code (in the NAV-TLV tab).
   use(m5-1.0) // Use M5 libraries
   
\SV
   // Register File
   module regfile(input logic clk,
      input logic we3,
      input logic [ 4:0] a1, a2, a3,
      input logic [31:0] wd3,
      output logic [31:0] rd1, rd2);
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

   // Unified Memory
   module mem(input logic clk, we,
      input logic [31:0] a, wd,
      output logic [31:0] rd);
      logic [31:0] RAM[127:0]; // increased size of memory
      initial
         begin
            RAM[0] = 32'h00500113;
            RAM[1] = 32'h00C00193;
            RAM[2] = 32'hFF718393;
            RAM[3] = 32'h0023E233;
            RAM[4] = 32'h0041F2B3;
            RAM[5] = 32'h004282B3;
            RAM[6] = 32'h003292b3;
            RAM[7] = 32'h0022d2b3;
            RAM[8] = 32'h00329463;
            RAM[9] = 32'h003292b3;
            RAM[10] = 32'h02728863;
            RAM[11] = 32'h0041A233;
            RAM[12] = 32'h00020463;
            RAM[13] = 32'h00000293;
            RAM[14] = 32'h0023A233;
            RAM[15] = 32'h005203B3;
            RAM[16] = 32'h402383B3;
            RAM[17] = 32'h0c71a423;
            RAM[18] = 32'h0d402103;
            RAM[19] = 32'h005104B3;
            RAM[20] = 32'h008001EF;
            RAM[21] = 32'h00100113;
            RAM[22] = 32'h00910133;
            RAM[23] = 32'hfff00213;
            RAM[24] = 32'h00100293;
            RAM[25] = 32'h01f00313;
            RAM[26] = 32'h00629333;
            RAM[27] = 32'h006242b3;
            RAM[28] = 32'h0042a333;
            RAM[29] = 32'h00031063;
            RAM[30] = 32'h00314133;
            RAM[31] = 32'h0821a223;
            RAM[32] = 32'h00210063;
         end
      assign rd = RAM[a[31:2]]; // word aligned
      always_ff @(posedge clk)
         if (we) RAM[a[31:2]] <= wd;
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
               if(DataAdr === 216 & WriteData === 4140) begin
                  $display("Simulation succeeded");
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
      $pcwrite = 1'b0;
      $irwrite = 1'b0;
      $adrsrc = 1'b0;
      $op[6:0] = /top/mem$instr[6:0];
      $funct3[2:0] = /top/mem$instr[14:12];
      $funct7b5 = /top/mem$instr[30];
   /datapath
      /pc
         $pc[31:0] = /top<>0$reset ? 32'b0 :
                     (/top/controller$pcwrite == 1'b1 ? >>1$result : 32'bx);
         $oldpc[31:0] = /top<>0$reset ? 32'b0 :
                        (/top/controller$irwrite == 1'b1 ? >>1$pc : 32'bx);
      /mem
         $adr[31:0] = $adrsrc == 1'b1 ? $result : $pc;
         $instr[31:0] = /top<>0$reset ? 32'b0 :
                         (/top/controller$irwrite == 1'b1 ? >>1$readdata : 32'bx);
         $data[31:0] = /top<>0$reset ? 32'b0 : >>1$readdata;
\SV
      regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RD1, RD2);
\TLV  
   /datapath
      /regfile
         $rd1 = *RD1;
         $rd2 = *RD2;
         /extend
            \always_comb
            $immext[31:0] = // I-type 
                            /top/controller$immsrc == 3'b000 ?
                            {{20{/top/mem$instr[31]}}, /top/mem$instr[31:20]} :
                            // S-type (stores)
                            /top/controller$immsrc == 3'b001 ?
                            {{20{/top/mem$instr[31]}}, /top/mem$instr[31:25],
                            /top/mem$instr[11:7]} :
                            // B-type (branches)
                            /top/controller$immsrc == 3'b010 ?
                            {{20{/top/mem$instr[31]}}, /top/mem$instr[7],
                            /top/mem$instr[30:25], /top/mem$instr[11:8], 1'b0} :
                            // J-type (jal)
                            /top/controller$immsrc == 3'b011 ?
                            {{12{/top/mem$instr[31]}}, /top/mem$instr[19:12],
                            /top/mem$instr[20], /top/mem$instr[30:21], 1'b0} :
                            // U-type (lui, auipc)
                            /top/controller$immsrc == 3'b100 ?
                            {/top/mem$instr[31:12], 12'b0} :
                            // undefined
                            32'bx;
         $a = /top<>0$reset ? 32'b0 : >>1$rd1;
         $writedata = /top<>0$reset ? 32'b0 : >>1$rd2;
      /alu
         $srca = /top/controller$alusrca[1] == 1'b1 ? /top/datapath/regfile$a :
                 (/top/controller$alusrca[0] == 1'b1 ? /top/datapath/pc$oldpc :
                                                       /top/datapath/pc$pc);
         $srcb = /top/controller$alusrcb[1] == 1'b1 ? 32'd4 :
                 (/top/controller$alusrcb[0] == 1'b1 ? /top/datapath/regfile/extend$immext :
                                                       /top/datapath/regfile$writedata);
         $flags[3:0] = {$v, $c, $n, $z};
         $condinvb[31:0] = $alucontrol[0] ? ~$srcb : $srcb;
         $coutsum[32:0] = $srca + $condinvb + $alucontrol[0];
         $isAddSub = ~$alucontrol[3] & ~$alucontrol[2] &
                     ~$alucontrol[1] | ~$alucontrol[3] &
                     ~$alucontrol[1] & $alucontrol[0];
         \always_comb
            $aluresult[31:0] = $alucontrol == 4'b0000 ? $coutsum{31:0] : // add
                            $alucontrol == 4'b0001 ? $coutsum[31:0] : // subtract
                            $alucontrol == 4'b0010 ? $srca & $srcb : // and
                            $alucontrol == 4'b0011 ? $srca | $srcb : // or
                            $alucontrol == 4'b0100 ? $srca ^ $srcb : // xor
                            $alucontrol == 4'b0101 ? $coutsum[32] ^ v : // slt
                            $alucontrol == 4'b0110 ? a << $srcb[4:0] : // sll
                            $alucontrol == 4'b0111 ? a >> $srcb[4:0] : // srl
                            $alucontrol == 4'b1000 ? $signed($srca) >>> $srcb[4:0] : // sra
                                                     32'bx;
         $z = ($aluresult == 32'b0);
         $n = $aluresult[31];
         $c = $coutsum[32] & $isAddSub;
         $v = ~($alucontrol[0] ^ $srca[31] ^ $srcb[31]) & ($srca[31] ^ $sum[31]) & $isAddSub;
         $aluout[31:0] = /top<>0$reset ? >>1$aluresult;
         $result[31:0] = /top/controller$resultsrc[1] == 1'b1 ? $aluresult :
                   (/top/controller$resultsrc[0] == 1'b1 ? $data : $aluout);
\TLV
   /mem
      // DataAdr is sourced either from aluresult or from PC calculation
      *DataAdr = /top/datapath/alu$aluresult;
      // Depending on state, the Read Data is either readdata or instr
      $instr[31:0] = *ReadData;
      $readdata[31:0] = *ReadData;
\SV
   mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);
   endmodule


