`timescale 1ns/1ps

module traffic_light_tb;

    // Must match the DUT parameters
    parameter T_A_GREEN  = 10;
    parameter T_A_YELLOW = 3;
    parameter T_B_GREEN  = 10;
    parameter T_B_YELLOW = 3;
    localparam PERIOD = T_A_GREEN + T_A_YELLOW + T_B_GREEN + T_B_YELLOW; // 

    localparam RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg        clk = 0;
    reg        rst;
    wire [2:0] road_a, road_b;


    traffic_light_controller #(
        .T_A_GREEN (T_A_GREEN),
        .T_A_YELLOW(T_A_YELLOW),
        .T_B_GREEN (T_B_GREEN),
        .T_B_YELLOW(T_B_YELLOW)
    ) dut (
        .clk   (clk),
        .rst   (rst),
        .road_a(road_a),
        .road_b(road_b)
    );

    // Clock: 1 cycle = 1 "second" (10 ns period in simulation)
    always #5 clk = ~clk;

    // Reference model: cycles since the last reset
    integer cyc;
    always @(posedge clk) begin
        if (rst) cyc <= 0;
        else     cyc <= cyc + 1;
    end

    // Expected outputs for the current point in the cycle
    reg [2:0] exp_a, exp_b;
    integer   k;
    always @(*) begin
        k = cyc % PERIOD;
        if (k < T_A_GREEN) begin
            exp_a = GRN; exp_b = RED;
        end else if (k < T_A_GREEN + T_A_YELLOW) begin
            exp_a = YEL; exp_b = RED;
        end else if (k < T_A_GREEN + T_A_YELLOW + T_B_GREEN) begin
            exp_a = RED; exp_b = GRN;
        end else begin
            exp_a = RED; exp_b = YEL;
        end
    end

    integer errors   = 0;
    integer checking = 0;

    always @(negedge clk) begin
        if (checking) begin
            if (road_a !== exp_a || road_b !== exp_b) begin
                errors = errors + 1;
                $display("[%0t] MISMATCH at cycle %0d: A=%b (exp %b)  B=%b (exp %b)",
                         $time, cyc, road_a, exp_a, road_b, exp_b);
            end
            if (road_a[0] && road_b[0]) begin
                errors = errors + 1;
                $display("[%0t] ERROR: both roads green!", $time);
            end
        end
    end

    // Print a line whenever the lights change (handy to read in the console)
    always @(road_a or road_b)
        if (checking)
            $display("[%0t] cycle %0d: A=%b  B=%b", $time, cyc, road_a, road_b);

    // Stimulus
    initial begin
        $dumpfile("traffic_light_tb.vcd");
        $dumpvars(0, traffic_light_tb);

        // Test 1: reset, then run 3 full cycles
        rst = 1;
        repeat (2) @(posedge clk);
        @(negedge clk) rst = 0;
        checking = 1;
        repeat (3 * PERIOD) @(negedge clk);

        // Test 2: reset in the middle of a cycle (during Road A yellow)
        repeat (11) @(negedge clk);
        $display("--- applying mid-run reset ---");
        rst = 1;
        @(negedge clk);
        @(negedge clk) rst = 0;

        // Run 2 more full cycles after the reset
        repeat (2 * PERIOD) @(negedge clk);

        if (errors == 0) $display("PASS: all checks passed.");
        else             $display("FAIL: %0d error(s).", errors);
        $finish;
    end

endmodule