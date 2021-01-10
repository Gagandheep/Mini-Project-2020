`timescale 1ns / 1ps

module Datapath_Unit(
	input clk,
	input readInstruction,
	input [15:0] pc_instr,				// 16 bit instruction
	input memRead,
	input memWrite,
	input writeBack,
	input aluMode,
	input execute,
	input [2:0] op,
	input readInstructionComplete,
	input resetInstructionMemory,
	input resetALU,
	input memoryOperationComplete,
	input resetDataMemory,
	input pcSetForBranch,
	input jumpExecute,
	output reg [3:0] opcode,// 4 bit opcode
	output reg [15:0] rd1,
	output reg [15:0] rd2,
	output reg [5:0] offset,
	output reg [11:0] offsetJump,
	output reg writeBackComplete,
	output reg decodeComplete,
	/////////////
	input aes_start,
	input [127:0] aes_in,
	input [127:0] aes_key,
	input i2c_reset
);
	
	wire [15:0] result;
	wire [15:0] rdata;
	wire executeComplete;
	wire branchExecute;
	
    /////////////
    wire aes_done;
    wire [127:0] aes_out;
    //wire [127:0] aes_in;// = 128'h29C3505F571420F6402299B31A02D73A;
    //wire [127:0] aes_key;// = 128'h5468617473206D79204B756E67204675;
    /////////////
    	
	Instruction_Memory im(clk, readInstruction, resetInstructionMemory, branchExecute, offset, offsetJump, jumpExecute, pc_instr,readInstructionComplete,pcSetForBranch);
	Data_Memory dm(clk, memRead, memWrite, result, rd2, executeComplete, resetDataMemory, rdata, memoryOperationComplete, aes_key, aes_in);
	ALU alu(clk, aluMode, rd1, rd2, offset, execute, op, resetALU, result, executeComplete, branchExecute);
	// other modules;
	
	/////////////
	wire aes_ed = pc_instr[0];
	aes_control ac(.out(aes_out), .done(aes_done), .in(aes_in), .key(aes_key), .encr_decr(aes_ed), .start(aes_start), .clk(clk));
	
	wire i2c_RW = pc_instr[0];
	wire [6:0] i2c_Addr = pc_instr[7:1];
	wire SDA;
	wire SCL;
	i2c ins(.clk(clk), .reset(i2c_reset), .SDA(SDA), .SCL(SCL), .Data(rd2), .RW(i2c_RW), .Addr(i2c_Addr));
	/////////////
	
	//Program counter
	// reg pc;
	
	// Registers
	reg [15:0] R [7:0];
		
	//
	reg [2:0] rs1;
	reg [2:0] rs2;
	reg [2:0] ws;
	
	initial
		begin
			$display("Initial block of Datapath_Unit");
			//pc=0;
			R[0]=0;
			R[1]=0;
			R[2]=0;
			R[3]=0;
			R[4]=0;
			R[5]=0;
			R[6]=0;
			R[7]=0;
			opcode=4'bXXXX;
			decodeComplete=0;
			writeBackComplete=0;
		end

	always @(posedge readInstructionComplete) begin
			writeBackComplete=0;
			rs1 = pc_instr[11:9];
			rs2 = pc_instr[8:6];
			ws = pc_instr[5:3];
			offset = pc_instr[5:0];
			offsetJump = pc_instr[11:0];
			$display("Rs1 = %b",rs1);
			$display("Rs2 = %b",rs2);
			rd1=R[rs1];
			rd2=R[rs2];
			opcode = pc_instr[15:12];
			$display("Opcode = %b",opcode);
			decodeComplete=1;		
		end
	
	always @(posedge memoryOperationComplete) begin
			decodeComplete=0;
			if(writeBack==0) begin
				$display("No write back required");
				writeBackComplete=1;
			end
			else if(writeBack==1) begin
				if(memRead==0 && memWrite==0) begin
					R[ws]=rdata;
					$display("Write back to R%d.",ws);
					end
				else if(memRead==1 && memWrite==0) begin
					R[rs2]=rdata;
					$display("Write back to R%d.",rs2);
					end
				$monitor("\tR[0] = %d", R[0],			
				"\tR[1] = %d", R[1],
				"\tR[2] = %d", R[2],
				"\tR[3] = %d", R[3],
				"\tR[4] = %d", R[4],
				"\tR[5] = %d", R[5],
				"\tR[6] = %d", R[6],
				"\tR[7] = %d\n", R[7]);
				$display("Write back done.");
				writeBackComplete=1;
			end
		end
	
	always @(posedge pcSetForBranch)
	begin
		decodeComplete=0;
		$display("No write back required");
		$display("Branch/Jump execution complete");
		writeBackComplete=1;
	end
			
	/////////////////////////////////////////////////////////////
	always @(posedge aes_done)
	begin
	   decodeComplete=0;
	   $display("aes operation done");
	   writeBackComplete=1;
	end
	/////////////////////////////////////////////////////////////
	
endmodule


