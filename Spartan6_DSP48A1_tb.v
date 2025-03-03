module Spartan6_DSP48A1_tb ();

reg [17:0]A,B,D,BCIN;
reg [47:0]C,PCIN;
reg CARRYIN,CLK;
reg [7:0]OPMODE;
reg CEA,CEB,CED,CEC,CECARRYIN,CEM,CEP,CEOPMODE;
reg RSTA,RSTB,RSTD,RSTC,RSTCARRYIN,RSTM,RSTP,RSTOPMODE; 

reg CARRYOUT_ex,CARRYOUTF_ex;         
reg [35:0]M_ex;
reg [47:0]P_ex,PCOUT_ex;              
reg [17:0]BCOUT_ex;

wire CARRYOUT,CARRYOUTF;
wire [35:0]M;
wire [47:0]P,PCOUT;
wire [17:0]BCOUT;

Spartan6_DSP48A1 #(.A0REG(0),.A1REG(1),.B0REG(0),.B1REG(1),.CREG(1),.DREG(1),
                   .MREG(1),.PREG(1),.CARRYINREG(1),.CARRYOUTREG(1),.OPMODEREG(1),
                   .CARRYINSEL("OPMODE5"),.B_INPUT("DIRECT"),.RSTTYPE("SYNC") )     

              DUT (.A(A),.B(B),.D(D),.BCIN(BCIN),.C(C),.PCIN(PCIN),.CARRYIN(CARRYIN),.CLK(CLK),
                   .OPMODE(OPMODE),.CEA(CEA),.CEB(CEB),.CED(CED),.CEC(CEC),.CECARRYIN(CECARRYIN),.CEM(CEM),.CEP(CEP),.CEOPMODE(CEOPMODE),
                   .RSTA(RSTA),.RSTB(RSTB),.RSTD(RSTD),.RSTC(RSTC),.RSTCARRYIN(RSTCARRYIN),.RSTM(RSTM),.RSTP(RSTP),.RSTOPMODE(RSTOPMODE),
                   .CARRYOUT(CARRYOUT),.CARRYOUTF(CARRYOUTF),.M(M),.P(P),.PCOUT(PCOUT),.BCOUT(BCOUT) );


initial begin
    CLK=0;
    forever #1 CLK=~CLK;
end

initial begin

    //initial inputs
    A=10;
    B=20;
    C=30;
    D=40;
    BCIN=1;
    CARRYIN=1;
    PCIN=1;               
    OPMODE=8'b11111111;
    
    //deactivate control signals
    RSTA=1;
    RSTB=1;
    RSTC=1;
    RSTD=1;
    RSTCARRYIN=1;
    RSTM=1;
    RSTP=1;
    RSTOPMODE=1;

    CEA=1;
    CEB=1;
    CEC=1;
    CED=1;
    CECARRYIN=1;
    CEM=1;
    CEOPMODE=8'b11111111;
    CEP=1;

    BCOUT_ex=0;
    M_ex=0;
    P_ex=0;
    PCOUT_ex=0;
    CARRYOUT_ex=0;
    CARRYOUTF_ex=0;
    
    @(negedge CLK);
    if( M_ex!=M || P_ex!=P || BCOUT_ex!=BCOUT || CARRYOUT_ex!=CARRYOUT || CARRYOUTF_ex!=CARRYOUTF || PCOUT_ex !=PCOUT)begin
    $display("Error in Deactivate state");
    $stop;    
    end

    //activate control signals
    RSTA=0;
    RSTB=0;
    RSTC=0;
    RSTD=0;
    RSTCARRYIN=0;
    RSTM=0;
    RSTP=0;
    RSTOPMODE=0;

    CEA=1;
    CEB=1;
    CEC=1;
    CED=1;
    CECARRYIN=1;
    CEM=1;
    CEOPMODE=1;
    CEP=1;

    //check when OPMODE=8'b00111101; 
    A=10;
    B=20;
    C=30;
    D=40;
    OPMODE=8'b00111101;

    BCOUT_ex=D+B;
    M_ex=(D+B)*A;
    P_ex=M_ex+C+OPMODE[5];
    PCOUT_ex=P_ex;
    CARRYOUT_ex=0;
    CARRYOUTF_ex=CARRYOUT_ex;
    repeat(4)@(negedge CLK);
    if( M_ex!=M || P_ex!=P || BCOUT_ex!=BCOUT || CARRYOUT_ex!=CARRYOUT || CARRYOUTF_ex!=CARRYOUTF || PCOUT_ex !=PCOUT)begin
    $display("Error in case 1 !");
    $stop;    
    end

    //check when OPMODE=8'b00011101; 
    A=10;
    B=5;
    C=50;
    D=5;
    OPMODE=8'b00011101;

    BCOUT_ex=10;
    M_ex=100;
    P_ex=150;
    PCOUT_ex=P_ex;
    CARRYOUT_ex=0;
    CARRYOUTF_ex=CARRYOUT_ex;
    repeat(4)@(negedge CLK);
    if( M_ex!=M || P_ex!=P || BCOUT_ex!=BCOUT || CARRYOUT_ex!=CARRYOUT || CARRYOUTF_ex!=CARRYOUTF || PCOUT_ex !=PCOUT)begin
    $display("Error in case 2 !");
    $stop;    
    end

   //////////////////////////////////////////////////
  // Now : I will check without expected outputs: //
 //////////////////////////////////////////////////

    BCOUT_ex=0;
    M_ex=0;
    P_ex=0;
    PCOUT_ex=0;
    CARRYOUT_ex=0;
    CARRYOUTF_ex=0;

    //check when OPMODE=8'b00000001 without expected;
    OPMODE = 8'b00000001; 
    repeat (4) @ (negedge CLK);
    if ((PCOUT !== (B * A)) || (P !== (B * A)) || (M !== (B * A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== B))begin
      $display ("Error in case 4 !");
      $stop;
    end

$display("All cases passed successfully");
$stop;
end


initial begin
  $monitor ("%t :OPMODE = %0d , A = %0d , B = %0d , C = %0d , D = %0d , P = %0d , PCOUT = %0d , M = %0d , BCOUT = %0d , CARRYOUT = %0d , CARRYOUTF = %0d",
            $time, OPMODE, A, B, C, D, P , PCOUT, M, BCOUT, CARRYOUT, CARRYOUTF);
end

endmodule