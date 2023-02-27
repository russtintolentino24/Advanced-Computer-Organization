`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2021 00:42:14
// Design Name: 
// Module Name: processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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


module processor(
clk, nrst, pc, inst, addr, wdata, wr_en, wmask, rdata );

//Proc IO ports
input clk, nrst;
output [31:0] pc;
input [31:0] inst;
output [31:0] addr;
output [63:0] wdata;
output wr_en; 
output [7:0] wmask; 
input [63:0] rdata;     
    
reg [31:0] pc_wire; 
//reg [31:0] addr_wire; 
//reg [31:0] wrdata_wire; 

    
   

wire [4:0] rf_readreg1_wire;
wire [4:0] rf_readreg2_wire;  
wire [4:0]  rf_writereg_wire;
wire [63:0] rf_readdata1_wire;
wire [63:0] rf_readdata2_wire;
reg [63:0] rf_writedata_wire; 
wire [63:0] rf_writedata_input;

wire [63:0] rs1;
wire [63:0] rs2;

wire RegWrite; 
wire ALUSrc;
wire [2:0] ALUop;
wire MemWrite, MemRead;
wire [1:0] MemtoReg;
wire bne, bra, j, StoreData, z;
wire [63:0] ALUres;

wire rd_temp;

wire [63:0] sd_immed;

wire [63:0] addi_immed;

wire [31:0] jal_immed;

wire [31:0] jalr_immed;

wire [31:0] bra_immed;

wire [6:0] funct7;
wire [4:0] rs2_encode;
wire [4:0] rs1_encode;
wire [2:0] funct3;
wire [4:0] rd;
wire [6:0] opcode;


assign funct3 = inst[14:12];


assign funct7 = inst[31:25];


assign opcode = inst[6:0];


assign rf_readreg2_wire = inst[24:20];


assign rf_readreg1_wire = inst[19:15];


assign rf_writereg_wire = inst[11:7];


assign sd_immed = {{52{inst[31]}},{inst[31:25],inst[11:7]}};


assign addi_immed = {{52{inst[31]}},{inst[31:20]}};


assign bra_immed = {{19{inst[31]}},{inst[31],inst[7],inst[30:25],inst[11:8],1'b0}};


assign jal_immed = {{12{inst[31]}},{inst[31],inst[19:12],inst[20],inst[30:21],1'b0}};


assign jalr_immed = {{20{inst[31]}},{inst[31:20]}};


//PC
always@(posedge clk)begin

    if(!nrst)
        pc_wire <= 32'b0;
    
    else begin
    
    if(j)begin
    
         if (opcode == `JALRopcode) begin

             if(jalr_immed[31] == 1'd1)
                pc_wire <= rf_readdata1_wire[31:0] - (~jalr_immed + 1);
                else
                 pc_wire <= jalr_immed + rf_readdata1_wire[31:0];
       end

        else begin
         if(jal_immed[31] == 1'd1) 
            pc_wire <= pc_wire - (~jal_immed + 1);
             else
                    pc_wire <= pc_wire + jal_immed;

    end
    end

    else begin
        if(bne && ~z) begin
            if(bra_immed[31] == 1'd1)
                pc_wire <= pc_wire - (~bra_immed + 1);
               else
                   pc_wire <= pc_wire + bra_immed;

    end

        else if(~bne && z && bra) begin
            if(bra_immed[31] == 1'd1)
                pc_wire <= pc_wire - (~bra_immed + 1);
                else
                    pc_wire <= pc_wire + bra_immed;

    end
        
        else pc_wire <= pc_wire + 3'd4;
    
    
    end
end

end
assign pc = pc_wire;
    
    
    
//controlunit c1

controlunit c1(

.inst(inst), .ALUSrc(ALUSrc), .ALUop(ALUop),
.MemtoReg(MemtoReg), .MemWrite(wr_en), 
.bne(bne), .bra(bra), .rf_writereg(rd_temp),
.RegWrite(RegWrite), .StoreData(StoreData), .wmask(wmask),
.j(j) 

);


//ALUblock a1
ALU a1(
.ALUop(ALUop), .a(rs1), .b(rs2), .z(z),
.ALUres(ALUres)


);

//Regfile r1
registerfile rf1(
.clk(clk), .nrst(nrst),
.rf_readreg1(rf_readreg1_wire), .rf_readreg2(rf_readreg2_wire),
.rf_writereg(rf_writereg_wire), .rf_writedata(rf_writedata_input),
.rf_readdata1(rf_readdata1_wire), .rf_readdata2(rf_readdata2_wire),
.RegWrite(RegWrite)


);


//ALU
assign rs1 = rf_readdata1_wire;

assign rs2 = (ALUSrc)? ((StoreData)? sd_immed: addi_immed): rf_readdata2_wire;






//RF


assign rf_writedata_input = rf_writedata_wire;

always@(*) begin


//case (MemtoReg)
//    2'b00: rf_writedata_wire <= ALUres;
    
    
//    2'b01: begin
//        case(funct3)
//         `LD:   rf_writedata_wire <= rdata;                           
//         `LW:   rf_writedata_wire <= {{32{rdata[31]}},rdata[31:0]};    
//         `LH:   rf_writedata_wire <= {{48{rdata[15]}},rdata[15:0]};   
//         `LWU:  rf_writedata_wire <= {32'b0,rdata[31:0]};              
//         `LHU:  rf_writedata_wire <= {48'b0,rdata[15:0]};    
//        endcase 
//     end
    
//    2'b10: rf_writedata_wire <= pc_wire + 3'b100;    
    

//    default: rf_writedata_wire <= 1'b0;

//endcase
//end

    if (MemtoReg == 2'b00)
        rf_writedata_wire <= ALUres;
    
    
    else if (MemtoReg == 2'b01) begin
        case(funct3)
         `LD:   rf_writedata_wire <= rdata;                           
         `LW:   rf_writedata_wire <= {{32{rdata[31]}},rdata[31:0]};    
         `LH:   rf_writedata_wire <= {{48{rdata[15]}},rdata[15:0]};   
         `LWU:  rf_writedata_wire <= {32'b0,rdata[31:0]};              
         `LHU:  rf_writedata_wire <= {48'b0,rdata[15:0]};    
        endcase 
     end
    
    else if (MemtoReg == 2'b10) 
       rf_writedata_wire <= pc_wire + 3'b100;    
    

    else
      rf_writedata_wire <= 1'b0;
end




assign addr = ALUres[31:0];

assign wdata = rf_readdata2_wire;




endmodule
