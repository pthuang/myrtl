/*********************************
File_name:      spi_slave.v
Project_name:   project_name
Author:         Weitao Zhao
Function:

        MCS_VALID_LEVEL : //1: high level 0: low level
        SCK_DIV         : spi sclk rate is user_clk/SCK_DIV
        SCK_MODE        : [1]: 0 means the IDLE level of sck is low; 
                [0]:1 means mosi(miso) switch data at negeage of sck 
                and capture the data at posedge of clk.
        DATA_ENDIAN     : 1: big endian , hign bit is high pirior;
                          0: little endian , low bit is high pirior;

version: 0.0


log:    2020.05.15 create file v0.0


********************************/
module spi_slave # (
    parameter   [31:0] MAIN_CLK_RATE   = 32'd100_000_000, // Default: 100 MHz
    parameter   [31:0] SPI_CLK_RATE    = 32'd2_500_000  , // Default: 2.5 MHz
    parameter   [ 0:0] MCS_VALID_LEVEL = 0              , //      
    parameter   [ 1:0] SCK_MODE        = 2'b01          , //  
    parameter   [ 0:0] DATA_ENDIAN     = 1              , //    
    // parameter   [15:0] INPUT_WIDTH     = 16             , // 
    parameter   [15:0] OUTPUT_WIDTH    = 16               // 
)
(
    input                           user_clk            , // user clock 
    input                           user_rst            , // user reset, Async valid hign 
    output reg                      o_rx_evt            , // receive data out event(from master)
    output reg[OUTPUT_WIDTH-1:0]    o_rx_data           , // data payload
    // Master 4-line spi interface -----------------------
    input                           mcs                 , // 4-line spi 
    input                           sclk                , // 4-line spi 
    input                           mosi                , // 4-line spi 
    output reg                      miso                  // 4-line spi 
);

    //==================< Internal Declaration >============================
    localparam  SCK_DIV     = MAIN_CLK_RATE/SPI_CLK_RATE;

    localparam  IDLE        = 5'b00001  ;
    localparam  SLAVE_BUSY  = 5'b00010  ;
    localparam  SLAVE_OUT   = 5'b00100  ;

    reg [04:00]             c_state     ;
    reg [04:00]             n_state     ;

    reg                     mcs_r       ;
    reg [31:00]             cnt_mbusy   ;
    reg [31:00]             cnt_bit     ;
    reg                     rx_evt      ;
    reg [OUTPUT_WIDTH-1:0]  rx_data     ;

    //=======================< Debug Logic >================================



    //=======================< Main Logic >=================================
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
            if( (~mcs && mcs_r && ~MCS_VALID_LEVEL) || (mcs && ~mcs_r && MCS_VALID_LEVEL) ) begin
                n_state = SLAVE_BUSY;
            end else begin
                n_state = IDLE;
            end
        end
        SLAVE_BUSY:
        begin
            if( cnt_mbusy == (SCK_DIV - 1) && cnt_bit == (OUTPUT_WIDTH-1) && sclk == ~SCK_MODE[0]) begin
                n_state = SLAVE_OUT;
            end else begin
                n_state = SLAVE_BUSY;
            end
        end
        SLAVE_OUT :
        begin
            n_state = IDLE;
        end
        default:n_state = IDLE;
        endcase
    end




    always@(posedge user_clk or posedge user_rst) begin
        if(user_rst) begin
            mcs_r       <=  'b0;
            cnt_mbusy   <=  'h0;
            cnt_bit     <=  'h0;
            rx_evt      <=  'b0;
            rx_data     <=  'h0;
            o_rx_evt    <=  'h0;
            o_rx_data   <=  'h0;
            miso        <=  'b0;
        end else begin
            rx_evt  <=  0;
            o_rx_evt    <=  rx_evt;
            casex(c_state)
            IDLE        : 
            begin
                mcs_r   <=  mcs;
            end
            SLAVE_BUSY : 
            begin
                cnt_mbusy   <=  cnt_mbusy + 1;
                cnt_bit <=  cnt_bit;
                if(cnt_mbusy == (SCK_DIV - 1)) begin
                    cnt_mbusy   <=  'h0;
                    if(sclk == ~SCK_MODE[0]) begin
                        cnt_bit <=  cnt_bit + 1;
                        if(cnt_bit ==  (OUTPUT_WIDTH - 1)) begin
                            cnt_bit <=  0;
                        end
                    end else begin
                        rx_data[OUTPUT_WIDTH-1]  <=  mosi;
                        rx_data[OUTPUT_WIDTH-2:0]   <=  rx_data[OUTPUT_WIDTH-1:1];
                        if(DATA_ENDIAN) begin
                            rx_data[0]  <=  mosi;
                            rx_data[OUTPUT_WIDTH-1:1]   <=  rx_data[OUTPUT_WIDTH-2:0];
                        end
                    end
                end
            end
            SLAVE_OUT  : 
            begin
                rx_evt      <=  1;
                o_rx_data   <=  rx_data;
            end
            default:
            begin
                cnt_mbusy   <=  'h0;
                cnt_bit     <=  'h0;
            end
            endcase 
        end
    end



    //=================< Submodule Instantiation >==========================




endmodule
