`timescale 1ns/1ps

module ALU( input wire [31:0] op1,
           input wire [31:0] op2,
           input wire [3:0] alu_op,
           output reg [31:0] result,
           output reg zero
          );
  
   // ALU operation parameters
    parameter AND_OP     = 4'b0000;
    parameter OR_OP      = 4'b0001;
    parameter ADD_OP     = 4'b0010;
    parameter SUB_OP     = 4'b0110;
    parameter SLT_OP     = 4'b0100;
    parameter LSR_OP     = 4'b1000;
    parameter LSL_OP     = 4'b1001;
    parameter ARSR_OP    = 4'b1010;
    parameter XOR_OP     = 4'b0101;
  
  always @(*)
    begin : ALU_OPERATION
      case(alu_op)
            AND_OP:   result = op1 & op2;    
            OR_OP:    result = op1 | op2;    
            ADD_OP:   result = op1 + op2;    
            SUB_OP:   result = op1 - op2;
            SLT_OP:   result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0; 
            LSR_OP:   result = op1 >> op2[4:0]; 
            LSL_OP:   result = op1 << op2[4:0];  
        ARSR_OP:  result = $unsigned($signed(op1) >>> op2[4:0]);            
            XOR_OP:   result = op1 ^ op2;  
            default:  result = 32'b0;       
        endcase
      
      zero = ( result == 32'b0 );
   end  
endmodule
