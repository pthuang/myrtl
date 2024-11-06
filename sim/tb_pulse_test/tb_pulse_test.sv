`timescale 1ns / 1ps
module tb_pulse_test;

    //================================================
    // Parameters 
    //================================================
    parameter PERIOD_245P76M = 4.0  ; // 4.069
    parameter PERIOD         = 1000 ; // 
     

    reg     clk = 1'b0;
    reg     rst = 1'b0;

    always #(PERIOD_245P76M/2) clk = !clk; 

    initial
    begin
        rst = 0;
        #100
        rst = 1;
        #100
        @(posedge clk) 
            rst = 0; 
    end

    logic   [31:00] cnt0         = 0    ;
    logic   [31:00] width        = 256  ; //
    logic   [31:00] width_change = 32   ; // 
    logic   [31:00] remain_num   = width - width_change   ; // 

    logic           start_evt           ;
    logic           pulse_origin        ;
    logic           pulse_c             ;
    logic           pulse_h             ;
    logic           pulse_dly           ;
    logic           pulse_ext           ;

    always @(posedge clk) begin
        if (rst) begin
            cnt0      <= 0;
            start_evt <= 0;
        end else begin 
            cnt0 <= (cnt0 == PERIOD-1) ? 0 : cnt0 + 1;
            start_evt <= (cnt0 == 32) ? 1 : 0;
        end
    end



    pulse_generate pulse_generate ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .start_evt      ( start_evt         ), // start_evt
        .pulse_width    ( width             ), // pulse width clk cycle num
        .pulse_out      ( pulse_origin      )  // Generated pulse 
    ); 

    pulse_coarctation pulse_coarctation ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .pulse_in       ( pulse_origin      ), // pulse in 
        .remain_num     ( remain_num        ), // coarctation clk cycle num  
        .pulse_out      ( pulse_c           )  // coarctation valid out 
    ); 

    pulse_hold pulse_hold ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .pulse_in       ( pulse_origin      ), // pulse in 
        .hold_num       ( width_change      ), // hold clk cycle num  
        .pulse_out      ( pulse_h           )  // hold valid out 
    ); 

    pulse_delay pulse_delay ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .pulse_in       ( pulse_origin      ), // reset 
        .delay_num      ( width_change      ), // delay clk cycle num
        .pulse_out      ( pulse_dly         )  // delay pulse out 
    );

    pulse_extend  # (
        .PERIOD         ( PERIOD            )  // 
    ) pulse_extend ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .pulse_in       ( pulse_origin      ), // valid in 
        .extend_num_l   ( width_change      ), // extend clk cycle num for left 
        .extend_num_r   ( width_change      ), // extend clk cycle num for right 
        .pulse_out      ( pulse_ext         )  // hold valid out 
    ); 


endmodule 

