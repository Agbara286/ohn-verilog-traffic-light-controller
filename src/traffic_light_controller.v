module traffic_light_controller #(
    parameter T_A_GREEN  = 10,   
    parameter T_A_YELLOW = 3,    
    parameter T_B_GREEN  = 10,   
    parameter T_B_YELLOW = 3     
)(
    input  wire clk,             
    input  wire rst,             
    output reg  [2:0] road_a,    //[2]=Red, [1]=Yellow, [0]=Green
    output reg  [2:0] road_b
);

    // State encoding
    localparam S_A_GREEN  = 2'b00,
               S_A_YELLOW = 2'b01,
               S_B_GREEN  = 2'b10,
               S_B_YELLOW = 2'b11;

    reg [1:0] state, next_state;
    reg [7:0] timer;

    // Sequential logic = state + timer
    always @(posedge clk) begin
        if (rst) begin
            state <= S_A_GREEN;
            timer <= 0;
        end
        else begin
            state <= next_state;

            if (state != next_state)
                timer <= 0;
            else
                timer <= timer + 1'b1;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;

        case (state)
            S_A_GREEN:  if (timer >= T_A_GREEN  - 1) next_state = S_A_YELLOW;
            S_A_YELLOW: if (timer >= T_A_YELLOW - 1) next_state = S_B_GREEN;
            S_B_GREEN:  if (timer >= T_B_GREEN  - 1) next_state = S_B_YELLOW;
            S_B_YELLOW: if (timer >= T_B_YELLOW - 1) next_state = S_A_GREEN;
            default:    next_state = S_A_GREEN;
        endcase
    end

    always @(*) begin
        case (state)
            S_A_GREEN: begin
                road_a = 3'b001;  // Green
                road_b = 3'b100;  // Red
            end
            S_A_YELLOW: begin
                road_a = 3'b010;  // Yellow
                road_b = 3'b100;  // Red
            end
            S_B_GREEN: begin
                road_a = 3'b100;  // Red
                road_b = 3'b001;  // Green
            end
            S_B_YELLOW: begin
                road_a = 3'b100;  // Red
                road_b = 3'b010;  // Yellow
            end
            default: begin
                road_a = 3'b100;
                road_b = 3'b100;
            end
        endcase
    end

endmodule