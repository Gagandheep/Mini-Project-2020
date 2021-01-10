module decryption_unit(output reg [127:0] out,
                       input [127:0] in, key,
                       input [3:0] ctr,
                       input clk);

    wire [127:0] invsubbytes_out, 
                 invshiftrow_out, 
                 invmixcolumn_out,
                 addroundkey_in,
                 invshiftrow_in,
                 w;
    
    wire [3:0] [7:0] wu, wv, u, v;

    assign invshiftrow_in = (ctr == 4'h2) ? out : invmixcolumn_out;
    assign addroundkey_in = (ctr == 4'h1) ? in : invsubbytes_out;

    // Inv Mix Columns
    genvar j;

    generate

        for (j = 127; j >= 31; j = j - 32) begin : gen1
				
            xtime xtwu(.out(wu[(j-31)/32]), .in(out[j:j-7] ^ out[j-16:j-23]));
            xtime xtwv(.out(wv[(j-31)/32]), .in(out[j-8:j-15] ^ out[j-24:j-31]));

            assign w[j:j-7] = out[j:j-7] ^ u[(j-31)/32];
            assign w[j-8:j-15] = out[j-8:j-15] ^ v[(j-31)/32];
            assign w[j-16:j-23] = out[j-16:j-23] ^ u[(j-31)/32];
            assign w[j-24:j-31] = out[j-24:j-31] ^ v[(j-31)/32];

        end

        for (j = 0; j < 4; j = j + 1) begin : gen2
            
            xtime xtu(.out(u[j]), .in(wu[j]));
            xtime xtv(.out(v[j]), .in(wv[j]));

        end

    endgenerate

    fix_co_eff_mult mc0(.out({invmixcolumn_out[127:120], invmixcolumn_out[119:112], invmixcolumn_out[111:104], invmixcolumn_out[103:96]}), .in({w[127:120], w[119:112], w[111:104], w[103:96]}));
    fix_co_eff_mult mc1(.out({invmixcolumn_out[95:88], invmixcolumn_out[87:80], invmixcolumn_out[79:72], invmixcolumn_out[71:64]}), .in({w[95:88], w[87:80], w[79:72], w[71:64]}));
    fix_co_eff_mult mc2(.out({invmixcolumn_out[63:56], invmixcolumn_out[55:48], invmixcolumn_out[47:40], invmixcolumn_out[39:32]}), .in({w[63:56], w[55:48], w[47:40], w[39:32]}));
    fix_co_eff_mult mc3(.out({invmixcolumn_out[31:24], invmixcolumn_out[23:16], invmixcolumn_out[15:8], invmixcolumn_out[7:0]}), .in({w[31:24], w[23:16], w[15:8], w[7:0]}));

    // Inv Shift rows
    // Row 1
    assign invshiftrow_out[127:120] = invshiftrow_in[127:120];
    assign invshiftrow_out[95:88] = invshiftrow_in[95:88];
    assign invshiftrow_out[63:56] = invshiftrow_in[63:56];
    assign invshiftrow_out[31:24] = invshiftrow_in[31:24];

    // Row 2
    assign invshiftrow_out[119:112] = invshiftrow_in[23:16];
    assign invshiftrow_out[87:80] = invshiftrow_in[119:112];
    assign invshiftrow_out[55:48] = invshiftrow_in[87:80];
    assign invshiftrow_out[23:16] = invshiftrow_in[55:48];

    // Row 3
    assign invshiftrow_out[111:104] = invshiftrow_in[47:40];
    assign invshiftrow_out[79:72] = invshiftrow_in[15:8];
    assign invshiftrow_out[47:40] = invshiftrow_in[111:104];
    assign invshiftrow_out[15:8] = invshiftrow_in[79:72];

    // Row 4
    assign invshiftrow_out[103:96] = invshiftrow_in[71:64];
    assign invshiftrow_out[71:64] = invshiftrow_in[39:32];
    assign invshiftrow_out[39:32] = invshiftrow_in[7:0];
    assign invshiftrow_out[7:0] = invshiftrow_in[103:96];

    // Inv Sub Bytes
    genvar i;
    
    generate
	 
        for (i = 127; i > 0; i = i - 8) begin : gen0
            
            inv_s_box isb(.out(invsubbytes_out[i:i-7]), .in(invshiftrow_out[i:i-7]));

        end
    
    endgenerate

    // Add round key
    always @(posedge clk) out <= addroundkey_in ^ key;

endmodule
