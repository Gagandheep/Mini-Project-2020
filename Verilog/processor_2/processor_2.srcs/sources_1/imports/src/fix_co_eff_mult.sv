module fix_co_eff_mult(output [3:0] [7:0] out,
                       input [3:0] [7:0] in);

    wire [7:0] w, w0, w1, w2, w3;
    
    assign w = in[0] ^ in[1] ^ in[2] ^ in[3];

    xtime xt3(.out(w3), .in(in[3] ^ in[2]));
    xtime xt2(.out(w2), .in(in[2] ^ in[1]));
    xtime xt1(.out(w1), .in(in[1] ^ in[0]));
    xtime xt0(.out(w0), .in(in[0] ^ in[3]));
        
    assign out[3] = in[3] ^ w ^ w3;
    assign out[2] = in[2] ^ w ^ w2;
    assign out[1] = in[1] ^ w ^ w1;
    assign out[0] = in[0] ^ w ^ w0;

endmodule