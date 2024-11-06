`timescale 1ns / 1ps
//=============================================================================
// File_name    : pulse_generate.sv
// Project_name : xxx.xpr
// Author       : pthuang 
// Function     : generate a continuous pulse, from start_evt and pulse width  
//            is pulse_width.
//                    ___
// start_evt      ___|  |___________________________________________________
//                       _____________________________________
// pulse_out      ______| <---------- pulse_width ---------> |______________
// Delay        : 1 cycle 
// Version      : 1.0  
// Log          : 2024.02.26 create file v1.0 
//=============================================================================
module pulse_generate ( 
    input               clk             , // clock 
    input               rst             , // reset 
    input               start_evt       , // start_evt 
    input       [31:00] pulse_width     , // pulse width clk cycle num 
    output logic        pulse_out         // Generated pulse 
);
    
    logic       [31:00] cnt_width       ; // 
    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            pulse_out <= 0;
            cnt_width <= 0;
        end else begin
            if (start_evt) begin 
                pulse_out <= 1; 
                cnt_width <= 0; 
            end else if (pulse_out) begin 
                if (cnt_width == pulse_width-1) begin 
                    cnt_width <= 0;
                    pulse_out <= 0;
                end else begin 
                    cnt_width <= cnt_width + 1;
                end 
            end else begin
                cnt_width <= 0; 
                pulse_out <= pulse_out;
            end 
        end
    end



endmodule

