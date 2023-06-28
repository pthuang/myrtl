/*********************************
File_name:      spi_master.v
Project_name:   project_name
Author:         Weitao Zhao
Function:

        MCS_VALID_LEVEL : //1: high level 0: low level
        SCK_DIV         : spi sclk rate is user_clk/SCK_DIV
        SCK_MODE        : [1]: 0 means the IDLE level of sck is low; 
                [0]:1 means mosi(miso) switch data at negeage of sck 
                and capture the data at posedge of clk.
        DATA_ENDIAN     : 1£º big endian , hign bit is high pirior;
                          0£º little endian , low bit is high pirior;

version: 0.0


log:    2020.04.22 create file v0.0


********************************/
module spi_master # (
    parameter   [31:0] USER_CLK_RATE   = 32'd100_000_000, // Default: 100 MHz
    parameter   [31:0] SPI_CLK_RATE    = 32'd2_500_000  , // Default: 2.5 MHz
    parameter   [ 0:0] MCS_VALID_LEVEL = 0              , //   
    parameter   [ 1:0] SCK_MODE        = 2'b01          , // 
    parameter   [ 0:0] DATA_ENDIAN     = 1              , //    
    parameter   [15:0] INPUT_WIDTH     = 16             , // 
    parameter   [15:0] OUTPUT_WIDTH    = 16               // 
)
(
    input                           user_clk            , // user clock 
    input                           user_rst            , // user reset, Async valid hign 
    input                           i_rd_evt            , // spi read event
    input                           i_wr_evt            , // spi write event
    input     [INPUT_WIDTH-1 :0]    i_wr_data           , // data payload
    output reg                      o_rd_evt            , // read data out event(from slave)
    output reg[OUTPUT_WIDTH-1:0]    o_rd_data           , // data payload 
    // Master 4-line spi interface -----------------------
    output reg                      mcs                 , // 4-line spi 
    output reg                      sclk                , // 4-line spi 
    output reg                      mosi                , // 4-line spi 
    input                           miso                  // 4-line spi 
);

    //==================< Internal Declaration >============================
    localparam  SCK_DIV     = USER_CLK_RATE/SPI_CLK_RATE;

    localparam  IDLE        = 5'b00001;
    localparam  MASTER_BUSY = 5'b00010;
    localparam  MASTER_OUT  = 5'b00100;
    // localparam   SLAVE_BUSY  = 5'b01000;
    // localparam   SLAVE_OUT   = 5'b10000;


    reg [04:00]             c_state     ;
    reg [04:00]             n_state     ;

    reg                     rd_en       ;
    reg [31:00]             cnt_mbusy   ;
    reg [31:00]             cnt_bit     ;
    reg                     write_flag  ;
    reg                     read_flag   ;
    reg                     read_evt    ;
    reg [INPUT_WIDTH-1 :0]  wr_data     ;
    reg [OUTPUT_WIDTH-1:0]  rd_data     ;

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
            if(i_wr_evt || i_rd_evt) begin
                n_state = MASTER_BUSY;
            end else begin
                n_state = IDLE;
            end
        end
        MASTER_BUSY:
        begin
            if( (cnt_mbusy == (SCK_DIV - 1)) && (cnt_bit == (INPUT_WIDTH - 1)) && (sclk == SCK_MODE[0])) begin
                n_state = MASTER_OUT;
            end else begin
                n_state = MASTER_BUSY;
            end
        end
        MASTER_OUT :
        begin
            n_state = IDLE;
        end
        default:n_state = IDLE;
        endcase
    end


    always@(posedge user_clk or posedge user_rst) begin
        if(user_rst) begin
            wr_data     <=  'h0;
            rd_en       <=  'd0;
            cnt_mbusy   <=  'h0;
            cnt_bit     <=  'h0;
            write_flag  <=  'b0;
            read_flag   <=  'b0;
            read_evt    <=  'b0;
            o_rd_evt    <=  'b0;
            rd_data     <=  'h0;
            o_rd_data   <=  'h0;
            mcs         <=  'b0;
            sclk        <=  'b0;
            mosi        <=  'b0;
        end else begin
            read_evt    <=  0;
            o_rd_evt    <=  read_evt;
            casex(c_state)
            IDLE        : 
            begin
                mcs <= ~MCS_VALID_LEVEL;
                sclk    <=  SCK_MODE[1];
                if(i_wr_evt) begin
                    write_flag  <=  1;
                    wr_data <=  i_wr_data;
                    mcs <= 0;
                    if(MCS_VALID_LEVEL) begin
                        mcs <= 1;
                    end
                    sclk    <=  1;        // negedge capture
                    if(SCK_MODE[0]) begin // posedge capture 
                        sclk    <=  0;
                    end
                    mosi    <=  i_wr_data[0];
                    if(DATA_ENDIAN) begin
                        mosi    <=  i_wr_data[INPUT_WIDTH-1];
                    end
                end
                if(i_rd_evt) begin
                    read_flag   <=  1;
                    mcs         <= MCS_VALID_LEVEL;
                    sclk        <=  1;
                    if(SCK_MODE[0]) begin
                        sclk    <=  0;
                    end
                end
            end
            MASTER_BUSY : 
            begin
                mcs <= MCS_VALID_LEVEL;
                cnt_mbusy   <=  cnt_mbusy + 1;
                rd_en   <=  rd_en;
                cnt_bit <=  cnt_bit;
                if(cnt_mbusy == (SCK_DIV - 2)) begin
                    rd_en   <=  ~rd_en;
                end else if(cnt_mbusy == (SCK_DIV - 1)) begin
                    cnt_mbusy   <=  'h0;
                    if(sclk == SCK_MODE[0]) begin
                        cnt_bit <=  cnt_bit + 1;
                        if(cnt_bit == (INPUT_WIDTH - 1)) begin
                            cnt_bit <=  0;
                            mcs     <= ~MCS_VALID_LEVEL;
                            sclk    <=  SCK_MODE[1];
                        end
                    end
                    sclk    <=  ~sclk;
                    if(write_flag) begin
                        mosi    <=  wr_data[INPUT_WIDTH-1];
                        if(sclk == ~SCK_MODE[0]) begin
                            wr_data <=  {wr_data[1],wr_data[INPUT_WIDTH-1:2],wr_data[0]};
                            if(DATA_ENDIAN) begin
                                wr_data <=  {wr_data[INPUT_WIDTH-2:0],wr_data[INPUT_WIDTH-1]};
                            end
                            mosi    <=  mosi;
                        end
                    end
                end
                
                // read logic
                rd_data   <=  rd_data;
                if(cnt_mbusy == 0 && rd_en) begin
                    rd_data[0]                <=  miso;
                    rd_data[OUTPUT_WIDTH-1:1] <=  rd_data[OUTPUT_WIDTH-2:0];
                end
            end
            MASTER_OUT  : 
            begin
                mcs     <= ~MCS_VALID_LEVEL;
                sclk    <=  SCK_MODE[1];
                write_flag  <=  0;
                read_flag   <=  0;
                if(read_flag) begin
                    read_evt    <=  1;
                    o_rd_data   <=  rd_data;
                end
            end
            default:
            begin
                wr_data     <=  'h0;
                rd_en       <=  'd0;
                cnt_mbusy   <=  'h0;
                cnt_bit     <=  'h0;
                write_flag  <=  'b0;
                read_evt    <=  'b0;
                o_rd_evt    <=  'b0;
                o_rd_data   <=  'h0;
                mcs         <=  'b0;
                sclk        <=  'b0;
                mosi        <=  'b0;
            end
            endcase 
        end
    end





endmodule
