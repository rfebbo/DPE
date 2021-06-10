`include "../DPE_srcs/DPE_params.sv"
`timescale 1ns/10ps

module spike_MAC_wrapper_compiled_tb ();


    logic scanIn, CLK, SC_EN, RESETn, scanOut;

    spike_MAC_wrapper_compiled dut(scanIn, CLK, SC_EN, RESETn, scanOut);

    always #5 CLK = ~CLK;

    logic [SC_MAC_IN_WIDTH:0] in;
    logic [SC_MAC_OUT_WIDTH-1:0] out;

    initial begin
        CLK = 0;
        RESETn = 0;
        SC_EN = 1;
        #26;
        RESETn = 1;
        
        //spike 8 bits
        in[INPUT_VEC_LEN-1:0] = 'h80; //1000 0000 //copy top row of matrix

        // DATAinp[INPUT_VEC_LEN + kk + jj*WIDTH + ii*WIDTH*OUTPUT_VEC_LEN];

        //matrix 64 bytes row major
        for (logic[(WIDTH/2)-1:0] i = 0; i < INPUT_VEC_LEN; i++) begin
            for (logic[(WIDTH/2)-1:0] j = 0; j < OUTPUT_VEC_LEN; j++) begin
                in[INPUT_VEC_LEN + j*WIDTH + i*WIDTH*OUTPUT_VEC_LEN+: WIDTH] = {i,j};
            end
        end

        in[SC_MAC_IN_WIDTH] = 1;

        for (int i = 0; i < SC_MAC_IN_WIDTH; i++) begin
            scanIn = in[i];
            #10;
        end
        scanIn = 1;
        #10
        SC_EN = 0;


        
    end

    
endmodule