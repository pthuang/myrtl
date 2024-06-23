//=========================================================================================
// File_name    : s_spi.v 
// Project_name : project_name
// Author       : pthuang
// Function     : MCS_VALID_LEVEL : 1: high level 0: low level
//                SCK_DIV         : spi sclk rate is user_clk/SCK_DIV
//                SCK_MODE        : [1]: 0 means the IDLE level of sck is low; 
//                                  [0]: 1 means mosi(miso) switch data at negeage of sck 
//                                       and capture the data at posedge of clk. 
//                                    ___
//                o_rd_samp_evt _____|  |________________     
//                              _________________________
//                i_rd_data     ________|________________
// 
// version      : V2.0
// log          : 2020.07.12 create file v1.0
//                2024.06.23 modify file v2.0
//=========================================================================================
module s_spi # (
    parameter   [31:00]         USER_CLK_RATE   = 32'd100_000_000   , // Default: 100 MHz
    parameter   [31:00]         SPI_CLK_RATE    = 32'd2_500_000     , // Default: 2.5 MHz
    parameter   [00:00]         MCS_VALID_LEVEL = 0                 , // 
    parameter   [01:00]         SCK_MODE        = 2'b01             , //   
    parameter   [15:00]         AWIDTH          = 16                , // 
    parameter   [15:00]         DWIDTH          = 16                  // 
) (     
    input                       user_clk                            , // user clock 
    input                       user_rst                            , // user reset, Async valid hign 
    output reg                  o_wr_evt                            , // receive data out event(from master)
    output reg  [DWIDTH-1:0]    o_wr_data                           , // data payload
    output reg  [AWIDTH-1:0]    o_addr                              , // address 
    output reg                  o_rd_samp_evt                       , // receive data out event(from master)
    input       [DWIDTH-1:0]    i_rd_data                           , // kick data to master 
    input                       mcs                                 , // 4-line spi 
    input                       sclk                                , // 4-line spi 
    input                       mosi                                , // 4-line spi 
    output reg                  miso                                  // 4-line spi 
);

    //==================< Internal Declaration >============================
    localparam SCK_DIV          = USER_CLK_RATE/SPI_CLK_RATE/2  ;
    localparam PAYLOAD_WIDTH    = AWIDTH + DWIDTH + 1           ;
    localparam IDLE             = 3'b001                        ;
    localparam SLAVE_BUSY       = 3'b010                        ;
    localparam SLAVE_OUT        = 3'b100                        ;

    reg         [04:00]         c_state                         ;
    reg         [04:00]         n_state                         ;
    reg                         mcs_r                           ;
    reg                         sclk_r                          ;
    wire                        mcs_posedge                     ;
    wire                        mcs_negedge                     ;
    wire                        sck_posedge                     ;
    wire                        sck_negedge                     ;
    reg                         rw_mode                         ; // 1: read 0: write  
    reg         [31:00]         cnt_bit                         ;
    reg                         rx_addr_evt                     ;
    reg         [AWIDTH-1:0]    rx_addr                         ;
    reg                         rx_evt                          ;
    reg         [DWIDTH-1:0]    rx_data                         ; 
    reg                         rd_samp_evt_r0                  ; 
    reg                         rd_samp_evt_r1                  ; 
    reg         [DWIDTH-1:0]    rd_data_r                       ; 
    reg         [DWIDTH-1:0]    rd_data_buf                     ; 

    assign mcs_posedge = (~mcs_r  &&  mcs );
    assign mcs_negedge = ( mcs_r  && ~mcs );
    assign sck_posedge = (~sclk_r &&  sclk);
    assign sck_negedge = ( sclk_r && ~sclk);
    //=======================< Debug Logic >================================



    //=======================< Main Logic >=================================
    always@(posedge user_clk) begin
        mcs_r  <= mcs; 
        sclk_r <= sclk;
    end

    always@(posedge user_clk or posedge user_rst) begin
        if(user_rst) begin
            c_state <=  IDLE;
        end else begin
            c_state <=  n_state;
        end
    end

    always@(*) begin
        case(c_state)
        IDLE       :
        begin
            if( (mcs_negedge && ~MCS_VALID_LEVEL) || (mcs_posedge && MCS_VALID_LEVEL) ) begin
                n_state = SLAVE_BUSY;
            end else begin
                n_state = IDLE;
            end
        end
        SLAVE_BUSY:
        begin
            if((mcs_posedge && ~MCS_VALID_LEVEL) || (mcs_negedge && MCS_VALID_LEVEL)) begin
                n_state = SLAVE_OUT;
            end else begin
                n_state = SLAVE_BUSY;
            end
        end
        SLAVE_OUT : begin n_state = IDLE; end
        default   : begin n_state = IDLE; end
        endcase
    end

    always@(posedge user_clk) begin
        rd_samp_evt_r0 <= o_rd_samp_evt;
        rd_samp_evt_r1 <= rd_samp_evt_r0; 
        if (rd_samp_evt_r0) begin
            rd_data_r <= i_rd_data;
        end
    end

    always@(posedge user_clk or posedge user_rst) begin
        if(user_rst) begin  
            cnt_bit       <= 'h0;
            rw_mode       <= 'b0;
            rx_addr_evt   <= 'b0;
            rx_addr       <= 'h0;
            rx_evt        <= 'b0;
            rx_data       <= 'h0; 
            o_wr_evt      <= 'h0;
            o_wr_data     <= 'h0;
            o_addr        <= 'h0;
            o_rd_samp_evt <= 'b0;
            rd_data_buf   <= 'h0;
            miso          <= 'b0;
        end else begin
            rx_addr_evt   <= 0;
            rx_evt        <= 0;
            o_wr_evt      <= rx_evt;
            o_rd_samp_evt <= 0;
            casex(c_state)
            IDLE        : 
            begin 
                rd_data_buf <= 0;
                miso        <= 0; 
            end
            SLAVE_BUSY : 
            begin 
                if (SCK_MODE[0]) begin 
                    if (sck_negedge) begin
                        if(cnt_bit ==  (PAYLOAD_WIDTH - 1)) begin
                            cnt_bit <=  0;
                        end else begin 
                            cnt_bit <=  cnt_bit + 1; 
                        end 
                    end

                    if (sck_posedge) begin
                        if (cnt_bit == 0) begin
                            rw_mode <= mosi;
                            rx_addr <= 0;
                        end else if (cnt_bit < (AWIDTH + 1)) begin
                            rx_addr <= {rx_addr[AWIDTH-2:0],mosi}; 
                        end else begin
                            if (~rw_mode) begin // write mode
                                rx_data <= {rx_data[DWIDTH-2:0],mosi}; 
                            end
                        end

                        if (cnt_bit == AWIDTH) begin
                            rx_addr_evt <= 1;
                        end
                    end
                end else begin
                    if (sck_posedge) begin
                        if(cnt_bit ==  (PAYLOAD_WIDTH - 1)) begin
                            cnt_bit <=  0;
                        end else begin
                            cnt_bit <=  cnt_bit + 1; 
                        end
                    end

                    if (sck_negedge) begin 
                        if (cnt_bit == 0) begin
                            rw_mode <= mosi;
                            rx_addr <= 0;
                        end else if (cnt_bit < (AWIDTH + 1)) begin
                            rx_addr <= {rx_addr[AWIDTH-2:0],mosi}; 
                        end else begin
                            if (~rw_mode) begin // write mode
                                rx_data <= {rx_data[DWIDTH-2:0],mosi}; 
                            end
                        end

                        if (cnt_bit == AWIDTH) begin
                            rx_addr_evt <= 1;
                        end
                    end
                end

                // spi read 
                if (rx_addr_evt) begin
                    o_addr <= rx_addr;
                    if (rw_mode) begin
                        o_rd_samp_evt <= 1;
                    end
                end

                if (rd_samp_evt_r1) begin
                    rd_data_buf <= rd_data_r;
                end

                if (rw_mode && (cnt_bit > (AWIDTH - 1)) && (cnt_bit < (PAYLOAD_WIDTH - 1))) begin 
                    if (SCK_MODE[0]) begin
                        if (sck_negedge) begin
                            miso <= rd_data_buf[DWIDTH-1];
                        end 
                        if (sck_posedge) begin
                            rd_data_buf <= {rd_data_buf[DWIDTH-2:0],1'b0}; 
                        end  
                    end else begin
                        if (sck_posedge) begin
                            miso <= rd_data_buf[DWIDTH-1];
                        end 
                        if (sck_negedge) begin
                            rd_data_buf <= {rd_data_buf[DWIDTH-2:0],1'b0}; 
                        end 
                    end     
                end 
            end
            SLAVE_OUT  : 
            begin
                cnt_bit <= 0;
                miso    <= 0;
                if (~rw_mode) begin
                    rx_evt      <=  1;
                    o_wr_data   <=  rx_data; 
                end
            end
            default:
            begin 
                cnt_bit     <=  'h0;
            end
            endcase 
        end
    end

endmodule
