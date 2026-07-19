`timescale 1ns / 1ps
//=============================================================================
// File_name    : pulse_delay.sv
// Project_name : xxx.xpr
// Author       : pthuang 
// Function     : delay pulse module.
//                    ________________
// pulse_in       ___|               |_____________________________________
//                   |<--- delay_num --->|___________________
// pulse_out      _______________________|                  |______________
// Delay        : 1 cycle 
// version      : 1.0  
// log          : 2024.03.01 create file v1.0 
//============================================================================= 
module pulse_delay ( 
    input  logic        clk             , // clock 
    input  logic        rst             , // reset 
    input  logic        pulse_in        , // pulse in 
    input  logic[31:00] delay_num       , // delay clk cycle num 
    output logic        pulse_out         // delay pulse out 
);
    
    logic       [01:00] pulse_in_r      ; // 
    logic       [31:00] delay_number_r  ; // 
    logic       [31:00] cnt_delay0      ; // 
    logic       [31:00] cnt_delay1      ; // 

    always_ff @(posedge clk) begin
        pulse_in_r <= {pulse_in_r[0], pulse_in};
        delay_number_r <= delay_num; 
    end 

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            cnt_delay0 <= 0;
            cnt_delay1 <= 0;
            pulse_out  <= 0;
        end else begin
            if (pulse_in_r == 2'b01) begin // posedge 
                cnt_delay0 <= 1;
            end else if (cnt_delay0 == delay_number_r-1) begin
                cnt_delay0 <= 0;
            end else if (|cnt_delay0) begin
                cnt_delay0 <= cnt_delay0 + 1;
            end else begin
                cnt_delay0 <= cnt_delay0;
            end 

            if (pulse_in_r == 2'b10) begin // negedge 
                cnt_delay1 <= 1;
            end else if (cnt_delay1 == delay_number_r-1) begin
                cnt_delay1 <= 0;
            end else if (|cnt_delay1) begin 
                cnt_delay1 <= cnt_delay1 + 1; 
            end else begin 
                cnt_delay1 <= cnt_delay1; 
            end 

            if (cnt_delay0 == delay_number_r-1) begin
                pulse_out <= 1;
            end else if (cnt_delay1 == delay_number_r-1) begin
                pulse_out <= 0; 
            end else begin
                pulse_out <= pulse_out; 
            end 
        end
    end

endmodule
