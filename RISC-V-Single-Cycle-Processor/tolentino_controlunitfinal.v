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



module controlunit (
inst, ALUSrc, ALUop, 
j, StoreData, LoadData, 
bra, bne, MemWrite,
MemtoReg, rf_writereg, RegWrite,
wmask  );


input [31:0] inst;
output ALUSrc; 
output [2:0] ALUop;
output [7:0] wmask;
output j, StoreData, LoadData;
output bra, bne;
output MemWrite;
output [1:0] MemtoReg;
output rf_writereg, RegWrite;
reg [7:0] wmask_res;
reg mmod_writedata_res, mmod_readdata_res;
reg j_res, bra_res, bne_res;
reg rf_writereg_res, RegWrite_res;
reg StoreData_res, LoadData_res;
reg ALUSrc_res;
reg [2:0] ALUop_res;
reg [1:0] MemtoReg_res;
reg MemWrite_res;

wire [6:0] funct7;
wire [2:0] funct3;
wire [6:0] opcode;

// assign ALUSrc = ALUSrc_res;
// assign ALUop = ALUop_res;
// assign MemtoReg = MemtoReg_res;
// assign MemWrite = MemWrite_res;
// assign j = j_res;
// assign bra = bra_res;
// assign bne = bne_res;
// assign StoreData = StoreData_res;
// assign LoadData = LoadData_res;
// assign RegWrite = RegWrite_res;
// assign rf_writereg = rf_writereg_res;
// assign wmask = wmask_res;

// assign funct7 = inst[31:25];
// assign funct3 = inst[14:12];
// assign opcode = inst[6:0];

always@(inst)begin
  case(opcode)
              
                 
    `LOADopcode: begin
                RegWrite_res     <= 1;           
                rf_writereg_res  <= 0;
                wmask_res        <= 8'd0;
                StoreData_res    <= 0; 
                bra_res          <= 0;
                bne_res          <= 0;           
                j_res            <= 0;           
                ALUSrc_res       <= 1;           
                ALUop_res        <= `AddiALU;   
                MemtoReg_res     <= 2'b01;       
                MemWrite_res     <= 0;
  

                

    end
            
           
    `STOREopcode: begin
        RegWrite_res     <= 0;           
        rf_writereg_res  <= 0;
        StoreData_res    <= 1;           
        j_res            <= 0;  
        bra_res          <= 0;
        bne_res          <= 0;      
        ALUSrc_res       <= 1;         
        ALUop_res        <= `AddiALU;   
        MemtoReg_res     <= 2'b00;       
        MemWrite_res     <= 1;           
          
        
                
            case(funct3)
                `SD: wmask_res <= 8'b11111111;  
                `SW: wmask_res <= 8'b00001111;  
                `SH: wmask_res <= 8'b00000011;  
            endcase
                
    end


              
    `ARITHopcode: begin
         RegWrite_res     <= 1;        
        rf_writereg_res  <= 0;
        StoreData_res    <= 0;
        wmask_res        <= 8'd0;
        j_res            <= 0;
        bne_res          <= 0;
        bra_res          <= 0;
        ALUSrc_res       <= 0;
        MemtoReg_res     <= 2'b0;
        MemWrite_res     <= 0;
       
       
                
                
               
            case(funct3)
                `Addf3: begin    
                        
                    if(funct7 == `Subf7) 
                        ALUop_res <= `SubALU;
                      else 
                        ALUop_res <= `AddALU;
                end
                `Andf3:   ALUop_res <= `AndALU;
                `Orf3:    ALUop_res <= `OrALU;
                `Xorf3:   ALUop_res <= `XorALU;
                `SLTf3:   ALUop_res <= `SLTALU;
            endcase
    end
            
            
    `ADDIopcode: begin
            RegWrite_res     <= 1;          
            rf_writereg_res  <= 0;
            StoreData_res    <= 0;
            wmask_res        <= 8'd0;
            j_res            <= 0;
            bne_res          <= 0;
            bra_res          <= 0;
            ALUSrc_res       <= 1;           
            ALUop_res        <= `AddiALU;  //**Add vs ADDI
            MemtoReg_res     <= 2'b00;       
            MemWrite_res     <= 0;
           
            
    end
            
          
    `COND_BRAopcode: begin
            RegWrite_res     <= 0;          
            rf_writereg_res  <= 0;
            StoreData_res    <= 0;
            wmask_res        <= 8'd0;
            j_res            <= 0;
            bra_res          <= 1; 
            ALUSrc_res       <= 0;   
            MemtoReg_res     <= 2'b00;
            MemWrite_res     <= 0;
                   
            
                
                
                if(funct3 == `BNEf3)  
                    bne_res <= 1;
                 else                
                    bne_res <= 0;
    end
            
            
    `JALopcode: begin
            RegWrite_res     <= 1;           
            rf_writereg_res  <= 0;
            StoreData_res    <= 0;
            wmask_res        <= 8'd0;
            j_res            <= 1;
            bra_res          <= 0;
            bne_res          <= 0;
            ALUSrc_res       <= 0;   
            MemtoReg_res     <= 2'b10;      
            MemWrite_res     <= 0;
               
                       
    end
            
            
            
    `JALRopcode: begin
            RegWrite_res     <= 1;           
            rf_writereg_res  <= 0;
            StoreData_res    <= 0;
            wmask_res        <= 8'd0;
            j_res            <= 1;
            bra_res          <= 0;
            bne_res          <= 0;
            ALUSrc_res       <= 1;           
            MemtoReg_res     <= 2'b10;       
            MemWrite_res     <= 0;
               
                       
    end
            
            
           
     default: begin
            RegWrite_res     <= 0;           
            rf_writereg_res  <= 0;
            StoreData_res    <= 0;
            wmask_res        <= 8'd0;
            j_res            <= 0;
            bra_res          <= 0;
            bne_res          <= 0;
            ALUSrc_res       <= 0;          
            MemtoReg_res     <= 2'b00;      
            MemWrite_res     <= 0;     
              
                   
    end
            
    endcase




end

 assign ALUSrc = ALUSrc_res;
 assign ALUop = ALUop_res;
 assign MemtoReg = MemtoReg_res;
 assign MemWrite = MemWrite_res;
 assign j = j_res;
 assign bra = bra_res;
 assign bne = bne_res;
 assign StoreData = StoreData_res;
 assign LoadData = LoadData_res;
 assign RegWrite = RegWrite_res;
 assign rf_writereg = rf_writereg_res;
 assign wmask = wmask_res;

 assign funct7 = inst[31:25];
 assign funct3 = inst[14:12];
 assign opcode = inst[6:0];




endmodule