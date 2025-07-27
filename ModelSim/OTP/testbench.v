`timescale 1ns/1ps

module testbench;

    // Inputs
    reg CLOCK_50;
    reg rstn;
    reg [2:0] User1_VGA_color, User2_VGA_color;
    reg [2:0] U1_B1_color, U1_B2_color, U1_B3_color, U2_B1_color, U2_B2_color, U2_B3_color;
    reg [8:0] User1_VGA_X, User2_VGA_X, U1_B1_X, U1_B2_X, U1_B3_X, U2_B1_X, U2_B2_X, U2_B3_X;
    reg [7:0] User1_VGA_Y, User2_VGA_Y, U1_B1_Y, U1_B2_Y, U1_B3_Y, U2_B1_Y, U2_B2_Y, U2_B3_Y;
    reg User1_plot_enable, User2_plot_enable;
    reg U1_B1_plot_enable, U1_B2_plot_enable, U1_B3_plot_enable, U2_B1_plot_enable, U2_B2_plot_enable, U2_B3_plot_enable;

    // Outputs
    wire [8:0] VGA_X;
    wire [7:0] VGA_Y;
    wire plot_enable;
    wire [2:0] VGA_COLOR;

    // Internal wires (for debugging purposes)
    wire [2:0] display_indicator;        // Tracks the current display phase
    wire [5:0] bullet_display_indicator; // Tracks which bullet is being displayed
    wire bullet_display_en;              // Bullet display enable
    wire [9:0] fast;                     // Counter for the main clock (1024 cycles)
    wire [6:0] bullet_fast;              // Counter for bullet display (128 cycles)
    wire bullet_slow;                    // Trigger for bullet display shifts

    // Instantiate the DUT (Device Under Test)
    Object_To_Paint_Selector DUT (
        .CLOCK_50(CLOCK_50),
        .rstn(rstn),
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
        .U1_B2_color(U1_B2_color),
        .U1_B2_X(U1_B2_X),
        .U1_B2_Y(U1_B2_Y),
        .U1_B2_plot_enable(U1_B2_plot_enable),
        .U1_B3_color(U1_B3_color),
        .U1_B3_X(U1_B3_X),
        .U1_B3_Y(U1_B3_Y),
        .U1_B3_plot_enable(U1_B3_plot_enable),
        .U2_B1_color(U2_B1_color),
        .U2_B1_X(U2_B1_X),
        .U2_B1_Y(U2_B1_Y),
        .U2_B1_plot_enable(U2_B1_plot_enable),
        .U2_B2_color(U2_B2_color),
        .U2_B2_X(U2_B2_X),
        .U2_B2_Y(U2_B2_Y),
        .U2_B2_plot_enable(U2_B2_plot_enable),
        .U2_B3_color(U2_B3_color),
        .U2_B3_X(U2_B3_X),
        .U2_B3_Y(U2_B3_Y),
        .U2_B3_plot_enable(U2_B3_plot_enable),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .plot_enable(plot_enable),
        .VGA_COLOR(VGA_COLOR)
    );

    // Assign internal DUT signals to testbench wires for debugging
    assign display_indicator = DUT.display_indicator;
    assign bullet_display_indicator = DUT.bullet_display_indicator;
    assign bullet_display_en = DUT.bullet_display_en;
    assign fast = DUT.fast;
    assign bullet_fast = DUT.bullet_fast;
    assign bullet_slow = DUT.bullet_slow;

    // Clock generation
    always #10 CLOCK_50 = ~CLOCK_50;  // 50 MHz clock (20 ns period)

    // Testbench procedure
    initial begin
        // Initialize inputs
        CLOCK_50 = 0;
        rstn = 0;

        // Initialize object and bullet values
        User1_VGA_color = 3'b001;
        User2_VGA_color = 3'b010;
        U1_B1_color = 3'b100;
        U1_B2_color = 3'b011;
        U1_B3_color = 3'b110;
        U2_B1_color = 3'b111;
        U2_B2_color = 3'b000;
        U2_B3_color = 3'b101;

        User1_VGA_X = 9'd10;
        User1_VGA_Y = 8'd20;
        User2_VGA_X = 9'd30;
        User2_VGA_Y = 8'd40;

        U1_B1_X = 9'd50;
        U1_B1_Y = 8'd60;
        U1_B2_X = 9'd70;
        U1_B2_Y = 8'd80;
        U1_B3_X = 9'd90;
        U1_B3_Y = 9'd100;

        U2_B1_X = 9'd110;
        U2_B1_Y = 8'd120;
        U2_B2_X = 9'd130;
        U2_B2_Y = 9'd140;
        U2_B3_X = 9'd150;
        U2_B3_Y = 9'd160;

        User1_plot_enable = 1'b1;
        User2_plot_enable = 1'b0;
        U1_B1_plot_enable = 1'b0;
        U1_B2_plot_enable = 1'b0;
        U1_B3_plot_enable = 1'b0;
        U2_B1_plot_enable = 1'b0;
        U2_B2_plot_enable = 1'b0;
        U2_B3_plot_enable = 1'b0;

        // Reset the system
        #50 rstn = 1;

        // Monitor signals
        $monitor("Time=%t | display_indicator=%b | bullet_display_indicator=%b | bullet_display_en=%b | fast=%d | bullet_fast=%d | bullet_slow=%b", 
                 $time, display_indicator, bullet_display_indicator, bullet_display_en, fast, bullet_fast, bullet_slow);

        // Test for multiple cycles to observe behavior
        repeat(50) begin
            #10240;  // Wait to observe each full phase of display_indicator
        end

        // End simulation
        $stop;
    end

endmodule
