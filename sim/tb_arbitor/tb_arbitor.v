`timescale 1ns / 1ps

module tb_arbitor;

    parameter LOG_CLK = 6.4;

    reg   log_clk;           // 156.25M
    reg   log_rst;
    reg   link_initialized;
    reg   iotx_tvalid;
    reg   wr_evt_1;
    reg   wr_evt_2;
    reg   wr_evt_3;
    reg   wr_evt_4;
    reg   wr_evt_5;
    reg   wr_evt_6;
    reg   wr_evt_7;
    reg   wr_evt_8;
    reg   wr_evt_9;

    wire  evt1_out;
    wire  evt2_out;
    wire  evt3_out;
    wire  evt4_out;
    wire  evt5_out;
    wire  evt6_out;
    wire  evt7_out;
    wire  evt8_out;
    wire  evt9_out;

    // Loop variables (module-level for Verilog compatibility)
    integer i0, i1, i2, i3, i4, i5, i6;

    // ---------------------------------------------------------------
    // Clock
    // ---------------------------------------------------------------
    initial begin
        log_clk = 0;
        forever #(LOG_CLK/2) log_clk = ~log_clk;
    end

    // ---------------------------------------------------------------
    // Helper tasks
    // ---------------------------------------------------------------
    task wait_clk;
        input integer n;
        repeat(n) @(posedge log_clk);
    endtask

    task evt_init;
        begin
            wr_evt_1 = 0; wr_evt_2 = 0; wr_evt_3 = 0;
            wr_evt_4 = 0; wr_evt_5 = 0; wr_evt_6 = 0;
            wr_evt_7 = 0; wr_evt_8 = 0; wr_evt_9 = 0;
        end
    endtask

    // Pulse multiple events simultaneously (wr_evt_1..wr_evt_9 = bits)
    task pulse_events;
        input [8:0] mask;
        begin
            wr_evt_1 = mask[0]; wr_evt_2 = mask[1]; wr_evt_3 = mask[2];
            wr_evt_4 = mask[3]; wr_evt_5 = mask[4]; wr_evt_6 = mask[5];
            wr_evt_7 = mask[6]; wr_evt_8 = mask[7]; wr_evt_9 = mask[8];
            @(posedge log_clk);
            wr_evt_1 = 0; wr_evt_2 = 0; wr_evt_3 = 0;
            wr_evt_4 = 0; wr_evt_5 = 0; wr_evt_6 = 0;
            wr_evt_7 = 0; wr_evt_8 = 0; wr_evt_9 = 0;
        end
    endtask

    // Pulse a single event by number (1-9)
    task pulse_one;
        input integer evt;
        reg [8:0] m;
        begin
            m = 1 << (evt - 1);
            pulse_events(m);
        end
    endtask

    // Drain FIFO — wait until all event outputs go low
    task drain_fifo;
        integer timeout;
        begin
            // Wait at least 1 cycle for dequeue NBA to take effect
            @(posedge log_clk);
            timeout = 0;
            while (timeout < 500) begin
                @(posedge log_clk);
                timeout = timeout + 1;
                if (~(evt1_out|evt2_out|evt3_out|evt4_out|evt5_out|
                      evt6_out|evt7_out|evt8_out|evt9_out))
                    timeout = 999;
            end
            if (timeout == 500) $display("WARNING: drain_fifo timeout");
        end
    endtask

    // ---------------------------------------------------------------
    // Main test sequence
    // ---------------------------------------------------------------
    initial begin
        $display("=== TB: arbitor coverage-driven testbench ===");

        // ---- Init ----
        link_initialized = 0;
        iotx_tvalid       = 0;
        evt_init();

        // === Phase 0: Reset ===
        $display("Phase 0: Reset");
        log_rst = 1;
        wait_clk(10);
        @(posedge log_clk);
        log_rst = 0;
        wait_clk(5);

        // === Phase 1: Link init + cnt_1s run for toggle coverage ===
        $display("Phase 1: Link init + cnt_1s run");
        @(posedge log_clk);
        link_initialized = 1;
        // Run counter for ~200K cycles to toggle bits [17:0]
        wait_clk(200000);

        // Force cnt_1s high bits to toggle (bits [30:18])
        $display("Phase 1b: Force cnt_1s high bits");
        force arbitor.cnt_1s = 31'h7FFFFFFF;
        wait_clk(2);
        release arbitor.cnt_1s;
        wait_clk(2);
        force arbitor.cnt_1s = 0;
        wait_clk(2);
        release arbitor.cnt_1s;
        wait_clk(5);

        // === Phase 2: Single events (cover fifo[0] CASE + event_in tests) ===
        $display("Phase 2: Single events");
        for (i0 = 1; i0 <= 9; i0 = i0 + 1) begin
            pulse_one(i0);
            drain_fifo;
            wait_clk(10);
        end

        // === Phase 3: Pairs — cover fifo[1] CASE ===
        $display("Phase 3: Event pairs");
        for (i0 = 9; i0 >= 2; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 1; i1 = i1 - 1) begin
                pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)));
                drain_fifo;
                wait_clk(5);
            end
        end

        // === Phase 4: Triples — cover fifo[2] CASE ===
        $display("Phase 4: Event triples");
        for (i0 = 9; i0 >= 3; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 2; i1 = i1 - 1) begin
                for (i2 = i1 - 1; i2 >= 1; i2 = i2 - 1) begin
                    pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)) | (1 << (i2 - 1)));
                    drain_fifo;
                    wait_clk(3);
                end
            end
        end

        // === Phase 5: Full FIFO + quads — cover fifo[3] CASE ===
        $display("Phase 5: Event quads");
        for (i0 = 9; i0 >= 4; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 3; i1 = i1 - 1) begin
                for (i2 = i1 - 1; i2 >= 2; i2 = i2 - 1) begin
                    for (i3 = i2 - 1; i3 >= 1; i3 = i3 - 1) begin
                        pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)) |
                                     (1 << (i2 - 1)) | (1 << (i3 - 1)));
                        drain_fifo;
                        wait_clk(2);
                    end
                end
            end
        end

        // === Phase 6: Quints — cover fifo[4] CASE ===
        $display("Phase 6: Event quints");
        for (i0 = 9; i0 >= 5; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 4; i1 = i1 - 1) begin
                for (i2 = i1 - 1; i2 >= 3; i2 = i2 - 1) begin
                    for (i3 = i2 - 1; i3 >= 2; i3 = i3 - 1) begin
                        for (i4 = i3 - 1; i4 >= 1; i4 = i4 - 1) begin
                            pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)) |
                                         (1 << (i2 - 1)) | (1 << (i3 - 1)) |
                                         (1 << (i4 - 1)));
                            drain_fifo;
                            wait_clk(2);
                        end
                    end
                end
            end
        end

        // === Phase 7: Sextets — cover fifo[5] CASE ===
        $display("Phase 7: Event sextets");
        for (i0 = 9; i0 >= 6; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 5; i1 = i1 - 1) begin
                for (i2 = i1 - 1; i2 >= 4; i2 = i2 - 1) begin
                    for (i3 = i2 - 1; i3 >= 3; i3 = i3 - 1) begin
                        for (i4 = i3 - 1; i4 >= 2; i4 = i4 - 1) begin
                            for (i5 = i4 - 1; i5 >= 1; i5 = i5 - 1) begin
                                pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)) |
                                             (1 << (i2 - 1)) | (1 << (i3 - 1)) |
                                             (1 << (i4 - 1)) | (1 << (i5 - 1)));
                                drain_fifo;
                                wait_clk(2);
                            end
                        end
                    end
                end
            end
        end

        // === Phase 8: Septets — cover fifo[6] CASE ===
        $display("Phase 8: Event septets");
        for (i0 = 9; i0 >= 7; i0 = i0 - 1) begin
            for (i1 = i0 - 1; i1 >= 6; i1 = i1 - 1) begin
                for (i2 = i1 - 1; i2 >= 5; i2 = i2 - 1) begin
                    for (i3 = i2 - 1; i3 >= 4; i3 = i3 - 1) begin
                        for (i4 = i3 - 1; i4 >= 3; i4 = i4 - 1) begin
                            for (i5 = i4 - 1; i5 >= 2; i5 = i5 - 1) begin
                                for (i6 = i5 - 1; i6 >= 1; i6 = i6 - 1) begin
                                    pulse_events((1 << (i0 - 1)) | (1 << (i1 - 1)) |
                                                 (1 << (i2 - 1)) | (1 << (i3 - 1)) |
                                                 (1 << (i4 - 1)) | (1 << (i5 - 1)) |
                                                 (1 << (i6 - 1)));
                                    drain_fifo;
                                    wait_clk(2);
                                end
                            end
                        end
                    end
                end
            end
        end

        // === Phase 9: Full FIFO (all 9) — cover fifo[7],[8] diagonal ===
        $display("Phase 9: Full FIFO fill (all 9)");
        pulse_events(9'b111111111);
        drain_fifo;
        wait_clk(10);

        // Octets — cover fifo[7] additional CASE
        // 9'b111111110 (evts 9..2): fifo[7]=1 — already covered
        // For fifo[7]=2: need 8 events with exactly one < 2 (i.e., event 1)
        // That's events 1..9 minus one high event. Already covered by full set.
        // But to be safe, do a few specific octets:
        pulse_events(9'b111111110); drain_fifo; wait_clk(5);  // fifo[7]=1
        pulse_events(9'b111111101); drain_fifo; wait_clk(5);  // fifo[7]=1, fifo[6]=?
        pulse_events(9'b111111011); drain_fifo; wait_clk(5);
        pulse_events(9'b111110111); drain_fifo; wait_clk(5);
        pulse_events(9'b111101111); drain_fifo; wait_clk(5);
        pulse_events(9'b111011111); drain_fifo; wait_clk(5);
        pulse_events(9'b110111111); drain_fifo; wait_clk(5);
        pulse_events(9'b101111111); drain_fifo; wait_clk(5);
        pulse_events(9'b011111111); drain_fifo; wait_clk(5);

        // === Phase 10: iotx_tvalid=1 blocking (condition + expression coverage) ===
        $display("Phase 10: iotx_tvalid=1 blocking test");
        // Fill FIFO, then block dequeue
        pulse_events(9'b111111111);
        @(posedge log_clk);
        iotx_tvalid = 1;
        wait_clk(50);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(10);

        // Test iotx_tvalid=1 with single event
        pulse_one(5);
        @(posedge log_clk);
        iotx_tvalid = 1;
        wait_clk(20);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(10);

        // Test iotx_tvalid=1 while events are arriving
        iotx_tvalid = 1;
        pulse_one(3);
        wait_clk(10);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(10);

        // iotx_tvalid=1 with empty fifo
        iotx_tvalid = 1;
        wait_clk(10);
        iotx_tvalid = 0;
        wait_clk(5);

        // iotx_tvalid=1 with multiple events queued
        link_initialized = 1;
        iotx_tvalid = 1;
        pulse_events(9'b111111111);
        wait_clk(20);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(10);

        // === Phase 11: Runtime reset (cover rst toggle + reset branches) ===
        $display("Phase 11: Runtime reset");
        pulse_events(9'b000001111);
        wait_clk(5);
        @(posedge log_clk);
        log_rst = 1;
        wait_clk(5);
        @(posedge log_clk);
        log_rst = 0;
        wait_clk(10);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(10);

        // === Phase 12: link_initialized de-assertion ===
        $display("Phase 12: Link de-initialization");
        link_initialized = 0;
        wait_clk(20);
        pulse_one(1);
        wait_clk(10);
        link_initialized = 1;
        wait_clk(10);

        // === Phase 13: no_evt=0 test (events arriving during dequeue) ===
        $display("Phase 13: no_evt=0 concurrent input/output");
        pulse_one(9);
        wait_clk(3);
        pulse_one(8);
        wait_clk(3);
        pulse_one(7);
        drain_fifo;
        wait_clk(10);

        // Fire events while fifo draining
        pulse_events(9'b111111111);
        wait_clk(1);
        pulse_one(1);
        drain_fifo;
        wait_clk(5);

        // === Phase 14: evt_flag propagation ===
        $display("Phase 14: evt_flag propagation");
        pulse_events(9'b111111111);
        drain_fifo;
        wait_clk(10);

        // Events while dequeue happening
        pulse_one(9);
        wait_clk(2);
        pulse_events(9'b001111111);
        drain_fifo;
        wait_clk(10);

        // === Phase 15: Back-to-back events (no_evt_out stress) ===
        $display("Phase 15: Back-to-back events");
        for (i0 = 1; i0 <= 9; i0 = i0 + 1) begin
            pulse_one(i0);
            wait_clk(1);
        end
        drain_fifo;
        wait_clk(10);

        // === Phase 16: iotx_tvalid toggle while FIFO has entries ===
        $display("Phase 16: iotx_tvalid toggling");
        pulse_events(9'b000001111);
        wait_clk(1);
        iotx_tvalid = 1;
        wait_clk(3);
        iotx_tvalid = 0;
        drain_fifo;
        wait_clk(5);

        // === Phase 17: Exhaustive evt_flag cascade (condition coverage) ===
        $display("Phase 17: Exhaustive evt_flag cascade");
        // evt_flagN: SET by event_(N+2), CHECKED by event_(N+1)
        // evt_flag4: events 5+6 → 9'b000110000 (b4=event_5, b5=event_6)
        // evt_flag5: events 6+7 → 9'b001100000 (b5=event_6, b6=event_7)
        // evt_flag6: events 7+8 → 9'b011000000 (b6=event_7, b7=event_8)
        // evt_flag7: events 8+9 → 9'b110000000 (b7=event_8, b8=event_9)

        pulse_events(9'b000110000);  // events 5+6 → evt_flag4 set by event_6
        repeat(60) @(posedge log_clk);

        pulse_events(9'b001100000);  // events 6+7 → evt_flag5 set by event_7
        repeat(60) @(posedge log_clk);

        pulse_events(9'b011000000);  // events 7+8 → evt_flag6 set by event_8
        repeat(60) @(posedge log_clk);

        pulse_events(9'b110000000);  // events 8+9 → evt_flag7 set by event_9
        repeat(60) @(posedge log_clk);

        // Cascading chains
        pulse_events(9'b011100000);  // events 6+7+8
        repeat(60) @(posedge log_clk);

        pulse_events(9'b111100000);  // events 5+6+7+8
        repeat(60) @(posedge log_clk);

        pulse_events(9'b111110000);  // events 4+5+6+7+8
        repeat(60) @(posedge log_clk);

        // Full 9 events
        pulse_events(9'b111111111);
        repeat(100) @(posedge log_clk);

        // Link-toggled version
        link_initialized = 0;
        wait_clk(3);
        pulse_events(9'b111111111);
        wait_clk(3);
        link_initialized = 1;
        repeat(100) @(posedge log_clk);
        drain_fifo;
        wait_clk(10);

        $display("=== DONE ===");
        // No $finish — bounded run time in simulate.do controls exit
    end

    // ---------------------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------------------
    arbitor arbitor (
        .clk                ( log_clk           ),
        .rst                ( log_rst           ),
        .link_initialized   ( link_initialized  ),
        .iotx_tvalid        ( iotx_tvalid       ),
        .event_in_0         ( wr_evt_1          ),
        .event_in_1         ( wr_evt_2          ),
        .event_in_2         ( wr_evt_3          ),
        .event_in_3         ( wr_evt_4          ),
        .event_in_4         ( wr_evt_5          ),
        .event_in_5         ( wr_evt_6          ),
        .event_in_6         ( wr_evt_7          ),
        .event_in_7         ( wr_evt_8          ),
        .event_in_8         ( wr_evt_9          ),
        .event_out_0        ( evt1_out          ),
        .event_out_1        ( evt2_out          ),
        .event_out_2        ( evt3_out          ),
        .event_out_3        ( evt4_out          ),
        .event_out_4        ( evt5_out          ),
        .event_out_5        ( evt6_out          ),
        .event_out_6        ( evt7_out          ),
        .event_out_7        ( evt8_out          ),
        .event_out_8        ( evt9_out          )
    );

endmodule
