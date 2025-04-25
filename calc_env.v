`timescale 1ns / 1ps

module calc_enc (
    input btnc,
    input btnl,
    input btnr,
    output [3:0] alu_op
);
  

  assign alu_op[0] = (~btnc & btnr) | (btnl & btnr);
    assign alu_op[1] = (~btnl & btnc) | (btnc & ~btnr);
  assign alu_op[2] = (btnc & btnr) | ((~btnc & btnl) & ~btnr);
  assign alu_op[3] = ((btnl & ~btnc) & btnr) | ((btnl & btnc) & ~btnr);

endmodule
