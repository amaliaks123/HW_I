
module regfile #(parameter DATAWIDTH = 32)(
  input clk,                      // Ρολόι
  input [4:0] readReg1,           // Διεύθ θύρας ανάγνωσης 1
  input [4:0] readReg2,           // Διεύθ θύρας ανάγνωσης 2
  input [4:0] writeReg,           // Διεύθ θύρας εγγραφής
  input [DATAWIDTH-1:0] writeData,// Δεδομένα προς εγγραφή
  input write,                    // Σήμα εγγραφής
  output reg [DATAWIDTH-1:0] readData1, //Δεδ ανάγν. θύρας 1
  output reg [DATAWIDTH-1:0] readData2  // Δεδ ανάγν. θύρας 2
);
  
  reg [DATAWIDTH-1:0] reg_file[31:0];
  
  
  initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
      reg_file[i] = {DATAWIDTH{1'b0}};
    end
  end

    
  always @(posedge clk) begin
    if (write) 
      reg_file[writeReg] <= writeData; 
  end
      
  always @(readReg1 or readReg2 or writeReg or writeData or write) begin
    readData1 = (write && (writeReg == readReg1)) ? writeData : reg_file[readReg1];
    readData2 = (write && (writeReg == readReg2)) ? writeData : reg_file[readReg2];
    end

endmodule 
