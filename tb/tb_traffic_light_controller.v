`timescale 1s / 100ms

module tb_traffic_light_controller;

    // Testbench signals
    reg clk;
    reg rst;
    wire [2:0] road_a;
    wire [2:0] road_b;

    
    localparam [2:0] RED    = 3'b100;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] GREEN  = 3'b001;

   
    integer errors = 0;

    // Instantiating the Unit Under Test 
    traffic_light_controller uut (
        .clk    (clk),
        .rst    (rst),
        .road_a (road_a),
        .road_b (road_b)
    );

   
    initial clk = 0;
    always #0.5 clk = ~clk;

    // Helper function to print readable light names in console
    function [47:0] light_name;
        input [2:0] light;
        begin
            case (light)
                RED:     light_name = "RED   ";
                YELLOW:  light_name = "YELLOW";
                GREEN:   light_name = "GREEN ";
                default: light_name = "ERROR ";
            endcase
        end
    endfunction

    // Both roads must NEVER be Green simultaneously
    always @(posedge clk) begin
        #0.1; 
        if (!rst && (road_a == GREEN) && (road_b == GREEN)) begin
            $display("[FAIL] Time %0.1f s: SAFETY VIOLATION - Both roads are GREEN!", $realtime);
            errors = errors + 1;
        end
    end

    // Task to verify expected outputs and exact state duration
    task check_state;
        input [2:0] exp_a;
        input [2:0] exp_b;
        input integer duration_sec;
        input [159:0] state_label;
        integer i;
        begin
            $display("--- Checking %0s (Expected: A=%0s, B=%0s for %0d s) ---",
                     state_label, light_name(exp_a), light_name(exp_b), duration_sec);
            for (i = 1; i <= duration_sec; i = i + 1) begin
                if (road_a !== exp_a || road_b !== exp_b) begin
                    $display("[FAIL] Time %0t s (Sec %0d/%0d): Got A=%0s B=%0s | Expected A=%0s B=%0s",
                             $time, i, duration_sec,
                             light_name(road_a), light_name(road_b),
                             light_name(exp_a), light_name(exp_b));
                    errors = errors + 1;
                end else begin
                    $display("[PASS] Time %0t s (Sec %0d/%0d): Road A = %0s | Road B = %0s",
                             $time, i, duration_sec, light_name(road_a), light_name(road_b));
                end
                @(posedge clk);
                #0.1; 
            end
        end
    endtask

    // Main Simulation Sequence
    initial begin
       
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light_controller);

        $display("=========================================================");
        $display("   Starting Digital Traffic Light Controller Simulation  ");
        $display("=========================================================");

        
        rst = 1;
        @(posedge clk);
        #0.1;
      
        @(negedge clk);
        rst = 0;

       sing reset on the falling edge
        check_state(GREEN,  RED,    10, "State 1 (Cycle 1)");
        check_state(YELLOW, RED,     3, "State 2 (Cycle 1)");
        check_state(RED,    GREEN,  10, "State 3 (Cycle 1)");
        check_state(RED,    YELLOW,  3, "State 4 (Cycle 1)");

      
        $display("=========================================================");
        $display("   Verifying Continuous Loop-Back to State 1 (Cycle 2)   ");
        $display("=========================================================");
        check_state(GREEN,  RED,    10, "State 1 (Cycle 2)");
        check_state(YELLOW, RED,     3, "State 2 (Cycle 2)");

        
        $display("=========================================================");
        if (errors == 0) begin
            $display("   SIMULATION PASSED: 0 errors detected!                 ");
        end else begin
            $display("   SIMULATION FAILED: %0d error(s) detected.             ", errors);
        end
        $display("=========================================================");

        $finish;
    end

endmodule