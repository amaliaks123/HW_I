`timescale 1ns/1ps
`include "alu.v"
`include "regfile.v"

module datapath #(parameter  INITIAL_PC = 32'h00400000)(
  input clk,
  input rst,
  input [31:0] instr,
  input PCSrc,
  input ALUSrc,
  input RegWrite,
  input MemToReg,
  input [3:0] ALUCtrl,
  input loadPC,
  output reg [31:0] PC,
  output Zero,
  output [31:0] dAddress,
  output [31:0] dWriteData,
  input [31:0] dReadData,
  output [31:0] WriteBackData
);
  
  // Internal wires and registers
  reg [31:0] branch_offset;
  reg [31:0] immediate;
  wire [31:0] readData1, readData2, aluResult;
  reg [31:0] aluOp2;
  wire [31:0] writeBackDataMux;
  reg [31:0] nextPC;

  
  // Instruction fields
  wire [6:0] opcode = instr[6:0];
  wire [4:0] rd = instr[11:7];
  wire [4:0] rs1 = instr[19:15];
  wire [4:0] rs2 = instr[24:20];
  
  regfile registers (
      .clk(clk),
      .readReg1(rs1),
      .readReg2(rs2),
      .writeReg(rd),
      .writeData(writeBackDataMux),
      .write(RegWrite),
      .readData1(readData1),
      .readData2(readData2)
  );
  
    // Immediate generation
    always @(*) begin
        case (opcode)
            7'b0010011: // I-type
                immediate = {{20{instr[31]}}, instr[31:20]};
            7'b0100011: // S-type
                immediate = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: // B-type
              branch_offset = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            default:
                immediate = 32'b0;
        endcase
    end
   
  
  // Program Counter (PC) logic
  always @(posedge clk or posedge rst) begin
      if (rst)
          PC <= INITIAL_PC;
      else if (loadPC) 
          PC <= nextPC;
  end
  
  always @(*) begin
    if (PCSrc)
      nextPC = PC + branch_offset;
    else
      nextPC = PC + 4;
  end
  
    
  // ALU Operand Selection
  assign aluOp2 = (ALUSrc) ? immediate : readData2;

  // ALU
  ALU ALU_unit (
      .op1(readData1),
      .op2(aluOp2),
      .alu_op(ALUCtrl),
      .result(aluResult),
      .zero(Zero)
  );

 
  
  // Memory address and data output
    assign dAddress = aluResult;
    assign dWriteData = readData2;

    // Write-back logic
  assign writeBackDataMux = (MemToReg) ? dReadData : aluResult;
    assign WriteBackData = writeBackDataMux;

endmodule
