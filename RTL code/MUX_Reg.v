module MUX_reg #(
                 parameter RSTTYPE = "SYNC",
                 parameter SIZE = 1,
                 parameter ENABLE = 1) (
    input  clk, rst, clk_en,
    input  [SIZE-1:0] in,
    output [SIZE-1:0] out );

reg [SIZE-1:0] in_sync, in_async; 


always @(posedge clk or posedge rst) begin
    if (rst) begin
        in_async <= 0;
    end 
    else if (clk_en) begin
        in_async <= in;
    end
end

always @(posedge clk) begin
    if (rst) begin
        in_sync <= 0;
    end 
    else if (clk_en) begin
        in_sync <= in;
    end
end

assign out = (!ENABLE) ? in : (RSTTYPE == "SYNC") ? in_sync : in_async;

endmodule
