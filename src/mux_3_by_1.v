module Mux_3_by_1(a, b, c, s, d);
    input [31:0] a, b, c;
    input [1:0] s;
    output [31:0] d;
    assign d = s[1] ? c : (s[0] ? b : a);
endmodule