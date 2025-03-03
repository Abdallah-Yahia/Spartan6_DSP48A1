module MUX4x1 #(parameter SIZE = 48) (
    input [SIZE-1:0] A, B, C, D,
    input [1:0] S,
    output reg [SIZE-1:0] Y
);
    always @(*) begin
        case (S)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            2'b11: Y = D;
            default: Y = 0;
        endcase
    end
endmodule