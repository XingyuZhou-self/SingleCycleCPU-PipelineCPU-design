//// data memory
//// ���ݴ洢��ģ�飬֧�� Word��Halfword��Byte ����Ķ�д
module dm (
    input          clk,
    input          DMWr,        // Memory write enable
    input  [8:2]   addr,        // Word-aligned address
    input  [31:0]  din,         // Data input
    input  [2:0]   DMType,      // �������Ϳ����ź�
    output [31:0]  dout         // Data output
);
    reg [31:0] dmem[127:0];

    always @(posedge clk) begin
        if (DMWr) begin
            case (DMType)
                `dm_word:                 dmem[addr[8:2]] <= din;                // 32-bit Word
                `dm_halfword:             dmem[addr[8:2]][15:0]  <= din[15:0];   // 16-bit Halfword (signed)
                `dm_halfword_unsigned:    dmem[addr[8:2]][15:0]  <= din[15:0];   // 16-bit Halfword (unsigned)
                `dm_byte:                 dmem[addr[8:2]][7:0]   <= din[7:0];    // 8-bit Byte (signed)
                `dm_byte_unsigned:        dmem[addr[8:2]][7:0]   <= din[7:0];    // 8-bit Byte (unsigned)
                default:                  dmem[addr[8:2]] <= din;                // Ĭ��32-bitд��
            endcase
            $display("dmem[0x%8X] = 0x%8X,", addr << 2, din);
        end
    end

    // ��ȡ���� (֧�ַ�����չ������չ)
    assign dout = (DMType == `dm_word) ? dmem[addr[8:2]] :                        // 32-bit Word
                  (DMType == `dm_halfword) ? {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]} :  // 16-bit Halfword (signed)
                  (DMType == `dm_halfword_unsigned) ? {16'b0, dmem[addr[8:2]][15:0]} :             // 16-bit Halfword (unsigned)
                  (DMType == `dm_byte) ? {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]} :        // 8-bit Byte (signed)
                  (DMType == `dm_byte_unsigned) ? {24'b0, dmem[addr[8:2]][7:0]} :                  // 8-bit Byte (unsigned)
                  32'h00000000;  // Default: return zero if DMType is invalid

endmodule
//�ؼ���  ��ַ�������⣺
//�� RISC-V �У��洢���ĵ�ַ�ǰ��ֽڣ�8 λ��Ѱַ�ġ�
//�����֣�32 λ�����ʣ���ַ��Ҫ�� 4 �ֽڶ��룻���ڰ��֣�16 λ�����ʣ���ַ��Ҫ�� 2 �ֽڶ��롣

//�����ֵ�ַ��
//�ֵ�ַ�� addr[8:2]����ȥ����ַ�ĵ� 2 λ����Ϊ���� 4 �ֽڶ���ģ���

//���ݵ�ַ��λȷ��д��λ�ã�
//���ڰ��֣�16 λ��д�룬��Ҫ���� addr[1] ��ȷ����д���ֵĸ߰벿�ֻ��ǵͰ벿�֡�
//�����ֽڣ�8 λ��д�룬��Ҫ���� addr[1:0] ��ȷ����д���ֵ��ĸ��ֽڡ�
//������뻹�иĽ��ռ䣬ֻ����addr��[8:2]λ����ֻ�����ֵ�ַ������λĬ��Ϊ00
//module dm (
//    input          clk,
//    input          DMWr,        // Memory write enable
//    input  [8:2]   addr,        // Byte-aligned address
//    input  [31:0]  din,         // Data input
//    input  [2:0]   DMType,      // �������Ϳ����ź�
//    output [31:0]  dout         // Data output
//);
//    reg [31:0] dmem[127:0];  // 128 words (32-bit each)

//    // д���߼�
//    always @(posedge clk) begin
//        if (DMWr) begin
//            case (DMType)
//                `dm_word: begin
//                    // 32-bit Word (aligned to 4 bytes)
//                    dmem[addr[8:2]] <= din;
//                end
//                `dm_halfword, `dm_halfword_unsigned: begin
//                    // 16-bit Halfword (aligned to 2 bytes)
//                    if (addr[1] == 1'b0) begin
//                        dmem[addr[8:2]][15:0] <= din[15:0];  // д��Ͱ���
//                    end else begin
//                        dmem[addr[8:2]][31:16] <= din[15:0]; // д��߰���
//                    end
//                end
//                `dm_byte, `dm_byte_unsigned: begin
//                    // 8-bit Byte
//                    case (addr[1:0])
//                        2'b00: dmem[addr[8:2]][7:0]   <= din[7:0];   // д���ֽ� 0
//                        2'b01: dmem[addr[8:2]][15:8]  <= din[7:0];   // д���ֽ� 1
//                        2'b10: dmem[addr[8:2]][23:16] <= din[7:0];   // д���ֽ� 2
//                        2'b11: dmem[addr[8:2]][31:24] <= din[7:0];   // д���ֽ� 3
//                    endcase
//                end
//                default: begin
//                    // Ĭ��32-bitд��
//                    dmem[addr[8:2]] <= din;
//                end
//            endcase
//            $display("dmem[0x%8X] = 0x%8X,", addr << 2, din);
//        end
//    end

//    // ��ȡ�߼� (֧�ַ�����չ������չ)
//    assign dout = (DMType == `dm_word) ? dmem[addr[8:2]] :                        // 32-bit Word
//                  (DMType == `dm_halfword) ? {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]} :  // 16-bit Halfword (signed)
//                  (DMType == `dm_halfword_unsigned) ? {16'b0, dmem[addr[8:2]][15:0]} :             // 16-bit Halfword (unsigned)
//                  (DMType == `dm_byte) ? {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]} :        // 8-bit Byte (signed)
//                  (DMType == `dm_byte_unsigned) ? {24'b0, dmem[addr[8:2]][7:0]} :                  // 8-bit Byte (unsigned)
//                  32'h00000000;  // Default: return zero if DMType is invalid

//endmodule