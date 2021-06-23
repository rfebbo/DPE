`include "DPE_params.sv"



typedef enum logic [3:0] {LD, ST, MUL, JMP, RANK, IDLE} instruction;

typedef enum logic [1:0] {INIT, FETCH, DECODE, EXECUTE} CPU_STATE;

typedef enum logic {fe_enable, fe_read} fetch_state;

typedef enum logic [1:0] {tx_wait, tx_read, tx_send, tx_incr} TX_state;
typedef enum logic [1:0] {rx_wait, rx_wait_d, rx_write, rx_finish} RX_state;

//states for each instruction
typedef enum logic {ld_enable, ld_read} ld_state;
typedef enum logic {st_enable, st_write} st_state;
typedef enum logic {set, get} mul_state;
typedef enum logic [1:0] { copy, sorting, swapping, done } rank_state;

module DPE
  #(parameter SPI_MODE = 0)
( // Inputs
            input scanIn, // scan inputs
            input CLK, // Clock signal
            input SC_CLK, //scan clock
            input SC_EN, //Scan Enable
            input RESETn, //Global reset
            // Outputs
            output scanOut,    // scan output

            // SPI Interface
            input      i_SPI_Clk,
            output     o_SPI_MISO,
            input      i_SPI_MOSI,
            input      i_SPI_CS_n
            );

    //scan chain signals
    wire [SC_DPE_IN_WIDTH:0]DATA; // Circuit EN (1-bit) + 32 bits per sram word + 8 bits per sram address
    wire [SC_DPE_IN_WIDTH-1:0]DATAinp;
    wire [SC_DPE_OUT_WIDTH-1:0]DATAoutp; //the entire register stack 1024 bits
    wire [SC_DPE_OUT_WIDTH-1:0]DATAout;
    wire EN;
    wire ParEN;    
    
    //MSB is the circuit enable
    assign EN = DATA[SC_DPE_IN_WIDTH];
    
    //Enable parallel loading of result in the Scan Chain
    assign ParEN = !SC_EN & EN;

    //shift register for scan in/out
    ShiftRegN  #(SC_DPE_IN_WIDTH+1) SRscanInps  (.d(scanIn), .clk (SC_CLK), .en (SC_EN), .rstn (RESETn), .out (DATA));
    //parallel load register for inputs
    RegPLoad  #(SC_DPE_IN_WIDTH) RegInps  (.clk (SC_CLK), .ld(ParEN), .pd(DATA[SC_DPE_IN_WIDTH-1:0]), .rstn (RESETn), .out (DATAinp));
    //output register paralley loaded and part of the scan chain
    ShiftRegPLoad  #(SC_DPE_OUT_WIDTH) RegOuts  (.d(DATA[0]), .clk (SC_CLK), .en (SC_EN), .ld(ParEN), .pd(DATAoutp), .rstn (RESETn), .out (DATAout));

    assign scanOut = DATAout[0];

    logic [SRAM_WORD_LENGTH-1:0] data_in; //data read from sram
    logic [SRAM_WORD_LENGTH-1:0] data_out; //data write to sram
    logic [SRAM_ADDR_WIDTH-1:0] addr;
    logic write_en;
    logic sense_enb;

    logic o_RX_DV;    // Data Valid pulse (1 clock cycle)
    logic [7:0] o_RX_Byte;  // Byte received on MOSI
    logic i_TX_DV;    // Data Valid pulse to register i_TX_Byte
    logic [7:0] i_TX_Byte;  // Byte to serialize to MISO.
    logic TX; //high when sending sram data
    logic RX; //high when receiving sram data
    logic [2:0] TX_idx;
    logic [SRAM_WORD_LENGTH-1:0] data_TX;
    logic [2:0] RX_idx;
    logic [SRAM_WORD_LENGTH-1:0] data_RX;
    logic [SRAM_ADDR_WIDTH-1:0] addr_tmp;

    SPI_Slave #(.SPI_MODE(SPI_MODE)) SPI_Slave_UUT
    (
    // Control/Data Signals,
    .i_Rst_L(RESETn),      // FPGA Reset
    .i_Clk(CLK),          // FPGA Clock
    .o_RX_DV(o_RX_DV),      // Data Valid pulse (1 clock cycle)
    .o_RX_Byte(o_RX_Byte),  // Byte received on MOSI
    .i_TX_DV(i_TX_DV),      // Data Valid pulse
    .i_TX_Byte(i_TX_Byte),  // Byte to serialize to MISO (set up for loopback)

    // SPI Interface
    .i_SPI_Clk(i_SPI_Clk),
    .o_SPI_MISO(o_SPI_MISO),
    .i_SPI_MOSI(i_SPI_MOSI),
    .i_SPI_CS_n(i_SPI_CS_n)
    );

    //SRAM
    sram_1kb_64x128x32 sram(.addr0(addr[0]), .addr1(addr[1]), .addr2(addr[2]), .addr3(addr[3]),
    .addr4(addr[4]), .addr5(addr[5]), .addr6(addr[6]), .addr7(addr[7]),
    .din0(data_in[0]), .din1(data_in[1]), .din2(data_in[2]), .din3(data_in[3]), .din4(data_in[4]),
    .din5(data_in[5]), .din6(data_in[6]), .din7(data_in[7]), .din8(data_in[8]), .din9(data_in[9]),
    .din10(data_in[10]), .din11(data_in[11]), .din12(data_in[12]), .din13(data_in[13]),
    .din14(data_in[14]), .din15(data_in[15]), .din16(data_in[16]), .din17(data_in[17]),
    .din18(data_in[18]), .din19(data_in[19]), .din20(data_in[20]), .din21(data_in[21]),
    .din22(data_in[22]), .din23(data_in[23]), .din24(data_in[24]), .din25(data_in[25]),
    .din26(data_in[26]), .din27(data_in[27]), .din28(data_in[28]), .din29(data_in[29]),
    .din30(data_in[30]), .din31(data_in[31]),
    .dout0(data_out[0]), .dout1(data_out[1]), .dout2(data_out[2]), .dout3(data_out[3]),
    .dout4(data_out[4]), .dout5(data_out[5]), .dout6(data_out[6]), .dout7(data_out[7]),
    .dout8(data_out[8]), .dout9(data_out[9]), .dout10(data_out[10]), .dout11(data_out[11]),
    .dout12(data_out[12]), .dout13(data_out[13]), .dout14(data_out[14]), .dout15(data_out[15]),
    .dout16(data_out[16]), .dout17(data_out[17]), .dout18(data_out[18]), .dout19(data_out[19]),
    .dout20(data_out[20]), .dout21(data_out[21]), .dout22(data_out[22]), .dout23(data_out[23]),
    .dout24(data_out[24]), .dout25(data_out[25]), .dout26(data_out[26]), .dout27(data_out[27]),
    .dout28(data_out[28]), .dout29(data_out[29]), .dout30(data_out[30]), .dout31(data_out[31]),
    .clk(CLK), .write_en(write_en), .sense_en(sense_enb));

    logic [SRAM_ADDR_WIDTH-1:0] pc; //program counter

    instruction inst; //current instruction

    CPU_STATE s;

    //fetch
    fetch_state f_state;

    //load / store
    ld_state l_state;
    logic [SRAM_ADDR_WIDTH-1:0] ld_addr;
    logic [REG_ADDR_WIDTH-1:0] ld_reg_addr;

    st_state s_state;
    logic [SRAM_ADDR_WIDTH-1:0] st_addr;
    logic [REG_ADDR_WIDTH-1:0] st_reg_addr;

    //mul
    mul_state m_state;
    logic [REG_ADDR_WIDTH-1:0] spike_reg_addr;
    logic [REG_ADDR_WIDTH-1:0] mat_reg_addr;
    logic [REG_ADDR_WIDTH-1:0] res_reg_addr;

    
    logic [INPUT_VEC_LEN-1: 0] m_spikes;
    logic [INPUT_VEC_LEN-1:0][OUTPUT_VEC_LEN-1:0][WIDTH-1:0] m_matrix;
    logic [OUTPUT_VEC_LEN-1:0][OUT_WIDTH-1:0] m_out;

    spike_MAC mac(m_spikes, m_matrix, m_out);

    //jmp
    logic [SRAM_ADDR_WIDTH-1:0] jmp_addr;

    //rank
    rank_state r_state;
    logic [REG_ADDR_WIDTH-1:0] rank_start;
    logic [REG_ADDR_WIDTH-1:0] rank_res;
    logic [WIDTH-1:0] temp_idx;
    logic [OUTPUT_VEC_LEN-1:0][OUT_WIDTH-1:0] values;
    logic [OUT_WIDTH-1:0] temp_val;

    //SPI states
    TX_state tx_state;
    RX_state rx_state;
    
    //local registers
    logic [N_LOCAL_REGS-1:0][WIDTH-1:0] regs;

    //flatten regs into DATAoutp for scanchain
    genvar ii;
    for (ii = 0; ii < N_LOCAL_REGS; ii++) begin
        // assign DATAoutp[ii*WIDTH +: WIDTH] = regs[ii];
        assign DATAoutp[WIDTH*(ii+1)-1:WIDTH*ii] = regs[ii];
    end

    always_ff @(posedge CLK) begin

        write_en <= 0; //active high
        sense_enb <= 0; //active low


        if(~RESETn) begin
            //reset state machines
            tx_state <= tx_wait;
            rx_state <= rx_wait;
            s <= INIT;
            f_state <= fe_enable;
            l_state <= ld_enable;
            s_state <= st_enable;
            m_state <= set;
            r_state <= copy;
            //reset program counter
            pc <= 0;
            //reset regs
            regs <= 0;
            TX <= 0;
            RX <= 0;
            // i_TX_Byte <= 'hF5;
            // i_TX_DV <= 1;
            TX_idx <= 0;
            RX_idx <= 0;
        end
        else if(o_RX_DV && ~TX && ~RX) begin
            addr_tmp <= addr;
            if(o_RX_Byte == 'h00) begin
                TX <= 1;
            end
            if(o_RX_Byte == 'h01) begin
                RX <= 1;
            end
        end
        else if(TX) begin
            case (tx_state)
                tx_wait: begin //wait for address
                    if (o_RX_DV) begin
                        tx_state <= tx_read;
                        addr <= o_RX_Byte;
                        sense_enb <= 0;
                    end
                end
                tx_read: begin
                    
                    tx_state <= tx_send;
                    data_TX <= data_out;
                end
                tx_send: begin
                    i_TX_DV <= 1;
                    i_TX_Byte <= data_TX[TX_idx*8+:8];


                    tx_state <= tx_incr;
                end
                tx_incr: begin
                    i_TX_DV <= 0;
                    if(TX_idx == 'h3) begin
                        TX <= 0;
                        tx_state <= tx_wait;
                        TX_idx <= 0;
                        addr <= addr_tmp;
                    end
                    else if (i_SPI_CS_n) begin //wait for another spi TX/RX clock burst
                        TX_idx <= TX_idx + 1;
                        tx_state <= tx_send;
                    end

                end
            endcase
        end
        else if(RX) begin
            case (rx_state)
                rx_wait: begin //wait for address
                    if (o_RX_DV) begin
                        rx_state <= rx_wait_d;
                        addr <= o_RX_Byte;
                        sense_enb <= 1;
                    end
                end
                rx_wait_d: begin //wait for address
                    if (o_RX_DV) begin
                        data_RX[RX_idx*8+:8] <= o_RX_Byte;
                        sense_enb <= 1;

                        if(RX_idx == 'h3) begin
                            rx_state <= rx_write;
                        end
                        else begin
                            RX_idx <= RX_idx + 1;
                        end
                    end
                end
                rx_write: begin
                    data_in <= data_RX;
                    sense_enb <= 1;
                    write_en <= 1;
                    rx_state <= rx_finish;
                end
                rx_finish: begin
                    sense_enb <= 1;
                    write_en <= 0;
                    rx_state <= rx_wait;
                    RX <= 0;
                    addr <= addr_tmp;
                end
            endcase
            
        end
        else begin
            case (s)
                INIT: begin
                    sense_enb <= 1; //active low
                    if (ParEN) begin
                        if (DATAinp == 'hFFFFFFFFFF) begin
                            s <= FETCH;
                            write_en <= 0;
                        end
                        else begin
                            write_en <= 1; //active high
                            //write data to sram
                            data_in <= DATAinp[SRAM_WORD_LENGTH-1:0];
                            addr <= DATAinp[SC_DPE_IN_WIDTH-1:SRAM_WORD_LENGTH];

                        end
                    end
                end
                FETCH: begin

                    case (f_state)
                        fe_enable: begin
                            //read the instruction at 'pc' from sram
                            f_state <= fe_read;
                            addr <= pc;
                            write_en <= 0;
                            sense_enb <= 0;
                        end
                        fe_read: begin
                            //decode opcode
                            case (data_out[3:0])
                                'h0: inst <= LD;
                                'h1: inst <= ST;
                                'h2: inst <= MUL;
                                'h3: inst <= JMP;
                                'h4: inst <= RANK;
                                'h5: inst <= IDLE;
                                default: inst <= IDLE;
                            endcase
                            pc <= pc + 1;
                            f_state <= fe_enable;
                            s <= DECODE;
                        end
                        default: begin
                        end
                    endcase
                end
                DECODE: begin
                    
                    sense_enb <= 0;
                    //store whats in data_out for use in EXECUTE stage
                    case (inst)
                        LD: begin
                            l_state <= ld_enable;
                            ld_addr <= data_out[4+:SRAM_ADDR_WIDTH]; //starting after opcode width of sram addr
                            ld_reg_addr <= data_out[4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH];
                            s <= EXECUTE;
                        end
                        ST: begin
                            s_state <= st_enable;
                            st_addr <= data_out[4+:SRAM_ADDR_WIDTH]; //starting after opcode width of sram addr
                            st_reg_addr <= data_out[4+SRAM_ADDR_WIDTH+:REG_ADDR_WIDTH];
                            s <= EXECUTE;
                        end
                        MUL: begin
                            m_state <= set;
                            spike_reg_addr <= data_out[4+:REG_ADDR_WIDTH]; //starting after opcode width of local reg addr
                            mat_reg_addr <= data_out[4+REG_ADDR_WIDTH+:REG_ADDR_WIDTH];
                            res_reg_addr <= data_out[4+REG_ADDR_WIDTH*2+:REG_ADDR_WIDTH];
                            s <= EXECUTE;
                        end 
                        JMP: begin
                            jmp_addr <= data_out[4+:SRAM_ADDR_WIDTH];

                            s <= EXECUTE;
                        end 
                        RANK: begin
                            r_state <= copy;
                            rank_start <= data_out[4+:REG_ADDR_WIDTH];
                            rank_res <= data_out[4+REG_ADDR_WIDTH+:REG_ADDR_WIDTH];

                            s <= EXECUTE;
                        end 
                        default: begin
                            s <= EXECUTE;
                        end
                    endcase
                end
                EXECUTE: begin

                    case (inst)
                        LD: begin
                            case (l_state)
                                ld_enable: begin
                                    l_state <= ld_read;
                                    addr <= ld_addr;
                                    write_en <= 0; //active high
                                end
                                ld_read: begin
                                    sense_enb <= 0; //active low
                                    l_state <= ld_enable;
                                    //32bit word to 4 8bit words
                                    regs[ld_reg_addr] <= data_out[7:0];
                                    regs[ld_reg_addr+1] <= data_out[15:8];
                                    regs[ld_reg_addr+2] <= data_out[23:16];
                                    regs[ld_reg_addr+3] <= data_out[31:24];
                                    s <= FETCH;
                                end
                                default: begin
                                    s <= FETCH;
                                end
                            endcase
                        end
                        ST: begin
                            case (s_state)
                                st_enable: begin
                                    s_state <= st_write;
                                    addr <= st_addr;
                                    //4 8bit words to 32bit word 
                                    data_in[7:0] <= regs[st_reg_addr];
                                    data_in[15:8] <= regs[st_reg_addr+1];
                                    data_in[23:16] <= regs[st_reg_addr+2];
                                    data_in[31:24] <= regs[st_reg_addr+3];
                                end
                                st_write: begin
                                    s_state <= st_enable;
                                    write_en <= 1;
                                    sense_enb <= 1;
                                    s <= FETCH;
                                end
                                default: begin
                                    s <= FETCH;
                                end
                            endcase
                        end
                        MUL: begin
                            case (m_state)
                                set: begin //set inputs so the MAC can begin calculations
                                    m_state <= get;
                                    m_spikes <= regs[spike_reg_addr];

                                    for (int i = 0; i < INPUT_VEC_LEN; i++) begin
                                        for (int j = 0; j < OUTPUT_VEC_LEN; j++) begin
                                            m_matrix[i][j] <= regs[mat_reg_addr + j + i * OUTPUT_VEC_LEN];
                                        end
                                    end
                                end
                                get: begin //get outputs
                                    m_state <= set;

                                    // this assumes OUT_WIDTH/WIDTH = 2
                                    for (int j = 0; j < OUTPUT_VEC_LEN; j++) begin
                                        regs[res_reg_addr + 2*j] <= m_out[j][WIDTH-1:0];
                                        regs[res_reg_addr + 2*j + 1] <= m_out[j][OUT_WIDTH-1:WIDTH];
                                    end
                                    s <= FETCH;
                                end
                                default: begin
                                    s <= FETCH;
                                end
                            endcase
                        end 
                        JMP: begin
                            pc <= jmp_addr;
                            s <= FETCH;
                        end
                        // RANK: begin
                        //     case(r_state)
                        //         copy: begin
                        //             r_state <= sorting;
                        //             for (int i = 0; i < OUTPUT_VEC_LEN; i=i+1) begin 
                        //                 regs[rank_res + i] <= i;

                        //                 values[i] <= {regs[rank_start + i*2 + 1],regs[rank_start + i*2]};
                        //             end
                        //         end
                        //         sorting: begin //slow bubble sort that does not work :`(
                        //             r_state <= done;
                        //             // for (int i = 0; i < OUTPUT_VEC_LEN-1; i=i+1) begin 
                        //             // // this assumes OUT_WIDTH/WIDTH = 2
                        //             //     if ($unsigned(values[i]) > $unsigned(values[i+1])) begin
                        //             //         r_state <= sorting;
                        //             //         temp_idx = regs[i + rank_res];
                        //             //         regs[i + rank_res] = regs[i + rank_res + 1];
                        //             //         regs[i + rank_res + 1] = temp_idx;

                        //             //         temp_val = values[i];
                        //             //         values[i] = values[i+1];
                        //             //         values[i+1] = temp_val;

                        //             //     end
                        //             // end
                        //         end
                        //         swapping: begin //unused state
                        //             r_state <= sorting;
                        //         end
                        //         done: begin
                        //             s <= FETCH;
                        //         end
                        //         default: begin
                        //             s <= FETCH;
                        //         end
                        //     endcase
                        // end
                        default: begin
                            s <= FETCH;
                        end
                    endcase
                end
                default: begin
                    s <= FETCH;
                end
            endcase
        end
    end


endmodule