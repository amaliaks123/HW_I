`timescale 1ns/1ps
`include "datapath.v"


module top_proc #(
    parameter INITIAL_PC = 32'h0000_0000
)(
    input clk,
    input rst,
    input [31:0] instr,
    input [31:0] dReadData,
    output [31:0] PC,
    output [31:0] dAddress,
    output [31:0] dWriteData,
    output MemRead,
    output MemWrite,
    output [31:0] WriteBackData
);
  
    

    // Σήματα ελέγχου
    reg MemRead_reg, MemWrite_reg, ALUSrc, MemToReg, RegWrite, loadPC, PCSrc;
    reg [3:0] ALUCtrl;

    // Ενδιάμεσες μεταβλητές
    wire [31:0] ALUResult, regData1, regData2, immData;
    wire Zero;

    // Συνδέσεις με τη διαδρομή δεδομένων (datapath)
    datapath #(.INITIAL_PC(INITIAL_PC)) dp (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .ALUSrc(ALUSrc),
        .ALUCtrl(ALUCtrl),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .loadPC(loadPC),
        .PCSrc(PCSrc),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .Zero(Zero)
     );

    typedef enum logic [2:0] {
      IF = 3'b000,  // Instruction Fetch
      ID = 3'b001,  // Instruction Decode
      EX = 3'b010,  // Execute
      MEM = 3'b011, // Memory Access
      WB = 3'b100   // Write Back
    } state_t;
  
    state_t state, next_state;
  
    always @(posedge clk or posedge rst) begin
       if (rst) 
           state <= IF; // Reset to IF state
       else 
           state <= next_state;
    end


    // FSM: Define next state logic
    always @(*) begin
        case (state)
            IF: next_state = ID;
            ID: next_state = EX;
            EX: next_state = MEM;
            MEM: next_state = WB; 
            WB: next_state = IF;  
            default: next_state = IF; 
        endcase
    end

    // Σήματα Ελέγχου ανά Κατάσταση
    always @(*) begin
        // Προεπιλεγμένες τιμές
      {MemRead_reg, MemWrite_reg, ALUSrc, MemToReg, RegWrite, loadPC, PCSrc} = 0;
        ALUCtrl = 4'b0000; // Default: ADD

       case (state)
          IF: begin // Instruction Fetch
             loadPC = 1;
             PCSrc = 0; // Default PC + 4
          end
          ID: begin // Instruction Decode
            case (instr[6:0])
                 7'b0010011, 7'b0000011: begin // I
                    ALUSrc = 1; // Imm as 2nd operand
                 end
                 7'b1100011: begin // B-type (BEQ)
                    ALUSrc = 0; //2nd op from register
                 end
                 7'b0100011: begin // S-type (SW)
                    ALUSrc = 1; // Imm for mem address
                 end
            endcase     
          end
          EX: begin
            // ALU Control Logic
            case (instr[6:0])
               7'b0110011: begin // R-Type
                 case ({instr[30], instr[14:12]})
                    4'b0000: ALUCtrl = 4'b0010; // ADD
                    4'b1000: ALUCtrl = 4'b0110; // SUB
                    4'b0111: ALUCtrl = 4'b0000; // AND
                    4'b0110: ALUCtrl = 4'b0001; // OR
                    4'b0100: ALUCtrl = 4'b1010; // XOR
                    default: ALUCtrl = 4'b0000; 
                  endcase
               end
               7'b0010011: begin // I-Type
                  ALUSrc = 1;
                  case (instr[14:12])
                    3'b000: ALUCtrl = 4'b0010; // ADDI
                    3'b100: ALUCtrl = 4'b1010; // XORI
                    3'b110: ALUCtrl = 4'b0001; // ORI
                    3'b111: ALUCtrl = 4'b0000; // ANDI
                    default: ALUCtrl = 4'b0000;
                  endcase
               end
               7'b0000011, 7'b0100011: begin // LW/SW
                  ALUSrc = 1; 
                  ALUCtrl = 4'b0010;  
               end
               7'b1100011: begin // BEQ
                  ALUCtrl = 4'b0110; // SUB
                  PCSrc = Zero; 
               end
           endcase
         end
         MEM: begin // Memory Access
           MemRead_reg = (instr[6:0] == 7'b0000011); // LW
           MemWrite_reg = (instr[6:0] == 7'b0100011); // SW
         end
         WB: begin
            // Write back to registers
            RegWrite = 1;
            MemToReg = (instr[6:0] == 7'b0000011); // LW
            loadPC = 1;
               
        end
     endcase
    end
 
    // Αναθέσεις εξόδου
    assign MemRead = MemRead_reg;
    assign MemWrite = MemWrite_reg;

endmodule
