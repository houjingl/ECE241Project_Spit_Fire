`timescale 1ns / 1ps

module testbench();

    reg CLOCK_50;
    reg rstn, startn, up, down, left, right;
    reg [2:0] Obj_Memory_Color;
    reg [8:0] enemy_bullet_X;
    reg [7:0] enemy_bullet_Y;

    wire [3:0] LEDR;
    wire [8:0] VGA_X_Pos;
    wire [7:0] VGA_Y_Pos;
    wire [2:0] VGA_Color;
    wire VGA_Plot_EN;
    wire [8:0] Obj_Init_X;
    wire [7:0] Obj_Init_Y;
    wire [4:0] Memory_XC;
    wire [4:0] Memory_YC;
    wire game_over_en;

    // Instantiate the DisplayObj module
    DisplayObj dut (
        .CLOCK_50(CLOCK_50),
        .rstn(rstn),
        .startn(startn),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .LEDR(LEDR),
        .VGA_X_Pos(VGA_X_Pos),
        .VGA_Y_Pos(VGA_Y_Pos),
        .VGA_Color(VGA_Color),
        .VGA_Plot_EN(VGA_Plot_EN),
        .Obj_Init_X(Obj_Init_X),
        .Obj_Init_Y(Obj_Init_Y),
        .Obj_Memory_Color(Obj_Memory_Color),
        .Memory_XC(Memory_XC),
        .Memory_YC(Memory_YC),
        .enemy_bullet_X(enemy_bullet_X),
        .enemy_bullet_Y(enemy_bullet_Y),
        .game_over_en(game_over_en)
    );

    // Clock generation
    always #10 CLOCK_50 = ~CLOCK_50; // 50 MHz clock

    initial begin
        // Initialize inputs
        CLOCK_50 = 0;
        rstn = 0;
        startn = 0;
        up = 0; down = 0; left = 0; right = 0;
        Obj_Memory_Color = 3'b000;
        enemy_bullet_X = 9'd50;
        enemy_bullet_Y = 8'd50;

        // Apply reset
        #20 rstn = 1;

        // Start simulation
        #20 startn = 1;

        // Move down
        #50 down = 1;
        #100 down = 0;

        // Move up
        #50 up = 1;
        #100 up = 0;

        // Move left
        #50 left = 1;
        #100 left = 0;

        // Move right
        #50 right = 1;
        #100 right = 0;

        // Simulate collision with bullet
        #50 enemy_bullet_X = 9'd160;
        enemy_bullet_Y = 8'd120;

        #50;
        $stop; // End simulation
    end

endmodule
