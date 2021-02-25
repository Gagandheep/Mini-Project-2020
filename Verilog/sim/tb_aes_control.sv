module tb_aes_control;
    
    wire [127:0] out;
    wire done;
    // reg [127:0] in = 128'h54776F204F6E65204E696E652054776F;
    reg [127:0] in = 128'h29C3505F571420F6402299B31A02D73A;
    reg [127:0] key = 128'h5468617473206D79204B756E67204675;
    reg start = 0, clk = 0, ed = 0;
    localparam clk_h_dur = 3333.333;

    aes_control ac(.out(out), .done(done), .in(in), .key(key), .encr_decr(ed), .start(start), .clk(clk));
    
    always begin
        # clk_h_dur
        clk = ~clk;
    end
    
    initial begin
        #(clk_h_dur*11)
        start = 1;
        #(clk_h_dur*2)
        start = 0;
        #(clk_h_dur*100)
        start = 1;
        #(clk_h_dur*2)
        start = 0;
        #(clk_h_dur*80)
        in = out;
        ed = 1;
        #(clk_h_dur*10)
        start = 1;
        #(clk_h_dur*2)
        start = 0;
        // #(clk_h_dur*50)
        // $finish;
    end

endmodule
