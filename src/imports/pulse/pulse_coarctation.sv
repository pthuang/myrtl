//================================================================================
// File_name    : pulse_coarctation.v
// Project_name : xxx.xpr
// Author       : pthuang 
// Function     : coarctation pulse some times
//                     __________________________
// pulse_in       ____|                         |_________
//                     _________________
// pulse_out      ____|                |__________________
//                    |<- remain_num ->|           
// Delay        : 1 cycle   
// Version      : V1.0 
// Log          : 2024.11.06 create file V1.0     
//================================================================================
module pulse_coarctation ( 
    input               clk             , // clock 
    input               rst             , // reset 
    input               pulse_in        , // pulse in 
    input       [31:00] remain_num      , // coarctation clk cycle num  
    output logic        pulse_out         // coarctation valid out 
); 
    //==================< Internal Declaration >============================
    logic       [01:00] pulse_r         ;
    logic       [31:00] remain_num_r    ;    
    logic               pulse_rising    ;
    logic       [31:00] cnt_coarc       ;

    //=======================< Main Logic >=================================
    always_ff @(posedge clk) begin
        pulse_r    <= {pulse_r[0], pulse_in};
        remain_num_r <= remain_num; 
    end
    assign pulse_rising  = ((~pulse_r[0]) && pulse_in);
    
    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            cnt_coarc   <= 0;
            pulse_out   <= 0;
        end else begin 
            if(pulse_r[0]) begin 
                cnt_coarc <= (cnt_coarc == remain_num_r-1) ? (remain_num_r-1) : (cnt_coarc + 1);
            end else begin
                cnt_coarc <= 'h0;
            end 

            if(pulse_rising) begin 
                pulse_out <= 1'b1; 
            end else if(cnt_coarc == remain_num_r-1) begin 
                pulse_out <= 1'b0;
            end else begin
                pulse_out <= pulse_out; 
            end 
        end
    end
    
endmodule

