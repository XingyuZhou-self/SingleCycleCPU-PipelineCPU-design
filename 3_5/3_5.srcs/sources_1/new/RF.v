module RF(
    input         clk, 
    input         rst,
    input         RFWr, 
    input  [4:0]  A1, A2, A3, 
    input  [31:0] WD, 
    output [31:0] RD1, RD2
);

    reg [31:0] rf[31:0];  // 32 �� 32 λ�Ĵ���
    integer i;

    // **��ʼ���Ĵ���**
    always @(posedge clk or posedge rst) begin
        if (rst) begin  
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;  // ���мĴ�������
        end
        else if (RFWr && A3 != 0) begin  
            rf[A3] <= WD;  // **ֻ�� A3 ���� 0 ʱ��д��**
        end
    end

    // **���Ĵ���**
    assign RD1 = (A1 != 0) ? rf[A1] : 32'b0;  // **��֤ x0 ���� 0**
    assign RD2 = (A2 != 0) ? rf[A2] : 32'b0;  // **��֤ x0 ���� 0**

endmodule
