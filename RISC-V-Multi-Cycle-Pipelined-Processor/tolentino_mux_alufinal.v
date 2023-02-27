`timescale 1ns / 1ps



module mux_alu(
    
    ALUSrc, StoreData,
    rf_readdata2, 
    sd_immed, addi_immed, 
    rs2
    );
    
    input [63:0] rf_readdata2;
    input [63:0] sd_immed; 
    input [63:0] addi_immed;
    input ALUSrc;
    input StoreData;
    output [63:0] rs2;
    
    assign rs2 = ALUSrc ? ((StoreData) ? sd_immed : addi_immed) : rf_readdata2;

endmodule