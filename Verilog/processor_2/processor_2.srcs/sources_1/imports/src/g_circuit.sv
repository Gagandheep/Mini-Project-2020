module g_circuit(output [31:0] out,
                 input [31:0] in,
                 input [3:0] ctr);

    wire [7:0] rcon [0:10] = '{8'h00, 8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80, 8'h1B, 8'h36};

    wire [31:0] w1, w2;

    assign w1 = {in[23:0], in[31:24]};
    assign out = w2 ^ {rcon[ctr], 8'h00, 8'h00, 8'h00};
    
    genvar i;

    generate

        for (i = 31; i > 0; i = i - 8) begin : gen
            
            s_box sb(.out(w2[i:i-7]), .in(w1[i:i-7]));

        end
    
    endgenerate

endmodule