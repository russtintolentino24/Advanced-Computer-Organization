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

module memwb_stagereg(
clk, nrst, rdata, rdata_out, 
inst_in, inst_out,
pc_in, pc_out,
ALUres, ALUres_out, 
ALUop, ALUSrc, MemWrite, MemRead, RegWrite, MemtoReg, 
j, bra, bne,
StoreData, LoadData,  wmask,
ALUop_res, ALUSrc_res, MemWrite_res, MemRead_res, RegWrite_res, MemtoReg_res, 
j_res, bra_res, bne_res,
StoreData_res, LoadData_res, wmask_res 


    );
    
    input clk, nrst;

    input [31:0] inst_in;
    output reg [31:0] inst_out;

    input [31:0] pc_in;
    output reg [31:0] pc_out;

    input [63:0] ALUres, rdata;
    output reg [63:0] ALUres_out, rdata_out;
    
    
    
    
    //Input Control Unit Signals
    
    input ALUSrc; 
    input [2:0] ALUop; 
    input MemWrite;
    input MemRead;
    input RegWrite;
    input [1:0] MemtoReg; 
    input j, bra, bne;
    input StoreData, LoadData; 
    input [7:0] wmask; 
    
   
    
    
    //Output Control Unit Signals

    output reg ALUSrc_res;
    output reg [2:0] ALUop_res;  
    output reg MemWrite_res;
    output reg MemRead_res;
    output reg RegWrite_res;
    output reg [1:0] MemtoReg_res; 
    output reg j_res, bra_res, bne_res;
    output reg StoreData_res, LoadData_res; 
    output reg [7:0] wmask_res;   
    
    
    
    always@(posedge clk) begin
    
        if (!nrst)begin
            inst_out <= 32'd0;
            pc_out <= 32'd0;
            ALUres_out <= 64'd0;
            rdata_out <= 64'd0;
        end
        
         else begin
            inst_out <= inst_in;
            pc_out <= pc_in;
            ALUres_out <= ALUres;
            rdata_out <= rdata;   
        end
    end
    
    always@(posedge clk) begin
        
        if (!nrst)begin
            
            ALUSrc_res <= 1'd0;
            ALUop_res <= 3'd0;
            MemWrite_res <= 1'd0;
            MemRead_res <= 1'd0;
            RegWrite_res <= 1'd0;
            MemtoReg_res <= 2'd0;
            bra_res <= 1'd0;
            bne_res <= 1'd0;
            j_res <= 1'd0;
            StoreData_res <= 1'd0;
            LoadData_res <= 1'd0;
            wmask_res <= 8'd0;
        end
        
         else begin
            
            ALUSrc_res <= ALUSrc;
            ALUop_res <= ALUop;
            MemWrite_res <= MemWrite;
            MemRead_res <= MemRead;
            RegWrite_res <= RegWrite;
            MemtoReg_res <= MemtoReg;
            bra_res <= bra;
            bne_res <= bne;
            j_res <= j;
            StoreData_res <= StoreData;
            LoadData_res <= LoadData;
            wmask_res <= wmask;
         end

    end
endmodule