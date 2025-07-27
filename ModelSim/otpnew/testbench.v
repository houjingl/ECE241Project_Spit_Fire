`timescale 1ns/1ps

module testbench;

    // Inputs
    reg CLOCK_50;
    reg rstn;
    reg [2:0] background_color;
    reg game_display_en;
    reg [8:0] XC;
    reg [7:0] YC;
    reg [2:0] User1_VGA_color, User2_VGA_color, U1_B1_color, U2_B1_color;
    reg [8:0] User1_VGA_X, User2_VGA_X, U1_B1_X, U2_B1_X;
    reg [7:0] User1_VGA_Y, User2_VGA_Y, U1_B1_Y, U2_B1_Y;
    reg User1_plot_enable, User2_plot_enable;
    reg U1_B1_plot_enable, U2_B1_plot_enable;

    // Outputs
    wire [8:0] VGA_X;
    wire [7:0] VGA_Y;
    wire plot_enable;
    wire [2:0] VGA_COLOR;

    // Internal signals for debugging
    wire [3:0] display_indicator;
    wire [14:0] fast;
    wire slow_clock_trigger;

    // Instantiate the DUT (Device Under Test)
    Object_To_Paint_Selector DUT (
        .CLOCK_50(CLOCK_50),
        .rstn(rstn),
        .background_color(background_color),
        .game_display_en(game_display_en),
        .XC(XC),
        .YC(YC),
        .User1_VGA_color(User1_VGA_color),
        .User1_VGA_X(User1_VGA_X),
        .User1_VGA_Y(User1_VGA_Y),
        .User1_plot_enable(User1_plot_enable),
        .User2_VGA_color(User2_VGA_color),
        .User2_VGA_X(User2_VGA_X),
        .User2_VGA_Y(User2_VGA_Y),
        .User2_plot_enable(User2_plot_enable),
        .U1_B1_color(U1_B1_color),
        .U1_B1_X(U1_B1_X),
        .U1_B1_Y(U1_B1_Y),
        .U1_B1_plot_enable(U1_B1_plot_enable),
        .U2_B1_color(U2_B1_color),
        .U2_B1_X(U2_B1_X),
        .U2_B1_Y(U2_B1_Y),
        .U2_B1_plot_enable(U2_B1_plot_enable),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .plot_enable(plot_enable),
        .VGA_COLOR(VGA_COLOR)
    );

    // Assign internal DUT signals for debugging
    assign display_indicator = DUT.display_indicator;
    assign fast = DUT.fast;
    assign slow_clock_trigger = DUT.slow_clock_trigger;

    // Clock generation
    always #10 CLOCK_50 = ~CLOCK_50; // Generate 50 MHz clock (20 ns period)

    // Testbench procedure
    initial begin
        // Initialize inputs
        CLOCK_50 = 0;
        rstn = 0;
        background_color = 3'b000;
        game_display_en = 0;
        XC = 9'd0;
        YC = 8'd0;

        User1_VGA_color = 3'b001;
        User1_VGA_X = 9'd10;
        User1_VGA_Y = 8'd20;
        User1_plot_enable = 1'b1;

        User2_VGA_color = 3'b010;
        User2_VGA_X = 9'd30;
        User2_VGA_Y = 8'd40;
        User2_plot_enable = 1'b0;

        U1_B1_color = 3'b011;
        U1_B1_X = 9'd50;
        U1_B1_Y = 8'd60;
        U1_B1_plot_enable = 1'b0;

        U2_B1_color = 3'b100;
        U2_B1_X = 9'd70;
        U2_B1_Y = 8'd80;
        U2_B1_plot_enable = 1'b0;

        // Apply reset
        #50 rstn = 1;

        // Enable game display and monitor outputs
        game_display_en = 1'b1;
        $monitor("Time=%t | VGA_X=%d, VGA_Y=%d, VGA_COLOR=%b, plot_enable=%b, display_indicator=%b, fast=%d", 
                 $time, VGA_X, VGA_Y, VGA_COLOR, plot_enable, display_indicator, fast);

        // Observe for multiple cycles
        repeat(50) begin
            #10240; // Wait for each display phase (based on slow_clock_trigger timing)
        end

        // End simulation
        $stop;
    end

endmodule
