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
        `ALUOp_lui   : C = B;                          // LUI: ֱ��ʹ��������
        `ALUOp_auipc : C = PC + B;                     // AUIPC: PC + ������
        `ALUOp_add   : C = A + B;
        `ALUOp_sub   : C = A - B;                      // BEQ/BNEʹ��SUB
        `ALUOp_xor   : C = A ^ B;
        `ALUOp_or    : C = A | B;
        `ALUOp_and   : C = A & B;
        `ALUOp_sll   : C = A << B[4:0];
        `ALUOp_srl   : C = A >> B[4:0];
        `ALUOp_sra   : C = A >>> B[4:0];
        `ALUOp_slt   : C = {31'b0, (A < B)};           // SLT
        `ALUOp_sltu  : C = {31'b0, ($unsigned(A) < $unsigned(B))};
        `ALUOp_blt   : C = {31'b0, (A < B)};           // BLT (�з���)
        `ALUOp_bge   : C = {31'b0, (A >= B)};          // BGE (�з���)
        `ALUOp_bltu  : C = {31'b0, ($unsigned(A) < $unsigned(B))}; // BLTU
        `ALUOp_bgeu  : C = {31'b0, ($unsigned(A) >= $unsigned(B))};// BGEU
        default      : C = 0;
      endcase
   end
   
   assign Zero = (C == 32'b0); // BEQ�������źţ���A==Bʱ��SUB���C=0��Zero=1��
endmodule