//================================================================================
// File_name    : pulse_extend.v
// Project_name : xxx.xpr
// Author       : pthuang 
// Function     : hold pulse some times
//                                        _______
// pulse_in       _______________________|      |____________________________
//                     _____________________________________________
// pulse_out      ____|                                            |_________
//                    |<- extend_num_l ->|      |<- extend_num_r ->|         
// Delay        : 1 cycle    
// Version      : V1.0 
// Log          : 2024.11.06 create file V1.0  
//================================================================================
module pulse_extend  # (
    parameter PERIOD  = 32'h12BFFFFF      // default: 1.28s 
) ( 
    input               clk             , // clock 
    input               rst             , // reset 
    input               pulse_in        , // valid in 
    input       [31:00] extend_num_l    , // extend clk cycle num for left 
    input       [31:00] extend_num_r    , // extend clk cycle num for right 
    output logic        pulse_out         // hold valid out 
); 

    //==================< Internal Declaration >============================
    logic       [31:00] delay_num       ;    
    logic               pulse_ex_left   ;
    logic               pulse_ex_right  ; 

    //=======================< Main Logic >=================================
    always_ff @(posedge clk) begin
        delay_num   <= PERIOD - extend_num_l;
    end
    pulse_delay pulse_delay ( 
        .clk            ( clk               ), // clock 
        .rst            ( rst               ), // reset 
        .pulse_in       ( pulse_in          ), // valid in 
        .delay_num      ( delay_num         ), // delay clk cycle num  
        .pulse_out      ( pulse_ex_left     )  // delay pulse out 
    );

    pulse_hold pulse_hold ( 
        .clk            ( clk               ), // @245.76M
        .rst            ( rst               ), // @245.76M
        .pulse_in       ( pulse_in          ), // valid in 
        .hold_num       ( extend_num_r      ), // hold clk cycle num  
        .pulse_out      ( pulse_ex_right    )  // hold valid out 
    );
    
    assign pulse_out = (pulse_ex_left || pulse_ex_right); 
    
    
endmodule

