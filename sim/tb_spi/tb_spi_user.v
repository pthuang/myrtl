`timescale 1 ns / 1 ps
/***********************************************************
simulation time consumed: 900 us
Tools:  Modelsim se-64 10.7
***********************************************************/
module tb_spi_user;


//==================< Parameter Declaration >============================
parameter   CLK_100M        =  10;
parameter   MAIN_CLK_RATE   =  32'd100_000_000;   //Default: 100 MHz
parameter   SPI_CLK_RATE    =  32'd2_500_000;     //Default: 2.5 MHz
parameter   MCS_VALID_LEVEL =  1'b0;    
parameter   SCK_MODE        =  2'b10;    
parameter   DATA_ENDIAN     =  1'b1;
parameter   SPI_DATA_WIDTH  =  16'd16;

parameter   TB_CNT_MAX  =  8*(MAIN_CLK_RATE/SPI_CLK_RATE)*SPI_DATA_WIDTH;


//==================< Internal Declaration >=============================
reg         mclk;
reg         mrst;
reg         tb_en = 0;
reg [63:0]  cnt0 = 0;
reg         flag0 = 0;
reg [31:0]  temp = 0;
reg [31:0]  temp1 = 0;
reg [31:0]  temp2 = 0;
reg                         i_rd_evt = 0;   //spi read event
reg                         i_wr_evt = 0;   //spi write event
reg [SPI_DATA_WIDTH-1:0]    i_wr_data = 0;  //data payload

wire                        o_rd_evt;   //read data out event(from slave)
wire[SPI_DATA_WIDTH-1:0]    o_rd_data;  //data payload
wire        mcs;
wire        sclk;
wire        mosi;
reg         miso = 0;


wire                        o_rx_evt;   
wire[SPI_DATA_WIDTH-1:0]    o_rx_data;


// Generate mclk----------------------------
initial 
begin
    mclk     <=  0;
    forever #(CLK_100M/2)   mclk   <=  ~mclk;
end


initial
begin
    mrst = 1;
    tb_en = 0;
    #100
    @(posedge mclk)
        mrst = 0;
    
    #10000;
    @(posedge mclk)
        tb_en = 1;
    
    
    #800000;
    @(posedge mclk)
        tb_en = 0;

end


generate 
if(SCK_MODE[0])
begin
    always@(negedge sclk)
    begin
        temp    <=  $random;
        miso    <=  temp[31];
    end
end
else
begin
    always@(posedge sclk)
    begin
        temp    <=  $random;
        miso    <=  temp[31];
    end
end

endgenerate

always@(negedge mclk)
begin
    i_wr_evt    <=  0;
    i_rd_evt    <=  0;
    if(tb_en)
    begin
        
        cnt0        <=  cnt0 + 1;
        if(cnt0 == TB_CNT_MAX - 2)
        begin
            temp1    <=  $random;
        end
        else if(cnt0 == TB_CNT_MAX - 1)
        begin
            temp2[ 9: 0]    <=  temp[9:0];
            temp2[21:10]    <=  temp1[15: 4];
            temp2[31:22]    <=  temp2[23:14];
            i_wr_data   <= temp2[23: 8];
        end
        
        else if(cnt0 == TB_CNT_MAX)
        begin
            cnt0    <=  0;
            flag0   <=  ~flag0;
            i_rd_evt    <=  1;
            if(flag0)
            begin
                i_wr_evt    <=  1;
                i_rd_evt    <=  0;
            end
        end
    end
end



//=================< Submodule Instantiation >==========================
spi_master #
(
    .MAIN_CLK_RATE   (MAIN_CLK_RATE     ),    
    .SPI_CLK_RATE    (SPI_CLK_RATE      ),    
    .MCS_VALID_LEVEL (MCS_VALID_LEVEL   ),
    .SCK_MODE        (SCK_MODE          ),    
    .DATA_ENDIAN     (DATA_ENDIAN       ),
    .INPUT_WIDTH     (SPI_DATA_WIDTH    ),
    .OUTPUT_WIDTH    (SPI_DATA_WIDTH    )
)
spi_master
(
    .mclk       (mclk      ),
    .mrst       (mrst      ),
    .i_rd_evt   (i_rd_evt  ),   //spi read event
    .i_wr_evt   (i_wr_evt  ),   //spi write event
    .i_wr_data  (i_wr_data ),   //data payload
    .o_rd_evt   (o_rd_evt  ),   //read data out event(from slave)
    .o_rd_data  (o_rd_data ),   //data payload
    .mcs        (mcs       ),
    .sclk       (sclk      ),
    .mosi       (mosi      ),
    .miso       (miso      )
);


spi_slave #
(
    .MAIN_CLK_RATE   (MAIN_CLK_RATE     ),    
    .SPI_CLK_RATE    (SPI_CLK_RATE      ),  
    .MCS_VALID_LEVEL (MCS_VALID_LEVEL   ),
    .SCK_MODE        (SCK_MODE          ),    
    .DATA_ENDIAN     (DATA_ENDIAN       ),
    .OUTPUT_WIDTH    (SPI_DATA_WIDTH    )
)
spi_slave
(
    .mclk       (mclk      ),
    .mrst       (mrst      ),
    .o_rx_evt   (o_rx_evt  ),   //receive data out event(from master)
    .o_rx_data  (o_rx_data ),   //data payload
    .mcs        (mcs       ),
    .sclk       (sclk      ),
    .mosi       (mosi      ),
    .miso       (          )
);


endmodule