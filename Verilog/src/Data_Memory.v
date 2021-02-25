`timescale 1ns / 1ps
`include "Parameter.v"

module Data_Memory(
	input clk,
	input memRead,
	input memWrite,
	input [15:0] result,
	input [15:0] rd2,
	input executeComplete,
	input resetDataMemory,
	output reg [15:0] rdata,
	output reg memoryOperationComplete,
	//////////////////
	output reg [127:0] aes_key,
	output reg [127:0] aes_in
//	input aes_done,
//	output reg aes_write_complete,
//	input aes_out
);

reg [`col - 1:0] memory [`row_d - 1:0];

///////////////////////
reg [`col_aes - 1:0] memory_aes [`row_aes - 1:0];
///////////////////////

integer f;

initial
	begin
		$readmemb("test_data.txt", memory);
		
		///////////////////////////////////
		$readmemh("test_aes.txt", memory_aes);
		aes_key=memory_aes[0];
		aes_in=memory_aes[1];
		///////////////////////////////////
		
		f = $fopen(`filename);
		$fmonitor(f, "time = %d\n", $time, 
		"\tmemory[0] = %b\n", memory[0],			
		"\tmemory[1] = %b\n", memory[1],
		"\tmemory[2] = %b\n", memory[2],
		"\tmemory[3] = %b\n", memory[3],
		"\tmemory[4] = %b\n", memory[4],
		"\tmemory[5] = %b\n", memory[5],
		"\tmemory[6] = %b\n", memory[6],
		"\tmemory[7] = %b\n", memory[7]); 
		`simulation_time;
		$fclose(f);
		//$display("Data read from Data_memory is = %b\n",memory);

	end
	
	// your logic
		
	always @(posedge executeComplete) begin
			$display("Load or Store task inside Data_Memory");
			if (memRead == 1 && memWrite ==0)
			 begin
				$display("Load task inside Data Memory");
				$display("Result = %b",result);
				rdata=memory[result];
				$display("Load complete. Rdata = %b",rdata);
			 end
			else if(memRead == 0 && memWrite ==1) 
				begin
//					always @(posedge clk) begin
					$display("Time %0t",$time);
					$display("Store task inside Data Memory %0t",$time);
					$display("Result = %b",result);
					$display("Rd2 = %b",rd2);
					memory[result] = rd2;
					$display("Store complete");
//					end
				end
			else if (memRead == 0 && memWrite ==0)
			 begin
				$display("Inside Data Memory - No memory operation required");
				$display("Result = %b",result);
				rdata=result;
				$display("Rdata = %b",rdata);
			 end
//			else if (aes_done == 1)
//             begin
//                $display("Inside Data Memory - aes memory write operation");
//                rdata=memory[result];
//                memory_aes[2] = aes_out;
//                aes_write_complete = 1;
//             end
			memoryOperationComplete=1;
	end
	
	always @(posedge resetDataMemory)
	begin
		memoryOperationComplete=0;
	end
	
	

endmodule
