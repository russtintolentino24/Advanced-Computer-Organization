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

module programcounter(
    clk, nrst,
    opcode,  z,
    pc_jbra, rf_readdata1,
    j, bra, bne, 
    jal_immed, jalr_immed, bra_immed, 
    pc_next

    );
    
    input clk, nrst;
    input [63:0] rf_readdata1; 
    input [31:0] pc_jbra; //pc for jump and branch
    input [6:0] opcode; 
    input [31:0] jalr_immed, bra_immed, jal_immed; 
    input j, bne, z, bra; 

    reg [31:0] pc;

    output [31:0] pc_next;
    

    always@(posedge clk) begin
        
        if (!nrst)
            pc <= 32'd0;  

        else begin
            if (j) begin

                if(opcode == `JALRopcode) begin 
                    if(jalr_immed[31] == 1'd1) //if negative
                     pc <= rf_readdata1[31:0] - (~jalr_immed + 1);
                        else
                        pc <= jalr_immed + rf_readdata1[31:0];
                end

                else begin 

                    if (jal_immed[31] == 1'b1) 
                    pc <= pc_jbra - (~jal_immed + 1); 
                     else
                     pc <= pc_jbra + jal_immed;
                end
            end

            else begin 

                if(bne && ~z) begin
                    if (bra_immed[31] == 1'b1) 
                    pc <= pc_jbra - (~bra_immed + 1);
                     else
                     pc <= pc_jbra + bra_immed;
                end      

                else if(~bne && bra && z) begin
                    if (bra_immed[31] == 1'b1) 
                    pc <= pc_jbra - (~bra_immed+1);
                     else
                     pc <= pc_jbra + bra_immed;
                end

                else 
                pc <= pc+3'd4;

            end
         end
      end
    
    assign pc_next = pc;

endmodule