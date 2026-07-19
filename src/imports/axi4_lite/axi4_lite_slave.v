`timescale 1ns / 1ps
//=============================================================================
// File_name    : axi4_lite_slave.v
// Project_name : xxx.xpr
// Author       : pthuang  
// Function     : axi4_lite_slave module.  
// Version      : 1.0  
// Log          : 2025.04.06 create file v1.0 
//=============================================================================
module axi4_lite_slave # (
    parameter                       A_WIDTH	    = 4     , // 
    parameter                       D_WIDTH	    = 32      // 
) (
    input                           s_axi_clk       , // axi clock
    input                           s_axi_areset    , // axi reset high active
    output reg                      s_axi_aw_ready  , // write address  channel 
    input                           s_axi_aw_valid  , // write address  channel 
    input       [A_WIDTH-1:0]       s_axi_aw_addr   , // write address  channel 
    output reg                      s_axi_w_ready   , // write data     channel
    input                           s_axi_w_valid   , // write data     channel
    input       [D_WIDTH-1:0]       s_axi_w_data    , // write data     channel   
    input       [(D_WIDTH/8)-1:0]   s_axi_w_strb    , // write data     channel
    input                           s_axi_b_ready   , // write response channel
    output reg                      s_axi_b_valid   , // write response channel
    output reg  [1:0]               s_axi_b_resp    , // write response channel
    output reg                      s_axi_ar_ready  , // read address   channel
    input                           s_axi_ar_valid  , // read address   channel
    input       [A_WIDTH-1:0]       s_axi_ar_addr   , // read address   channel
    input                           s_axi_r_ready   , // read data      channel
    output reg                      s_axi_r_valid   , // read data      channel
    output reg  [D_WIDTH-1:0]       s_axi_r_data    , // read data      channel
    output reg  [1:0]               s_axi_r_resp    , // read data      channel 

    output reg                      m_wen           , // master write en
    output reg  [A_WIDTH-1:00]      m_waddr         , // master write address
    output reg  [D_WIDTH-1:00]      m_wdata         , // master write data
    output reg                      m_ren           , // master read en
    output reg  [A_WIDTH-1:00]      m_raddr         , // master read address
    input                           m_rvalid        , // master read rvalid  
    input       [D_WIDTH-1:00]      m_rdata           // master read data 
); 

    localparam  LSB = D_WIDTH/32 + 1; // 用于配合字节有效位，32为=2，64为=3 
    integer     i;
    reg         [A_WIDTH-1:0]       waddr       ; // 
    reg         [A_WIDTH-1:0]       raddr       ; //
    reg         [D_WIDTH-1:0]       W_DATA_reg0 ; // 
    reg         [D_WIDTH-1:0]       W_DATA_reg1 ; // 
    reg         [D_WIDTH-1:0]       W_DATA_reg2 ; // 
    reg         [D_WIDTH-1:0]       W_DATA_reg3 ; // 
    reg         [D_WIDTH-1:0]       R_DATA_reg  ; // 


    //=====================================================================
    // Write Address Channel 
    always@(posedge s_axi_clk) begin
        if(s_axi_areset) begin
            s_axi_aw_ready  <= 1'b0; 
            m_waddr         <= 'd0;
        end else begin
            if(s_axi_b_valid && s_axi_b_ready) begin // is also clear aw_valid condition in axi master 
                s_axi_aw_ready <= 1'b0; 
            end else if(~s_axi_aw_ready && s_axi_aw_valid && s_axi_w_valid)	begin 
                s_axi_aw_ready <= 1'b1; 
            end else begin 
                s_axi_aw_ready <= 1'b0; 
            end 

            
            if(~s_axi_aw_ready && s_axi_aw_valid && s_axi_w_valid) begin // load address when assert s_axi_aw_ready 
                m_waddr <= s_axi_aw_addr; 
            end 
        end 
    end 

    //======================================================================
    // Write Data Channel 
    always@(posedge s_axi_clk) begin
        if(s_axi_areset) begin
            s_axi_w_ready <= 1'b0;
            m_wdata       <= 'd0;
            m_wen         <= 1'b0;
        end else begin
            if(s_axi_b_valid && s_axi_b_ready) begin // is also clear w_valid condition in axi master
                s_axi_w_ready <= 1'b0;
            end else if(~s_axi_w_ready && s_axi_aw_valid && s_axi_w_valid) begin // 地址和数据要同步，所以都有效时才能ready
                s_axi_w_ready <= 1'b1;
            end else begin
                s_axi_w_ready <= 1'b0; 
            end 

            if(s_axi_aw_valid && s_axi_w_valid && s_axi_aw_ready && s_axi_w_ready) begin 
                m_wdata <= s_axi_w_data; 
                m_wen   <= 1'b1; 
            end 

            if (m_wen) begin
                m_wen <= 1'b0; 
            end
        end
    end
	
    always@(posedge s_axi_clk) begin 
        if(s_axi_areset) begin
            W_DATA_reg0 <= 'd0;
            W_DATA_reg1 <= 'd0;
            W_DATA_reg2 <= 'd0;
            W_DATA_reg3 <= 'd0;	
        end else begin 
            if(s_axi_aw_valid && s_axi_w_valid && s_axi_aw_ready && s_axi_w_ready) begin	
                case(waddr[A_WIDTH-1:LSB]) 
                2'b00: begin
                    for(i=0;i<D_WIDTH/8;i=i+1) begin 
                        if(s_axi_w_strb[i])   //字节有效位 
                            W_DATA_reg0[i*8 +: 8] <= s_axi_w_data[i*8 +: 8]; 
                    end
                end
                2'b01: begin
                    for(i=0;i<D_WIDTH/8;i=i+1) begin 
                        if(s_axi_w_strb[i])   //字节有效位
                            W_DATA_reg1[i*8 +: 8] <= s_axi_w_data[i*8 +: 8]; 
                    end
                end
                2'b10: begin
                    for(i=0;i<D_WIDTH/8;i=i+1) begin 
                        if(s_axi_w_strb[i])   //字节有效位
                            W_DATA_reg2[i*8 +: 8] <= s_axi_w_data[i*8 +: 8]; 
                    end
                end
                2'b11: begin
                    for(i=0;i<D_WIDTH/8;i=i+1) begin 
                        if(s_axi_w_strb[i]) // 字节有效位
                            W_DATA_reg3[i*8 +: 8] <= s_axi_w_data[i*8 +: 8]; 
                    end
                end
                default: begin
                    W_DATA_reg0 <= W_DATA_reg0;
                    W_DATA_reg1 <= W_DATA_reg1;
                    W_DATA_reg2 <= W_DATA_reg2;
                    W_DATA_reg3 <= W_DATA_reg3; 
                end
                endcase 
            end   
        end 
    end

    //======================================================================	  	  	  	  
    // Write Response Channel 
    always@(posedge s_axi_clk) begin
        if(s_axi_areset) begin
            s_axi_b_valid   <= 1'b0;
            s_axi_b_resp    <= 2'b00; //00: OK; 01: EXOK; 10:SLVERR; 11:DECERR
        end else begin
            if(~s_axi_b_valid && s_axi_aw_valid && s_axi_w_valid && s_axi_aw_ready && s_axi_w_ready) begin
                s_axi_b_valid   <= 1'b1;
                s_axi_b_resp    <= 2'b00; 
            end else if(s_axi_b_ready && s_axi_b_valid)	begin // 地址和数据要同步，所以都有效时才能ready
                s_axi_b_valid   <= 1'b0; 
            end 
        end 
    end
	
    //======================================================================		
    // Read Address Channel 
    always@(posedge s_axi_clk) begin
        if(s_axi_areset) begin    
            s_axi_ar_ready  <= 1'b0;
            m_raddr         <= 'd0;
        end else begin
            if(~s_axi_ar_ready && s_axi_ar_valid && s_axi_r_valid) begin 
                s_axi_ar_ready <= 1'b1;  
            end else begin
                s_axi_ar_ready <= 1'b0; 
            end
            
            if(~s_axi_ar_ready && s_axi_ar_valid) begin
                m_raddr <= s_axi_ar_addr;
            end 
        end
    end 
	
    //======================================================================    
    // Read Data Channel 
    always@(posedge s_axi_clk) begin
        if(s_axi_areset) begin  
            s_axi_r_valid <= 1'b0;
            s_axi_r_resp <= 2'b00; 
        end else if(s_axi_r_ready && s_axi_r_valid)begin
            s_axi_r_valid <= 1'b0;
            s_axi_r_resp <= 2'b00;	
        end else if(~s_axi_r_valid && s_axi_ar_valid) begin
            s_axi_r_valid <= 1'b1; 
            s_axi_r_resp <= 2'b00; 
        end 	  
    end
 
    always@(posedge s_axi_clk) begin 
        if (s_axi_areset) begin
            m_ren           <= 1'b0;
            s_axi_r_data    <= 'd0;
        end else begin 
            if(~s_axi_r_ready && s_axi_r_valid && s_axi_ar_valid) begin 
                m_ren <= 1'b1; 
            end else if(m_ren) begin 
                m_ren <= 1'b0; 
            end 

            if(~s_axi_r_ready && s_axi_r_valid && s_axi_ar_valid) begin 
                s_axi_r_data <= R_DATA_reg;
            end else begin 
                s_axi_r_data <= 'd0; 
            end 
        end
    end 

    always@(*) begin
        if(~s_axi_r_ready && s_axi_r_valid && s_axi_ar_valid) begin // addr 到了的时钟的数据立刻读取
            case(raddr[A_WIDTH - 1 : LSB])	
            2'b00   : R_DATA_reg = W_DATA_reg0;
            2'b01   : R_DATA_reg = W_DATA_reg1;
            2'b10   : R_DATA_reg = W_DATA_reg2;
            2'b11   : R_DATA_reg = W_DATA_reg3;
            default : R_DATA_reg = 'd0;
            endcase
        end 
    end

    // 简化写法
    // assign j = raddr[A_WIDTH - 1 : LSB]
    // R_DATA_reg = W_DATA_regj
    // always@(posedge s_axi_clk) begin
    //     if(s_axi_areset) 
    //         s_axi_r_data <= 'd0;
    //     else if(~s_axi_r_ready && s_axi_r_valid && s_axi_ar_valid)
    //         s_axi_r_data <= R_DATA_reg;
    //     else 	
    //         s_axi_r_data <= 'd0;
    // end 


endmodule 
