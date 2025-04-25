`include "alu.v"
`timescale 1ns / 1ps

module calc( input clk,
            input btnc, btnl,
            input btnu, btnr,
            input btnd,
            input [15:0] sw, 
            output [15:0] led
           );
  
  reg [15:0] accumulator;
  wire [31:0] op1 = {{16{accumulator[15]}}, accumulator};
  wire [31:0] op2 = {{16{sw[15]}}, sw};
  
  
  // Σύνδεση με την ALU
    wire [31:0] result;
    wire zero;
    wire [3:0] alu_op;

    ALU my_alu (
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );
  
  // Υπολογισμός του alu_op μέσω του calc_enc
   calc_enc encoder (
        .btnc(btnc),
        .btnl(btnl),
        .btnr(btnr),
        .alu_op(alu_op)
    );
  
   // Λογική του accumulator
   always @(posedge clk) begin
       if (btnu) begin
           accumulator <= 16'b0;
         end 
       else 
           if (btnd) begin
              accumulator <= result[15:0];
           end
   end
  
   // Σύνδεση του accumulator με τα LEDs
   assign led = accumulator;

endmodule
  


  
  
  
            
