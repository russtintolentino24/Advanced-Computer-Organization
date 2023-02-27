`timescale 1ns / 1ps


//----Defined Constants----

//----ALUOp----
`define AddALU     3'b000
`define SubALU     3'b001
`define AndALU     3'b010
`define OrALU      3'b011
`define XorALU     3'b100
`define SLTALU     3'b101
`define AddiALU    3'b110 //Add vs ADDI**






//----Load from mem----
`define LD              3'b011
`define LW              3'b010
`define LWU             3'b110
`define LH              3'b001
`define LHU             3'b101
//----Store to mem----
`define SD              3'b011
`define SW              3'b010
`define SH              3'b001




//----Funct3----
//||Arithmetic||
`define Addf3             3'b000
`define Andf3             3'b111
`define Orf3              3'b110
`define Xorf3             3'b100
`define SLTf3             3'b010

//||Conditional Jump||
`define BNEf3             3'b001


//----Funct7----
//||Arithmetic||
`define Subf7            7'b0100000



//----Opcode----
`define ARITHopcode           7'b0110011
`define ADDIopcode            7'b0010011 
`define COND_BRAopcode        7'b1100011
`define JALopcode             7'b1101111
`define JALRopcode            7'b1100111
`define LOADopcode            7'b0000011
`define STOREopcode           7'b0100011




module alu(
    rs1, rs2, 
    ALUop, 
    z, 
    ALUres
    );
    
   input [2:0] ALUop;
   input [63:0] rs1, rs2;
   output reg z;
   output reg [63:0] ALUres;
   
   
   always@(*) begin
   case (ALUop)
    `AddALU: ALUres <= rs1 + rs2;
    `SubALU: ALUres <= rs1 - rs2;
    `AndALU: ALUres <= rs1 & rs2;
    `OrALU: ALUres <= rs1 | rs2;
    `XorALU: ALUres <= rs1 ^ rs2;
    `SLTALU:
        begin 
			if (rs1[63] != rs2[63]) begin
				if (rs1[63] > rs2[63]) //begin
				    ALUres <= 1;
			    //end 
                else //begin
					ALUres <= 0;
			    //end
				end 
            else begin
					if (rs1 < rs2) //begin
						ALUres <= 1;
					//end
					else //begin
						ALUres <= 0;
					//end
				end
			end
    `AddiALU: 
        begin 
            if (rs2[63] == 1'b1) //check if negative imm
                ALUres <= rs1 - (~rs2 + 1); //2s complement
            else
                ALUres <= rs1 + rs2;
        end

    default: ALUres <= 64'd0;
    //begin
            //ALUres<=64'd0;
    //end
   endcase
end
   
   always@(*) begin

    if ((rs1 - rs2) == 64'd0)
        z <= 1;
    else 
        z <= 0;   
   end

endmodule