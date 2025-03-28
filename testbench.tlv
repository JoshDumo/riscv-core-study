\m5_TLV_version 1d: tl-x.org
\m5
   // This region contains M5 macro definitions. It will not appear
   // in the resulting TLV code (in the NAV-TLV tab).
   use(m5-1.0) // Use M5 libraries
   
\TLV riscvsingle($clk, $reset, $pc, $instr, $memwrite, $dataadr, $writedata, $readdata)


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
