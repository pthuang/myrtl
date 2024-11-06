//================================================================================
// File_name    : pulse_hold.v
// Project_name : xxx.xpr
// Author       : pthuang
// Function     : hold pulse some times
//                     _____
// pulse_in       ____|    |______________________________
//                     __________________________
// pulse_out      ____|                         |_________
//                         |<---- hold_num ---->|         
// Delay        : 1 cycle 
// Version      : V1.0 
// Log          : 2024.11.06 create file V1.0     
//================================================================================
module pulse_hold ( 
    input               clk             , // clock 
    input               rst             , // reset 
    input               pulse_in        , // pulse in 
    input       [31:00] hold_num        , // hold clk cycle num  
    output logic        pulse_out         // hold valid out 
); 
    //==================< Internal Declaration >============================
    logic               pulse_r         ;
    logic       [31:00] hold_num_r      ;    
    logic               pulse_rising    ;
    logic               pulse_falling   ;
    logic               hold_en         ;
    logic       [31:00] cnt_hold        ; 

    //=======================< Main Logic >=================================
    always_ff @(posedge clk) begin
        pulse_r    <= pulse_in;
        hold_num_r <= hold_num; 
    end
    assign pulse_rising  = ((~pulse_r) && pulse_in);
    assign pulse_falling = (pulse_r && (~pulse_in));
    
    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            hold_en     <= 0;
            cnt_hold    <= 0;
            pulse_out   <= 0;
        end else begin
            if(pulse_falling) begin
                hold_en <= 1;
            end else if(pulse_rising || (cnt_hold == hold_num_r-1)) begin // resync before valid_hold pull down. 
                hold_en <= 0;
            end else begin 
                hold_en <= hold_en;
            end 
            
            if(hold_en) begin
                cnt_hold <= (cnt_hold == hold_num_r-1) ? 0 : (cnt_hold + 1);
            end else begin
                cnt_hold <= 'h0;
            end 

            if(pulse_rising) begin 
                pulse_out <= 1'b1; 
            end else if(cnt_hold == hold_num_r-1) begin 
                pulse_out <= 1'b0;
            end else begin
                pulse_out <= pulse_out; 
            end 
        end
    end
    
    
endmodule

