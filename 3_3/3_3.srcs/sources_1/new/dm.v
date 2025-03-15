//// data memory
//// 数据存储器模块，支持 Word、Halfword、Byte 级别的读写
module dm (
    input          clk,
    input          DMWr,        // Memory write enable
    input  [8:2]   addr,        // Word-aligned address
    input  [31:0]  din,         // Data input
    input  [2:0]   DMType,      // 数据类型控制信号
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
                default:                  dmem[addr[8:2]] <= din;                // 默认32-bit写入
            endcase
            $display("dmem[0x%8X] = 0x%8X,", addr << 2, din);
        end
    end

    // 读取操作 (支持符号扩展和零扩展)
    assign dout = (DMType == `dm_word) ? dmem[addr[8:2]] :                        // 32-bit Word
                  (DMType == `dm_halfword) ? {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]} :  // 16-bit Halfword (signed)
                  (DMType == `dm_halfword_unsigned) ? {16'b0, dmem[addr[8:2]][15:0]} :             // 16-bit Halfword (unsigned)
                  (DMType == `dm_byte) ? {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]} :        // 8-bit Byte (signed)
                  (DMType == `dm_byte_unsigned) ? {24'b0, dmem[addr[8:2]][7:0]} :                  // 8-bit Byte (unsigned)
                  32'h00000000;  // Default: return zero if DMType is invalid

endmodule
//关键：  地址对齐问题：
//在 RISC-V 中，存储器的地址是按字节（8 位）寻址的。
//对于字（32 位）访问，地址需要按 4 字节对齐；对于半字（16 位）访问，地址需要按 2 字节对齐。

//计算字地址：
//字地址是 addr[8:2]，即去掉地址的低 2 位（因为字是 4 字节对齐的）。

//根据地址低位确定写入位置：
//对于半字（16 位）写入，需要根据 addr[1] 来确定是写入字的高半部分还是低半部分。
//对于字节（8 位）写入，需要根据 addr[1:0] 来确定是写入字的哪个字节。
//下面代码还有改进空间，只传入addr的[8:2]位，即只传入字地址，低两位默认为00
//module dm (
//    input          clk,
//    input          DMWr,        // Memory write enable
//    input  [8:2]   addr,        // Byte-aligned address
//    input  [31:0]  din,         // Data input
//    input  [2:0]   DMType,      // 数据类型控制信号
//    output [31:0]  dout         // Data output
//);
//    reg [31:0] dmem[127:0];  // 128 words (32-bit each)

//    // 写入逻辑
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
//                        dmem[addr[8:2]][15:0] <= din[15:0];  // 写入低半字
//                    end else begin
//                        dmem[addr[8:2]][31:16] <= din[15:0]; // 写入高半字
//                    end
//                end
//                `dm_byte, `dm_byte_unsigned: begin
//                    // 8-bit Byte
//                    case (addr[1:0])
//                        2'b00: dmem[addr[8:2]][7:0]   <= din[7:0];   // 写入字节 0
//                        2'b01: dmem[addr[8:2]][15:8]  <= din[7:0];   // 写入字节 1
//                        2'b10: dmem[addr[8:2]][23:16] <= din[7:0];   // 写入字节 2
//                        2'b11: dmem[addr[8:2]][31:24] <= din[7:0];   // 写入字节 3
//                    endcase
//                end
//                default: begin
//                    // 默认32-bit写入
//                    dmem[addr[8:2]] <= din;
//                end
//            endcase
//            $display("dmem[0x%8X] = 0x%8X,", addr << 2, din);
//        end
//    end

//    // 读取逻辑 (支持符号扩展和零扩展)
//    assign dout = (DMType == `dm_word) ? dmem[addr[8:2]] :                        // 32-bit Word
//                  (DMType == `dm_halfword) ? {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]} :  // 16-bit Halfword (signed)
//                  (DMType == `dm_halfword_unsigned) ? {16'b0, dmem[addr[8:2]][15:0]} :             // 16-bit Halfword (unsigned)
//                  (DMType == `dm_byte) ? {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]} :        // 8-bit Byte (signed)
//                  (DMType == `dm_byte_unsigned) ? {24'b0, dmem[addr[8:2]][7:0]} :                  // 8-bit Byte (unsigned)
//                  32'h00000000;  // Default: return zero if DMType is invalid

//endmodule