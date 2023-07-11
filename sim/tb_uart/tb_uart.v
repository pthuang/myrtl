`timescale 1ns/1ps
/***********************************************************
simulation time consuming:  6 ms
Tools:  Modelsim se-64 10.7
***********************************************************/

module tb_uart;


parameter MODULE_CLK_RATE = 32'd100_000_000; 
parameter UART_BAUDCLK_RATE = 32'd115200;
parameter TB_CNT_MAX = 15*MODULE_CLK_RATE/UART_BAUDCLK_RATE;
parameter CLK_150M = 6.66;
parameter CLK_100M = 10;


reg         clk;
reg         rst;
reg         tb_en;
reg [31:0]  cnt0;
reg [31:0]  temp_random;
reg         uart_tx_evt_i;
reg [7:0]   uart_tx_data_i;

wire        uart_tx_o;
wire        uart_tx_done;

// uart rx signals---------------
wire        uart_rx_evt_o;
wire[7:0]   uart_rx_data_o;
wire        baud_bps_tb;         //for simulation

// generate clock--------------
initial
begin
    clk = 0;
    forever #(CLK_100M/2) clk = ~clk;
end

// Generate reset-------------
initial
begin
    rst = 1;
    tb_en = 0;
    
    
    #100
    @(posedge clk)
    begin
        rst = 0;
    end
    
    #500
    @(posedge clk)
    begin
        tb_en = 1;
    end
    
    #5000000;
    @(posedge clk)
    begin
        tb_en = 0;
    end
    
    
end



always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        cnt0            <= 'h0;
        temp_random     <= 'h0;
        uart_tx_data_i  <= 'h0;
        uart_tx_evt_i   <= 'h0;
    end
    else
    begin
        uart_tx_evt_i   <=  0;
        if(tb_en)
        begin
            cnt0    <=  cnt0 + 1;
            if(cnt0 == TB_CNT_MAX-2)
            begin
                temp_random <=  $random;
                
            end
            else if(cnt0 == TB_CNT_MAX-1)
            begin
                temp_random[ 7: 0]    <=  temp_random[31:24];
                temp_random[31: 8]    <=  temp_random[23: 0];
                uart_tx_data_i  <=  temp_random[7:0];
                
            end
            else if(cnt0 == TB_CNT_MAX)
            begin
                cnt0    <=  0;
                uart_tx_evt_i   <=  1;
                
            end
        end
    end
end















uart_tx # (
    .MODULE_CLK_RATE    ( MODULE_CLK_RATE       ),
    .UART_BAUDCLK_RATE  ( UART_BAUDCLK_RATE     )
) uart_tx (
    .clk                ( clk                   ),
    .rst                ( rst                   ),
    .uart_tx_data_i     ( uart_tx_data_i        ),
    .uart_tx_evt_i      ( uart_tx_evt_i         ),
    .uart_tx            ( uart_tx_o             ),
    .uart_tx_done       ( uart_tx_done          )
);



uart_rx # (
    .MODULE_CLK_RATE    ( MODULE_CLK_RATE       ),
    .UART_BAUDCLK_RATE  ( UART_BAUDCLK_RATE     )
) uart_rx (
    .clk                ( clk                   ),
    .rst                ( rst                   ),
    .uart_rx            ( uart_tx_o             ),
    .uart_rx_evt_o      ( uart_rx_evt_o         ),
    .uart_rx_data_o     ( uart_rx_data_o        ),
    .baud_bps_tb        ( baud_bps_tb           )
 );
  


endmodule