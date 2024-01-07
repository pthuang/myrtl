`timescale 1 ps / 1 ps
module arbitor ( 
    input               clk                 , // 156.25M
    input               rst                 , // 
    input               link_initialized    , // 
    input               iotx_tvalid         , // 
    input               event_in_0          , // Lowest priority
    input               event_in_1          , // 
    input               event_in_2          , // 
    input               event_in_3          , // 
    input               event_in_4          , // 
    input               event_in_5          , // 
    input               event_in_6          , // 
    input               event_in_7          , // 
    input               event_in_8          , // Highest priority
    output reg          event_out_0         , // Lowest priority
    output reg          event_out_1         , // 
    output reg          event_out_2         , // 
    output reg          event_out_3         , // 
    output reg          event_out_4         , // 
    output reg          event_out_5         , // 
    output reg          event_out_6         , // 
    output reg          event_out_7         , // 
    output reg          event_out_8           // Highest priority
);
    reg         [04:00] fifo[8:0]           ;
    reg                 evt_flag0           ;
    reg                 evt_flag1           ;
    reg                 evt_flag2           ;
    reg                 evt_flag3           ;
    reg                 evt_flag4           ;
    reg                 evt_flag5           ;
    reg                 evt_flag6           ;
    reg                 evt_flag7           ;

    wire                no_evt_out          ;
    wire                no_evt              ;
    reg         [30:00] cnt_1s              ;
    reg                 ready_dly           ;

    assign no_evt_out = ~(event_out_8|event_out_7|event_out_6|event_out_5|event_out_4|event_out_3|event_out_2|event_out_1|event_out_0);
    assign no_evt     = ~(event_in_8|event_in_7|event_in_6|event_in_5|event_in_4|event_in_3|event_in_2|event_in_1|event_in_0
                         |evt_flag7|evt_flag6|evt_flag4|evt_flag3|evt_flag2|evt_flag1|evt_flag0);
    
    always @(posedge clk or posedge rst ) begin
        if ( rst ) begin
            cnt_1s    <= 0;
            ready_dly <= 0;
        end else begin
            cnt_1s <= 0;
            if(link_initialized) begin
                cnt_1s <= cnt_1s + 1;
                // if(cnt_1s == 156250000 - 1) begin
                    ready_dly <= 1;
                // end
            end
        end
    end 

    always@(posedge clk or posedge rst ) begin
        if(rst ) begin
            fifo[0]   <= 0;
            fifo[1]   <= 0;
            fifo[2]   <= 0;
            fifo[3]   <= 0;
            fifo[4]   <= 0;
            fifo[5]   <= 0;
            fifo[6]   <= 0;
            fifo[7]   <= 0;
            fifo[8]   <= 0;
            evt_flag0 <= 0;
            evt_flag1 <= 0;
            evt_flag2 <= 0;
            evt_flag3 <= 0;
            evt_flag4 <= 0;
            evt_flag5 <= 0;
            evt_flag6 <= 0;
            evt_flag7 <= 0;
            event_out_0  <= 0;
            event_out_1  <= 0;
            event_out_2  <= 0;
            event_out_3  <= 0;
            event_out_4  <= 0;
            event_out_5  <= 0;
            event_out_6  <= 0;
            event_out_7  <= 0;
            event_out_8  <= 0;
        end else begin 
            event_out_0 <= 0;
            event_out_1 <= 0;
            event_out_2 <= 0;
            event_out_3 <= 0;
            event_out_4 <= 0;
            event_out_5 <= 0;
            event_out_6 <= 0;
            event_out_7 <= 0;
            event_out_8 <= 0;
            if(fifo[8][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                fifo[8] <= 0;
                case ( fifo[8][3:0] )
                4'd1: event_out_0 <= 1;
                4'd2: event_out_1 <= 1;
                4'd3: event_out_2 <= 1;
                4'd4: event_out_3 <= 1;
                4'd5: event_out_4 <= 1;
                4'd6: event_out_5 <= 1;
                4'd7: event_out_6 <= 1;
                4'd8: event_out_7 <= 1;
                4'd9: event_out_8 <= 1;
                endcase
            end else begin
                if(fifo[7][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                    fifo[7] <= 0;
                    case ( fifo[7][3:0] )
                        4'd1: event_out_0 <= 1;
                        4'd2: event_out_1 <= 1;
                        4'd3: event_out_2 <= 1;
                        4'd4: event_out_3 <= 1;
                        4'd5: event_out_4 <= 1;
                        4'd6: event_out_5 <= 1;
                        4'd7: event_out_6 <= 1;
                        4'd8: event_out_7 <= 1;
                        4'd9: event_out_8 <= 1;
                    endcase
                end else begin
                    if ( fifo[6][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                        fifo[6] <= 0;
                        case ( fifo[6][3:0] )
                            4'd1: event_out_0 <= 1;
                            4'd2: event_out_1 <= 1;
                            4'd3: event_out_2 <= 1;
                            4'd4: event_out_3 <= 1;
                            4'd5: event_out_4 <= 1;
                            4'd6: event_out_5 <= 1;
                            4'd7: event_out_6 <= 1;
                            4'd8: event_out_7 <= 1;
                            4'd9: event_out_8 <= 1;
                        endcase
                    end else begin 
                        if ( fifo[5][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                            fifo[5] <= 0;
                            case ( fifo[5][3:0] )
                                4'd1: event_out_0 <= 1;
                                4'd2: event_out_1 <= 1;
                                4'd3: event_out_2 <= 1;
                                4'd4: event_out_3 <= 1;
                                4'd5: event_out_4 <= 1;
                                4'd6: event_out_5 <= 1;
                                4'd7: event_out_6 <= 1;
                                4'd8: event_out_7 <= 1;
                                4'd9: event_out_8 <= 1;
                            endcase
                        end else begin
                            if ( fifo[4][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                                fifo[4] <= 0;
                                case ( fifo[4][3:0] )
                                4'd1: event_out_0 <= 1;
                                4'd2: event_out_1 <= 1;
                                4'd3: event_out_2 <= 1;
                                4'd4: event_out_3 <= 1;
                                4'd5: event_out_4 <= 1;
                                4'd6: event_out_5 <= 1;
                                4'd7: event_out_6 <= 1;
                                4'd8: event_out_7 <= 1;
                                4'd9: event_out_8 <= 1;
                                endcase
                            end else begin 
                                if ( fifo[3][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out ) begin
                                    fifo[3] <= 0;
                                    case ( fifo[3][3:0] )
                                    4'd1: event_out_0 <= 1;
                                    4'd2: event_out_1 <= 1;
                                    4'd3: event_out_2 <= 1;
                                    4'd4: event_out_3 <= 1;
                                    4'd5: event_out_4 <= 1;
                                    4'd6: event_out_5 <= 1;
                                    4'd7: event_out_6 <= 1;
                                    4'd8: event_out_7 <= 1;
                                    4'd9: event_out_8 <= 1;
                                    endcase
                                end else begin 
                                    if ( fifo[2][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out) begin
                                        fifo[2] <= 0;
                                        case ( fifo[2][3:0] )
                                        4'd1: event_out_0 <= 1;
                                        4'd2: event_out_1 <= 1;
                                        4'd3: event_out_2 <= 1;
                                        4'd4: event_out_3 <= 1;
                                        4'd5: event_out_4 <= 1;
                                        4'd6: event_out_5 <= 1;
                                        4'd7: event_out_6 <= 1;
                                        4'd8: event_out_7 <= 1;
                                        4'd9: event_out_8 <= 1;
                                        endcase
                                    end else begin 
                                        if ( fifo[1][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out) begin
                                            fifo[1] <= 0;
                                            case ( fifo[1][3:0] )
                                            4'd1: event_out_0 <= 1;
                                            4'd2: event_out_1 <= 1;
                                            4'd3: event_out_2 <= 1;
                                            4'd4: event_out_3 <= 1;
                                            4'd5: event_out_4 <= 1;
                                            4'd6: event_out_5 <= 1;
                                            4'd7: event_out_6 <= 1;
                                            4'd8: event_out_7 <= 1;
                                            4'd9: event_out_8 <= 1;
                                            endcase
                                        end else begin
                                            if ( fifo[0][4] == 1 & ~iotx_tvalid & no_evt & no_evt_out) begin
                                                fifo[0] <= 0;
                                                case ( fifo[0][3:0] )
                                                4'd1: event_out_0 <= 1;
                                                4'd2: event_out_1 <= 1;
                                                4'd3: event_out_2 <= 1;
                                                4'd4: event_out_3 <= 1;
                                                4'd5: event_out_4 <= 1;
                                                4'd6: event_out_5 <= 1;
                                                4'd7: event_out_6 <= 1;
                                                4'd8: event_out_7 <= 1;
                                                4'd9: event_out_8 <= 1;
                                                endcase
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    //Ñ¹¶ÑÕ»
                    if (ready_dly)
                    begin
                        if ( event_in_0|evt_flag0 )
                        begin
                            fifo[0] <= {1'b1,4'd1};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag0 <= 0;
                        end
                        if ( event_in_1|evt_flag1 )
                        begin
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd2};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag1 <= 0;
                        end
                        if ( event_in_2|evt_flag2 )
                        begin
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd3};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag2 <= 0;
                        end
                        if ( event_in_3|evt_flag3 )
                        begin
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd4};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag3 <= 0;
                        end
                        if ( event_in_4|evt_flag4 )
                        begin
                            evt_flag3 <= event_in_3|evt_flag3;
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd5};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag4 <= 0;
                        end
                        if ( event_in_5|evt_flag5 ) begin
                            evt_flag4 <= event_in_4|evt_flag4;
                            evt_flag3 <= event_in_3|evt_flag3;
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd6};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag5 <= 0;
                        end
                        if ( event_in_6|evt_flag6 ) begin
                            evt_flag5 <= event_in_5|evt_flag5;
                            evt_flag4 <= event_in_4|evt_flag4;
                            evt_flag3 <= event_in_3|evt_flag3;
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd7};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag6 <= 0;
                        end
                        if ( event_in_7|evt_flag7 ) begin
                            evt_flag6 <= event_in_6|evt_flag6;
                            evt_flag5 <= event_in_5|evt_flag5;
                            evt_flag4 <= event_in_4|evt_flag4;
                            evt_flag3 <= event_in_3|evt_flag3;
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd8};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                            evt_flag7 <= 0;
                        end
                        if(event_in_8) begin
                            evt_flag7 <= event_in_7|evt_flag7;
                            evt_flag6 <= event_in_6|evt_flag6;
                            evt_flag5 <= event_in_5|evt_flag5;
                            evt_flag4 <= event_in_4|evt_flag4;
                            evt_flag3 <= event_in_3|evt_flag3;
                            evt_flag2 <= event_in_2|evt_flag2;
                            evt_flag1 <= event_in_1|evt_flag1;
                            evt_flag0 <= event_in_0|evt_flag0;
                            fifo[0] <= {1'b1,4'd9};
                            fifo[1] <= fifo[0];
                            fifo[2] <= fifo[1];
                            fifo[3] <= fifo[2];
                            fifo[4] <= fifo[3];
                            fifo[5] <= fifo[4];
                            fifo[6] <= fifo[5];
                            fifo[7] <= fifo[6];
                            fifo[8] <= fifo[7];
                        end
                    end
                end
            end
        end
    end

endmodule