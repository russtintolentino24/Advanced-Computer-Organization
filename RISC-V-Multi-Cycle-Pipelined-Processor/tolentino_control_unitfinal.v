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


module control_unit(
    inst, 
    ALUSrc, ALUop,
    MemWrite, MemRead, RegWrite, MemtoReg,
    j, bra,  bne, 
    StoreData, LoadData,wmask

    );
    
    input [31:0] inst;
    output reg ALUSrc; 
    output reg [2:0] ALUop;
    output reg MemWrite;
    output reg MemRead;
    output reg RegWrite;
    output reg [1:0] MemtoReg;
    output reg j, bra, bne;
    output reg StoreData, LoadData; 
    output reg [7:0] wmask; 
    
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    
    assign funct7=inst[31:25];
    assign funct3=inst[14:12];
    assign opcode=inst[6:0];
    
    always@(*)begin
        case (opcode)
        `LOADopcode: begin 
                ALUSrc <= 1; 
                ALUop <= `AddiALU; 
                MemWrite <= 0;
                RegWrite <= 1; 
                MemtoReg <= 2'b01;  
                bra <= 0;
                bne <= 0;    
                j <= 0;           
                StoreData <= 0;  
                LoadData <= 1;
                wmask <= 8'd0;
        end
        

         `STOREopcode: begin 
                ALUSrc <= 1;
                ALUop <= `AddiALU; 
                MemWrite <= 1;
                RegWrite <= 0;   
                MemtoReg <= 2'b00;
                bra <= 0;
                bne <= 0;  
                j <= 0;
                StoreData <= 1;
                LoadData <= 0;
                
                    case(funct3)
                        `SD: wmask <= 8'b11111111;
                        `SW: wmask <= 8'b00001111;
                        `SH: wmask <= 8'b00000011;
                        default: wmask <= 8'd0;
                    endcase
        end
        

            `ARITHopcode: begin 
                ALUSrc <= 0;
                MemWrite <= 0;
                RegWrite <= 1;
                MemtoReg <= 2'b00;
                bra <= 0;
                bne <= 0;       
                j <= 0;
                wmask <= 8'd0;
                StoreData <= 0;
                LoadData <= 0;
                
                
                    case(funct3)
                        `Addf3: begin 
                        
                            if(funct7 == `Subf7) 
                            ALUop <= `SubALU; 
                             else 
                             ALUop <= `AddALU; 
                        end

                    `Andf3: ALUop <= `AndALU;
                    `Orf3:  ALUop <= `OrALU;
                    `Xorf3: ALUop <= `XorALU;
                    `SLTf3: ALUop <= `SLTALU;
                    default: ALUop <= `AndALU;
                endcase
        end



            `ADDIopcode: begin 
                ALUSrc <= 1;
                ALUop <= `AddiALU; 
                MemWrite <= 0;
                RegWrite <= 1;  
                MemtoReg <= 2'b00;
                bra <= 0;
                bne <= 0;   
                j <= 0;
                StoreData <= 0;
                LoadData <= 0;
                wmask <= 8'd0; 
                
        end
        
        
        
        
        
        `COND_BRAopcode: begin 
                ALUSrc <= 0;
                MemWrite <= 0;
                RegWrite <= 0;
                MemtoReg <= 2'b00;
                bra <= 1;      
                j <= 0;
                wmask <= 8'd0;
                StoreData <= 0;
                LoadData <= 0;
            
                if(funct3 == 3'b001) 
                    bne <= 1; 
                 else        
                    bne <= 0;  
        end
        
         `JALRopcode: begin 
                ALUSrc <= 1;
                ALUop <= 4'b1011;
                MemWrite <= 0;
                RegWrite <= 1;   
                MemtoReg <= 2'b10; 
                bra <= 0;
                bne <= 0; 
                j <= 1;
                wmask <= 8'd0;
                StoreData <= 0;
                LoadData <= 0;
                           
        end
        
         `JALopcode: begin 
                ALUSrc<= 0;
                ALUop <= 4'b1011;
                MemWrite <= 0;
                RegWrite <= 1;
                MemtoReg <= 2'b10;
                bra <= 1; 
                bne <= 0;    
                j <= 1;
                wmask <= 8'd0;
                StoreData <= 0;
                LoadData <= 0;
                   
        end
        
         default: begin
                ALUSrc <= 0;
                MemWrite <=0;
                RegWrite <= 0; 
                MemtoReg <=2'b00;
                bra <= 0;
                bne <= 0;
                j <= 0;
                wmask <= 8'd0;
                StoreData <= 0;
                LoadData <= 0;
        end 
    endcase
end
    
endmodule