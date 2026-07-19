`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sunwave
// Engineer: Wenjie Zhao
// Create Date: 2023/03/06
//////////////////////////////////////////////////////////////////////////////////
module axi_cpu_if (
    input               clk                                     ,
    input               rst                                     ,
    input     [09:00]   s_axi_awaddr                            ,
    input               s_axi_awvalid                           ,
    input     [31:00]   s_axi_wdata                             ,
    input               s_axi_wvalid                            ,
    output reg          s_axi_bvalid                            ,
    input     [09:00]   s_axi_araddr                            ,
    input               s_axi_arvalid                           ,
    output reg[31:00]   s_axi_rdata                             ,
    output reg          s_axi_rvalid                            ,
    // FPGA info                
    input     [31:00]   fpga_date                               ,
    input     [31:00]   fpga_version                            ,
    input     [56:00]   fpga_dna                                ,
    // reset & locked                
    output reg          rst_sys_lmk              = 'b0          ,
    output reg          rst_sys_50               = 'b0          ,
    input               mmcm_lmk_status                         ,
    input               mmcm_50_status                          ,
    input               jesd_rx_sync                            , 
    // xadc
    output reg[06:00]   xadc_addr                = 'h0          ,
    output reg          xadc_re                  = 'h0          ,
    input     [15:00]   xadc_dout                               ,
    // LMK04828             
    output reg          lmk_cs                   = 'b1          ,
    output reg          lmk_sck                  = 'b1          ,
    output reg          lmk_sdio                 = 'b1          ,
    input               lmk_sdout                               ,
    input               sts_ld                                  ,
    output reg          lmk_resetn               = 'b1          ,
    // AFE7689
    input               afe_tdo                                 ,
    output reg          afe_tclk                 = 'b0          ,             
    output reg          afe_tdi                  = 'b0          ,             
    output reg          afe_treset               = 'b0          ,             
    output reg          afe_tms                  = 'b0          ,             
    output reg[01:00]   afe_txenable             = 'h0          , 
    input               afe_pllrefld                            ,
    input               afe_pllclkld                            ,
    output reg          afe_rst_n                = 'b1          ,
    output reg[02:00]   jesd_reset               = 'b0          ,
    // AFE7685 SPI
    output reg          afe7685_init_done        = 'h0          ,
    output reg          afe7685_spi_wevt         = 'h0          ,
    output reg          afe7685_spi_revt         = 'h0          ,
    output reg[14:00]   afe7685_spi_addr         = 'h0          ,
    output reg[07:00]   afe7685_spi_wdata        = 'h0          ,
    input     [07:00]   afe7685_spi_rdata                       ,
    input               afe7685_spi_busy                        ,
    output reg[23:00]   chan_cfg_pre_len         = 'h005D26     , // default: 23846 cycles@245.76M 
    output reg[00:00]   cfg_mode                 = 'h0          ,
    output reg[00:00]   cfg_fresh_gen            = 'h0          ,
    output reg[03:00]   cfg_channel_sel          = 'h0          ,
    output reg[15:00]   afe7685_cfg_delay_len    = 'h0020       , // default: 32  cycles@245.76M
    // Band Configuration 
    output reg[15:00]   network_standard         = 16'h3000     , // 
    input     [15:00]   sync_status                             , // 
    output reg[02:00]   ch0_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch1_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch2_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch3_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch4_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch5_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch6_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch7_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch8_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch9_sync_mode            = 3'h0         , // default: 
    output reg[02:00]   ch10_sync_mode           = 3'h0         , // default: 
    output reg[02:00]   ch11_sync_mode           = 3'h0         , // default: 
    output reg[02:00]   ch12_sync_mode           = 3'h0         , // default: 
    output reg[02:00]   ch13_sync_mode           = 3'h0         , // default: 
    output reg[02:00]   ch14_sync_mode           = 3'h0         , // default: 
    output reg[02:00]   ch15_sync_mode           = 3'h0         , // default: 
    output reg[31:00]   ch0_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch1_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch2_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch3_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch4_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch5_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch6_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch7_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch8_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch9_gps_fhdr_pos         = 32'h0        , // default: 0  
    output reg[31:00]   ch10_gps_fhdr_pos        = 32'h0        , // default: 0  
    output reg[31:00]   ch11_gps_fhdr_pos        = 32'h0        , // default: 0  
    output reg[31:00]   ch12_gps_fhdr_pos        = 32'h0        , // default: 0  
    output reg[31:00]   ch13_gps_fhdr_pos        = 32'h0        , // default: 0  
    output reg[31:00]   ch14_gps_fhdr_pos        = 32'h0        , // default: 0  
    output reg[31:00]   ch15_gps_fhdr_pos        = 32'h0        , // default: 0  
    input     [31:00]   ch0_air_fhdr_pos                        , //   
    input     [31:00]   ch1_air_fhdr_pos                        , //   
    input     [31:00]   ch2_air_fhdr_pos                        , //   
    input     [31:00]   ch3_air_fhdr_pos                        , //   
    input     [31:00]   ch4_air_fhdr_pos                        , //   
    input     [31:00]   ch5_air_fhdr_pos                        , //   
    input     [31:00]   ch6_air_fhdr_pos                        , //   
    input     [31:00]   ch7_air_fhdr_pos                        , //   
    input     [31:00]   ch8_air_fhdr_pos                        , //   
    input     [31:00]   ch9_air_fhdr_pos                        , //   
    input     [31:00]   ch10_air_fhdr_pos                       , //   
    input     [31:00]   ch11_air_fhdr_pos                       , //   
    input     [31:00]   ch12_air_fhdr_pos                       , //   
    input     [31:00]   ch13_air_fhdr_pos                       , //   
    input     [31:00]   ch14_air_fhdr_pos                       , //   
    input     [31:00]   ch15_air_fhdr_pos                       , //  
    // PHY              
    inout               phy1_mdio                               ,
    output reg          phy1_mdc                 = 'b0          ,
    output reg          phy0_rstn                = 'b1          ,
    output reg          phy0_int                 = 'b0          ,
    // CTRL             
    input               sdio_wp                                 ,
    input               sdio_cd                                 ,
    input               ain1                                    ,
    output reg[01:00]   iic_sel                  = 'h0          ,
    // OP mudule status     
    input               op_l2los                                ,
    input               op_l2present                            ,
    input               op_l2txf                                ,
    input               op_l1txf                                ,
    input               op_l1present                            ,
    input               op_l1los                                ,
    //------------------------------------------------------
    output reg[04:00]   rst_test                 = 'h0          ,
    // -------------------------------------------------------
    input     [07:00]   cpri_sync                               ,
    output reg[07:00]   cpri_loopback            = 'h0          ,
    output reg[02:00]   serdes_loopback          = 'h0          ,
    output reg          serdes_reset             = 'b0          ,
    output reg[04:00]   serdes_txprecursor_0     = 'b01110      ,
    output reg[04:00]   serdes_txprecursor_1     = 'b01101      ,
    output reg[04:00]   serdes_txpostcursor_0    = 'b01011      ,
    output reg[04:00]   serdes_txpostcursor_1    = 'b01010      ,
    output reg[03:00]   serdes_txdiffctrl_0      = 'b1011       ,
    output reg[03:00]   serdes_txdiffctrl_1      = 'b0110       ,
    output reg[07:00]   serdes_rx_lpmen          = 'hff         ,
    output reg[07:00]   opt_sync_monitor_rst     = 'h0          ,
    input     [07:00]   opt_sync_monitor_cnt0                   ,
    input     [07:00]   opt_sync_monitor_cnt1                   ,
    input               opt_switch                              ,
    input     [31:00]   local_unit_id                           ,
    input     [15:00]   ip_1st_2bytes                           ,
    input     [15:00]   mac_1st_2bytes                          ,
    input     [15:00]   mac_last_2bytes                         ,
    input               rx_eth_bw_sel                           ,
    input     [31:00]   local_fiber_delay                       ,
    // fpga PLL locked 
    input               serdes_qpll_lock                        ,
    input               jesd_qpll_locked                        ,
    input               ddr_init_done                           ,
    // GPS 
    output reg[15:00]   gps_sync_hold_len        = 16'd1000     , 
    input               gps_status                              , 
    input     [11:00]   gps_hour                                , 
    input     [11:00]   gps_min                                 , 
    input     [11:00]   gps_sec                                 , 
    input     [15:00]   gps_ms                                  ,
    input     [31:00]   gps_date                                ,
    input     [07:00]   gps_talker_id                           ,
    input     [07:00]   gps_pos_lat_direction                   ,
    input     [15:00]   gps_pos_lat_degree                      ,
    input     [15:00]   gps_pos_lat_minute                      ,
    input     [31:00]   gps_pos_lat_second                      ,
    input     [07:00]   gps_pos_long_direction                  ,
    input     [15:00]   gps_pos_long_degree                     ,
    input     [15:00]   gps_pos_long_minute                     ,
    input     [31:00]   gps_pos_long_second                     ,
    // fir sel 
    output reg[04:00]   chan_filter_sel0         = 6            , // 
    output reg[04:00]   chan_filter_sel1         = 7            , // 
    output reg[04:00]   chan_filter_sel2         = 8            , // 
    output reg[04:00]   chan_filter_sel3         = 5            , // 
    output reg[04:00]   chan_filter_sel4         = 6            , // 
    output reg[04:00]   chan_filter_sel5         = 6            , // 
    output reg[04:00]   chan_filter_sel6         = 14           , // 
    output reg[04:00]   chan_filter_sel7         = 12           , // 
    output reg[04:00]   chan_filter_sel8         = 13           , // 
    output reg[04:00]   chan_filter_sel9         = 19           , // 
    output reg[04:00]   chan_filter_sel10        = 9            , // 
    output reg[04:00]   chan_filter_sel11        = 13           , // 
    output reg[04:00]   chan_filter_sel12        = 22           , // 
    output reg[04:00]   chan_filter_sel13        = 22           , // 
    output reg[04:00]   chan_filter_sel14        = 19           , // 
    output reg[04:00]   chan_filter_sel15        = 21           , //  
    // dxc_top
    output reg[31:00]   dxc_dds_freq_cword_0     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_1     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_2     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_3     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_4     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_5     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_6     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_7     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_8     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_9     = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_10    = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_11    = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_12    = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_13    = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_14    = 0            , // 
    output reg[31:00]   dxc_dds_freq_cword_15    = 0            , //
    output reg[15:00]   dxc_en                   = 0            , // 
    // data flow ctrl 
    output reg          dds_enable               = 'b0          ,
    output reg[31:00]   ch0_dds_phase            = 32'h01312D00 , // default: 32'd20000000 -> 1 M
    output reg[31:00]   ch1_dds_phase            = 32'h02625A00 , // default: 32'd40000000 -> 2 M
    output reg          fir_bypass               = 'b0          , // 
    output reg          iq_cdc_loop_en           = 'b0          , // 
    output reg          ddr_bypass               = 'b0          , // 
    output reg          jesd_loop_en             = 'b0          , // 
    output reg          jesd_loop_fir_en         = 'b1          , // 
    output reg          cpu_cpri_test_en         = 'b0          , // 
    output reg          cpri_rx_debug_sel        = 'b0          , // 
    output reg[31:00]   fir_delay_number         = 'hF1         , // default: 241 
    output reg          test_rst                 = 1'b0         ,
    // alc
    output reg          alc_en                   = 1'b1         ,
    output reg[07:00]   alc_dbfsThreshold_ch0    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch1    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch2    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch3    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch4    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch5    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch6    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch7    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch8    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_ch9    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_cha    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_chb    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_chc    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_chd    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_che    = 8'h3c        ,
    output reg[07:00]   alc_dbfsThreshold_chf    = 8'h3c        ,
    input     [06:00]   alc_att0_ch0                            ,
    input     [06:00]   alc_att0_ch1                            ,
    input     [06:00]   alc_att0_ch2                            ,
    input     [06:00]   alc_att0_ch3                            ,
    input     [06:00]   alc_att0_ch4                            ,
    input     [06:00]   alc_att0_ch5                            ,
    input     [06:00]   alc_att0_ch6                            ,
    input     [06:00]   alc_att0_ch7                            ,
    input     [06:00]   alc_att0_ch8                            ,
    input     [06:00]   alc_att0_ch9                            ,
    input     [06:00]   alc_att0_cha                            ,
    input     [06:00]   alc_att0_chb                            ,
    input     [06:00]   alc_att0_chc                            ,
    input     [06:00]   alc_att0_chd                            ,
    input     [06:00]   alc_att0_che                            ,
    input     [06:00]   alc_att0_chf                            ,
    input     [06:00]   alc_att1_ch0                            ,
    input     [06:00]   alc_att1_ch1                            ,
    input     [06:00]   alc_att1_ch2                            ,
    input     [06:00]   alc_att1_ch3                            ,
    input     [06:00]   alc_att1_ch4                            ,
    input     [06:00]   alc_att1_ch5                            ,
    input     [06:00]   alc_att1_ch6                            ,
    input     [06:00]   alc_att1_ch7                            ,
    input     [06:00]   alc_att1_ch8                            ,
    input     [06:00]   alc_att1_ch9                            ,
    input     [06:00]   alc_att1_cha                            ,
    input     [06:00]   alc_att1_chb                            ,
    input     [06:00]   alc_att1_chc                            ,
    input     [06:00]   alc_att1_chd                            ,
    input     [06:00]   alc_att1_che                            ,
    input     [06:00]   alc_att1_chf                            ,
    input     [07:00]   rx_dbfs_ch0                             ,
    input     [07:00]   rx_dbfs_ch1                             ,
    input     [07:00]   rx_dbfs_ch2                             ,
    input     [07:00]   rx_dbfs_ch3                             ,
    input     [07:00]   rx_dbfs_ch4                             ,
    input     [07:00]   rx_dbfs_ch5                             ,
    input     [07:00]   rx_dbfs_ch6                             ,
    input     [07:00]   rx_dbfs_ch7                             ,
    input     [07:00]   rx_dbfs_ch8                             ,
    input     [07:00]   rx_dbfs_ch9                             ,
    input     [07:00]   rx_dbfs_cha                             ,
    input     [07:00]   rx_dbfs_chb                             ,
    input     [07:00]   rx_dbfs_chc                             ,
    input     [07:00]   rx_dbfs_chd                             ,
    input     [07:00]   rx_dbfs_che                             ,
    input     [07:00]   rx_dbfs_chf                             , //
    output reg          peak_n_ave               = 1'b1         , //
    output reg          sbpgc_enable             = 1'b1         , //
    output reg[31:00]   sbpgc_power_user_0       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_1       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_2       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_3       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_4       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_5       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_6       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_7       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_8       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_9       = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_10      = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_11      = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_12      = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_13      = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_14      = 32'h0207567A , // -18dBFS 
    output reg[31:00]   sbpgc_power_user_15      = 32'h0207567A , // -18dBFS 
    input     [31:00]   window_dl_max_value                     ,
    input     [31:00]   dl_switch_max_value                        
);

    localparam  FINAL_NUM = 5'd22 ;
    integer     i;

    reg                     wen                         ;
    reg [09:00]             waddr                       ;
    reg [31:00]             wdata                       ;
    reg [FINAL_NUM - 1:00]  ren                         ;
    reg [09:00]             raddr[FINAL_NUM - 1:00]     ;
    reg [31:00]             rdata[FINAL_NUM - 1:00]     ;
    reg                     rvalid                      ;
    wire axi_wen = s_axi_awvalid & s_axi_wvalid;
    wire axi_ren = s_axi_arvalid;
    always @(posedge clk) begin
        // write to pl 
        wen <= axi_wen;
        if (axi_wen) begin
            waddr <= s_axi_awaddr;
            wdata <= s_axi_wdata;
        end
        s_axi_bvalid <= wen;
        // read from pl rd address gen 
        ren <= {ren[FINAL_NUM - 2:0],axi_ren};
        if (axi_ren) begin 
            raddr[0] <= s_axi_araddr;
        end 
        for(i=0; i <= FINAL_NUM-2; i=i+1) begin
            if(ren[i]) begin 
                raddr[i+1] <= raddr[i]; 
            end 
        end 
        // read data gen 
        rvalid <= ren[FINAL_NUM - 1];
        s_axi_rvalid <= rvalid;
        if (rvalid) begin
            s_axi_rdata <= rdata[FINAL_NUM - 1]; 
        end 
    end
    
    reg  phy1_mdio_sel = 'b0;
    reg  phy1_mdio_wr  = 'b0;
    wire phy1_mdio_rd = phy1_mdio;
    assign phy1_mdio = phy1_mdio_sel ? phy1_mdio_wr : 'bZ;
    
    reg [07:00]     fpga_reconfig;
    
    always @(posedge clk) begin
        if (wen) begin
            case(waddr)
            'h006   : begin fpga_reconfig           <= wdata[07:00] ; end 
            'h009   : begin xadc_addr               <= wdata[06:00] ; end 
            'h00a   : begin xadc_re                 <= wdata[0]     ; end 
            'h00c   : begin rst_sys_50              <= wdata[0]     ; end 
            'h00f   : begin rst_sys_lmk             <= wdata[0]     ; end 
            'h011   : begin lmk_cs                  <= wdata[0]     ; end 
            'h012   : begin lmk_sck                 <= wdata[0]     ; end 
            'h013   : begin lmk_sdio                <= wdata[0]     ; end  
            'h019   : begin afe_tclk                <= wdata[0]     ; end 
            'h01a   : begin afe_tdi                 <= wdata[0]     ; end 
            'h01b   : begin afe_treset              <= wdata[0]     ; end 
            'h01c   : begin afe_tms                 <= wdata[0]     ; end 
            'h01f   : begin afe_txenable            <= wdata[01:00] ; end 
            'h020   : begin afe_rst_n               <= wdata[0]     ; end 
            'h021   : begin jesd_reset              <= wdata[02:00] ; end 
            'h022   : begin phy0_rstn               <= wdata[0]     ; end 
            'h023   : begin phy0_int                <= wdata[0]     ; end 
            'h024   : begin phy1_mdc                <= wdata[0]     ; end 
            'h025   : begin phy1_mdio_sel           <= wdata[0]     ; end 
            'h026   : begin phy1_mdio_wr            <= wdata[0]     ; end 
            'h02f   : begin iic_sel                 <= wdata[01:00] ; end 
            'h032   : begin lmk_resetn              <= wdata[0]     ; end 
            'h039   : begin afe7685_init_done       <= wdata[0]     ; end 
            'h040   : begin afe7685_spi_wevt        <= wdata[0]     ; end 
            'h041   : begin afe7685_spi_revt        <= wdata[0]     ; end 
            'h042   : begin afe7685_spi_addr        <= wdata[14:00] ; end 
            'h043   : begin afe7685_spi_wdata       <= wdata[7:0]   ; end 
            'h046   : begin chan_cfg_pre_len        <= wdata[23:00] ; end 
            'h047   : begin cfg_mode                <= wdata[00:00] ; end
            'h048   : begin cfg_fresh_gen           <= wdata[00:00] ; end
            'h049   : begin cfg_channel_sel         <= wdata[03:00] ; end
            'h04a   : begin afe7685_cfg_delay_len   <= wdata[15:00] ; end
            'h04e   : begin network_standard        <= wdata[15:00] ; end
            'h050   : begin ch0_sync_mode           <= wdata[02:00] ; end
            'h051   : begin ch1_sync_mode           <= wdata[02:00] ; end
            'h052   : begin ch2_sync_mode           <= wdata[02:00] ; end
            'h053   : begin ch3_sync_mode           <= wdata[02:00] ; end
            'h054   : begin ch4_sync_mode           <= wdata[02:00] ; end
            'h055   : begin ch5_sync_mode           <= wdata[02:00] ; end
            'h056   : begin ch6_sync_mode           <= wdata[02:00] ; end
            'h057   : begin ch7_sync_mode           <= wdata[02:00] ; end
            'h058   : begin ch8_sync_mode           <= wdata[02:00] ; end
            'h059   : begin ch9_sync_mode           <= wdata[02:00] ; end
            'h05a   : begin ch10_sync_mode          <= wdata[02:00] ; end
            'h05b   : begin ch11_sync_mode          <= wdata[02:00] ; end
            'h05c   : begin ch12_sync_mode          <= wdata[02:00] ; end
            'h05d   : begin ch13_sync_mode          <= wdata[02:00] ; end
            'h05e   : begin ch14_sync_mode          <= wdata[02:00] ; end
            'h05f   : begin ch15_sync_mode          <= wdata[02:00] ; end
            'h060   : begin ch0_gps_fhdr_pos        <= wdata        ; end
            'h061   : begin ch1_gps_fhdr_pos        <= wdata        ; end
            'h062   : begin ch2_gps_fhdr_pos        <= wdata        ; end
            'h063   : begin ch3_gps_fhdr_pos        <= wdata        ; end
            'h064   : begin ch4_gps_fhdr_pos        <= wdata        ; end
            'h065   : begin ch5_gps_fhdr_pos        <= wdata        ; end
            'h066   : begin ch6_gps_fhdr_pos        <= wdata        ; end
            'h067   : begin ch7_gps_fhdr_pos        <= wdata        ; end
            'h068   : begin ch8_gps_fhdr_pos        <= wdata        ; end
            'h069   : begin ch9_gps_fhdr_pos        <= wdata        ; end
            'h06a   : begin ch10_gps_fhdr_pos       <= wdata        ; end
            'h06b   : begin ch11_gps_fhdr_pos       <= wdata        ; end
            'h06c   : begin ch12_gps_fhdr_pos       <= wdata        ; end
            'h06d   : begin ch13_gps_fhdr_pos       <= wdata        ; end
            'h06e   : begin ch14_gps_fhdr_pos       <= wdata        ; end
            'h06f   : begin ch15_gps_fhdr_pos       <= wdata        ; end
            'h081   : begin serdes_reset            <= wdata[0]     ; end 
            'h082   : begin serdes_txdiffctrl_0     <= wdata[27:24] ; 
                            serdes_txdiffctrl_1     <= wdata[19:16] ; end
            'h084   : begin serdes_txprecursor_0    <= wdata[28:24] ; 
                            serdes_txprecursor_1    <= wdata[20:16] ; end
            'h086   : begin serdes_txpostcursor_0   <= wdata[28:24] ; 
                            serdes_txpostcursor_1   <= wdata[20:16] ; end
            'h088   : begin serdes_rx_lpmen         <= wdata[07:00] ; end 
            'h090   : begin cpri_loopback           <= wdata[07:00] ; end 
            'h091   : begin serdes_loopback         <= wdata[02:00] ; end 
            'h095   : begin rst_test                <= wdata[04:00] ; end 
            'h097   : begin opt_sync_monitor_rst    <= wdata[07:00] ; end 
            'h0af   : begin gps_sync_hold_len       <= wdata[15:00] ; end 
            'h0c0   : begin chan_filter_sel0        <= wdata[04:00] ; end   
            'h0c1   : begin chan_filter_sel1        <= wdata[04:00] ; end   
            'h0c2   : begin chan_filter_sel2        <= wdata[04:00] ; end   
            'h0c3   : begin chan_filter_sel3        <= wdata[04:00] ; end   
            'h0c4   : begin chan_filter_sel4        <= wdata[04:00] ; end   
            'h0c5   : begin chan_filter_sel5        <= wdata[04:00] ; end   
            'h0c6   : begin chan_filter_sel6        <= wdata[04:00] ; end   
            'h0c7   : begin chan_filter_sel7        <= wdata[04:00] ; end   
            'h0c8   : begin chan_filter_sel8        <= wdata[04:00] ; end   
            'h0c9   : begin chan_filter_sel9        <= wdata[04:00] ; end   
            'h0ca   : begin chan_filter_sel10       <= wdata[04:00] ; end   
            'h0cb   : begin chan_filter_sel11       <= wdata[04:00] ; end   
            'h0cc   : begin chan_filter_sel12       <= wdata[04:00] ; end   
            'h0cd   : begin chan_filter_sel13       <= wdata[04:00] ; end   
            'h0ce   : begin chan_filter_sel14       <= wdata[04:00] ; end   
            'h0cf   : begin chan_filter_sel15       <= wdata[04:00] ; end  
            'h0d0   : begin dxc_dds_freq_cword_0    <= wdata        ; end   
            'h0d1   : begin dxc_dds_freq_cword_1    <= wdata        ; end   
            'h0d2   : begin dxc_dds_freq_cword_2    <= wdata        ; end   
            'h0d3   : begin dxc_dds_freq_cword_3    <= wdata        ; end   
            'h0d4   : begin dxc_dds_freq_cword_4    <= wdata        ; end   
            'h0d5   : begin dxc_dds_freq_cword_5    <= wdata        ; end   
            'h0d6   : begin dxc_dds_freq_cword_6    <= wdata        ; end   
            'h0d7   : begin dxc_dds_freq_cword_7    <= wdata        ; end   
            'h0d8   : begin dxc_dds_freq_cword_8    <= wdata        ; end   
            'h0d9   : begin dxc_dds_freq_cword_9    <= wdata        ; end   
            'h0da   : begin dxc_dds_freq_cword_10   <= wdata        ; end   
            'h0db   : begin dxc_dds_freq_cword_11   <= wdata        ; end   
            'h0dc   : begin dxc_dds_freq_cword_12   <= wdata        ; end   
            'h0dd   : begin dxc_dds_freq_cword_13   <= wdata        ; end   
            'h0de   : begin dxc_dds_freq_cword_14   <= wdata        ; end   
            'h0df   : begin dxc_dds_freq_cword_15   <= wdata        ; end  
            'h0e0   : begin dxc_en                  <= wdata[15:00] ; end
            'h0e1   : begin dds_enable              <= wdata[0]     ; end 
            'h0e2   : begin ch0_dds_phase           <= wdata        ; end 
            'h0e3   : begin ch1_dds_phase           <= wdata        ; end 
            'h0e4   : begin fir_bypass              <= wdata[0]     ; end 
            'h0e5   : begin iq_cdc_loop_en          <= wdata[0]     ; end 
            'h0e6   : begin ddr_bypass              <= wdata[0]     ; end 
            'h0e7   : begin jesd_loop_en            <= wdata[0]     ; end 
            'h0e8   : begin jesd_loop_fir_en        <= wdata[0]     ; end 
            'h0e9   : begin cpu_cpri_test_en        <= wdata[0]     ; end 
            'h0ea   : begin cpri_rx_debug_sel       <= wdata[0]     ; end
            'h0eb   : begin fir_delay_number        <= wdata        ; end
            'h0ed   : begin test_rst                <= wdata[0]     ; end
            'h0ef   : begin alc_en                  <= wdata[0]     ; end
            'h0f0   : begin alc_dbfsThreshold_ch0   <= wdata[07:00] ; end
            'h0f1   : begin alc_dbfsThreshold_ch1   <= wdata[07:00] ; end
            'h0f2   : begin alc_dbfsThreshold_ch2   <= wdata[07:00] ; end
            'h0f3   : begin alc_dbfsThreshold_ch3   <= wdata[07:00] ; end
            'h0f4   : begin alc_dbfsThreshold_ch4   <= wdata[07:00] ; end
            'h0f5   : begin alc_dbfsThreshold_ch5   <= wdata[07:00] ; end
            'h0f6   : begin alc_dbfsThreshold_ch6   <= wdata[07:00] ; end
            'h0f7   : begin alc_dbfsThreshold_ch7   <= wdata[07:00] ; end
            'h0f8   : begin alc_dbfsThreshold_ch8   <= wdata[07:00] ; end
            'h0f9   : begin alc_dbfsThreshold_ch9   <= wdata[07:00] ; end
            'h0fa   : begin alc_dbfsThreshold_cha   <= wdata[07:00] ; end
            'h0fb   : begin alc_dbfsThreshold_chb   <= wdata[07:00] ; end
            'h0fc   : begin alc_dbfsThreshold_chc   <= wdata[07:00] ; end
            'h0fd   : begin alc_dbfsThreshold_chd   <= wdata[07:00] ; end
            'h0fe   : begin alc_dbfsThreshold_che   <= wdata[07:00] ; end
            'h0ff   : begin alc_dbfsThreshold_chf   <= wdata[07:00] ; end

            'h132   : begin 
                            sbpgc_enable            <= wdata[0]     ; 
                            peak_n_ave              <= wdata[1]     ;
                      end
            'h133   : begin sbpgc_power_user_0      <= wdata        ; end
            'h134   : begin sbpgc_power_user_1      <= wdata        ; end
            'h135   : begin sbpgc_power_user_2      <= wdata        ; end
            'h136   : begin sbpgc_power_user_3      <= wdata        ; end
            'h137   : begin sbpgc_power_user_4      <= wdata        ; end
            'h138   : begin sbpgc_power_user_5      <= wdata        ; end
            'h139   : begin sbpgc_power_user_6      <= wdata        ; end
            'h13a   : begin sbpgc_power_user_7      <= wdata        ; end
            'h13b   : begin sbpgc_power_user_8      <= wdata        ; end
            'h13c   : begin sbpgc_power_user_9      <= wdata        ; end
            'h13d   : begin sbpgc_power_user_10     <= wdata        ; end
            'h13e   : begin sbpgc_power_user_11     <= wdata        ; end
            'h13f   : begin sbpgc_power_user_12     <= wdata        ; end
            'h140   : begin sbpgc_power_user_13     <= wdata        ; end
            'h141   : begin sbpgc_power_user_14     <= wdata        ; end
            'h142   : begin sbpgc_power_user_15     <= wdata        ; end
            endcase
        end
        if (ren[0]) begin
            case(raddr[0]) // 0x000 ~ 0x00f
            'h000   : rdata[0] <= fpga_date                         ;
            'h001   : rdata[0] <= fpga_version                      ;
            'h002   : rdata[0] <= mmcm_50_status                    ;
            'h003   : rdata[0] <= mmcm_lmk_status                   ;
            'h005   : rdata[0] <= jesd_rx_sync                      ;
            'h006   : rdata[0] <= fpga_reconfig                     ;
            'h007   : rdata[0] <= fpga_dna[56:32]                   ;
            'h008   : rdata[0] <= fpga_dna[31:00]                   ;
            'h009   : rdata[0] <= xadc_addr                         ;
            'h00a   : rdata[0] <= xadc_re                           ;
            'h00b   : rdata[0] <= xadc_dout                         ;
            'h00c   : rdata[0] <= rst_sys_50                        ;
            'h00e   : rdata[0] <= opt_switch                        ;
            'h00f   : rdata[0] <= rst_sys_lmk                       ;
            default : rdata[0] <= 0                                 ;
            endcase
        end
        if (ren[1]) begin
            case(raddr[1]) // 0x010 ~ 0x01f
            'h010   : rdata[1] <= sts_ld                            ;
            'h011   : rdata[1] <= lmk_cs                            ;
            'h012   : rdata[1] <= lmk_sck                           ;
            'h013   : rdata[1] <= lmk_sdio                          ;
            'h014   : rdata[1] <= lmk_sdout                         ;
            'h019   : rdata[1] <= afe_tclk                          ;
            'h01a   : rdata[1] <= afe_tdi                           ;
            'h01b   : rdata[1] <= afe_treset                        ;
            'h01c   : rdata[1] <= afe_tms                           ;
            'h01d   : rdata[1] <= afe_tdo                           ;
            'h01e   : rdata[1] <= {afe_pllclkld, afe_pllrefld}      ;
            'h01f   : rdata[1] <= {30'h0, afe_txenable}             ;
            default : rdata[1] <= 0                                 ;
            endcase
        end
        if (ren[2]) begin
            case(raddr[2]) // 0x020 ~ 0x02f
            'h020   : rdata[2] <= afe_rst_n                         ;
            'h021   : rdata[2] <= jesd_reset                        ;
            'h022   : rdata[2] <= phy0_rstn                         ;
            'h023   : rdata[2] <= phy0_int                          ;
            'h024   : rdata[2] <= phy1_mdc                          ;
            'h025   : rdata[2] <= phy1_mdio_sel                     ;
            'h026   : rdata[2] <= phy1_mdio_wr                      ;
            'h027   : rdata[2] <= phy1_mdio_rd                      ;
            'h028   : rdata[2] <= ain1                              ;
            'h029   : rdata[2] <= sdio_wp                           ;
            'h02a   : rdata[2] <= sdio_cd                           ;
            'h02f   : rdata[2] <= iic_sel                           ;
            default : rdata[2] <= 0                                 ;
            endcase
        end
        if (ren[3]) begin
            case(raddr[3]) // 0x030 ~ 0x03f
            'h032   : rdata[3] <= lmk_resetn                        ;
            'h037   : rdata[3] <= {op_l2los,op_l2present,op_l2txf}  ;
            'h038   : rdata[3] <= {op_l1los,op_l1present,op_l1txf}  ;
            'h039   : rdata[3] <= afe7685_init_done                 ;
            default : rdata[3] <= 0                                 ;
            endcase 
        end 
        if (ren[4]) begin
            case(raddr[4]) // 0x040 ~ 0x04f
            'h040   : rdata[4] <= {31'h0,afe7685_spi_wevt}          ;
            'h041   : rdata[4] <= {31'h0,afe7685_spi_revt}          ;
            'h042   : rdata[4] <= {17'h0,afe7685_spi_addr}          ;
            'h043   : rdata[4] <= {24'h0,afe7685_spi_wdata}         ;
            'h044   : rdata[4] <= {24'h0,afe7685_spi_rdata}         ;
            'h045   : rdata[4] <= {31'h0,afe7685_spi_busy}          ;
            'h046   : rdata[4] <= {8'h0,chan_cfg_pre_len}           ;
            'h047   : rdata[4] <= cfg_mode                          ;
            'h048   : rdata[4] <= cfg_fresh_gen                     ;        
            'h049   : rdata[4] <= cfg_channel_sel                   ;
            'h04a   : rdata[4] <= {16'h0, afe7685_cfg_delay_len}    ;
            'h04e   : rdata[4] <= {16'h0, network_standard}         ;
            'h04f   : rdata[4] <= {16'h0, sync_status}              ;
            default : rdata[4] <= 0                                 ;
            endcase
        end
        if (ren[5]) begin
            case(raddr[5]) // 0x050 ~ 0x05f
            'h050   : rdata[5] <= {29'h0, ch0_sync_mode }           ;
            'h051   : rdata[5] <= {29'h0, ch1_sync_mode }           ;
            'h052   : rdata[5] <= {29'h0, ch2_sync_mode }           ;
            'h053   : rdata[5] <= {29'h0, ch3_sync_mode }           ;
            'h054   : rdata[5] <= {29'h0, ch4_sync_mode }           ;
            'h055   : rdata[5] <= {29'h0, ch5_sync_mode }           ;
            'h056   : rdata[5] <= {29'h0, ch6_sync_mode }           ;
            'h057   : rdata[5] <= {29'h0, ch7_sync_mode }           ;
            'h058   : rdata[5] <= {29'h0, ch8_sync_mode }           ;
            'h059   : rdata[5] <= {29'h0, ch9_sync_mode }           ;
            'h05a   : rdata[5] <= {29'h0, ch10_sync_mode}           ;
            'h05b   : rdata[5] <= {29'h0, ch11_sync_mode}           ;
            'h05c   : rdata[5] <= {29'h0, ch12_sync_mode}           ;
            'h05d   : rdata[5] <= {29'h0, ch13_sync_mode}           ;
            'h05e   : rdata[5] <= {29'h0, ch14_sync_mode}           ;
            'h05f   : rdata[5] <= {29'h0, ch15_sync_mode}           ;
            default : rdata[5] <= 0                                 ;
            endcase 
        end 
        if (ren[6]) begin
            case(raddr[6]) // 0x060 ~ 0x06f
            'h060   : rdata[6] <= ch0_gps_fhdr_pos                  ;
            'h061   : rdata[6] <= ch1_gps_fhdr_pos                  ;
            'h062   : rdata[6] <= ch2_gps_fhdr_pos                  ;
            'h063   : rdata[6] <= ch3_gps_fhdr_pos                  ;
            'h064   : rdata[6] <= ch4_gps_fhdr_pos                  ;
            'h065   : rdata[6] <= ch5_gps_fhdr_pos                  ;
            'h066   : rdata[6] <= ch6_gps_fhdr_pos                  ;
            'h067   : rdata[6] <= ch7_gps_fhdr_pos                  ;
            'h068   : rdata[6] <= ch8_gps_fhdr_pos                  ;
            'h069   : rdata[6] <= ch9_gps_fhdr_pos                  ;
            'h06a   : rdata[6] <= ch10_gps_fhdr_pos                 ;
            'h06b   : rdata[6] <= ch11_gps_fhdr_pos                 ;
            'h06c   : rdata[6] <= ch12_gps_fhdr_pos                 ;
            'h06d   : rdata[6] <= ch13_gps_fhdr_pos                 ;
            'h06e   : rdata[6] <= ch14_gps_fhdr_pos                 ;
            'h06f   : rdata[6] <= ch15_gps_fhdr_pos                 ;
            default : rdata[6] <= 0                                 ;
            endcase
        end
        if (ren[7]) begin
            case(raddr[7]) // 0x070 ~ 0x07f
            'h070   : rdata[7] <= ch0_air_fhdr_pos                  ;
            'h071   : rdata[7] <= ch1_air_fhdr_pos                  ;
            'h072   : rdata[7] <= ch2_air_fhdr_pos                  ;
            'h073   : rdata[7] <= ch3_air_fhdr_pos                  ;
            'h074   : rdata[7] <= ch4_air_fhdr_pos                  ;
            'h075   : rdata[7] <= ch5_air_fhdr_pos                  ;
            'h076   : rdata[7] <= ch6_air_fhdr_pos                  ;
            'h077   : rdata[7] <= ch7_air_fhdr_pos                  ;
            'h078   : rdata[7] <= ch8_air_fhdr_pos                  ;
            'h079   : rdata[7] <= ch9_air_fhdr_pos                  ;
            'h07a   : rdata[7] <= ch10_air_fhdr_pos                 ;
            'h07b   : rdata[7] <= ch11_air_fhdr_pos                 ;
            'h07c   : rdata[7] <= ch12_air_fhdr_pos                 ;
            'h07d   : rdata[7] <= ch13_air_fhdr_pos                 ;
            'h07e   : rdata[7] <= ch14_air_fhdr_pos                 ;
            'h07f   : rdata[7] <= ch15_air_fhdr_pos                 ;
            default : rdata[7] <= 0                                 ;
            endcase
        end
        if (ren[8])begin
            case(raddr[8]) //0x080 ~ 0x08f
            'h081   : rdata[8] <= serdes_reset                                                      ;
            'h082   : rdata[8] <= {4'h0, serdes_txdiffctrl_0  , 4'h0, serdes_txdiffctrl_1  , 16'h0} ;
            'h084   : rdata[8] <= {3'h0, serdes_txprecursor_0 , 3'h0, serdes_txprecursor_1 , 16'h0} ;
            'h086   : rdata[8] <= {3'h0, serdes_txpostcursor_0, 3'h0, serdes_txpostcursor_1, 16'h0} ;
            'h088   : rdata[8] <= serdes_rx_lpmen                                                   ;
            'h089   : rdata[8] <= cpri_sync                                                         ;
            default : rdata[8] <= 0                                 ;
            endcase
        end
        if (ren[9]) begin
            case(raddr[9]) // 0x090 ~ 0x09f
            'h090   : rdata[9] <= cpri_loopback                                                     ;
            'h091   : rdata[9] <= serdes_loopback                                                   ;
            'h095   : rdata[9] <= rst_test                                                          ;
            'h097   : rdata[9] <= opt_sync_monitor_rst                                              ;
            'h098   : rdata[9] <= {opt_sync_monitor_cnt1, opt_sync_monitor_cnt0}                    ;
            default : rdata[9] <= 0                                                                 ;
            endcase
        end
        if (ren[10])begin
            case(raddr[10]) //0x0a0 ~ 0x0af
            'h0a0   : rdata[10] <= local_unit_id                        ;
            'h0a1   : rdata[10] <= ip_1st_2bytes                        ;
            'h0a2   : rdata[10] <= {mac_last_2bytes, mac_1st_2bytes}    ;
            'h0a6   : rdata[10] <= rx_eth_bw_sel                        ;
            'h0a9   : rdata[10] <= local_fiber_delay                    ;
            'h0aa   : rdata[10] <= serdes_qpll_lock                     ;
            'h0ab   : rdata[10] <= jesd_qpll_locked                     ;
            'h0ac   : rdata[10] <= ddr_init_done                        ;
            'h0af   : rdata[10] <= {16'h0, gps_sync_hold_len}           ;
            default : rdata[10] <= 0                                    ;
            endcase 
        end
        if (ren[11]) begin
            case(raddr[11]) // 0x0b0 ~ 0x0bf
            'h0b0   : rdata[11] <= {31'h0,~gps_status}                  ;
            'h0b1   : rdata[11] <= gps_hour                             ;
            'h0b2   : rdata[11] <= gps_min                              ;
            'h0b3   : rdata[11] <= gps_sec                              ;
            'h0b4   : rdata[11] <= gps_ms                               ;
            'h0b5   : rdata[11] <= gps_date                             ;
            'h0b6   : rdata[11] <= gps_talker_id                        ;
            'h0b7   : rdata[11] <= gps_pos_lat_direction                ;
            'h0b8   : rdata[11] <= gps_pos_lat_degree                   ;
            'h0b9   : rdata[11] <= gps_pos_lat_minute                   ;
            'h0ba   : rdata[11] <= gps_pos_lat_second                   ;
            'h0bb   : rdata[11] <= gps_pos_long_direction               ;
            'h0bc   : rdata[11] <= gps_pos_long_degree                  ;
            'h0bd   : rdata[11] <= gps_pos_long_minute                  ;
            'h0be   : rdata[11] <= gps_pos_long_second                  ;
            default : rdata[11] <= 0                                    ;
            endcase
        end
        if (ren[12])begin
            case(raddr[12]) //0x0c0 ~ 0x0cf
            'h0c0   : rdata[12] <= chan_filter_sel0                     ;   
            'h0c1   : rdata[12] <= chan_filter_sel1                     ;   
            'h0c2   : rdata[12] <= chan_filter_sel2                     ;   
            'h0c3   : rdata[12] <= chan_filter_sel3                     ;   
            'h0c4   : rdata[12] <= chan_filter_sel4                     ;   
            'h0c5   : rdata[12] <= chan_filter_sel5                     ;   
            'h0c6   : rdata[12] <= chan_filter_sel6                     ;   
            'h0c7   : rdata[12] <= chan_filter_sel7                     ;   
            'h0c8   : rdata[12] <= chan_filter_sel8                     ;   
            'h0c9   : rdata[12] <= chan_filter_sel9                     ;   
            'h0ca   : rdata[12] <= chan_filter_sel10                    ;   
            'h0cb   : rdata[12] <= chan_filter_sel11                    ;   
            'h0cc   : rdata[12] <= chan_filter_sel12                    ;   
            'h0cd   : rdata[12] <= chan_filter_sel13                    ;   
            'h0ce   : rdata[12] <= chan_filter_sel14                    ;   
            'h0cf   : rdata[12] <= chan_filter_sel15                    ; 
            default : rdata[12] <= 0                                    ;
            endcase
        end
        if (ren[13]) begin
            case(raddr[13]) // 0x0d0 ~ 0x0df
            'h0d0   : rdata[13] <= dxc_dds_freq_cword_0                 ;   
            'h0d1   : rdata[13] <= dxc_dds_freq_cword_1                 ;   
            'h0d2   : rdata[13] <= dxc_dds_freq_cword_2                 ;   
            'h0d3   : rdata[13] <= dxc_dds_freq_cword_3                 ;   
            'h0d4   : rdata[13] <= dxc_dds_freq_cword_4                 ;   
            'h0d5   : rdata[13] <= dxc_dds_freq_cword_5                 ;   
            'h0d6   : rdata[13] <= dxc_dds_freq_cword_6                 ;   
            'h0d7   : rdata[13] <= dxc_dds_freq_cword_7                 ;   
            'h0d8   : rdata[13] <= dxc_dds_freq_cword_8                 ;   
            'h0d9   : rdata[13] <= dxc_dds_freq_cword_9                 ;   
            'h0da   : rdata[13] <= dxc_dds_freq_cword_10                ;   
            'h0db   : rdata[13] <= dxc_dds_freq_cword_11                ;   
            'h0dc   : rdata[13] <= dxc_dds_freq_cword_12                ;   
            'h0dd   : rdata[13] <= dxc_dds_freq_cword_13                ;   
            'h0de   : rdata[13] <= dxc_dds_freq_cword_14                ;   
            'h0df   : rdata[13] <= dxc_dds_freq_cword_15                ;
            default : rdata[13] <= 0                                    ;
            endcase
        end
        if (ren[14])begin 
            case(raddr[14]) //0x0e0 ~ 0x0ef
            'h0e0   : rdata[14] <= {16'h0, dxc_en}                      ;
            'h0e1   : rdata[14] <= {31'h0, dds_enable}                  ;
            'h0e2   : rdata[14] <= ch0_dds_phase                        ;
            'h0e3   : rdata[14] <= ch1_dds_phase                        ;
            'h0e4   : rdata[14] <= {31'h0, fir_bypass}                  ;
            'h0e5   : rdata[14] <= {31'h0, iq_cdc_loop_en}              ;
            'h0e6   : rdata[14] <= {31'h0, ddr_bypass}                  ;
            'h0e7   : rdata[14] <= {31'h0, jesd_loop_en}                ;
            'h0e8   : rdata[14] <= {31'h0, jesd_loop_fir_en}            ;
            'h0e9   : rdata[14] <= {31'h0, cpu_cpri_test_en}            ;
            'h0ea   : rdata[14] <= {31'h0, cpri_rx_debug_sel}           ;
            'h0eb   : rdata[14] <= fir_delay_number                     ;
            'h0ed   : rdata[14] <= test_rst                             ;
            'h0ef   : rdata[14] <= alc_en                               ;
            default : rdata[14] <= 0                                    ;
            endcase
        end
        if (ren[15]) begin
            case(raddr[15]) // 0x0f0 ~ 0x0ff
            'h0f0   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch0}       ;
            'h0f1   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch1}       ;
            'h0f2   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch2}       ;
            'h0f3   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch3}       ;
            'h0f4   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch4}       ;
            'h0f5   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch5}       ;
            'h0f6   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch6}       ;
            'h0f7   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch7}       ;
            'h0f8   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch8}       ;
            'h0f9   : rdata[15] <= {24'h0, alc_dbfsThreshold_ch9}       ;
            'h0fa   : rdata[15] <= {24'h0, alc_dbfsThreshold_cha}       ;
            'h0fb   : rdata[15] <= {24'h0, alc_dbfsThreshold_chb}       ;
            'h0fc   : rdata[15] <= {24'h0, alc_dbfsThreshold_chc}       ;
            'h0fd   : rdata[15] <= {24'h0, alc_dbfsThreshold_chd}       ;
            'h0fe   : rdata[15] <= {24'h0, alc_dbfsThreshold_che}       ;
            'h0ff   : rdata[15] <= {24'h0, alc_dbfsThreshold_chf}       ;
            default : rdata[15] <= 0                                    ;
            endcase
        end
        if (ren[16])begin
            case(raddr[16]) //0x100 ~ 0x10f
            'h100   : rdata[16] <= {25'h0,alc_att0_ch0}                 ;
            'h101   : rdata[16] <= {25'h0,alc_att0_ch1}                 ;
            'h102   : rdata[16] <= {25'h0,alc_att0_ch2}                 ;
            'h103   : rdata[16] <= {25'h0,alc_att0_ch3}                 ;
            'h104   : rdata[16] <= {25'h0,alc_att0_ch4}                 ;
            'h105   : rdata[16] <= {25'h0,alc_att0_ch5}                 ;
            'h106   : rdata[16] <= {25'h0,alc_att0_ch6}                 ;
            'h107   : rdata[16] <= {25'h0,alc_att0_ch7}                 ;
            'h108   : rdata[16] <= {25'h0,alc_att0_ch8}                 ;
            'h109   : rdata[16] <= {25'h0,alc_att0_ch9}                 ;
            'h10a   : rdata[16] <= {25'h0,alc_att0_cha}                 ;
            'h10b   : rdata[16] <= {25'h0,alc_att0_chb}                 ;
            'h10c   : rdata[16] <= {25'h0,alc_att0_chc}                 ;
            'h10d   : rdata[16] <= {25'h0,alc_att0_chd}                 ;
            'h10e   : rdata[16] <= {25'h0,alc_att0_che}                 ;
            'h10f   : rdata[16] <= {25'h0,alc_att0_chf}                 ;
            default : rdata[16] <= 0                                    ;
            endcase
        end
        if (ren[17]) begin
            case(raddr[17]) // 0x110 ~ 0x11f
            'h110   : rdata[17] <= {25'h0,alc_att1_ch0}                 ;
            'h111   : rdata[17] <= {25'h0,alc_att1_ch1}                 ;
            'h112   : rdata[17] <= {25'h0,alc_att1_ch2}                 ;
            'h113   : rdata[17] <= {25'h0,alc_att1_ch3}                 ;
            'h114   : rdata[17] <= {25'h0,alc_att1_ch4}                 ;
            'h115   : rdata[17] <= {25'h0,alc_att1_ch5}                 ;
            'h116   : rdata[17] <= {25'h0,alc_att1_ch6}                 ;
            'h117   : rdata[17] <= {25'h0,alc_att1_ch7}                 ;
            'h118   : rdata[17] <= {25'h0,alc_att1_ch8}                 ;
            'h119   : rdata[17] <= {25'h0,alc_att1_ch9}                 ;
            'h11a   : rdata[17] <= {25'h0,alc_att1_cha}                 ;
            'h11b   : rdata[17] <= {25'h0,alc_att1_chb}                 ;
            'h11c   : rdata[17] <= {25'h0,alc_att1_chc}                 ;
            'h11d   : rdata[17] <= {25'h0,alc_att1_chd}                 ;
            'h11e   : rdata[17] <= {25'h0,alc_att1_che}                 ;
            'h11f   : rdata[17] <= {25'h0,alc_att1_chf}                 ;
            default : rdata[17] <= 0                                    ;
            endcase
        end
        if (ren[18])begin
            case(raddr[18]) //0x120 ~ 0x12f
            'h120   : rdata[18] <= {24'h0,rx_dbfs_ch0}                 ;
            'h121   : rdata[18] <= {24'h0,rx_dbfs_ch1}                 ;
            'h122   : rdata[18] <= {24'h0,rx_dbfs_ch2}                 ;
            'h123   : rdata[18] <= {24'h0,rx_dbfs_ch3}                 ;
            'h124   : rdata[18] <= {24'h0,rx_dbfs_ch4}                 ;
            'h125   : rdata[18] <= {24'h0,rx_dbfs_ch5}                 ;
            'h126   : rdata[18] <= {24'h0,rx_dbfs_ch6}                 ;
            'h127   : rdata[18] <= {24'h0,rx_dbfs_ch7}                 ;
            'h128   : rdata[18] <= {24'h0,rx_dbfs_ch8}                 ;
            'h129   : rdata[18] <= {24'h0,rx_dbfs_ch9}                 ;
            'h12a   : rdata[18] <= {24'h0,rx_dbfs_cha}                 ;
            'h12b   : rdata[18] <= {24'h0,rx_dbfs_chb}                 ;
            'h12c   : rdata[18] <= {24'h0,rx_dbfs_chc}                 ;
            'h12d   : rdata[18] <= {24'h0,rx_dbfs_chd}                 ;
            'h12e   : rdata[18] <= {24'h0,rx_dbfs_che}                 ;
            'h12f   : rdata[18] <= {24'h0,rx_dbfs_chf}                 ;
            default : rdata[18] <= 0                                   ;
            endcase
        end 
        if (ren[19])begin
            case(raddr[19]) //0x130 ~ 0x13f
            'h130   : rdata[19] <= window_dl_max_value                 ;
            'h131   : rdata[19] <= dl_switch_max_value                 ;
            'h132   : rdata[19] <= {peak_n_ave,sbpgc_enable}           ;
            'h133   : rdata[19] <= sbpgc_power_user_0                  ;
            'h134   : rdata[19] <= sbpgc_power_user_1                  ;
            'h135   : rdata[19] <= sbpgc_power_user_2                  ;
            'h136   : rdata[19] <= sbpgc_power_user_3                  ;
            'h137   : rdata[19] <= sbpgc_power_user_4                  ;
            'h138   : rdata[19] <= sbpgc_power_user_5                  ;
            'h139   : rdata[19] <= sbpgc_power_user_6                  ;
            'h13a   : rdata[19] <= sbpgc_power_user_7                  ;
            'h13b   : rdata[19] <= sbpgc_power_user_8                  ;
            'h13c   : rdata[19] <= sbpgc_power_user_9                  ;
            'h13d   : rdata[19] <= sbpgc_power_user_10                 ;
            'h13e   : rdata[19] <= sbpgc_power_user_11                 ;
            'h13f   : rdata[19] <= sbpgc_power_user_12                 ;
            default : rdata[19] <= 0                                   ;
            endcase
        end 
        if (ren[20])begin
            case(raddr[20]) //0x130 ~ 0x13f
            'h140   : rdata[20] <= sbpgc_power_user_13                 ;
            'h141   : rdata[20] <= sbpgc_power_user_14                 ;
            'h142   : rdata[20] <= sbpgc_power_user_15                 ;
            default : rdata[20] <= 0                                   ;
            endcase
        end 
        if (ren[FINAL_NUM - 1]) begin
            case(raddr[FINAL_NUM - 1][9:4])
            'h00    : rdata[FINAL_NUM - 1] <= rdata[00] ; // select table  0
            'h01    : rdata[FINAL_NUM - 1] <= rdata[01] ; // select table  1
            'h02    : rdata[FINAL_NUM - 1] <= rdata[02] ; // select table  2
            'h03    : rdata[FINAL_NUM - 1] <= rdata[03] ; // select table  3
            'h04    : rdata[FINAL_NUM - 1] <= rdata[04] ; // select table  4
            'h05    : rdata[FINAL_NUM - 1] <= rdata[05] ; // select table  5
            'h06    : rdata[FINAL_NUM - 1] <= rdata[06] ; // select table  6
            'h07    : rdata[FINAL_NUM - 1] <= rdata[07] ; // select table  7
            'h08    : rdata[FINAL_NUM - 1] <= rdata[08] ; // select table  8
            'h09    : rdata[FINAL_NUM - 1] <= rdata[09] ; // select table  9
            'h0a    : rdata[FINAL_NUM - 1] <= rdata[10] ; // select table 10
            'h0b    : rdata[FINAL_NUM - 1] <= rdata[11] ; // select table 11
            'h0c    : rdata[FINAL_NUM - 1] <= rdata[12] ; // select table 12
            'h0d    : rdata[FINAL_NUM - 1] <= rdata[13] ; // select table 13
            'h0e    : rdata[FINAL_NUM - 1] <= rdata[14] ; // select table 14
            'h0f    : rdata[FINAL_NUM - 1] <= rdata[15] ; // select table 15
            'h10    : rdata[FINAL_NUM - 1] <= rdata[16] ; // select table 16
            'h11    : rdata[FINAL_NUM - 1] <= rdata[17] ; // select table 17
            'h12    : rdata[FINAL_NUM - 1] <= rdata[18] ; // select table 18
            'h13    : rdata[FINAL_NUM - 1] <= rdata[19] ; // select table 19
            'h14    : rdata[FINAL_NUM - 1] <= rdata[20] ; // select table 19
            default : rdata[FINAL_NUM - 1] <= 0         ; // select table none 
            endcase
        end
    end

endmodule
