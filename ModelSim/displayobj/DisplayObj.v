module DisplayObj(
    CLOCK_50, rstn, startn, up, left, down, right, LEDR,
    VGA_X_Pos, VGA_Y_Pos, VGA_Color, VGA_Plot_EN, // VGA adapter input
    Obj_Init_X, Obj_Init_Y, // Object position
    Obj_Memory_Color, Memory_XC, Memory_YC, // Outputs for external memory module
    enemy_bullet_X, enemy_bullet_Y, game_over_en
);

    input CLOCK_50;
    input rstn, startn;
    input up, down, left, right;
    output [3:0] LEDR;

    ////////////////////////////// Input from bullet.v ////////////////////////////////
    input [8:0] enemy_bullet_X;
    input [7:0] enemy_bullet_Y;

    //////////////////////////// Output Declarations /////////////////////////////////
    output game_over_en;
    output [8:0] VGA_X_Pos; // Wired to VGA_X
    output [7:0] VGA_Y_Pos; // Wired to VGA_Y
    output [2:0] VGA_Color; // Wired to VGA_COLOR
    output VGA_Plot_EN;     // Wired to plot_enable

    output [8:0] Obj_Init_X; // Return the current x location of the object
    output [7:0] Obj_Init_Y; // Return the current y location of the object
    input [2:0] Obj_Memory_Color;

    output [4:0] Memory_XC;  // Wired out to the memory XC
    output [4:0] Memory_YC;  // Wired out to the memory YC

    ////////////////////////////// Wire Declarations /////////////////////////////////
    wire x_match, y_match, paint_done, move_enable;
    wire go_down, go_up, go_left, go_right;
    wire v_enable, h_enable, upDn, LeftRight, plot_enable, erase_enable;
    wire [8:0] newX_Loc, oldX_Loc;
    wire [7:0] newY_Loc, oldY_Loc;
    wire [4:0] XC, YC;
    wire YCincrement;

    /////////////////////////////// Collision Logic ///////////////////////////////////
    assign x_match = (VGA_X_Pos == enemy_bullet_X) ? 1 : 0;
    assign y_match = (VGA_Y_Pos == enemy_bullet_Y) ? 1 : 0;
    assign game_over_en = x_match && y_match;

    ////////////////////////////// Parameter Definitions /////////////////////////////
    parameter [8:0] X_init_loc = 9'd160;
    parameter [7:0] Y_init_loc = 8'd120;
    parameter User1OrUser2 = 1'b1; // 0 -> user1, 1 -> user2

    ////////////////////////////// New Assignments ///////////////////////////////////
    assign VGA_X_Pos = oldX_Loc + XC;
    assign VGA_Y_Pos = oldY_Loc + YC;
    assign VGA_Plot_EN = plot_enable;
    assign Obj_Init_X = oldX_Loc;
    assign Obj_Init_Y = oldY_Loc;

    assign Memory_XC = XC;
    assign Memory_YC = YC;

    ////////////////////////////// Input Control Signals /////////////////////////////
    assign go_down = down;
    assign go_up = up;
    assign go_left = left;
    assign go_right = right;
    assign move_enable = go_down || go_up || go_left || go_right;

    assign paint_done = (YC == 5'b11111 && XC == 5'b11111);

    ////////////////////////////// LEDs for Debugging ///////////////////////////////
    assign LEDR[0] = go_down;
    assign LEDR[1] = go_up;
    assign LEDR[2] = go_left;
    assign LEDR[3] = go_right;

    //////////////////////////// Instantiated Submodules ////////////////////////////
    regn X_InitialLOC (newX_Loc, rstn, CLOCK_50, oldX_Loc);
        defparam X_InitialLOC.n = 9;
        defparam X_InitialLOC.rst_Loc = X_init_loc;

    regn Y_InitialLOC (newY_Loc, rstn, CLOCK_50, oldY_Loc);
        defparam Y_InitialLOC.n = 8;
        defparam Y_InitialLOC.rst_Loc = Y_init_loc;

    updownCounter CounterUpDn(oldY_Loc, v_enable, upDn, rstn, CLOCK_50, newY_Loc);
        defparam CounterUpDn.rst_Loc = Y_init_loc;

    leftrightConter CounterLR(oldX_Loc, h_enable, LeftRight, rstn, CLOCK_50, newX_Loc);
        defparam CounterLR.rst_Loc = X_init_loc;

    colorSelection_MUX Color_MUX(Obj_Memory_Color, erase_enable, VGA_Color);

    animationFSM FSM(CLOCK_50,
        paint_done, move_enable, rstn, startn, go_down, go_up, go_left, go_right, oldX_Loc, oldY_Loc,
        v_enable, h_enable, upDn, LeftRight, plot_enable, erase_enable, idling
    );

    count_obj X_count (CLOCK_50, rstn, plot_enable, XC);
    count_obj Y_count (CLOCK_50, rstn, YCincrement, YC);
    assign YCincrement = (XC == 5'b11111);

endmodule

module regn(R, Resetn, Clock, Q);
    parameter n = 8;
    parameter rst_Loc = 8'd160;

    input [n-1:0] R;
    input Resetn, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= rst_Loc;
        else
            Q <= R;
endmodule

module updownCounter(oldY_loc, V_enable, UpDn, rstn, clock, newY_Loc);
    parameter rst_Loc = 9'd160;

    input [7:0] oldY_loc;
    input V_enable, UpDn, rstn, clock;
    output reg [7:0] newY_Loc;

    wire slow;
    reg [20:0] fast;

    always @(posedge clock, negedge rstn) begin
        if (!rstn)
            fast <= 20'd255;
        else if (slow)
            fast <= 20'd255;
        else
            fast <= fast - 1'b1;
    end

    assign slow = (fast == 20'b0) ? 1 : 0;

    always @(posedge clock, negedge rstn) begin
        if (!rstn)
            newY_Loc <= rst_Loc;
        else if (V_enable && slow)
            newY_Loc <= oldY_loc + (UpDn ? 1 : -1);
    end
endmodule

module leftrightConter(oldX_loc, H_enable, LeftRight, rstn, clock, newX_Loc);
    parameter rst_Loc = 9'd160;

    input [8:0] oldX_loc;
    input H_enable, LeftRight, rstn, clock;
    output reg [8:0] newX_Loc;

    wire slow;
    reg [20:0] fast;

    always @(posedge clock, negedge rstn) begin
        if (!rstn)
            fast <= 20'd255;
        else if (slow)
            fast <= 20'd255;
        else
            fast <= fast - 1'b1;
    end

    assign slow = (fast == 20'b0) ? 1 : 0;

    always @(posedge clock, negedge rstn) begin
        if (!rstn)
            newX_Loc <= rst_Loc;
        else if (H_enable && slow)
            newX_Loc <= oldX_loc + (LeftRight ? 1 : -1);
    end
endmodule

module slow_clock(CLOCK_50, rstn, slow_clock);
    input CLOCK_50, rstn;
    output slow_clock;

    reg [20:0] fast;

    always @(posedge CLOCK_50, negedge rstn) begin
        if (!rstn)
            fast <= 20'd255;
        else if (slow_clock)
            fast <= 20'd255;
        else
            fast <= fast - 1'b1;
    end

    assign slow_clock = (fast == 20'b0) ? 1 : 0;
endmodule

module count_obj(Clock, Resetn, Enable, Q);
    parameter n = 5;

    input Clock, Resetn, Enable;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (Enable)
            Q <= Q + 1;
endmodule

module animationFSM(
    CLOCK_50, paint_done, move_enable, rstn, startn, go_down, go_up, go_left, go_right,
    Obj_Init_X, Obj_Init_Y, v_enable, h_enable, upDn, LeftRight, plot_enable, erase_enable, idle_sig
);
    // Signal and parameter declarations at the top
    input CLOCK_50, paint_done, move_enable, rstn, startn, go_down, go_up, go_left, go_right;
    input [8:0] Obj_Init_X;
    input [7:0] Obj_Init_Y;

    output v_enable, h_enable, upDn, LeftRight, plot_enable, erase_enable, idle_sig;

    reg control_sig, goD, goU, goL, goR;
    reg move_en;
    reg [6:0] y, Y;

    parameter [6:0] Sidle = 7'b0000001, Sdraw = 7'b0000010, Serase = 7'b0000100, 
                     Sdown = 7'b0001000, Sup = 7'b0010000, Sleft = 7'b0100000, Sright = 7'b1000000;

    wire signal_uni;
    assign signal_uni = (goD && ~goU && ~goL && ~goR) || (~goD && goU && ~goL && ~goR) || 
                        (~goD && ~goU && goL && ~goR) || (~goD && ~goU && ~goL && goR);

    always @(y, paint_done, move_enable, rstn, startn, goD, goU, goL, goR) begin
        case (y)
            Sidle: if (startn) Y = Sdraw;
            Sdraw: if (move_en && paint_done && signal_uni) Y = Serase; else Y = Sdraw;
            Serase: if (paint_done == 1 && Obj_Init_X == 9'd2 && goL) Y = Sdraw;
                    else if (paint_done == 1 && Obj_Init_X == 9'd287 && goR) Y = Sdraw;
                    else if (paint_done == 1 && Obj_Init_Y == 8'd1 && goD) Y = Sdraw;
                    else if (paint_done == 1 && Obj_Init_Y == 8'd177 && goU) Y = Sdraw;
                    else if (paint_done == 1 && (Obj_Init_X == 8'd127 && goR) || (Obj_Init_X == 8'd160 && goL)) Y = Sdraw;
                    else if (paint_done == 1 && goD && ~goU && ~goL && ~goR) Y = Sdown;
                    else if (paint_done == 1 && ~goD && goU && ~goL && ~goR) Y = Sup;
                    else if (paint_done == 1 && ~goD && ~goU && goL && ~goR) Y = Sleft;
                    else if (paint_done == 1 && ~goD && ~goU && ~goL && goR) Y = Sright;
                    else Y = Serase;
            Sdown: Y = Sdraw;
            Sup: Y = Sdraw;
            Sleft: Y = Sdraw;
            Sright: Y = Sdraw;
            default: Y = Sidle;
        endcase
    end

    assign draw_state_output = y[1];

    // Control signal register
    always @(posedge CLOCK_50, negedge rstn) begin
        if (!rstn) begin
            control_sig <= 1'b0;
            goD <= 1'b0;
            goU <= 1'b0;
            goL <= 1'b0;
            goR <= 1'b0;
        end else if (draw_state_output) begin
            goD <= go_down;
            goU <= go_up;
            goL <= go_left;
            goR <= go_right;
        end
    end

    always @(posedge CLOCK_50) begin
        if (draw_state_output && move_enable)
            move_en <= 1'b1;
        else if (!draw_state_output)
            move_en <= 1'b0;
    end

    // Current and next state logic
    always @(posedge CLOCK_50, negedge rstn) begin
        if (!rstn)
            y <= Sidle;
        else
            y <= Y;
    end

    // Output logic
    assign v_enable = y[3] || y[4];
    assign h_enable = y[5] || y[6];
    assign upDn = y[4];
    assign LeftRight = y[6];
    assign plot_enable = y[1] || y[2];
    assign erase_enable = y[2];
    assign idle_sig = y[0];

endmodule

module colorSelection_MUX(mem_RGB, s, out_RGB);
    input [2:0] mem_RGB;
    input s;
    output [2:0] out_RGB;

    assign out_RGB = (s == 1'b1) ? 3'b111 : mem_RGB;
endmodule
