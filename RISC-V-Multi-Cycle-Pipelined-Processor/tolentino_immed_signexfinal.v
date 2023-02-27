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

module immed_signex(
    inst, 
    sd_immed, addi_immed,
    bra_immed, jal_immed, jalr_immed 
    

    );
    
    input [31:0] inst;

    output [63:0] sd_immed, addi_immed;
    output [31:0] bra_immed, jal_immed, jalr_immed;
    
    
    assign sd_immed = {{52{inst[31]}},inst[31:25],inst[11:7]};

    assign addi_immed = {{52{inst[31]}},inst[31:20]};

    assign bra_immed = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};

    assign jal_immed = {{12{inst[31]}},{inst[31],inst[19:12],inst[20],inst[30:21],1'b0}};

    assign jalr_immed = {{20{inst[31]}},{inst[31:20]}}; 
    
    
endmodule