`include "../DPE_srcs/DPE_params.sv"
`timescale 1ns/10ps

module DPE_tb(); 

    // Inputs
    logic scanIn; // scan inputs
    logic CLK; // Clock signal
    logic SC_CLK; // scan Clock signal
    logic SC_EN; //Scan Enable
    logic RESETn; //Global reset
    // Outputs
    logic scanOut;    // scan output
    DPE dpe(.scanIn(scanIn), .CLK(CLK), .SC_CLK(SC_CLK), .SC_EN(SC_EN), .RESETn(RESETn), .scanOut(scanOut));

    //1Kb SRAM emulator 128x64
    logic [255:0][SRAM_WORD_LENGTH-1:0] ram;

    int pc; //programming counter

    always #5 CLK = ~CLK;
    always #125 SC_CLK = ~SC_CLK;

    // always begin
    //     #2 data_in <= ram[addr];
    //     if(write_en) begin
    //         ram[addr] <= data_out;
    //     end
    // end

    initial begin
        CLK = 0;
        SC_CLK = 0;
        RESETn = 0;
        ram = 0;
        SC_EN = 0;
        #500;
        RESETn = 1;

        //set some memory
        //spike 8 bits
        ram['h80] = 32'h00000080; //1000 0000 //copy top row of matrix

        //matrix 64 bytes takes up 16 32bit ram 
        //lets set the first row to some values that are easy to read for debugging
        
        ram['h81] = 'h03020100;
        ram['h82] = 'h07060504;
        
        for (int i = 'h83; i <= 'h90; i++) begin
            ram[i] = $random;
        end

        //set some instructions in memory
        //read spike: ld 80 0
        pc = 0;
        ram[pc] = 0;
        ram[pc][3:0] = 'h0; //ld
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h080; //where from in ram
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h00; //where to in registers
        pc++;

        //read mat: ld 81 thru 90 into 4 thru 40
        for (int i = 0; i < 16; i++) begin
            ram[pc] = 0;
            ram[pc][3:0] = 'h0; //ld
            ram[pc][4+:SRAM_ADDR_WIDTH] = 'h081+i; //where from in ram
            ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h04+(i*4); //where to in registers
            pc++;
            //not sure why this line does not work...
            // ram[pc][23:0] = {('h04+(i*4)),('h081 + i),'h0};
        end

        //multiply: mul 0 4 44
        ram[pc] = 0;
        ram[pc][3:0] = 'h2; //mul
        ram[pc][4+:REG_ADDR_WIDTH] = 'h00; // where the spikes are in regs 
        ram[pc][4+REG_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h04; // where the matrix starts in regs
        ram[pc][4+REG_ADDR_WIDTH*2+:REG_ADDR_WIDTH] = 'h44; // where the result should go in regs
        pc++;

        //rank outputs
        ram[pc] = 0;
        ram[pc][3:0] = 'h4; //rank
        ram[pc][4+:REG_ADDR_WIDTH] = 'h44; // where in regs to rank (8*8*2 bits long)
        ram[pc][4+REG_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h54; // where in regs to store rank
        pc++;

        //store rank to sram
        ram[pc] = 0;
        ram[pc][3:0] = 'h1; //store
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h91; // where in sram to store
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h54; // where in regs store from
        pc++;
        ram[pc] = 0;
        ram[pc][3:0] = 'h1; //store
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h92; // where in sram to store
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h58; // where in regs store from
        pc++;

        //test jmp
        ram[pc] = 0;
        ram[pc][3:0] = 'h3; //jmp
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h00; // where to jump in sram
        pc++;


        for (logic[SRAM_ADDR_WIDTH-1:0] i = 0; i < 'h90; i++) begin
            for (int j = 0; j < SRAM_WORD_LENGTH; j++) begin
                scanIn = ram[i][j]; // data
                #250;
            end
            for (int j = 0; j < SRAM_ADDR_WIDTH; j++) begin
                scanIn <= i[j]; //address
                #250;
            end

            scanIn = 1;
            SC_EN = 1;
            #250;
            SC_EN = 0;
        end

        //send FFFFFFFFFF signal to DPE to signify the end of INIT
        for (int j = 0; j < SRAM_WORD_LENGTH; j++) begin
            scanIn = 1;
            #250;
        end
        for (int j = 0; j < SRAM_ADDR_WIDTH; j++) begin
            scanIn <= 1;
            #250;
        end
        scanIn = 1;
        SC_EN = 1;
        #250;
        SC_EN = 0;
    end
endmodule