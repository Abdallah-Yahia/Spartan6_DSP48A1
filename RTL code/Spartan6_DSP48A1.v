module Spartan6_DSP48A1 #(
    parameter A0REG = 0, A1REG = 1,
    parameter B0REG = 0, B1REG = 1,
    parameter CREG = 1, DREG = 1,
    parameter MREG = 1, PREG = 1,
    parameter CARRYINREG = 1, CARRYOUTREG = 1,
    parameter OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5",
    parameter B_INPUT = "DIRECT",
    parameter RSTTYPE = "SYNC"
) (
    input [17:0] A, B, D, BCIN,
    input [47:0] C, PCIN,
    input CARRYIN, CLK,
    input [7:0] OPMODE,
    input CEA, CEB, CED, CEC, CECARRYIN, CEM, CEP, CEOPMODE,
    input RSTA, RSTB, RSTD, RSTC, RSTCARRYIN, RSTM, RSTP, RSTOPMODE,
    output CARRYOUT, CARRYOUTF,
    output [35:0] M,
    output [47:0] P, PCOUT,
    output [17:0] BCOUT

);

    wire [17:0] b_sel, A0_mux, B0_mux, D_mux, pre_add_sub_out, out_mux_white, A1_mux, B1_mux;
    wire [35:0] mul_out, M_mux;
    wire [47:0] C_mux, dab_concatenated, out_mux_x, out_mux_z, post_add_sub_out;
    wire carry_in, my_carry, carry_out;
    wire [7:0] opmode_out;

    assign PCOUT = P;
    assign CARRYOUTF = CARRYOUT;

    assign b_sel = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADED") ? BCIN : 18'b0;

    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(18), .ENABLE(A0REG)) m0 (.clk(CLK), .rst(RSTA), .clk_en(CEA), .in(A), .out(A0_mux));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(18), .ENABLE(B0REG)) m1 (.clk(CLK), .rst(RSTB), .clk_en(CEB), .in(b_sel), .out(B0_mux));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(18), .ENABLE(DREG)) m2 (.clk(CLK), .rst(RSTD), .clk_en(CED), .in(D), .out(D_mux));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(48), .ENABLE(CREG)) m3 (.clk(CLK), .rst(RSTC), .clk_en(CEC), .in(C), .out(C_mux));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(8), .ENABLE(OPMODEREG)) m4 (.clk(CLK), .rst(RSTOPMODE), .clk_en(CEOPMODE), .in(OPMODE), .out(opmode_out));

    assign dab_concatenated = {D_mux[11:0], A1_mux, B1_mux};

    assign pre_add_sub_out = (opmode_out[6] == 0) ? (D_mux + B0_mux) : (D_mux - B0_mux);
    assign out_mux_white = (opmode_out[4] == 0) ? B0_mux : pre_add_sub_out;

    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(18), .ENABLE(A1REG)) m5 (.clk(CLK), .rst(RSTA), .clk_en(CEA), .in(A0_mux), .out(A1_mux));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(18), .ENABLE(B1REG)) m6 (.clk(CLK), .rst(RSTB), .clk_en(CEB), .in(out_mux_white), .out(B1_mux));

    assign BCOUT = B1_mux;

    assign mul_out = B1_mux * A1_mux;
    
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(36), .ENABLE(MREG)) m7 (.clk(CLK), .rst(RSTM), .clk_en(CEM), .in(mul_out), .out(M_mux));

 
    genvar i;
    generate
        for (i = 0; i < 36; i = i + 1) begin
            buf(M[i], M_mux[i]);
        end
    endgenerate

    MUX4x1 #(.SIZE(48)) mux_x (.A(48'b0), .B({12'b0, M_mux}), .C(P), .D(dab_concatenated), .S(opmode_out[1:0]), .Y(out_mux_x));
    MUX4x1 #(.SIZE(48)) mux_z (.A(48'b0), .B(PCIN), .C(P), .D(C_mux), .S(opmode_out[3:2]), .Y(out_mux_z));

    assign carry_in = (CARRYINSEL == "OPMODE5") ? opmode_out[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0;

    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(1), .ENABLE(CARRYINREG)) m8 (.clk(CLK), .rst(RSTCARRYIN), .clk_en(CECARRYIN), .in(carry_in), .out(my_carry));

    assign {carry_out, post_add_sub_out} = (opmode_out[7] == 0) ? (out_mux_x + out_mux_z + my_carry) : (out_mux_x - out_mux_z - my_carry);

    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(48), .ENABLE(PREG)) m9 (.clk(CLK), .rst(RSTP), .clk_en(CEP), .in(post_add_sub_out), .out(P));
    MUX_reg #(.RSTTYPE(RSTTYPE), .SIZE(1), .ENABLE(CARRYOUTREG)) m10 (.clk(CLK), .rst(RSTCARRYIN), .clk_en(CECARRYIN), .in(carry_out), .out(CARRYOUT));


endmodule
