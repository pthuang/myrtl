/***********************************************************************
File_name:      uart_tx.v
Project_name:   tb_uart
Author:         Weitao Zhao
Function:
            uart transmit driver





version: 1.0


log:    2021.05.08 create file v0.0
log:    2023.03.01 modify file v1.0 -> Change the comments to English.


**********************************************************************/
module uart_tx # (
    parameter MODULE_CLK_RATE   = 32'd100000000 , // module clock domain, default:100MHz
    parameter UART_BAUDCLK_RATE = 32'd115200      // uart Baudrate, default:115200Hz
)
(
    input               clk             , // clock 
    input               rst             , // active high reset
    input               uart_tx_evt_i   , // tx event 
    input     [07:00]   uart_tx_data_i  , // tx data 
    output reg          uart_tx_done    , // tx done 
    output              uart_tx           // 
);

    localparam BAUD_DIV     = MODULE_CLK_RATE / UART_BAUDCLK_RATE; 
    localparam BAUD_DIV_CAP = BAUD_DIV / 2;

    wire[7:00] tx_data_buff = {uart_tx_data_i[0],uart_tx_data_i[1],uart_tx_data_i[2],uart_tx_data_i[3],uart_tx_data_i[4],uart_tx_data_i[5],uart_tx_data_i[6],uart_tx_data_i[7]};

    //-----------------------------------------------  
    reg [13:00] baud_div;               // 
    reg         baud_bps;               //
    reg         uart_send_flag;         // 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            baud_div <= 0;
            baud_bps <= 0;
        end else begin
            baud_bps <= 0;
            baud_div <= 0;
            if(baud_div < BAUD_DIV && uart_send_flag) begin
                baud_div <= baud_div + 1'b1;
                baud_bps <= 0;
                if(baud_div == BAUD_DIV_CAP) begin
                    baud_bps <= 1'b1;
                end
            end
        end
    end

    //--------------------------------------------------
    reg [09:00] send_data;    // 
    reg [08:00] bit_num;      // 
    reg         uart_tx_o_r;  // 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            uart_send_flag  <= 'b0;
            send_data       <= 'h0;
        end else begin
            if(uart_tx_evt_i) begin
                uart_send_flag <= 1'b1;
                send_data <={1'b0,tx_data_buff,1'b1}; 
            end else if(bit_num==0) begin
                uart_send_flag  <=  'h0;
                send_data       <=  'h0;
            end
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            bit_num    <= 9'd10;    
            uart_tx_o_r<= 1;
        end else begin
            if(uart_send_flag) begin
                if(baud_bps) begin
                    if(bit_num > 0) begin
                        uart_tx_o_r<= send_data[bit_num-1];    
                        bit_num    <= bit_num - 1'b1;
                    end
                end else if(bit_num == 0) begin
                    bit_num <= 9'd10;
                end
            end else begin
                uart_tx_o_r<= 1'b1; 
                bit_num    <= 9'd10;
            end
        end
    end

    assign uart_tx = uart_tx_o_r;

    reg        tx_done_flag;
    reg [10:0] tx_done_cnt;
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            tx_done_flag <= 1'b0;
            tx_done_cnt  <= 11'h0;
            uart_tx_done <= 1'b0;
        end else begin
            if(uart_send_flag && (bit_num==0)) begin
                tx_done_flag <= 1'b1;
            end
            
            if(tx_done_flag) begin
                tx_done_cnt <= tx_done_cnt + 1'b1;
            end
            
            uart_tx_done <= 1'b0;
            if(tx_done_cnt == 11'd1302) begin // >= 651 
                tx_done_flag <= 1'b0;
                tx_done_cnt  <= 11'h0;
                uart_tx_done <= 1'b1;
            end
        end
    end



endmodule
