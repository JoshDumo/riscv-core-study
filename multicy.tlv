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
   
\SV
      mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);
   endmodule
