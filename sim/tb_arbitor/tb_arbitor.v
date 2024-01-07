`timescale 1ns / 1ps

module tb_arbitor;

    parameter LOG_CLK = 6.4;

    reg   log_clk;    // 156.25M
    reg   log_rst;
    reg   link_initialized;
    reg   iotx_tvalid;
    reg   wr_evt_1;
    reg   wr_evt_2;
    reg   wr_evt_3;
    reg   wr_evt_4;
    reg   wr_evt_5;
    reg   wr_evt_6;
    reg   wr_evt_7;
    reg   wr_evt_8;
    reg   wr_evt_9;

    wire  evt1_out;
    wire  evt2_out;
    wire  evt3_out;
    wire  evt4_out;
    wire  evt5_out;
    wire  evt6_out;
    wire  evt7_out;
    wire  evt8_out;
    wire  evt9_out;


    initial
    begin
        log_clk = 0;
        forever
        begin
            # (LOG_CLK/2) log_clk = ~log_clk;
        end
    end


    initial
    begin
        link_initialized = 0;
        iotx_tvalid = 0;
        wr_evt_1 = 0;
        wr_evt_2 = 0;
        wr_evt_3 = 0;
        wr_evt_4 = 0;
        wr_evt_5 = 0;
        wr_evt_6 = 0;
        wr_evt_7 = 0;
        wr_evt_8 = 0;
        wr_evt_9 = 0;
        
        
        log_rst = 1;
        #100
        @(posedge log_clk)
        begin
            log_rst = 0;
        end
        
        #100
        @(posedge log_clk)
        begin
            link_initialized = 1;
        end
        
        // #1000000000;
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
        end
        @(posedge log_clk)
        begin
            // iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
        end
        
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
            wr_evt_5 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
            wr_evt_5 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
            wr_evt_5 = 1;
            wr_evt_6 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
            wr_evt_5 = 0;
            wr_evt_6 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
            wr_evt_5 = 1;
            wr_evt_6 = 1;
            wr_evt_7 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
            wr_evt_5 = 0;
            wr_evt_6 = 0;
            wr_evt_7 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
            wr_evt_5 = 1;
            wr_evt_6 = 1;
            wr_evt_7 = 1;
            wr_evt_8 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
            wr_evt_5 = 0;
            wr_evt_6 = 0;
            wr_evt_7 = 0;
            wr_evt_8 = 0;
        end
        
        #200
        @(posedge log_clk)
        begin
            iotx_tvalid = 1;
            wr_evt_1 = 1;
            wr_evt_2 = 1;
            wr_evt_3 = 1;
            wr_evt_4 = 1;
            wr_evt_5 = 1;
            wr_evt_6 = 1;
            wr_evt_7 = 1;
            wr_evt_8 = 1;
            wr_evt_9 = 1;
        end
        @(posedge log_clk)
        begin
            iotx_tvalid = 0;
            wr_evt_1 = 0;
            wr_evt_2 = 0;
            wr_evt_3 = 0;
            wr_evt_4 = 0;
            wr_evt_5 = 0;
            wr_evt_6 = 0;
            wr_evt_7 = 0;
            wr_evt_8 = 0;
            wr_evt_9 = 0;
        end
        
        
        #200;
        
    end


    arbitor arbitor ( 
        .clk                ( log_clk           ),
        .rst                ( log_rst           ),
        .link_initialized   ( link_initialized  ),
        .iotx_tvalid        ( iotx_tvalid       ),
        .event_in_0         ( wr_evt_1          ), // 
        .event_in_1         ( wr_evt_2          ),
        .event_in_2         ( wr_evt_3          ),
        .event_in_3         ( wr_evt_4          ),
        .event_in_4         ( wr_evt_5          ),
        .event_in_5         ( wr_evt_6          ), // 
        .event_in_6         ( wr_evt_7          ), // 
        .event_in_7         ( wr_evt_8          ),
        .event_in_8         ( wr_evt_9          ),
        .event_out_0        ( evt1_out          ),
        .event_out_1        ( evt2_out          ),
        .event_out_2        ( evt3_out          ),
        .event_out_3        ( evt4_out          ),
        .event_out_4        ( evt5_out          ),
        .event_out_5        ( evt6_out          ), 
        .event_out_6        ( evt7_out          ),   
        .event_out_7        ( evt8_out          ),
        .event_out_8        ( evt9_out          )
    );

endmodule