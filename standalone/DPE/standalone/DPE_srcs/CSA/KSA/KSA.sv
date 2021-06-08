`include "DPE_params.sv"


`define actual_idx jj - (2**(stage+1) - (stage+1) -1)
`define up_idx 2**(stage)-WIDTH-(1-(`actual_idx))
`define prev_idx 2**(stage-1)-WIDTH-(1-(`actual_idx))

module KSA_int
    (input logic p,
    input logic g,
    input logic p_prev,
    input logic g_prev,
    output logic p_out,
    output logic g_out
    );

    assign p_out = p & p_prev;
    assign g_out = (p & g_prev) | g;

endmodule

module KSA_2 
    (input logic[WIDTH-1:0] a,
    input logic[WIDTH-1:0] b,
    input logic c_in,
    output logic[WIDTH-1:0] s,
    output logic c_out);

    logic [(WIDTH * KSA_DEPTH)-ARR_OFF-1:0] p;
    logic [(WIDTH * KSA_DEPTH)-ARR_OFF-1:0] g;

    // logic [5:0] pre_idx1 = 6'b000001;
    // logic [5:0] pre_idx2 = 6'b000010;
    // logic [5:0] pre_idx3 = 6'b000100;
    // logic [5:0] pre_idx4 = 6'b001000;
    // logic [5:0] pre_idx5 = 6'b010000;

    // logic [29:0] pre_idx;
    // assign pre_idx[0 +: 6] = 6'b000001;
    // assign pre_idx[6*1+:6] = 6'b000010;
    // assign pre_idx[6*2+:6] = 6'b000100;
    // assign pre_idx[6*3+:6] = 6'b001000;
    // assign pre_idx[6*4+:6] = 6'b010000;

    //+1 for c_in
    // assign p[0] = c_in;
    // assign g[0] = c_in;
    
    assign p[0+:WIDTH] = a ^ b;
    assign g[0+:WIDTH] = a & b;

    assign s[0] = p[0] ^ c_in;

    genvar jj, stage;
    // generate
    // integer stage = 1; //I wish these could be genvars
    integer ac_idx[KSA_DEPTH*WIDTH-1:0],p_idx[KSA_DEPTH*WIDTH-1:0], u_idx[KSA_DEPTH*WIDTH-1:0];
    for(stage = 1; stage < KSA_DEPTH; stage++)begin
        for (jj=WIDTH*stage; jj<=WIDTH*(stage+1)-1; jj=jj+1) begin //loop through p/g[(WIDTH * KSA_DEPTH)-ARR_OFF:WIDTH]
            
            // if(jj + (2**stage - stage -1) == ((WIDTH*stage)-1))begin
            //     assign stage = stage + 1;
            // end
            // assign og_idx[jj] = jj;
            if (jj - WIDTH*stage >= 2**stage-1 ) begin
                assign ac_idx[jj] = `actual_idx;
                assign p_idx[jj] = `prev_idx;
                assign u_idx[jj] = `up_idx;
                KSA_int ksa_int(p[`up_idx], g[`up_idx], p[`prev_idx], g[`prev_idx], p[`actual_idx], g[`actual_idx]);
            end
        end
            // assign stage = stage_calc(jj, stage);

            // assign prev_idx = 2**(stage-1)-WIDTH-(1-jj);
            // assign up_idx = 2**(stage)-WIDTH-(1-jj);
        

    end

    // function integer stage_calc(int jj, stage);
    //     if(jj + (2**stage - stage -1) == ((WIDTH*stage)-1))begin
    //         return stage + 1;
    //     end
    //     return stage;
    // endfunction
    // endgenerate
    //shifted left one bit for c_in
    // assign s = p[WIDTH: 0] ^ g[(WIDTH * KSA_DEPTH)-WIDTH-1 +: WIDTH];

    //no too sure about this
    // assign c_out = g[WIDTH*KSA_DEPTH-1];
    // $display($time, "henlo");

    
endmodule