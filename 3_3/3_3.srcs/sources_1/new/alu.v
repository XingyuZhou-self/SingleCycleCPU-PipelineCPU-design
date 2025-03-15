`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero, PC);
   input  signed [31:0] A, B;
   input         [4:0]  ALUOp;
   input  [31:0] PC;
   output signed [31:0] C;
   output Zero;
   
   reg [31:0] C;
       
   always @(*) begin
      case (ALUOp)
        `ALUOp_nop   : C = A;
        `ALUOp_lui   : C = B;                          // LUI: 直接使用立即数
        `ALUOp_auipc : C = PC + B;                     // AUIPC: PC + 立即数
        `ALUOp_add   : C = A + B;
        `ALUOp_sub   : C = A - B;                      // BEQ/BNE使用SUB
        `ALUOp_xor   : C = A ^ B;
        `ALUOp_or    : C = A | B;
        `ALUOp_and   : C = A & B;
        `ALUOp_sll   : C = A << B[4:0];
        `ALUOp_srl   : C = A >> B[4:0];
        `ALUOp_sra   : C = A >>> B[4:0];
        `ALUOp_slt   : C = {31'b0, (A < B)};           // SLT
        `ALUOp_sltu  : C = {31'b0, ($unsigned(A) < $unsigned(B))};
        `ALUOp_blt   : C = {31'b0, (A < B)};           // BLT (有符号)
        `ALUOp_bge   : C = {31'b0, (A >= B)};          // BGE (有符号)
        `ALUOp_bltu  : C = {31'b0, ($unsigned(A) < $unsigned(B))}; // BLTU
        `ALUOp_bgeu  : C = {31'b0, ($unsigned(A) >= $unsigned(B))};// BGEU
        default      : C = 0;
      endcase
   end
   
   assign Zero = (C == 32'b0); // BEQ依赖此信号（当A==B时，SUB结果C=0→Zero=1）
endmodule