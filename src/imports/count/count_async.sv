`timescale 1ns / 1ps
//=============================================================================
// File_name    : count_async.sv
// Project_name : xxx.xpr
// Author       : pthuang 
// Function     : count module with clear and async reset 
// version      : 1.0  
// log          : 2025.04.14 create file v1.0 
//============================================================================= 
module count_async # (
    parameter               WIDTH = 16'd32    // 
) ( 
    input  logic            clk             , // clock 
    input  logic            rst             , // reset 
    input  logic            clear           , // clear  
    input  logic[WIDTH-1:0] full_num        , // count full num  
    output logic[WIDTH-1:0] count_out         // count out 
);
    
    logic       [WIDTH-1:0] full_num_r      ; // 

    always_ff @(posedge clk) begin 
        full_num_r <= full_num; 
    end 

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            count_out <= 0; 
        end else begin 
            if (clear) begin 
                count_out <= 1;
            end else begin 
                count_out <= (count_out == full_num_r-1) ? 0 : (count_out + 1); 
            end 
        end
    end

endmodule
