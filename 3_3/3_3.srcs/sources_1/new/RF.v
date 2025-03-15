module RF(
    input         clk, 
    input         rst,
    input         RFWr, 
    input  [4:0]  A1, A2, A3, 
    input  [31:0] WD, 
    output [31:0] RD1, RD2
);

    reg [31:0] rf[31:0];  // 32 个 32 位寄存器
    integer i;

    // **初始化寄存器**
    always @(posedge clk or posedge rst) begin
        if (rst) begin  
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;  // 所有寄存器清零
        end
        else if (RFWr && A3 != 0) begin  
            rf[A3] <= WD;  // **只有 A3 不是 0 时才写入**
        end
    end

    // **读寄存器**
    assign RD1 = (A1 != 0) ? rf[A1] : 32'b0;  // **保证 x0 返回 0**
    assign RD2 = (A2 != 0) ? rf[A2] : 32'b0;  // **保证 x0 返回 0**

endmodule
