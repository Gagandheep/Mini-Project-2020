module aes_control(output reg [127:0] out,
                   output reg done,
                   input [127:0] in, key,
                   input encr_decr, start, clk);

    // FSM States
    localparam STATE_IDLE = 2'b00;
    localparam STATE_ENCR = 2'b01;
    localparam STATE_DECR = 2'b10;
    localparam STATE_KGEN = 2'b11;

    wire [127:0] sched_key, sched_key_decr, out_encr, out_decr, out_kgen;
    wire [3:0] counter;
    wire clk_controlled, same_keys;

    reg rst = 1'b0, en = 1'b0, done_kgen;
    reg [1:0] state = STATE_IDLE, state_prev = STATE_IDLE;
    reg [127:0] round_keys [0:10] = '{11{0}};

    assign clk_controlled = clk & en;
    assign same_keys = (round_keys[0] == key);
    assign sched_key_decr = round_keys[4'hB-counter];

    mod_n_counter mnc(.out(counter), .rst(rst), .clk(clk_controlled));
    encryption_unit enc(.out(out_encr), .in(in), .key(sched_key), .ctr(counter), .clk(clk_controlled));
    decryption_unit dec(.out(out_decr), .in(in), .key(sched_key_decr), .ctr(counter), .clk(clk_controlled));
    key_schedule ks(.out(sched_key), .in(key), .ctr(counter), .clk(clk_controlled));

    always @(posedge clk) begin

        state_prev <= state;

        if (done) out <= encr_decr ? out_encr : out_decr;

        rst <= (state != state_prev);

        if (start) en <= 1'b1;
        else if (done) en <= 1'b0;
        
        case (state)

            STATE_IDLE: begin

                if (start) state <= (encr_decr) ? STATE_ENCR : (same_keys ? STATE_DECR : STATE_KGEN);
                done_kgen <= 1'b0;

            end

            STATE_ENCR: begin

                if (done) begin
                    state <= STATE_IDLE;
                end
                round_keys[counter-4'h1] <= sched_key;

            end

            STATE_DECR: begin
                
                if (done) begin
                    state <= STATE_IDLE;
                end

            end

            STATE_KGEN: begin

                if (done_kgen) begin
                    state <= STATE_DECR;
                end
                round_keys[counter-4'h1] <= sched_key;

            end

        endcase

        casex (counter)

            4'hB:   begin
                if (state == STATE_KGEN) done_kgen <= 1'b1;
                else done <= 1'b1;
                
            end
            4'hX:   begin
                if (state == STATE_KGEN) done_kgen <= 1'b0;
                else done <= 1'b0;
            end
            default: done <= done;

        endcase

    end

    // always @(posedge start) begin
        
    //     en <= 1'b1;

    // end

endmodule
