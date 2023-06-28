/*********************************
File_name:      uart_rx.v
Project_name:   tb_uart
Author:         Weitao Zhao
Function:
            uart receive driver





version: 0.0


log:    2021.05.08 create file v0.0


********************************/
module uart_rx # (
    parameter MODULE_CLK_RATE   = 32'd100000000 , // user clock rate,default: 100 MHz
    parameter UART_BAUDCLK_RATE = 32'd115200      // spi  baud  rate,default: 115200 Hz
)
(
    input               clk                     , 
    input               rst                     , 
    input               uart_rx                 , 
    output              uart_rx_evt_o           , 
    output    [07:00]   uart_rx_data_o          , 
    output              baud_bps_tb              // for simulation
 );
 
    localparam BAUD_DIV     = MODULE_CLK_RATE / UART_BAUDCLK_RATE; // baud clock, 115200bps，100Mhz/115200=868
    localparam BAUD_DIV_CAP = BAUD_DIV / 2;                        // half point of baud clock, 100Mhz/115200/2=434
    
    
    //------------------------counter control -------------------------------
    reg [13:0] baud_div;                            // 
    reg        baud_bps;                            // 
    reg        bps_start;                           // 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            baud_div <= 0;
            baud_bps <= 0;
        end else begin
            baud_bps <= 0;
            baud_div <= 0;
            if(baud_div < BAUD_DIV && bps_start) begin
                baud_div <= baud_div + 1'b1;
                baud_bps <= 0;
                if(baud_div == BAUD_DIV_CAP) begin
                    baud_bps <= 1'b1;
                end
            end
        end
    end


    reg [4:0] uart_rx_i_r;                // 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            uart_rx_i_r <= 5'b11111;
        end else begin
            uart_rx_i_r<={uart_rx_i_r[3:0],uart_rx};
        end
    end
    // When five low levels are received continuously, that is, when uart_rx_int=0, it is regarded as the start signal received
    wire uart_rx_int = uart_rx_i_r[4] | uart_rx_i_r[3] | uart_rx_i_r[2] | uart_rx_i_r[1] | uart_rx_i_r[0];


    //------------------------ data receive ----------------------------------------
    reg [03:00] bit_num;          // 
    reg         uart_rx_done_r;   // 
    reg         state;

    reg [07:00] uart_rx_data_o_r0=0; // 
    reg [07:00] uart_rx_data_o_r1=0; // 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            uart_rx_done_r <= 0;
            bps_start      <= 0;    
            state          <= 1'b0;
            bit_num        <= 0;
            uart_rx_data_o_r0 <= 0;
            uart_rx_data_o_r1 <= 0;
        end else begin
            uart_rx_done_r <= 1'b0;
            case(state)
            1'b0 :
            begin
                if(!uart_rx_int) begin
                    bps_start <= 1'b1;
                    state     <= 1'b1;
                end
            end
            1'b1 :
            begin           
                if(baud_bps) begin
                    bit_num <= bit_num + 1'b1;
                    if( bit_num<4'd9 ) begin
                        uart_rx_data_o_r0[bit_num-1] <= uart_rx;
                    end
                end else if(bit_num==4'd10) begin
                    bit_num           <= 0;
                    uart_rx_done_r    <= 1'b1;
                    uart_rx_data_o_r1 <= uart_rx_data_o_r0;
                    state             <= 1'b0; // 
                    bps_start         <= 0;
                end
            end
            default:;
            endcase
        end
    end

    assign baud_bps_tb    = baud_bps;//for simulation
    assign uart_rx_data_o = uart_rx_data_o_r1;
    assign uart_rx_evt_o  = uart_rx_done_r;


endmodule
