module mod_n_counter #(parameter W=4, N=12)
                   (output reg [W-1:0] out = 0,
                   input rst, clk);
    
    always @(posedge clk, posedge rst) begin
        
        if (rst) begin
            
            out <= 0;

        end

        else begin
            
            out <= (out == N - 1) ? 0 : out + 1;
            
        end

    end

endmodule
