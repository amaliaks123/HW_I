`timescale 1ns / 1ps

module calc_tb();

    reg clk;
    reg btnc, btnl, btnu, btnr, btnd;
    reg [15:0] sw;
    wire [15:0] led;

    // Instantiate calc module
    calc uut (
        .clk(clk),
        .btnc(btnc),
        .btnl(btnl),
        .btnu(btnu),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
    );

    // Clock generation
    initial begin
      clk = 0;
      forever #5 clk = ~clk;
    end
  
    initial begin
       $dumpfile("calc_tb.vcd"); // Specify the waveform output file
       $dumpvars(0, calc_tb);    // Dump all variables in the testbench scope
    end

    
  
    initial begin
        // Αρχικοποίηση
        btnc = 0; btnl = 0; btnu = 0; btnr = 0; btnd = 0; sw = 16'b0;

        //Έλεγχος RESET
        btnu = 1; // Πατάμε κουμπί reset
        #10;
        btnu = 0;
        #10;
        $display("Test RESET: LED = %h (expected 0x0)", led);

        //Έλεγχος ADD
        btnl = 0; btnc = 1; btnr = 0; //ADD
        sw = 16'h354a;
        btnd = 1;
        #10;
        btnd = 0;
        #10;
        $display("Test ADD: LED = %h (expected 0x354a)", led);

      
        //Έλεγχος SUB
        btnl = 0; btnc = 1; btnr = 1; //SUB
        sw = 16'h1234;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test SUB: LED = %h (expected 0x2316)", led);

        //Έλεγχος OR
        btnl = 0; btnc = 0; btnr = 1; //OR
        sw = 16'h1001;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test OR: LED = %h (expected 0x3317)", led);

        //Έλεγχος AND
        btnl = 0; btnc = 0; btnr = 0; //AND
        sw = 16'hf0f0;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test AND: LED = %h (expected 0x3010)", led);

        //Έλεγχος XOR
        btnl = 1; btnc = 1; btnr = 1; //XOR
        sw = 16'h1fa2;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test XOR: LED = %h (expected 0x2fb2)", led);
      
        //Έλεγχος ADD
        btnl = 0; btnc = 1; btnr = 0; //ADD
        sw = 16'h6aa2;
        btnd = 1;
        #10;
        btnd = 0;
        #10;
        $display("Test ADD: LED = %h (expected 0x9a54)", led);

        //Έλεγχος Logical Shift Left
        btnl = 1; btnc = 0; btnr = 1; //LSL
        sw = 16'h0004;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test LSL: LED = %h (expected 0x9a54)", led);

        //Έλεγχος Shift Right Arithmetic
        btnl = 1; btnc = 1; btnr = 0; //SRA
        sw = 16'h0001;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test SRA: LED = %h (expected 0xd2a0)", led);

        //Έλεγχος Less Than
        btnl = 1; btnc = 0; btnr = 0; //LT
        sw = 16'h46ff;
        btnd = 1; 
        #10;
        btnd = 0;
        #10;
        $display("Test LT: LED = %h (expected 0x0001)", led);

        $finish; 
    end
endmodule
    
