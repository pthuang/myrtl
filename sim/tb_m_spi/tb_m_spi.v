`timescale 1 ns / 1 ps
/***********************************************************
simulation time consumed: 900 us
Tools:  Modelsim se-64 10.7
***********************************************************/
module tb_m_spi;


//==================< Parameter Declaration >============================
parameter   CLK_100M        =  10               ;
parameter   USER_CLK_RATE   =  32'd100_000_000  ; // Default: 100 MHz
parameter   SPI_CLK_RATE    =  32'd2_500_000    ; // Default: 2.5 MHz
parameter   MCS_VALID_LEVEL =  1'b0             ;    
parameter   SCK_MODE        =  2'b01            ; 
parameter   AWIDTH          =  16'd15           ; 
parameter   DWIDTH          =  16'd8            ; 
parameter   REGTABLE_DEPTH  =  16'd256          ; 

parameter   TB_CNT_MAX      =  8*(USER_CLK_RATE/SPI_CLK_RATE)*DWIDTH + 500;

//==================< Internal Declaration >=============================
reg                 clk             ;
reg                 rst             ;
reg                 tb_en     = 0   ;
reg [63:0]          cnt0      = 0   ;
reg                 flag0     = 0   ;
reg [31:0]          temp      = 0   ;
reg [31:0]          temp1     = 0   ;
reg [31:0]          temp2     = 0   ;
reg                 i_rd_evt  = 0   ; // spi read event 
reg                 i_wr_evt  = 0   ; // spi write event 
reg [DWIDTH-1:0]    i_wr_data = 8'h55; // data payload 
reg [AWIDTH-1:0]    i_addr    = 1   ; // address  
wire                o_rd_evt        ; // read data out event(from slave) 
wire[DWIDTH-1:0]    o_rd_data       ; // data payload 
wire                o_rw_done_evt   ; //  
wire                mcs             ; 
wire                sclk            ; 
wire                mosi            ; 
wire                miso            ; 

wire                o_wr_evt        ; // receive data out event(from master)
wire[DWIDTH-1:0]    o_wr_data       ; // data payload
wire[AWIDTH-1:0]    o_addr          ; // address 
wire                o_rd_samp_evt   ; // receive data out event(from master) 
reg [DWIDTH-1:0]    i_rd_data = 0   ; // data payload

reg [DWIDTH-1:0]    regtable[REGTABLE_DEPTH-1:0];

reg [DWIDTH-1:0]    regdut          ;
reg                 error_flag = 0  ; 

// Generate clk----------------------------
initial begin 
    clk     <=  0;
    forever #(CLK_100M/2)   clk   <=  ~clk;
end


initial
begin
    rst = 1;
    tb_en = 0;
    #100
    @(posedge clk)
        rst = 0;
    
    #10000;
    @(posedge clk)
        tb_en = 1;
    
    
    #800000;
    // @(posedge clk)
        // tb_en = 0;

end


always@(posedge clk) begin
    i_wr_evt    <=  0;
    i_rd_evt    <=  0;
    if(tb_en)
    begin 
        cnt0        <=  cnt0 + 1;
        if(cnt0 == TB_CNT_MAX - 2) begin
            temp1       <=  $random;
        end else if(cnt0 == TB_CNT_MAX - 1) begin 
            if (flag0) begin
                i_wr_data   <= temp1[07:00]; 
            end
        end
        
        else if(cnt0 == TB_CNT_MAX) begin
            cnt0    <=  0;
            flag0   <=  ~flag0;
            if(flag0) begin
                i_rd_evt    <=  1; 
            end else begin
                i_wr_evt    <=  1;
                if (i_addr < REGTABLE_DEPTH) begin
                    i_addr <= 0;
                end else begin
                    i_addr <= i_addr + 1; 
                end
            end
        end
    end
end



//=================< Submodule Instantiation >==========================
m_spi # (
    .USER_CLK_RATE      ( USER_CLK_RATE     ), // Default: 100 MHz
    .SPI_CLK_RATE       ( SPI_CLK_RATE      ), // Default: 2.5 MHz
    .MCS_VALID_LEVEL    ( MCS_VALID_LEVEL   ), // 
    .SCK_MODE           ( SCK_MODE          ), // 
    .AWIDTH             ( AWIDTH            ), // 
    .DWIDTH             ( DWIDTH            )  // 
) m_spi (
    .user_clk           ( clk               ), // user clock 
    .user_rst           ( rst               ), // user reset, Async valid hign 
    .i_rd_evt           ( i_rd_evt          ), // spi read event 
    .i_wr_evt           ( i_wr_evt          ), // spi write event 
    .i_wr_data          ( i_wr_data         ), // data payload 
    .i_addr             ( i_addr            ), // address 
    .o_rd_evt           ( o_rd_evt          ), // read data out event(from slave) 
    .o_rd_data          ( o_rd_data         ), // data payload 
    .o_rw_done_evt      ( o_rw_done_evt     ), // read/write done
    .mcs                ( mcs               ), // 4-line spi 
    .sclk               ( sclk              ), // 4-line spi 
    .mosi               ( mosi              ), // 4-line spi 
    .miso               ( miso              )  // 4-line spi 
);

s_spi # (
    .USER_CLK_RATE      ( USER_CLK_RATE     ), // Default: 100 MHz
    .SPI_CLK_RATE       ( SPI_CLK_RATE      ), // Default: 2.5 MHz
    .MCS_VALID_LEVEL    ( MCS_VALID_LEVEL   ), // 
    .SCK_MODE           ( SCK_MODE          ), //   
    .AWIDTH             ( AWIDTH            ), // 
    .DWIDTH             ( DWIDTH            )  // 
) s_spi ( 
    .user_clk           ( clk               ), // user clock 
    .user_rst           ( rst               ), // user reset, Async valid hign 
    .o_wr_evt           ( o_wr_evt          ), // receive data out event(from master)
    .o_wr_data          ( o_wr_data         ), // data payload
    .o_addr             ( o_addr            ), // address 
    .o_rd_samp_evt      ( o_rd_samp_evt     ), // receive data out event(from master) 
    .i_rd_data          ( i_rd_data         ), // kick data to master
    .mcs                ( mcs               ), // 4-line spi 
    .sclk               ( sclk              ), // 4-line spi 
    .mosi               ( mosi              ), // 4-line spi 
    .miso               ( miso              )  // 4-line spi 
);

always @(posedge clk) begin
    if (o_wr_evt) begin
        regtable[o_addr] <= o_wr_data;
    end

    if (o_rd_samp_evt) begin
        i_rd_data <= regtable[o_addr];
    end
end



// check  
always @(posedge clk) begin
    if (i_wr_evt) begin
        regdut <= i_wr_data;
    end

    if (o_rd_evt) begin
        if (o_rd_data != regdut) begin
            error_flag <= 1;
        end
    end
end

always @(posedge error_flag) begin
    $stop;
end 


endmodule