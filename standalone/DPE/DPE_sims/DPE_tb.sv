`include "../DPE_srcs/DPE_params.sv"
`timescale 1ns/10ps

module DPE_tb(); 



    parameter SPI_MODE = 1; // CPOL = 0, CPHA = 1
    // Inputs
    logic scanIn; // scan inputs
    logic CLK; // Clock signal
    logic SC_CLK; // scan Clock signal
    logic SC_EN; //Scan Enable
    logic RESETn; //Global reset
    // Outputs
    logic scanOut;    // scan output

    //SPI
    logic w_SPI_Clk;
    logic r_SPI_En    = 1'b0;
    // logic r_Clk       = 1'b0;
    logic w_SPI_CS_n;
    logic w_SPI_MOSI;
    logic w_SPI_MISO;
    logic r_Master_CS_n = 1'b1;

    DPE dpe(.scanIn(scanIn), .CLK(CLK), .SC_CLK(SC_CLK), .SC_EN(SC_EN), .RESETn(RESETn), .scanOut(scanOut), .i_SPI_Clk(w_SPI_Clk), .o_SPI_MISO(w_SPI_MISO), .i_SPI_MOSI(w_SPI_MOSI), .i_SPI_CS_n(r_Master_CS_n));

    //1Kb SRAM emulator 128x64
    logic [255:0][SRAM_WORD_LENGTH-1:0] ram;

    int pc; //programming counter

    

    // Master Specific
    logic [7:0] r_Master_TX_Byte = 0;
    logic r_Master_TX_DV = 1'b0;
    logic w_Master_TX_Ready;
    logic r_Master_RX_DV;
    logic [7:0] r_Master_RX_Byte;

    // Instantiate Master to drive Slave
    SPI_Master 
    #(.SPI_MODE(SPI_MODE),
        .CLKS_PER_HALF_BIT(2)) SPI_Master_UUT
    (
    // Control/Data Signals,
    .i_Rst_L(RESETn),     // FPGA Reset
    .i_Clk(CLK),         // FPGA Clock
    
    // TX (MOSI) Signals
    .i_TX_Byte(r_Master_TX_Byte),     // Byte to transmit on MOSI
    .i_TX_DV(r_Master_TX_DV),         // Data Valid Pulse with i_TX_Byte
    .o_TX_Ready(w_Master_TX_Ready),   // Transmit Ready for Byte
    
    // RX (MISO) Signals
    .o_RX_DV(r_Master_RX_DV),       // Data Valid pulse (1 clock cycle)
    .o_RX_Byte(r_Master_RX_Byte),   // Byte received on MISO

    // SPI Interface
    .o_SPI_Clk(w_SPI_Clk),
    .i_SPI_MISO(w_SPI_MISO),
    .o_SPI_MOSI(w_SPI_MOSI)
    );

    always #7 CLK = ~CLK;
    always #175 SC_CLK = ~SC_CLK;
    // always #70 w_SPI_Clk = ~w_SPI_Clk;

    // always begin
    //     #2 data_in <= ram[addr];
    //     if(write_en) begin
    //         ram[addr] <= data_out;
    //     end
    // end

    // Sends a single byte from master to slave.  Will drive CS on its own.
    task SendSingleByte(input [7:0] data);
        @(posedge CLK);
        r_Master_TX_Byte <= data;
        r_Master_TX_DV   <= 1'b1;
        r_Master_CS_n    <= 1'b0;
        @(posedge CLK);
        r_Master_TX_DV <= 1'b0;
        @(posedge w_Master_TX_Ready);
        r_Master_CS_n    <= 1'b1;    
    endtask // SendSingleByte

    initial begin
        CLK = 0;
        SC_CLK = 0;
        RESETn = 0;
        ram = 0;
        SC_EN = 1;
        #350;
        RESETn = 1;

        //set some memory
        //spike 8 bits
        // ram['h20] = 32'h00000001; //0000 0001 //copy bottom row of matrix
        ram['h20] = 32'h000000FF; //1111 1111 //full summation

        //matrix 64 bytes takes up 16 32bit ram 
        //lets set some values that are easy to read for debugging
        
        ram['h21] = 'h03020100;
        ram['h22] = 'hFF060504;
        ram['h23] = 'h03020100;
        ram['h24] = 'hFF060504;
        ram['h25] = 'h03020100;
        ram['h26] = 'hFF060504;
        ram['h27] = 'h03020100;
        ram['h28] = 'hFF060504;
        ram['h29] = 'h03020100;
        ram['h2a] = 'hFF060504;
        ram['h2b] = 'h03020100;
        ram['h2c] = 'hFF060504;
        ram['h2d] = 'h03020100;
        ram['h2e] = 'hFF060504;
        ram['h2f] = 'h03020100;
        ram['h30] = 'hFF060504;
        
        // for (int i = 'h23; i <= 'h30; i++) begin
        //     ram[i] = $random;
        // end

        //set some instructions in memory
        //read spike: ld 20 0
        pc = 0;
        ram[pc] = 0;
        ram[pc][3:0] = 'h0; //ld
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h020; //where from in ram
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h00; //where to in registers
        pc++;

        //read matrix: ld 21 thru 30 into 4 thru 40
        for (int i = 0; i <= 16; i++) begin
            ram[pc] = 0;
            ram[pc][3:0] = 'h0; //ld
            ram[pc][4+:SRAM_ADDR_WIDTH] = 'h021+i; //where from in ram
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
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h31; // where in sram to store
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h54; // where in regs store from
        pc++;
        ram[pc] = 0;
        ram[pc][3:0] = 'h1; //store
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h32; // where in sram to store
        ram[pc][4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH] = 'h58; // where in regs store from
        pc++;

        //test jmp
        ram[pc] = 0;
        ram[pc][3:0] = 'h3; //jmp
        ram[pc][4+:SRAM_ADDR_WIDTH] = 'h00; // where to jump in sram
        pc++;


        for (logic[SRAM_ADDR_WIDTH-1:0] i = 0; i <= 'h30; i++) begin
            for (int j = 0; j < SRAM_WORD_LENGTH; j++) begin
                scanIn = ram[i][j]; // data
                #350;
            end
            for (int j = 0; j < SRAM_ADDR_WIDTH; j++) begin
                scanIn <= i[j]; //address
                #350;
            end

            scanIn = 1;
            // SC_EN = 0;
            #350;
            SC_EN = 0;
            #350;
            SC_EN = 1;

        end

        //send FFFFFFFFFF signal to DPE to signify the end of INIT
        for (int j = 0; j < SRAM_WORD_LENGTH; j++) begin
            scanIn = 1;
            #350;
        end
        for (int j = 0; j < SRAM_ADDR_WIDTH; j++) begin
            scanIn <= 1;
            #350;
        end
        scanIn = 1;
        SC_EN = 0;
        #350;
        SC_EN = 1;

        #1200;
        SendSingleByte(8'h00);
        SendSingleByte(8'h00); //0
        SendSingleByte(8'h00); //1
        SendSingleByte(8'h00); //2
        SendSingleByte(8'h00); //3
        SendSingleByte(8'h01);
        SendSingleByte(8'h21);
        SendSingleByte(8'haa);
        SendSingleByte(8'haa);
        SendSingleByte(8'haa);
        SendSingleByte(8'haa);
        
    end
endmodule