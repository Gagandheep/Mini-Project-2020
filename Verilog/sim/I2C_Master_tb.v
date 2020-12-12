`timescale 1ns/1ps
module I2C_part_2_tb;

	reg clk;
	reg reset;
	reg RW;
	reg [7:0]Data;
	reg [6:0]Addr;
	wire SDA;
	wire SCL;

	I2C_Master ins(
		.clk(clk),
		.reset(reset),
		.SDA(SDA),
		.SCL(SCL),
		.Data(Data),
        .RW(RW),
        .Addr(Addr)
	);
initial begin
    reset <=0;
    #5 reset <= 1;
    RW <= 0;
    clk<=0;
    Addr <= 7'b1100110;
	Data <= 8'b11110000;//random value 
end
initial begin 
	forever
	#10 clk = ~clk;
	end

endmodule
