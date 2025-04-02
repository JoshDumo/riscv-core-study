\m5_TLV_version 1d: tl-x.org
\m5
   // This region contains M5 macro definitions. It will not appear
   // in the resulting TLV code (in the NAV-TLV tab).
   use(m5-1.0) // Use M5 libraries
   
\SV


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

   endmodule
