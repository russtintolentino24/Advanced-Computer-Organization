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




module registerfile(
clk, nrst, RegWrite,
rf_readreg1, rf_readreg2,
rf_writereg, rf_writedata,
rf_readdata1, rf_readdata2


);
input clk, nrst, RegWrite;
input [4:0] rf_readreg1;
input [4:0] rf_readreg2;
input [4:0] rf_writereg;
input [63:0] rf_writedata;
output [63:0] rf_readdata1;
output [63:0] rf_readdata2;
reg [63:0] Ram[31:0];

//integer i;

assign rf_readdata1 = Ram[rf_readreg1];
assign rf_readdata2 = Ram[rf_readreg2];

//initial begin
//        for(i = 32; i > 0; i = i - 1)
//            Ram[i] = 0;
//end

always@(posedge clk)begin

if(!nrst) 
begin
//             for(i = 32; i > 0; i = i - 1)
//             Ram[i] <= 0;
            Ram[0] <= 64'b0;
            Ram[1] <= 64'b0;
            Ram[2] <= 64'b0;
            Ram[3] <= 64'b0;
            Ram[4] <= 64'b0;
            Ram[5] <= 64'b0;
            Ram[6] <= 64'b0;
            Ram[7] <= 64'b0;
            Ram[8] <= 64'b0;
            Ram[9] <= 64'b0;
            Ram[10] <= 64'b0;
            Ram[11] <= 64'b0;
            Ram[12] <= 64'b0;
            Ram[13] <= 64'b0;
            Ram[14] <= 64'b0;
            Ram[15] <= 64'b0;
            Ram[16] <= 64'b0;
            Ram[17] <= 64'b0;
            Ram[18] <= 64'b0;
            Ram[19] <= 64'b0;
            Ram[20] <= 64'b0;
            Ram[21] <= 64'b0;
            Ram[22] <= 64'b0;
            Ram[23] <= 64'b0;
            Ram[24] <= 64'b0;
            Ram[25] <= 64'b0;
            Ram[26] <= 64'b0;
            Ram[27] <= 64'b0;
            Ram[28] <= 64'b0;
            Ram[29] <= 64'b0;
            Ram[30] <= 64'b0;
            Ram[31] <= 64'b0;

            
        end
        else begin
            if(RegWrite) begin 
                if(rf_writereg == 32'b0) 
                    Ram[rf_writereg] <= Ram[rf_writereg];
                  else
                    Ram[rf_writereg] <= rf_writedata;
            end

  else
    Ram[rf_writereg] <= Ram[rf_writereg];

    end
end
endmodule