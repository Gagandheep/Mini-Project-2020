module key_schedule(output reg [127:0] out,
                    input [127:0] in,
                    input [3:0] ctr,
                    input clk);

    wire [31:0] w0, w1, w2, w3, g; 
    wire [127:0] key;

    g_circuit gckt(.out(g), .in(key[31:0]), .ctr(ctr));

    assign w0 = g ^ key[127:96];
    assign w1 = w0 ^ key[95:64];
    assign w2 = w1 ^ key[63:32];
    assign w3 = w2 ^ key[31:0];
    assign key = (ctr == 4'h0) ? in : out;

    always @(posedge clk) begin
        
        out <= (ctr == 4'b0) ? in : {w0, w1, w2, w3};
    
    end

endmodule