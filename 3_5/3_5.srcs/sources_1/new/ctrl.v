module ctrl(
    input  [6:0] Op,       // opcode
    input  [6:0] Funct7,   // funct7
    input  [2:0] Funct3,   // funct3
    input        Zero,     // ���ڷ�֧�ж�

    output       RegWrite, // �Ƿ�д�Ĵ���
    output       MemWrite, // �Ƿ�д�洢��
    output [5:0] EXTOp,    // ��������չ��ʽ
    output [4:0] ALUOp,    // ALU ��������
    output [2:0] NPCOp,    // ��һ�� PC ѡ��
    output       ALUSrc,   // ALU �ĵڶ���������ѡ��
    output [2:0] DMType,   // �洢����������
    output [1:0] GPRSel,   // ͨ�üĴ���ѡ��
    output [1:0] WDSel     // д��Ĵ���������Դ
);
    
// ? **R-type ָ��**
wire rtype  = (Op == 7'b0110011);
wire i_add  = rtype & (Funct3 == 3'b000) & (Funct7 == 7'b0000000); // ADD
wire i_sub  = rtype & (Funct3 == 3'b000) & (Funct7 == 7'b0100000); // SUB
wire i_xor  = rtype & (Funct3 == 3'b100) & (Funct7 == 7'b0000000); // XOR
wire i_or   = rtype & (Funct3 == 3'b110) & (Funct7 == 7'b0000000); // OR
wire i_and  = rtype & (Funct3 == 3'b111) & (Funct7 == 7'b0000000); // AND
wire i_sll  = rtype & (Funct3 == 3'b001) & (Funct7 == 7'b0000000); // SLL
wire i_srl  = rtype & (Funct3 == 3'b101) & (Funct7 == 7'b0000000); // SRL
wire i_sra  = rtype & (Funct3 == 3'b101) & (Funct7 == 7'b0100000); // SRA
wire i_slt  = rtype & (Funct3 == 3'b010) & (Funct7 == 7'b0000000); // SLT
wire i_sltu = rtype & (Funct3 == 3'b011) & (Funct7 == 7'b0000000); // SLTU

// ? **I-type ָ��**
wire itype  = (Op == 7'b0010011);
wire i_addi = itype & (Funct3 == 3'b000); // ADDI
wire i_xori = itype & (Funct3 == 3'b100); // XORI
wire i_ori  = itype & (Funct3 == 3'b110); // ORI
wire i_andi = itype & (Funct3 == 3'b111); // ANDI
wire i_slli = itype & (Funct3 == 3'b001) & (Funct7 == 7'b0000000); // SLLI
wire i_srli = itype & (Funct3 == 3'b101) & (Funct7 == 7'b0000000); // SRLI
wire i_srai = itype & (Funct3 == 3'b101) & (Funct7 == 7'b0100000); // SRAI
wire i_slti = itype & (Funct3 == 3'b010); // SLTI
wire i_sltiu = itype & (Funct3 == 3'b011); // SLTIU

// ? **LUI & AUIPC**
wire i_lui   = (Op == 7'b0110111); // LUI
wire i_auipc = (Op == 7'b0010111); // AUIPC

// ? **��תָ��**
wire i_jal   = (Op == 7'b1101111); // JAL
wire i_jalr  = (Op == 7'b1100111); // JALR

// ? **��ָ֧��**
wire i_beq   = (Op == 7'b1100011) & (Funct3 == 3'b000); // BEQ
wire i_bne   = (Op == 7'b1100011) & (Funct3 == 3'b001); // BNE
wire i_blt   = (Op == 7'b1100011) & (Funct3 == 3'b100); // BLT
wire i_bge   = (Op == 7'b1100011) & (Funct3 == 3'b101); // BGE
wire i_bltu  = (Op == 7'b1100011) & (Funct3 == 3'b110); // BLTU
wire i_bgeu  = (Op == 7'b1100011) & (Funct3 == 3'b111); // BGEU

// ? **�洢������**
wire i_lb  = (Op == 7'b0000011) & (Funct3 == 3'b000); // LB
wire i_lh  = (Op == 7'b0000011) & (Funct3 == 3'b001); // LH
wire i_lw  = (Op == 7'b0000011) & (Funct3 == 3'b010); // LW
wire i_lbu = (Op == 7'b0000011) & (Funct3 == 3'b100); // LBU
wire i_lhu = (Op == 7'b0000011) & (Funct3 == 3'b101); // LHU

wire i_sb  = (Op == 7'b0100011) & (Funct3 == 3'b000); // SB
wire i_sh  = (Op == 7'b0100011) & (Funct3 == 3'b001); // SH
wire i_sw  = (Op == 7'b0100011) & (Funct3 == 3'b010); // SW

// ���� branch_taken �źţ��ؼ�������
wire beq_taken = i_beq & Zero;       // BEQ: A == B
wire bne_taken = i_bne & ~Zero;      // BNE: A != B
wire blt_taken = i_blt & ~Zero;      // BLT: A < B (�з���)
wire bge_taken = i_bge & ~Zero;      // BGE: A >= B (�з���)
wire bltu_taken = i_bltu & ~Zero;    // BLTU: A < B (�޷���)
wire bgeu_taken = i_bgeu & ~Zero;    // BGEU: A >= B (�޷���)
wire branch_taken = beq_taken | bne_taken | blt_taken | bge_taken | bltu_taken | bgeu_taken;

// ? **�����ź�**
assign RegWrite = rtype | itype | i_lui | i_auipc | i_jal | i_jalr | i_lb | i_lh | i_lw | i_lbu | i_lhu;
assign MemWrite = i_sb | i_sh | i_sw;
assign ALUSrc   = itype | i_lui | i_auipc | i_lb | i_lh | i_lw | i_lbu | i_lhu | i_sb | i_sh | i_sw;
// ����NPCOp�߼������ȼ���JALR > JAL > ��֧��
assign NPCOp = (i_jalr) ? 3'b100 : 
               (i_jal)  ? 3'b010 : 
               (branch_taken) ? 3'b001 : 
               3'b000;
// ? **���ݴ�ȡ**
assign WDSel = {i_jal | i_jalr, i_lb | i_lh | i_lw | i_lbu | i_lhu};
assign DMType = {
    i_lbu,                             // bit[2]
    i_lhu | i_lb | i_sb,               // bit[1]
    i_lh | i_sh | i_lb | i_sb          // bit[0]
};

// ����ALUOp���䣨�ؼ�����ָ֧��ʹ��SUB���ض��Ƚϣ�
assign ALUOp = 
    (i_add  | i_addi | i_lb | i_lh | i_lw | i_lbu | i_lhu | i_sb | i_sh | i_sw) ? `ALUOp_add  :
    (i_sub | i_beq | i_bne) ? `ALUOp_sub :  // BEQ/BNE����SUB
    (i_xor  | i_xori) ? `ALUOp_xor  :
    (i_or   | i_ori)  ? `ALUOp_or   :
    (i_and  | i_andi) ? `ALUOp_and  :
    (i_sll  | i_slli) ? `ALUOp_sll  :
    (i_srl  | i_srli) ? `ALUOp_srl  :
    (i_sra  | i_srai) ? `ALUOp_sra  :
    (i_slt  | i_slti) ? `ALUOp_slt  :
    (i_sltu | i_sltiu)? `ALUOp_sltu :
    (i_lui)           ? `ALUOp_lui  :
    (i_auipc)         ? `ALUOp_auipc:
    (i_blt)           ? `ALUOp_blt  :
    (i_bge)           ? `ALUOp_bge  :
    (i_bltu)          ? `ALUOp_bltu :
    (i_bgeu)          ? `ALUOp_bgeu :
    `ALUOp_nop;
assign EXTOp = 
    (i_addi | i_xori | i_ori | i_andi | i_slti | i_sltiu | i_jalr | i_lb | i_lh | i_lw | i_lbu | i_lhu) ? `EXT_CTRL_ITYPE :
    (i_sb | i_sh | i_sw) ? `EXT_CTRL_STYPE :
    (i_beq | i_bne | i_blt | i_bge | i_bltu | i_bgeu) ? `EXT_CTRL_BTYPE :
    (i_lui | i_auipc) ? `EXT_CTRL_UTYPE :
    (i_jal) ? `EXT_CTRL_JTYPE :
    (i_slli | i_srli | i_srai) ? `EXT_CTRL_ITYPE_SHAMT :
    6'b000000; // Ĭ��ֵ
endmodule
