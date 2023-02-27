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




module ALU (
ALUop, a, b, z,
ALUres
);

input signed [63:0] a;
input signed [63:0] b;
input [2:0] ALUop;
output signed [63:0] ALUres;
output z;
//output signed value_holder;
reg z_res;
reg signed [63:0] result;
//reg signed [63:0] wirevalue_holder;
//reg signed [63:0] wireALUres;



always@(*)begin

case(ALUop)

    `AddALU: result <= a + b;
    `SubALU: result <= a - b;
    `AndALU: result <= a & b;
    `OrALU: result <= a | b;
    `XorALU: result <= a ^ b;
    `SLTALU: //result <= a < b;
            begin                
            
                case({a[63],b[63]})
                    2'b00:begin         //case a and b are (+)
                        if(a < b) 
                            result <= 64'b1;
                          else 
                            result <= 64'b0;
                    end
                    
                    2'b01:begin         //case a is (+), b is (-)
                        result <= 64'b0;     
                    end
                    
                    2'b10:begin             //case a is (-), b is (+)
                        result <= 64'b1;
                    end
                    
                    2'b11:begin             //case a and b are (-)
                    
                        //if ||a|| > ||b||, then a < b
                        if((~a + 1)  > (~b + 1)) 
                            result <= 64'b1;
                          else 
                            result <= 64'b0;
                    end
                endcase
            end
    `AddiALU: begin
        if(b[63] == 1'd1)
            result <= a - (~b + 1);
          else
            result <= a + b;
    end
    default: result <= 32'd0;





      endcase





    


end

always@(*)begin
        
        if((a-b) == 64'd0)
            z_res <= 1'd1;
          else
            z_res <= 1'd0;
            
end

assign ALUres = result;
assign z = z_res;


endmodule


//https://www.excamera.com/sphinx/fpga-verilog-sign.html
//https://stackoverflow.com/questions/24162329/verilog-signed-vs-unsigned-samples-and-first