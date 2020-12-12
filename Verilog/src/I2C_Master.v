`timescale 1ns / 1ps

module I2C_Master(
input clk,
input reset,
input RW,
input [7:0] Data,
input [6:0] Addr,
output reg SDA,
output reg SCL
);
localparam IDLE = 3'b000;//Idle state both sda and scl are high
localparam START_BIT = 3'b001;//sda is low while scl is high to indicate start of communication
localparam ADDR_WR = 3'b010;//A 7 bit address is sent
//localparam STATE_RW = 3'b011;//Read or write bit where rw is assigned to sda line
localparam ACK_WR = 3'b011;//Acknoledgement bit should come from the slave but here for simulation purposes we have coded it like this
localparam DATA_WR = 3'b100;//send data bits
localparam DATA_RD = 3'b101;
localparam ACK_WR2 = 3'b110;//Acknoledgement
localparam STOP_BIT = 3'b111;//Stop bit is indicated where scl is low and sda is high
parameter delay_count = 2;//delay we aim for in real hardware implementation here we gave as 2 for simulation purposes
reg [7:0]data_reg = 0;
reg[4:0] state;//state registers to indicate the fsm
//reg[6:0] addr;//7 bit address register
reg[4:0] count;//count register for transmitting or receiving
reg[7:0] data;//data bits to be written on or read from the given 7 bit address 
reg[3:0] cycle_count;//counter for delay of hardware implementation
reg [10:0]bit_count = 0;//design register to keep track of which address,rw,data registers values
//reg rw = 1;//initially has to read

initial  
begin
	state <= IDLE;
	SDA <= 1;
	SCL <= 1;
	//addr <= 7'h00;//Data format register address 0x31 of ADXL345 accelerometer
	count <= 8'd0;//initial count value
	data <= 8'h00;// +/- 2g resolution
	//rw <= 1;//write mode as we need to write the data at the specific addr
end

always @(posedge clk or negedge reset) begin
    if (reset==1)//active low
	 begin
		case(state)
			IDLE: begin
				SDA <= 1;
				SCL <= 1;
				state <= START_BIT;
			end
			START_BIT: begin
				if(cycle_count < delay_count - 1)begin
					SDA <= 0;
					SCL <= 1;
					cycle_count <= cycle_count + 1;
					state <= START_BIT;
				end
				else
				begin
				cycle_count <= 0;
				state <= ADDR_WR;
				count<=0;
				cycle_count<= 0;
				end
			end//Start bit is passed
			ADDR_WR: begin 
			    data_reg <= {Addr, RW};
				if(count < 8)begin
					if(cycle_count < delay_count -1)
						begin
						SDA <= data_reg[count];
						SCL <= ~SCL;
						cycle_count <= cycle_count + 1;
						state <= ADDR_WR;
						end
					else begin
					cycle_count <=0;
					count <= count + 1;
					state <= ADDR_WR;
					end
					end
				else
				begin
				state <= ACK_WR;
				count <=0;
				cycle_count <=0;
				end
			end//Complete address is passed
			ACK_WR:begin 
				if(cycle_count < delay_count - 1)
				begin
                    SDA <= 0;
                    SCL <= ~SCL;
                    cycle_count <= cycle_count + 1;
                    state <= ACK_WR;
				end
				else begin
                    state <= RW ? DATA_RD : DATA_WR;
                    count <= 0;
                    cycle_count <=0;
			     end
			end//Acknoledgement is passed
			DATA_WR:begin 
				if(count < 8)begin
					if(cycle_count < delay_count -1)
						begin
						SDA <= data[count];
						SCL <= ~SCL;
						cycle_count <= cycle_count + 1;
						state <= DATA_WR;
						end
					else begin
                        cycle_count <=0;
                        count <= count + 1;
                        state <= DATA_WR;
					end
				end
				else
				begin
                    state <= ACK_WR2;
                    count <=0;
                    cycle_count <=0;
				end
			end//data is passed
			DATA_RD: begin
			     if(count < 8)                     //Check if 8 bits have been recived
                   begin
                        if(cycle_count < delay_count -1)
                        begin
                            data_reg[bit_count] <= SDA;
                            SCL <= ~SCL;
                            cycle_count <= cycle_count + 1;
                            state <= DATA_RD;
                        end
                        else 
                        begin
                            cycle_count <=0;
                            count <= count + 1;
                            state <= DATA_RD;
                        end
                    end
                    else
                    begin
                        count <= 0;
                        cycle_count <= 0;
                        state <= ACK_WR2;         //Go to next state
                    end
			end
			ACK_WR2:begin 
				if(cycle_count < delay_count - 1)
				begin
                    SDA <= 0;
                    SCL <= ~SCL;
                    cycle_count <= cycle_count + 1;
                    state <= ACK_WR2;
				end
				else begin
                    state <= STOP_BIT;
                    count <= 0;
                    cycle_count <=0;
				end
			end//Acknowledgement is passed again
			STOP_BIT:begin
				if(cycle_count <= delay_count - 1)
				    begin
                        SDA <= 1;
                        SCL <= 1;
                        cycle_count <= cycle_count + 1;
                    end
                    state <= IDLE; 
                    bit_count <= bit_count + 1;    
			     end	
	   endcase
	end
	else
	   state <=  IDLE;
end
	
endmodule
	


