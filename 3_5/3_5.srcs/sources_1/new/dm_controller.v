module dm_controller(
  input        mem_w,                  // 是否写内存
  input [31:0] Addr_in,                // 字节地址
  input [31:0] Data_write,             // 待写入数据
  input [2:0]  dm_ctrl,                // 内存操作类型 (DMType)
  input [31:0] Data_read_from_dm,      // 从内存读取的原始数据
  output [31:0] Data_read,             // 对齐后的读取数据
  output [31:0] Data_write_to_dm,      // 处理后的写入数据
  output [3:0] wea_mem                 // 字节写使能信号
);

  reg [31:0] data_r;
  reg [31:0] data_w_to_dm;
  reg [3:0]  w_local;

  // 写逻辑：按小端序处理半字/字节写入
  always @(*) begin
    data_w_to_dm = 32'b0;
    w_local      = 4'b0000;

    if (mem_w) begin
      case (dm_ctrl)
        // Word (SW)
        `dm_word: begin
          data_w_to_dm = Data_write;
          w_local      = 4'b1111;      // 写入全部4字节
        end

        // Halfword (SH)
        `dm_halfword,`dm_halfword_unsigned: begin
          case (Addr_in[1:0])
            2'b00: begin
              data_w_to_dm  = {16'b0,Data_write[15:0]}; // 地址对齐到半字
              w_local             = 4'b0011;          // 使能低2字节
            end
            2'b10: begin
              data_w_to_dm = {Data_write[15:0],16'b0}; // 非对齐半字
              w_local             = 4'b1100;          // 使能高2字节
            end
            default: ; // 其他情况忽略（假设已处理地址错误）
          endcase
        end

        // Byte (SB)
        `dm_byte,`dm_byte_unsigned: begin
          case (Addr_in[1:0])
            2'b00: begin
              data_w_to_dm   ={24'b0, Data_write[7:0]};
              w_local             = 4'b0001;
            end
            2'b01: begin
              data_w_to_dm  = {16'b0,Data_write[7:0],8'b0};
              w_local             = 4'b0010;
            end
            2'b10: begin
              data_w_to_dm = {8'b0,Data_write[7:0],16'b0};
              w_local             = 4'b0100;
            end
            2'b11: begin
              data_w_to_dm = {Data_write[7:0],24'b0};
              w_local             = 4'b1000;
            end
          endcase
        end
      endcase
    end
  end

  // 读逻辑：按小端序提取数据并符号/零扩展
  always @(*) begin
    data_r = 32'b0;

    case (dm_ctrl)
      // Word (LW)
      3'b000: begin
        data_r = Data_read_from_dm;
      end

      // Signed Halfword (LH)
      3'b001: begin
        case (Addr_in[1:0])
          2'b00: data_r = {{16{Data_read_from_dm[15]}}, Data_read_from_dm[15:0]};
          2'b10: data_r = {{16{Data_read_from_dm[31]}}, Data_read_from_dm[31:16]};
          default: data_r = 32'b0; // 非对齐处理（可自定义）
        endcase
      end

      // Unsigned Halfword (LHU)
      3'b010: begin
        case (Addr_in[1:0])
          2'b00: data_r = {16'b0, Data_read_from_dm[15:0]};
          2'b10: data_r = {16'b0, Data_read_from_dm[31:16]};
          default: data_r = 32'b0;
        endcase
      end

      // Signed Byte (LB)
      3'b011: begin
        case (Addr_in[1:0])
          2'b00: data_r = {{24{Data_read_from_dm[7]}},  Data_read_from_dm[7:0]};
          2'b01: data_r = {{24{Data_read_from_dm[15]}}, Data_read_from_dm[15:8]};
          2'b10: data_r = {{24{Data_read_from_dm[23]}}, Data_read_from_dm[23:16]};
          2'b11: data_r = {{24{Data_read_from_dm[31]}}, Data_read_from_dm[31:24]};
        endcase
      end

      // Unsigned Byte (LBU)
      3'b100: begin
        case (Addr_in[1:0])
          2'b00: data_r = {24'b0, Data_read_from_dm[7:0]};
          2'b01: data_r = {24'b0, Data_read_from_dm[15:8]};
          2'b10: data_r = {24'b0, Data_read_from_dm[23:16]};
          2'b11: data_r = {24'b0, Data_read_from_dm[31:24]};
        endcase
      end

      default: data_r = 32'b0;
    endcase
  end

  assign Data_read       = data_r;
  assign Data_write_to_dm = data_w_to_dm;
  assign wea_mem         = w_local;

endmodule