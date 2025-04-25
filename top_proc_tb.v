`timescale 1ns/1ps
`include "rom.v"
`include "ram.v"


module top_proc_tb;

    // Σήματα του DUT
    reg clk;
    reg rst;
    wire [31:0] instr;
    wire [31:0] dReadData;
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire MemRead;
    wire MemWrite;
    wire [31:0] WriteBackData;

    // Σύνδεση με το DUT
    top_proc #(.INITIAL_PC(32'h0000_0000)) dut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WriteBackData(WriteBackData)
    );

    // ROM: Μνήμη Εντολών
    INSTRUCTION_MEMORY instr_memory (
        .clk(clk),
        .addr(PC[8:0]),   
        .dout(instr)  // Έξοδος εντολής
    );

    // RAM: Μνήμη Δεδομένων
    DATA_MEMORY data_memory (
        .clk(clk),
        .we(MemWrite),          // Σήμα εγγραφής
        .addr(dAddress[8:0]),   
        .din(dWriteData),   // Δεδομένα προς εγγραφή
        .dout(dReadData)   // Δεδομένα ανάγνωσης       
    );
  
    // Ρολόι
    always #5 clk = ~clk;
 

    // Αρχικοποίηση Testbench
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;

        // Reset processor
        #10;
        rst = 0;

        // Run simulation
        #500;

        // Finish simulation
        $finish;
    end
  
  initial begin
    $monitor($time, " PC=%d, instr=%b, dAddress=%h, dWriteData=%h, MemRead=%b, MemWrite=%b, WriteBackData=%h", 
                 PC, instr, dAddress, dWriteData, MemRead, MemWrite, WriteBackData);
    end
  
  // Waveform generation
    initial begin
      $dumpfile("top_proc_tb.vcd"); // Output waveform file
        $dumpvars(0, top_proc_tb);   // Dump all variables in this module
    end
  
endmodule
