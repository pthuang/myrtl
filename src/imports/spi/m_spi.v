/*******************************************
File_name:      m_spi.v 
Project_name:   project_name
Author:         pthuang
Function:

        MCS_VALID_LEVEL : 1: high level 0: low level
        SCK_DIV         : spi sclk rate is user_clk/SCK_DIV
        SCK_MODE        : [1]: 0 means the IDLE level of sck is low; 
                          [0]: 1 means mosi(miso) switch data at negeage of sck 
                          and capture the data at posedge of clk. 

version: 1.0

log:    2020.07.12 create file v1.0

*******************************************/
module m_spi # (
    parameter [31:0] USER_CLK_RATE    = 32'd100_000_000, // Default: 100 MHz
    parameter [31:0] SPI_CLK_RATE     = 32'd2_500_000  , // Default: 2.5 MHz
    parameter [ 0:0] MCS_VALID_LEVEL  = 0              , //   
    parameter [ 1:0] SCK_MODE         = 2'b01          , //    
    parameter [15:0] AWIDTH           = 16             , // 
    parameter [15:0] DWIDTH           = 8                // 
) ( 
    input                       user_clk        , // user clock 
    input                       user_rst        , // user reset, Async valid hign 
    input                       i_rd_evt        , // spi read event
    input                       i_wr_evt        , // spi write event
    input     [DWIDTH-1:0]      i_wr_data       , // data payload
    input     [AWIDTH-1:0]      i_addr          , // address 
    output reg                  o_rd_evt        , // read data out event(from slave)
    output reg[DWIDTH-1:0]      o_rd_data       , // data payload 
    output reg                  o_rw_done_evt   , // read/write done 
    output reg                  mcs             , // 4-line spi 
    output reg                  sclk            , // 4-line spi 
    output reg                  mosi            , // 4-line spi 
    input                       miso              // 4-line spi 
);

    //==================< Internal Declaration >============================
    localparam  SCK_DIV         = USER_CLK_RATE/SPI_CLK_RATE;
    localparam  PAYLOAD_WIDTH   = AWIDTH + DWIDTH + 1;

    localparam  IDLE        = 5'b00001;
    localparam  BUSY        = 5'b00010;
    localparam  MASTER_OUT  = 5'b00100;
    // localparam   SLAVE_BUSY  = 5'b01000;
    // localparam   SLAVE_OUT   = 5'b10000;


    reg [04:00]             c_state     ;
    reg [04:00]             n_state     ;

    reg [PAYLOAD_WIDTH-1:0] tx_payload  ;
    reg                     rd_en       ;
    reg [31:00]             cnt_mbusy   ;
    reg [31:00]             cnt_bit     ;
    reg                     rw_mode     ; // 1: read 0: write 
    reg                     read_evt    ;
    reg [PAYLOAD_WIDTH-1:0] rx_payload  ;

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
                n_state = BUSY;
            end else begin
                n_state = IDLE;
            end
        end
        BUSY        :
        begin
            if( (cnt_mbusy == (SCK_DIV - 1)) && (cnt_bit == (PAYLOAD_WIDTH - 1)) && (sclk == SCK_MODE[0])) begin
                n_state = MASTER_OUT;
            end else begin
                n_state = BUSY;
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
            tx_payload    <= 'h0;
            rd_en         <= 'd0;
            cnt_mbusy     <= 'h0;
            cnt_bit       <= 'h0;
            rw_mode       <= 'b0;
            read_evt      <= 'b0;
            rx_payload    <= 'h0;
            o_rd_evt      <= 'b0;
            o_rd_data     <= 'h0;
            o_rw_done_evt <= 'b0;
            mcs           <= 'b0;
            sclk          <= 'b0;
            mosi          <= 'b0;
        end else begin
            read_evt      <= 0;
            o_rd_evt      <= read_evt;
            o_rw_done_evt <= 0;
            case(c_state)
            IDLE        : 
            begin
                mcs     <= ~MCS_VALID_LEVEL;
                sclk    <=  SCK_MODE[1];
                cnt_bit <= 0;
                if(i_wr_evt) begin
                    tx_payload <= {1'b0,i_addr,i_wr_data};
                    mosi       <= 1'b0; // first bit 
                    if(MCS_VALID_LEVEL) begin
                        mcs <= 1;
                    end else begin
                        mcs <= 0; 
                    end
                    if(SCK_MODE[0]) begin // posedge capture 
                        sclk <= 0;
                    end else begin // negedge capture
                        sclk <= 1; 
                    end
                end
                if(i_rd_evt) begin
                    rw_mode    <= 1;
                    tx_payload <= {1'b1,i_addr,{DWIDTH{1'b0}}};
                    mosi       <= 1'b1; // first bit 
                    // mcs         <= MCS_VALID_LEVEL;
                    if(SCK_MODE[0]) begin
                        sclk <= 0;
                    end else begin
                        sclk <= 1;
                    end
                end
                
            end
            BUSY : 
            begin
                mcs <= MCS_VALID_LEVEL; 
                if(cnt_mbusy == (SCK_DIV - 1)) begin
                    cnt_mbusy <= 'h0;
                end else begin
                    cnt_mbusy <= cnt_mbusy + 1; 
                end

                if (cnt_mbusy == (SCK_DIV - 1)) begin
                    sclk <=  ~sclk;
                    if(sclk == SCK_MODE[0]) begin
                        if(cnt_bit == (PAYLOAD_WIDTH - 1)) begin
                            cnt_bit <=  0;
                            mcs     <= ~MCS_VALID_LEVEL;
                            sclk    <=  SCK_MODE[1];
                        end else begin
                            cnt_bit <=  cnt_bit + 1; 
                        end
                    end

                    if(sclk == SCK_MODE[0]) begin 
                        mosi       <= tx_payload[PAYLOAD_WIDTH-1]; 
                    end else begin
                        tx_payload <= {tx_payload[PAYLOAD_WIDTH-2:0],1'b0};
                    end
                end
                
                // read logic 
                if (rw_mode) begin
                    if (cnt_mbusy == (SCK_DIV - 2)) begin
                        rd_en   <=  ~rd_en;
                    end
                end
                if(cnt_mbusy == 0 && rd_en) begin 
                    rx_payload <= {rx_payload[PAYLOAD_WIDTH-2:0],miso}; 
                end
            end
            MASTER_OUT  : 
            begin
                mcs     <= ~MCS_VALID_LEVEL;
                sclk    <=  SCK_MODE[1];
                rw_mode <=  0;
                o_rw_done_evt <= 1;
                if(rw_mode) begin
                    read_evt  <= 1;
                    o_rd_data <= rx_payload[DWIDTH-1:0];
                end
            end
            default:
            begin
                tx_payload <= 'h0;
                rd_en      <= 'd0;
                cnt_mbusy  <= 'h0;
                cnt_bit    <= 'h0;
                rw_mode    <= 'b0;
                read_evt   <= 'b0;
                o_rd_evt   <= 'b0;
                o_rd_data  <= 'h0;
                mcs        <= 'b0;
                sclk       <= 'b0;
                mosi       <= 'b0;
            end
            endcase 
        end
    end





endmodule
