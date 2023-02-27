`timescale 1ns/1ps

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

clk, nrst, pc, inst, addr, wdata, wr_en, wmask, rdata, 
ALUop1, ALUop2, ALUres, 
RFwrdata, RFwren 



);

input clk, nrst;
input [31:0] inst;
output [31:0] pc;
output [31:0] addr;
output [7:0] wmask;
output [63:0] ALUop1;
output [63:0] ALUop2;
output [63:0] ALUres;
output [63:0] RFwrdata;
output [63:0] wdata;
output RFwren;
output wr_en;
input [63:0] rdata;  

    //-----ifid stage-----//
    
    //inputs
    wire [31:0] inst_in_ifid;
    wire [31:0] pc_in_ifid;
    

    //outputs
    wire [31:0] inst_out_ifid;
    wire [31:0] pc_out_ifid;
   
    
    assign inst_in_ifid = inst;


    //Wires
    wire [31:0] pc_wire; 
    wire [31:0] jal_immed_out_idexe, jalr_immed_out_idexe, bra_immed_out_idexe;
    
    wire [31:0] jal_immed_out_exemem, jalr_immed_out_exemem, bra_immed_out_exemem, pc_jbra;
    wire MemWrite_res_idexe, RegWrite_res_idexe, bra_res_idexe, MemRead_res_idexe, ALUSrc_res_idexe; 
    wire [63:0] rf_readdata1, rf_readdata2; //RF read data wires
    wire [63:0] rf_readdata1_out, rf_readdata2_out; //read data output wires
    wire [63:0] writedata_out_wb; // wire to connect write back stage to writedata of RF
    wire j_res_idexe, StoreData_res_idexe, LoadData_res_idexe, bne_res_idexe; 
    wire z;
   

   //Idexe Wires (Ready for Next Stagereg)
        //input
    wire [31:0] inst_in_idexe;
    wire [31:0] pc_in_idexe;
     
        //output
    wire [31:0] inst_out_idexe;
    wire [31:0] pc_out_idexe;
    //wire [31:0] pc_out;

    

    //Program Counter
    programcounter PC0(
    .clk(clk), .nrst(nrst), 
    .opcode(inst_out_idexe[6:0]), .z(z), 
    .pc_jbra(pc_out_idexe), .rf_readdata1(rf_readdata1_out),
    .j(j_res_idexe), .bra(bra_res_idexe), .bne(bne_res_idexe),  
    .jal_immed(jal_immed_out_idexe), .jalr_immed(jalr_immed_out_idexe), .bra_immed(bra_immed_out_idexe), 
    .pc_next(pc_wire)
    );
    

    assign pc = pc_wire; //set processor output PC as wire connected to PC module
    
    

    //ifid_stagereg
    ifid_stagereg ifidsr0(
    .clk(clk), .nrst(nrst), 
    .inst_ifid(inst_in_ifid), .ifid_out(inst_out_ifid),
    .pc(pc), .pc_out(pc_out_ifid) 
    
    );

    
    //-----idexe stage-----//
    
    
    //connect input of idexe to output of ifid
    assign inst_in_idexe = inst_out_ifid;
    assign pc_in_idexe = pc_out_ifid;
    
    //Wire for Immediates
        //input
    wire [31:0] bra_immed_idexe, jal_immed_idexe, jalr_immed_idexe;
    wire [63:0] sd_immed_idexe;
    wire [63:0] addi_immed_idexe;
    
        //output
    wire [63:0] sd_immed_idexe_out;
    wire [63:0] addi_immed_idexe_out;

    
    //Wire Inputs for Control Unit
    wire ALUSrc_idexe; 
    wire [2:0] ALUop_idexe; 
    wire MemWrite_idexe; 
    wire MemRead_idexe;
    wire [1:0] MemtoReg_idexe; 
    wire RegWrite_idexe;
    wire bra_idexe, j_idexe, bne_idexe; 
    wire StoreData_idexe;
    wire LoadData_idexe;
    wire [7:0] wmask_idexe; 

    //Wire Outputs for Control Unit
    wire [2:0] ALUop_res_idexe; 
    wire [1:0] MemtoReg_res_idexe; 
    wire [7:0] wmask_res_idexe;  
    
    //Wire connecting to Register File
        //Reg File Input Wire
    wire [4:0] rf_readreg1;
    wire [4:0] rf_readreg2;
    wire [4:0] rf_writereg_idexe;
    
    //Wire for Writeback to RF
    wire RegWrite_res_memwb;
    
    

    //Control Unit
    control_unit c0 (
    .inst(inst_in_idexe), .ALUop(ALUop_idexe), .ALUSrc(ALUSrc_idexe), 
    .MemWrite(MemWrite_idexe), .MemRead(MemRead_idexe), 
    .RegWrite(RegWrite_idexe), .MemtoReg(MemtoReg_idexe),
    .j(j_idexe), .bra(bra_idexe), .bne(bne_idexe), 
    .StoreData(StoreData_idexe), .LoadData(LoadData_idexe), .wmask(wmask_idexe)
    );

    

    //Decoding Inst
    inst_rf instrf0(
    .inst(inst_out_ifid), 
    .rf_readreg1(rf_readreg1), .rf_readreg2(rf_readreg2),
    .rf_writereg(rf_writereg_idexe)
    );




    //Register File
    registerfile rf0(
    .clk(clk), .nrst(nrst),
    .rf_readreg1(rf_readreg1), .rf_readreg2(rf_readreg2), 
    .rf_writereg(inst_out_memwb[11:7]), .rf_writedata(writedata_out_wb),
    .rf_readdata1(rf_readdata1), .rf_readdata2(rf_readdata2),
    .RegWrite(RegWrite_res_memwb)
    );
    
    

    //Immediate Sign Extend Generator
    immed_signex immedsignex0(
    .inst(inst_out_ifid), 
    .sd_immed(sd_immed_idexe), .addi_immed(addi_immed_idexe),
    .jal_immed(jal_immed_idexe), .jalr_immed(jalr_immed_idexe), 
    .bra_immed(bra_immed_idexe)
    
    );



    

    //idexe stagereg
    idexe_stagereg idexesr0(
    .clk(clk), .nrst(nrst), 
    .inst_idexe(inst_in_idexe), .inst_idexe_out(inst_out_idexe),
    .pc_in(pc_in_idexe), .pc_out(pc_out_idexe),
    .rf_readdata1(rf_readdata1), .rf_readdata2(rf_readdata2),
    .rf_readdata1_out(rf_readdata1_out), .rf_readdata2_out(rf_readdata2_out),
    .jal_immed(jal_immed_idexe), .jalr_immed(jalr_immed_idexe), .bra_immed(bra_immed_idexe), 
    .sd_immed(sd_immed_idexe), .addi_immed(addi_immed_idexe),
    .jal_immed_out(jal_immed_out_idexe), .jalr_immed_out(jalr_immed_out_idexe), .bra_immed_out(bra_immed_out_idexe),
    .sd_immed_out(sd_immed_idexe_out), .addi_immed_out(addi_immed_idexe_out), 
    .ALUop(ALUop_idexe), .ALUSrc(ALUSrc_idexe),
    .MemWrite(MemWrite_idexe), .MemRead(MemRead_idexe), 
    .RegWrite(RegWrite_idexe), .MemtoReg(MemtoReg_idexe), 
    .j(j_idexe), .bra(bra_idexe), .bne(bne_idexe), 
    .StoreData(StoreData_idexe), .LoadData(LoadData_idexe), .wmask(wmask_idexe),
    .ALUop_res(ALUop_res_idexe), .ALUSrc_res(ALUSrc_res_idexe),
    .MemWrite_res(MemWrite_res_idexe), .MemRead_res(MemRead_res_idexe),
    .RegWrite_res(RegWrite_res_idexe), .MemtoReg_res(MemtoReg_res_idexe),
    .j_res(j_res_idexe), .bra_res(bra_res_idexe), .bne_res(bne_res_idexe),
    .StoreData_res(StoreData_res_idexe), .LoadData_res(LoadData_res_idexe), 
    .wmask_res(wmask_res_idexe)


    );




    //-----exemem stage-----//
    
    
    
    //Inputs
    wire [31:0] pc_in_exemem;
    wire [31:0] inst_in_exemem;
    

    //Outputs
    wire [31:0] pc_out_exemem;
    wire [31:0] inst_out_exemem;
    
    //Connect output of idexe to input of exemem
    assign pc_in_exemem = pc_out_idexe;
    assign inst_in_exemem = inst_out_idexe; 


    //Wire Inputs for Control Unit
    wire ALUSrc_exemem; 
    wire [2:0] ALUop_exemem; 
    wire MemWrite_exemem;
    wire MemRead_exemem;
    wire RegWrite_exemem;
    wire [1:0] MemtoReg_exemem; 
    wire bra_exemem, bne_exemem, j_exemem;
    wire StoreData_exemem, LoadData_exemem; 
    wire [7:0] wmask_exemem; 

    //Wire Outputs for Control Unit
    wire ALUSrc_res_exemem; 
    wire [2:0] ALUop_res_exemem; 
    wire MemWrite_res_exemem; 
    wire MemRead_res_exemem;
    wire RegWrite_res_exemem;
    wire [1:0] MemtoReg_res_exemem; 
    wire bra_res_exemem, bne_res_exemem, j_res_exemem; 
    wire StoreData_res_exemem, LoadData_res_exemem; 
    wire [7:0] wmask_res_exemem;  

    //ALU Wires
        //ALUop 2 Wire from Mux_Alu
    wire [63:0] rs2; 

    wire [2:0] ALUop; 
    wire [63:0] ALUres_exemem, ALUres_out_exemem;
    wire [63:0] rf_readdata2_out_exemem; //readdata2 output of exemem

    //Wire for Immediates
    wire [31:0] bra_immed_exemem, jal_immed_exemem, jalr_immed_exemem;
    

    

    //Connect output control signals of idexe to input control signals of exemem
    assign ALUSrc_exemem = ALUSrc_res_idexe;
    assign ALUop_exemem = ALUop_res_idexe;
    assign MemWrite_exemem = MemWrite_res_idexe;
    assign MemRead_exemem = MemRead_res_idexe;
    assign MemtoReg_exemem = MemtoReg_res_idexe;
    assign RegWrite_exemem = RegWrite_res_idexe;
    assign bra_exemem = bra_res_idexe;
    assign bne_exemem = bne_res_idexe;
    assign j_exemem = j_res_idexe;
    assign StoreData_exemem = StoreData_res_idexe;
    assign LoadData_exemem = LoadData_res_idexe;
    assign wmask_exemem = wmask_res_idexe;
    
        
    
    
    //MUX_alu
    mux_alu mux_alu0 (.ALUSrc(ALUSrc_res_idexe), .StoreData(StoreData_res_idexe), .sd_immed(sd_immed_idexe_out), .addi_immed(addi_immed_idexe_out), .rf_readdata2(rf_readdata2_out), .rs2(rs2)); 
    
    //ALU
    alu alu0 (.rs1(rf_readdata1_out), .rs2(rs2), .ALUop(ALUop_res_idexe), .z(z), .ALUres(ALUres_exemem)); 
    
   

    //exemem stagereg
    exemem_stagereg exememsr0 (
    .clk(clk), .nrst(nrst),
    .inst_in(inst_in_exemem), .inst_out(inst_out_exemem), 
    .pc_in(pc_in_exemem), .pc_out(pc_out_exemem), 
    .ALUres(ALUres_exemem), .ALUres_out(ALUres_out_exemem), 
    .rf_readdata2(rf_readdata2_out), .rf_readdata2_out(rf_readdata2_out_exemem),
    .ALUop(ALUop_exemem), .ALUSrc(ALUSrc_exemem),
    .MemWrite(MemWrite_exemem), .MemRead(MemRead_exemem), 
    .RegWrite(RegWrite_exemem), .MemtoReg(MemtoReg_exemem),
    .j(j_exemem), .bra(bra_exemem), .bne(bne_exemem), 
    .StoreData(StoreData_exemem), .LoadData(LoadData_exemem), .wmask(wmask_exemem),
    .MemWrite_res(MemWrite_res_exemem), .MemRead_res(MemRead_res_exemem), .RegWrite_res(RegWrite_res_exemem), .MemtoReg_res(MemtoReg_res_exemem),
    .ALUop_res(ALUop_res_exemem), .ALUSrc_res(ALUSrc_res_exemem), 
    .j_res(j_res_exemem), .bra_res(bra_res_exemem), .bne_res(bne_res_exemem),
    .StoreData_res(StoreData_res_exemem), .LoadData_res(LoadData_res_exemem),.wmask_res(wmask_res_exemem),
    .jal_immed(jal_immed_exemem), .jalr_immed(jalr_immed_exemem), .bra_immed(bra_immed_exemem), 
    .jal_immed_out(jal_immed_out_exemem), .jalr_immed_out(jalr_immed_out_exemem), .bra_immed_out(bra_immed_out_exemem)
    );


   
    //-----memwb stage-----//
        //Input
    wire [31:0] inst_in_memwb;
    wire [31:0] pc_in_memwb;
    
        //Output
    wire [31:0] pc_out_memwb;
    wire [31:0] inst_out_memwb;
    
    //connect output of exemem to input of memwb
    assign inst_in_memwb = inst_out_exemem; 
    assign pc_in_memwb = pc_out_exemem;
    assign ALUres_memwb = ALUres_out_exemem;
    
    //Wire Input for Control Unit
    wire ALUSrc_memwb; 
    wire [2:0] ALUop_memwb; 
    wire MemWrite_memwb;
    wire MemRead_memwb;
    wire [1:0] MemtoReg_memwb; 
    wire RegWrite_memwb;
    wire bra_memwb, j_memwb, bne_memwb;
    wire  StoreData_memwb, LoadData_memwb; 
    wire [7:0] wmask_memwb; 

      
    //rdata Wires
    wire [63:0] rdata_memwb;
    wire [63:0] rdata_out_memwb;
    wire [63:0] ALUres_out_memwb;


    //Wire Output for Control Unit
    wire ALUSrc_res_memwb; 
    wire [2:0] ALUop_res_memwb;
    wire MemWrite_res_memwb;
    wire MemRead_res_memwb;
    wire [1:0] MemtoReg_res_memwb; 
    wire j_res_memwb, bra_res_memwb, bne_res_memwb;
    wire  StoreData_res_memwb, LoadData_res_memwb; 
    wire [7:0] wmask_res_memwb; 


    //Connect output control signals of exemem to input control signals of memwb
    assign ALUSrc_memwb = ALUSrc_res_exemem;
    assign ALUop_memwb = ALUop_res_exemem;
    assign MemWrite_memwb = MemWrite_res_exemem;
    assign MemRead_memwb = MemRead_res_exemem;
    assign RegWrite_memwb = RegWrite_res_exemem;
    assign MemtoReg_memwb = MemtoReg_res_exemem;
    assign bra_memwb = bra_res_exemem;
    assign bne_memwb = bne_res_exemem;
    assign j_memwb = j_res_exemem;
    assign StoreData_memwb = StoreData_res_exemem;
    assign LoadData_memwb = LoadData_res_exemem;
    assign wmask_memwb = wmask_res_exemem;
        
    //Processor output signals 
    assign addr = ALUres_out_exemem[31:0]; 
    assign wdata = rf_readdata2_out_exemem;
    assign wmask = wmask_res_exemem;

    assign RFwrdata = writedata_out_wb;
    assign RFwren = RegWrite_res_memwb;

    assign ALUop1 = rf_readdata1_out;
    assign ALUop2 = rs2;
    assign ALUres = ALUres_out_exemem;
    
    
    assign wr_en = MemWrite_res_exemem;





    //memwb stagereg
    memwb_stagereg memwbsr0(
    .clk(clk), .nrst(nrst), 
    .inst_in(inst_in_memwb), .inst_out(inst_out_memwb),
    .pc_in(pc_in_memwb), .pc_out(pc_out_memwb),
    .rdata(rdata), .rdata_out(rdata_out_memwb),
    .ALUres(ALUres_out_exemem), .ALUres_out(ALUres_out_memwb),
    .ALUop(ALUop_memwb), .ALUSrc(ALUSrc_memwb), 
    .MemWrite(MemWrite_memwb), .MemRead(MemRead_memwb), .RegWrite(RegWrite_memwb), .MemtoReg(MemtoReg_memwb), 
    .j(j_memwb), .bra(bra_memwb), .bne(bne_memwb), 
    .StoreData(StoreData_memwb), .LoadData(LoadData_memwb), .wmask( wmask_memwb),
    .ALUop_res(ALUop_res_memwb), .ALUSrc_res(ALUSrc_res_memwb), 
    .MemWrite_res(MemWrite_res_memwb), .MemRead_res(MemRead_res_memwb), .RegWrite_res(RegWrite_res_memwb), .MemtoReg_res(MemtoReg_res_memwb), 
    .j_res(j_res_memwb), .bra_res(bra_res_memwb), .bne_res(bne_res_memwb),
    .StoreData_res(StoreData_res_memwb), .LoadData_res(LoadData_res_memwb),  
    .wmask_res(wmask_res_memwb)



    );


    

    mux_wb muxwb0 (
    .pc(pc_out_memwb), .ALUres(ALUres_out_memwb),
    .rdata(rdata_out_memwb), .funct3(inst_out_memwb[14:12]), 
    .MemtoReg(MemtoReg_res_memwb), .rf_writedata(writedata_out_wb)

    );

    

    
    
    
    
endmodule