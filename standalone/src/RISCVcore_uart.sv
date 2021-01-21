`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Md Badruddoja Majumder, Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 30, 2018
// 
// Module name: RISCVcore
// Description:
//   Implements top Mini-RISC-V core logic
//
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   clk -- system clock
//   Rst -- system reset signal
//   debug -- 1-bit debug control signal
//   debug_input -- 5-bit register address for viewing via debug port
// Output:
//   debug_output -- 32-bit output port for viewing contents of register
// 
//////////////////////////////////////////////////////////////////////////////////

//Interface bus between all pipeline stages
interface main_bus (
    input logic clk, Rst, debug, dbg, prog, mem_hold, //rx, //addr_dn, addr_up,
    input logic[4:0] debug_input, 
    input logic [95:0] key
//    output logic tx
    );
    
    logic         PC_En;
    logic         hz;
    logic         branch;
    logic  [31:0]  branoff;
    logic  [31:0]  ID_EX_pres_addr;
    logic  [31:0] ins;
    logic  [4:0]  ID_EX_rd;
    logic         ID_EX_memread,ID_EX_regwrite;
    logic  [4:0]  EX_MEM_rd,MEM_WB_rd,WB_ID_rd;
    logic  [4:0]  ID_EX_rs1,ID_EX_rs2;
    logic  [31:0] ID_EX_dout_rs1,ID_EX_dout_rs2,EX_MEM_dout_rs2;
    logic  [31:0] IF_ID_dout_rs1,IF_ID_dout_rs2;
    logic  [31:0]  IF_ID_pres_addr;
    logic         IF_ID_jalr;
    logic         ID_EX_jal,ID_EX_jalr;
    logic         ID_EX_compare;
    logic  [31:0] EX_MEM_alures,MEM_WB_alures,MEM_WB_memres;
    logic         EX_MEM_comp_res;
    
    logic [31:0] EX_MEM_pres_addr;
    logic [31:0] MEM_WB_pres_addr;
    
    logic  [4:0]  EX_MEM_rs1, EX_MEM_rs2;
    
    logic  [2:0]  ID_EX_alusel;
    logic  [4:0]  ID_EX_loadcntrl;
    logic  [2:0]  ID_EX_storecntrl;
    logic  [3:0]  ID_EX_cmpcntrl;
    logic  [4:0]  EX_MEM_loadcntrl;
    logic  [2:0]  EX_MEM_storecntrl;
    logic         ID_EX_alusrc;
    logic         EX_MEM_memread,MEM_WB_memread;
    logic         ID_EX_memwrite,EX_MEM_memwrite;
    logic         EX_MEM_regwrite,MEM_WB_regwrite,WB_ID_regwrite;
    logic         ID_EX_lui;
    logic         ID_EX_auipc;
    logic  [31:0] ID_EX_imm;
    logic  [31:0] WB_res,WB_ID_res;
    logic  [4:0]  adr_rs1;//used for debug option
    logic  [4:0]  IF_ID_rs1,IF_ID_rs2;
    logic         ID_EX_lb,ID_EX_lh,ID_EX_lw,ID_EX_lbu,ID_EX_lhu,ID_EX_sb,ID_EX_sh,ID_EX_sw;
    logic         EX_MEM_lb,EX_MEM_lh,EX_MEM_lw,EX_MEM_lbu,EX_MEM_lhu,EX_MEM_sb,EX_MEM_sh,EX_MEM_sw;
//    logic dbg;
    logic [31:0] uart_dout;
    logic memcon_prog_ena;
    
    logic IF_ID_jal;
    
    logic mmio_wea;
    logic [31:0] mmio_dat;
    logic mmio_read;
    
    logic [31:0] DD_out;
    
    logic [31:0] mem_din, mem_dout; 
    logic [31:0] mem_addr; 
    logic [3:0] mem_en; 
    logic mem_wea;
    logic mem_rea; 
       
    logic [31:0] imem_dout;
    logic imem_en;
    logic [31:0] imem_addr;
    
    
    //CSR signals 
//    logic [11:0] IF_ID_CSR_addr; 
//    logic [31:0] IF_ID_CSR_dout, ID_EX_CSR_dout;
//    logic [31:0] WB_CSR_res;
//    logic [11:0] MEM_WB_CSR_addr;
//    logic MEM_WB_CSR_write;
    
//    logic ID_EX_CSR_write;

    //modport declarations. These ensure each pipeline stage only sees and has access to the 
    //ports and signals that it needs
    
//    modport CSR(
//        input clk, IF_ID_CSR_addr, MEM_WB_CSR_addr,
//        input WB_CSR_res, MEM_WB_CSR_write,
//        output IF_ID_CSR_dout
//    );
    
    //modport for fetch stage
    modport fetch(
        input clk, PC_En, debug, prog, Rst, branch, IF_ID_jalr, IF_ID_jal,
        input dbg, mem_hold,
        //input rx,
        input uart_dout, memcon_prog_ena,
        input debug_input, branoff,
        output IF_ID_pres_addr, ins, 
        input imem_dout, 
        output imem_en, imem_addr
    );
    
    //modport for register file
    modport regfile(
        input clk, adr_rs1, IF_ID_rs2, MEM_WB_rd, Rst,
        input WB_res, MEM_WB_regwrite,
        output IF_ID_dout_rs1, IF_ID_dout_rs2 
    ); 
        
    //modport for decode stage
    modport decode(
        input clk, Rst, dbg, ins, IF_ID_pres_addr, MEM_WB_rd, WB_res, mem_hold,
        input EX_MEM_memread, EX_MEM_regwrite, MEM_WB_regwrite, EX_MEM_alures,
        input EX_MEM_rd, IF_ID_dout_rs1, IF_ID_dout_rs2, 
        inout ID_EX_memread, ID_EX_regwrite,
        output ID_EX_pres_addr, IF_ID_jalr, ID_EX_jalr, branch, IF_ID_jal,
        output IF_ID_rs1, IF_ID_rs2,
        output ID_EX_dout_rs1, ID_EX_dout_rs2, branoff, hz,
        output ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_alusel,
        output ID_EX_storecntrl, ID_EX_loadcntrl, ID_EX_cmpcntrl,
        output ID_EX_auipc, ID_EX_lui, ID_EX_alusrc, 
        output ID_EX_memwrite, ID_EX_imm, ID_EX_compare, ID_EX_jal
    );
     
    //modport for execute stage    
    modport execute(
        input clk, Rst, dbg, ID_EX_lui, ID_EX_auipc, ID_EX_loadcntrl, mem_hold,
        input ID_EX_storecntrl, ID_EX_cmpcntrl, 
        output EX_MEM_loadcntrl, EX_MEM_storecntrl, 
        input ID_EX_compare, ID_EX_pres_addr, ID_EX_alusel, ID_EX_alusrc,
        input ID_EX_memread, ID_EX_memwrite, ID_EX_regwrite, ID_EX_jal,
        input ID_EX_jalr, ID_EX_rs1, ID_EX_rs2, ID_EX_rd, ID_EX_dout_rs1, ID_EX_dout_rs2,
        output EX_MEM_dout_rs2, EX_MEM_rs2, EX_MEM_rs1,
        input ID_EX_imm, MEM_WB_regwrite, WB_ID_regwrite,
        output EX_MEM_alures,
        input WB_res, WB_ID_res, 
        output EX_MEM_memread, EX_MEM_rd,
        input MEM_WB_rd, WB_ID_rd,
        output EX_MEM_memwrite, EX_MEM_regwrite, EX_MEM_comp_res, 
        output EX_MEM_pres_addr,
        input key
    );
    
    //modport for memory stage
    modport memory (
        input clk, Rst, dbg, EX_MEM_storecntrl, mmio_read, mem_hold,
        input EX_MEM_pres_addr,
        input EX_MEM_loadcntrl, EX_MEM_alures, EX_MEM_dout_rs2, EX_MEM_rs2, WB_res, EX_MEM_rs1,
        input EX_MEM_rd, EX_MEM_regwrite, EX_MEM_memread, EX_MEM_memwrite,
        output MEM_WB_regwrite, MEM_WB_memread, MEM_WB_rd, MEM_WB_alures, MEM_WB_memres,
        output mmio_wea, mmio_dat, 
        
        input mem_dout, 
        output MEM_WB_pres_addr,
        output mem_din, mem_addr, mem_wea, mem_en, mem_rea
    );
    
    //modport for writeback stage
    modport writeback(
        input clk, Rst, dbg, MEM_WB_alures, MEM_WB_memres, MEM_WB_memread, mem_hold,
        input MEM_WB_regwrite, MEM_WB_rd,
        output WB_ID_regwrite, WB_ID_rd, WB_res, WB_ID_res
    );
    
    //modport for UART programmer
//    modport UART_Programmer(
//        input clk, Rst, rx,
//        output uart_dout, memcon_prog_ena
//    );
    
//    modport tx_control(
//        input clk, Rst, mmio_wea, mmio_dat,
//        output tx, mmio_read
//    );
    
//    modport Debug_Display(
//        input clk, Rst, mmio_wea, mmio_dat, 
////        input addr_dn, addr_up,
//        input debug_input, prog,
//        output DD_out
//    );
   
    
endinterface

module RISCVcore_uart(    
    riscv_bus rbus 
//    input   logic         clk,
//    input   logic         Rst,
//    input   logic         debug,
//    input   logic         rx, //uart recv
//    input   logic         prog, //reprogram or view instruction memory
//    input   logic [4:0]   debug_input,
//    output  logic [31:0]  debug_output,
    
//    output logic mem_wea,
//    output logic [3:0] mem_en, 
//    output logic [11:0] mem_addr, 
//    output logic [31:0] mem_din, 
//    input logic [31:0] mem_dout
//    input logic addr_dn, addr_up
//    output  logic         tx
    );
    //logic addr_dn = 0, addr_up = 0;
    
    logic clk, Rst, debug, prog, mem_wea, dbg; //rx,
    logic [4:0] debug_input;
    logic [31:0] debug_output, mem_addr, mem_din, mem_dout; 
    logic [3:0] mem_en; 
    
    always_comb begin
        clk = rbus.clk; 
        Rst = rbus.Rst; 
        debug = rbus.debug; 
        //rx = rbus.rx; 
        prog = rbus.prog; 
        debug_input = rbus.debug_input; 
        rbus.debug_output = debug_output; 
        rbus.mem_wea = mem_wea; 
        rbus.mem_rea = bus.mem_rea;
        rbus.mem_en = mem_en; 
        rbus.mem_addr = mem_addr; 
        rbus.mem_din = mem_din; 
        mem_dout = rbus.mem_dout; 
        rbus.imem_en = bus.imem_en;
        rbus.imem_addr = bus.imem_addr;
        bus.imem_dout = rbus.imem_dout;
        rbus.imem_din = bus.uart_dout;
        rbus.imem_prog_ena = bus.memcon_prog_ena;
    end
    
    
    main_bus bus(.key(rbus.key), .mem_hold(rbus.mem_hold), .*);
    
    assign mem_wea = bus.mem_wea;
//    assign mem_clk = bus.clk;
    assign mem_en = bus.mem_en;
    assign mem_addr = bus.mem_addr;
    assign mem_din = bus.mem_din;
    assign bus.mem_dout = mem_dout;
    
    
//    assign bus.PC_En=!bus.hz;
    assign bus.PC_En=(!bus.hz);
    assign dbg=(debug || prog); //added to stop pipeline on prog and/or debug
    //debugging resister
    assign bus.adr_rs1=debug ? debug_input:bus.IF_ID_rs1;
    
    always_ff @(posedge clk) begin
        if(Rst) begin
            debug_output<=32'h00000000;
        end
        else if (prog) begin //debug instruction memory
            debug_output<=bus.ins;
        end
        else if(debug) begin //debug register
            debug_output<= bus.IF_ID_dout_rs1;
        end
        else begin
//            debug_output<=bus.mmio_dat;
            debug_output<=32'h00000000;
        end
    end

    Fetch_Reprogrammable u1(bus.fetch);
    
    //register file
    Regfile u0(bus.regfile);
    
    Decode u2(bus.decode);
    
    Execute u3(bus.execute);
    
    Memory u4(bus.memory);
    
    Writeback u5(bus.writeback);
    
//    UART_Programmer uart(bus.UART_Programmer);
   
//    tx_control txc(bus.tx_control);
    
//    Debug_Display DD(bus.Debug_Display);
    
    
    
endmodule
