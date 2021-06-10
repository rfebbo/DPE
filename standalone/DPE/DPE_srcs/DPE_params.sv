`ifndef DPE_params
`define DPE_params;


//memory params
parameter N_LOCAL_REGS = 128; //# of 8bit registers on the DPE
parameter REG_ADDR_WIDTH = $clog2(N_LOCAL_REGS) + 1;
parameter SRAM_ADDR_WIDTH = 8; //8192 bits 32 bit word
parameter SRAM_WORD_LENGTH = 32;
parameter WIDTH = 8;

//spike mul params
parameter OUT_WIDTH = 16; //should be multiple of WIDTH
parameter INPUT_VEC_LEN = 8;
parameter OUTPUT_VEC_LEN = 8;

//CSA Params
parameter CSA_N_STAGE = 8;

//KSA Params
parameter KSA_DEPTH = $clog2(WIDTH) + 1; //KSA_DEPTH = log(WIDTH) + 1
parameter ARR_OFF = 2**KSA_DEPTH - KSA_DEPTH - 1; //ARR_OFF = 2^KSA_DEPTH - KSA_DEPTH -1 https://oeis.org/A000295

//scanchain width
parameter SC_DPE_IN_WIDTH = SRAM_WORD_LENGTH + SRAM_ADDR_WIDTH;
parameter SC_DPE_OUT_WIDTH = N_LOCAL_REGS * WIDTH;
parameter SC_MAC_IN_WIDTH = INPUT_VEC_LEN*OUTPUT_VEC_LEN*WIDTH+INPUT_VEC_LEN;
parameter SC_MAC_OUT_WIDTH = OUTPUT_VEC_LEN*OUT_WIDTH;
`endif