module xtime(output [7:0] out,
             input [7:0] in);

    assign out = in[7] ? (in << 1) ^ 8'h1B : (in << 1);

endmodule