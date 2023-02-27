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

module  mux_wb(
    pc, ALUres,
    funct3, rdata, 
    MemtoReg, rf_writedata

    );
    
    
    input [31:0] pc;
    input [63:0] ALUres;
    input [2:0] funct3;
    input [1:0] MemtoReg;
    input [63:0] rdata;
    output reg [63:0] rf_writedata;
    
   
    
    always@(*) begin
    
        case(MemtoReg)
            
            2'b00: rf_writedata <= ALUres;  
            
            2'b01: begin 
                case(funct3)
                    `LD: rf_writedata <= rdata; 
                    `LW: rf_writedata <= {{32{rdata[31]}},rdata[31:0]}; 
                    `LWU: rf_writedata <= {32'b0,rdata[31:0]}; 
                    `LH: rf_writedata <= {{48{rdata[15]}},rdata[15:0]}; 
                    `LHU: rf_writedata <= {48'b0,rdata[15:0]};  
                    default: rf_writedata <= 64'b0;
                endcase
            end            
            
            2'b10: rf_writedata <= pc+3'd4; 
            
            default: rf_writedata <= 64'd0;
        
        endcase   
    end
endmodule