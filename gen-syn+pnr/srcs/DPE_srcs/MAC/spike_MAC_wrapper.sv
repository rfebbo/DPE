`include "../DPE_params.sv"

module spike_MAC_wrapper(// Inputs
            input scanIn, // scan inputs
            input CLK, // Clock signal
            input SC_EN, //Scan Enable
            input RESETn, //Global reset
            // Outputs
            output scanOut    // scan output
            );


    //scan chain signals
    wire [SC_MAC_IN_WIDTH:0] DATA; // Circuit EN (1-bit) + SC_MAC_IN_WIDTH
    wire [SC_MAC_IN_WIDTH-1:0]DATAinp;
    wire [SC_MAC_OUT_WIDTH-1:0]DATAout;
    wire [SC_MAC_OUT_WIDTH-1:0]DATAoutp;
    wire EN;
    wire ParEN;
    
    //MSB is the circuit enable
    assign EN = DATA[SC_MAC_IN_WIDTH];
    
    //Enable parallel loading of result in the Scan Chain
    assign ParEN = !SC_EN & EN;

    //13 bit shift register for scan in/out
    ShiftRegN  #(SC_MAC_IN_WIDTH+1) SRscanInps  (.d(scanIn), .clk (CLK), .en (SC_EN), .rstn (RESETn), .out (DATA));
    //12 bit parallel load register for inputs
    RegPLoad  #(SC_MAC_IN_WIDTH) RegInps  (.clk (CLK), .ld(ParEN), .pd(DATA[SC_MAC_IN_WIDTH-1:0]), .rstn (RESETn), .out (DATAinp));
    //6 bit output register paralley loaded and part of the scan chain
    ShiftRegPLoad  #(SC_MAC_OUT_WIDTH) RegOuts  (.d(DATA[0]), .clk (CLK), .en (SC_EN), .ld(ParEN), .pd(DATAoutp), .rstn (RESETn), .out (DATAout));

    assign scanOut = DATAout[0];
    
    logic [INPUT_VEC_LEN-1: 0] m_spikes;
    logic [INPUT_VEC_LEN-1:0][OUTPUT_VEC_LEN-1:0][WIDTH-1:0] m_matrix;
    logic [OUTPUT_VEC_LEN-1:0][OUT_WIDTH-1:0] m_out;

    spike_MAC mac(m_spikes, m_matrix, m_out);


    genvar ii, jj, kk;
    for (ii = 0; ii < INPUT_VEC_LEN; ii++) begin
        assign m_spikes[ii] = DATAinp[ii];
    end

    for (ii = 0; ii < INPUT_VEC_LEN; ii++) begin
        for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin
            for (kk = 0; kk < WIDTH; kk++) begin
                assign m_matrix[ii][jj][kk] = DATAinp[INPUT_VEC_LEN + kk + jj*WIDTH + ii*WIDTH*OUTPUT_VEC_LEN];
            end
        end
    end


    for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin
        assign DATAoutp[jj*OUT_WIDTH +: OUT_WIDTH] = m_out[jj];
    end

endmodule