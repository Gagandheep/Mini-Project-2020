module encryption_unit(output reg [127:0] out,
                       input [127:0] in, key,
                       input [3:0] ctr,
                       input clk);

    wire [127:0] subbytes_out, 
                 shiftrow_out, 
                 mixcolumn_out,
                 addroundkey_in;

    assign addroundkey_in = (ctr-4'h1 == 4'h0) ? in : ((ctr-4'h1 == 4'hA) ? shiftrow_out : mixcolumn_out);

    // Sub Bytes
    genvar i;
    
    generate
	 
        for (i = 127; i > 0; i = i - 8) begin : gen
            
            s_box sb(.out(subbytes_out[i:i-7]), .in(out[i:i-7]));

        end
    
    endgenerate

    // Shift rows
    // Row 1
    assign shiftrow_out[127:120] = subbytes_out[127:120];
    assign shiftrow_out[95:88] = subbytes_out[95:88];
    assign shiftrow_out[63:56] = subbytes_out[63:56];
    assign shiftrow_out[31:24] = subbytes_out[31:24];

    // Row 2
    assign shiftrow_out[119:112] = subbytes_out[87:80];
    assign shiftrow_out[87:80] = subbytes_out[55:48];
    assign shiftrow_out[55:48] = subbytes_out[23:16];
    assign shiftrow_out[23:16] = subbytes_out[119:112];

    // Row 3
    assign shiftrow_out[111:104] = subbytes_out[47:40];
    assign shiftrow_out[79:72] = subbytes_out[15:8];
    assign shiftrow_out[47:40] = subbytes_out[111:104];
    assign shiftrow_out[15:8] = subbytes_out[79:72];

    // Row 4
    assign shiftrow_out[103:96] = subbytes_out[7:0];
    assign shiftrow_out[71:64] = subbytes_out[103:96];
    assign shiftrow_out[39:32] = subbytes_out[71:64];
    assign shiftrow_out[7:0] = subbytes_out[39:32];

    // Mix Columns
    fix_co_eff_mult mc0(.out({mixcolumn_out[127:120], mixcolumn_out[119:112], mixcolumn_out[111:104], mixcolumn_out[103:96]}), .in({shiftrow_out[127:120], shiftrow_out[119:112], shiftrow_out[111:104], shiftrow_out[103:96]}));
    fix_co_eff_mult mc1(.out({mixcolumn_out[95:88], mixcolumn_out[87:80], mixcolumn_out[79:72], mixcolumn_out[71:64]}), .in({shiftrow_out[95:88], shiftrow_out[87:80], shiftrow_out[79:72], shiftrow_out[71:64]}));
    fix_co_eff_mult mc2(.out({mixcolumn_out[63:56], mixcolumn_out[55:48], mixcolumn_out[47:40], mixcolumn_out[39:32]}), .in({shiftrow_out[63:56], shiftrow_out[55:48], shiftrow_out[47:40], shiftrow_out[39:32]}));
    fix_co_eff_mult mc3(.out({mixcolumn_out[31:24], mixcolumn_out[23:16], mixcolumn_out[15:8], mixcolumn_out[7:0]}), .in({shiftrow_out[31:24], shiftrow_out[23:16], shiftrow_out[15:8], shiftrow_out[7:0]}));

    // Add round key
    always @(posedge clk) out <= addroundkey_in ^ key;

endmodule
