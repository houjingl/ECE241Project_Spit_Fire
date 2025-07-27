module CosmicClash(CLOCK_50, KEY, LEDR,
				PS2_CLK,PS2_DAT, //For keyboard
        		VGA_R, VGA_G, VGA_B, //VGA adapter required
				VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

   input CLOCK_50;
	input [3:0]	KEY;
	
	output [9:0] LEDR;

	inout PS2_CLK;
	inout PS2_DAT;

	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;	

	//The main game logic 
	//FSM for the home page
	wire start_game_en, end_game_en, end_over, paint_done;//input
	wire game_display_en, home_plot_en, end_plot_en, erase_home_en; //output 
	
	
	assign start_game_en = start_game;
	
	gamestate_FSM Main_Game_Logic (CLOCK_50, rstn, start_game_en, user1_game_over_en, user2_game_over_en, end_over, paint_done,//input
											game_display_en, home_plot_en, end_plot_en, erase_home_en, user1_win, user2_win);//output
	
	//Counter for drawing the home page
	//home page is 318 * 208 total of 66144 pixels
	//print starting point (2, 2)
	//module count (Clock, Resetn, Enable, Q);
	//module regn(R, Resetn, Clock, Q);
	wire [8:0] XC;
	wire [7:0] YC;
	wire Y_inc;
	assign Y_inc = (XC == 9'd320);
	assign paint_done = (YC == 8'd240);
	
	counter counterX (CLOCK_50, rstn, (Y_inc | start_game_en), ~game_display_en, XC); // could be problematic to use start game en as load
		defparam counterX.n = 9;
	counter counterY (CLOCK_50, rstn, (paint_done | start_game_en), Y_inc, YC);
		defparam counterY.n = 8;
	
	wire [2:0] home_color, game_color, background_Color;
	reg [2:0] endgame_color;
	ColorSelect backgroundColorSelect (CLOCK_50, home_color, game_color, endgame_color, home_plot_en, end_plot_en, erase_home_en, background_Color);
	
	wire [2:0] User1_end_color, User2_end_color;
	homepage homepage_mem (YC * 320 + XC, CLOCK_50, 3'b0, 1'b0, home_color);
	gamebackground gamebackground_mem (YC * 320 + XC, CLOCK_50, 3'b0, 1'b0, game_color);
	User1End userEndGame (YC * 320 + XC, CLOCK_50, 3'b0, 1'b0, User1_end_color);
	User2End user2EndGame (YC * 320 + XC, CLOCK_50, 3'b0, 1'b0, User2_end_color);

	always@(posedge CLOCK_50) begin
		if (user1_win)
			endgame_color <= User1_end_color;
		else if (user2_win)
			endgame_color <= User2_end_color;
	end
	
	////////////////////////keyboard module//////////////////////////
	wire up1, left1, down1, right1, up2, left2, down2, right2, fire1, fire2, start_game;
	assign LEDR[0] = up1;
	assign LEDR[1] = left1;
	assign LEDR[2] = down1;
	assign LEDR[3] = right1;
	new_keyboard keyboard(~rstn, CLOCK_50, PS2_CLK, PS2_DAT, up1, left1, down1, right1, up2, left2, down2, right2, fire2, fire1, start_game);
	
	/////////////////////////////////////////////////////////////////	
	
	five_sec_counter counter5s (CLOCK_50, end_plot_en, end_over);
	
    //Bullet
    //module Bullet(CLOCK_50, rstn, fire, gunLoc_X, gunLoc_Y, leftRight,
    //            plot_EN, bulletLoc_X, bulletLoc_Y, bullet_color);
//module Bullet(CLOCK_50, rstn, fire, gunLoc_X, gunLoc_Y, leftRight,//input
//                plot_EN, bulletLoc_X, bulletLoc_Y, bullet_color);//output
    wire [2:0] U1_B1_color;
    wire [8:0] U1_B1_X;
    wire [7:0] U1_B1_Y;
    wire U1_B1_plot_enable;

    Bullet U1_B1 (CLOCK_50, rstn, ~fire1, User1_init_X + 16, User1_init_Y + 16, 1'b1,
                U1_B1_plot_enable, U1_B1_X, U1_B1_Y, U1_B1_color);
					 
		//User2 bullets
    wire [2:0] U2_B1_color;
    wire [8:0] U2_B1_X;
    wire [7:0] U2_B1_Y;
    wire U2_B1_plot_enable;

	////////ADD GUNLOC RELATIVE TO XLOC AND YLOC

Bullet U2_B1 (CLOCK_50, rstn, ~fire2, User2_init_X, User2_init_Y + 16, 1'b0,
                U2_B1_plot_enable, U2_B1_X, U2_B1_Y, U2_B1_color);


	//User 1
   wire [4:0] User1_XC;
   wire [4:0] User1_YC;
   wire [2:0] User1_memoryColor;
	wire [2:0] User1_VGA_color;
	wire [8:0] User1_VGA_X;
	wire [7:0] User1_VGA_Y;
	wire User1_plot_enable;
	wire [8:0] User1_init_X;
	wire [7:0] User1_init_Y;
	wire user1_game_over_en;
   //Memory for User1 Object
	
	wire [3:0] dummy1, dummy2;
	
   User1 U1RedPlane ({User1_YC, User1_XC}, CLOCK_50, 3'b0, 1'b0, User1_memoryColor);
	DisplayObj User1 (CLOCK_50, ~home_plot_en, start_game_en, down1, left1, up1, right1, dummy1,
					  User1_VGA_X, User1_VGA_Y, User1_VGA_color, User1_plot_enable,
					  User1_init_X, User1_init_Y,
					  User1_memoryColor, User1_XC, User1_YC,
					  U2_B1_X, U2_B1_Y, user1_game_over_en
					  );
					  defparam User1.User1OrUser2 = 1'b0;
					  defparam User1.X_init_loc = 9'd2;
					  defparam User1.Y_init_loc = 8'd2;

	
	
	//User 2
   wire [4:0] User2_XC;
   wire [4:0] User2_YC;
   wire [2:0] User2_memoryColor;
	wire [2:0] User2_VGA_color;
	wire [8:0] User2_VGA_X;
	wire [7:0] User2_VGA_Y;
	wire User2_plot_enable;
	wire [8:0] User2_init_X;
	wire [7:0] User2_init_Y;
	wire user2_game_over_en;
   //Memory for User2 Object
   User2 U2 ({User2_YC, User2_XC}, CLOCK_50, 3'b0, 1'b0, User2_memoryColor);
	DisplayObj User2 (CLOCK_50,~home_plot_en, start_game_en, down2, left2, up2, right2, dummy2,
					  User2_VGA_X, User2_VGA_Y, User2_VGA_color, User2_plot_enable,
					  User2_init_X, User2_init_Y,
					  User2_memoryColor, User2_XC, User2_YC,
					  U1_B1_X, U1_B1_Y, user2_game_over_en
					  );
					  defparam User2.User1OrUser2 = 1'b1;
					  defparam User2.X_init_loc = 9'd287;
					  defparam User2.Y_init_loc = 8'd177;

    wire [6:0] bullet_display_indicator;

	Object_To_Paint_Selector OTPMUX (CLOCK_50, rstn, background_Color, game_display_en, XC, YC,
								User1_VGA_color, User1_VGA_X, User1_VGA_Y, User1_plot_enable,
                        User2_VGA_color, User2_VGA_X, User2_VGA_Y, User2_plot_enable,
								U1_B1_color, U1_B1_X, U1_B1_Y, U1_B1_plot_enable, U2_B1_color, U2_B1_X,
								U2_B1_Y, U2_B1_plot_enable, VGA_X, VGA_Y, plot_enable, VGA_COLOR);

    //VGA Adapter
	wire [8:0] VGA_X;
	wire [7:0] VGA_Y;
	wire [2:0] VGA_COLOR;
	wire plot_enable;
	wire rstn;
	
	assign rstn = KEY[0];
	
	//PS2 keyboard
	wire [7:0]	ps2_key_data;
	wire ps2_key_pressed;

	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);
	
    vga_adapter VGA1 (
		.resetn(rstn),
		.clock(CLOCK_50),
      .colour(VGA_COLOR),
		.x(VGA_X),
		.y(VGA_Y),
		.plot(plot_enable/*plot_enable*/),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA1.RESOLUTION = "320x240";
	defparam VGA1.MONOCHROME = "FALSE";
	defparam VGA1.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA1.BACKGROUND_IMAGE = "ult.mif";

endmodule

module Object_To_Paint_Selector(CLOCK_50, rstn, background_color, game_display_en, XC, YC,
								User1_VGA_color, User1_VGA_X, User1_VGA_Y, User1_plot_enable,
                        User2_VGA_color, User2_VGA_X, User2_VGA_Y, User2_plot_enable,
								U1_B1_color, U1_B1_X, U1_B1_Y, U1_B1_plot_enable, U2_B1_color, U2_B1_X,
								U2_B1_Y, U2_B1_plot_enable, VGA_X, VGA_Y, plot_enable, VGA_COLOR);
    wire [2:0] U2_B1_color;
    wire [8:0] U2_B1_X;
    wire [7:0] U2_B1_Y;
    wire U2_B1_plot_enable;

	input [2:0] background_color;/////////////////
	input game_display_en;/////////////////////
	input [8:0] XC;
	input [7:0] YC;
	
	input [2:0] User1_VGA_color, User2_VGA_color, U1_B1_color, U2_B1_color;
	input [8:0] User1_VGA_X, User2_VGA_X, U1_B1_X, U2_B1_X;
	input [7:0] User1_VGA_Y, User2_VGA_Y, U1_B1_Y, U2_B1_Y;
	input User1_plot_enable, User2_plot_enable;
	input U1_B1_plot_enable, U2_B1_plot_enable;

	input CLOCK_50;
	input rstn;

	output reg [8:0] VGA_X;
	output reg [7:0] VGA_Y;
	output reg plot_enable;
	output reg [2:0] VGA_COLOR;
	
	reg [14:0] fast;
	always@ (posedge CLOCK_50, negedge rstn)
	begin
		if(rstn == 1'b0)
			fast <= 15'b111111111111111;
		else if(slow_clock_trigger == 1'b1)//
			fast <= 15'b111111111111111;
		else
			fast <= fast - 1'b1;
	end

	wire slow_clock_trigger;
	assign slow_clock_trigger = (fast == 10'b0) ? 1:0;
// Rotational shift reg for large clock period
	reg [3:0] display_indicator;
	parameter [3:0] default_set = 3'b0001;
	
	always @ (posedge CLOCK_50, negedge rstn) begin
		if (!rstn)
			display_indicator <= default_set;
		else if (slow_clock_trigger)
			display_indicator <= {display_indicator[0], display_indicator[3:1]};
	end
	
// For selecting which object to display
	parameter [3:0] obj1 = 3'b0001, obj2 = 3'b0010, U1bullet1 = 3'b0100, U2bullet1 = 4'b1000;
	reg [0:0] bullet_display_en;

  	always @(posedge CLOCK_50)begin
		if(game_display_en) begin
			if(display_indicator == obj1) begin
				VGA_X <= User1_VGA_X;
				VGA_Y <= User1_VGA_Y;
				plot_enable <= User1_plot_enable;
				VGA_COLOR <= User1_VGA_color;		
				bullet_display_en <= 1'b0;	
			end
			else if (display_indicator == obj2) begin
				VGA_X <= User2_VGA_X;
				VGA_Y <= User2_VGA_Y;
				plot_enable <= User2_plot_enable;
				VGA_COLOR <= User2_VGA_color;
				bullet_display_en <= 1'b0;				
			end
			else if (display_indicator == U1bullet1) begin
				bullet_display_en <= 1'b1; // enabling the bullet shift reg and clock
				VGA_X <= U1_B1_X;
				VGA_Y <= U1_B1_Y;
				plot_enable <= U1_B1_plot_enable;
				VGA_COLOR <= U1_B1_color;
			end	
			else if (display_indicator == U2bullet1) begin
				bullet_display_en <= 1'b1; // enabling the bullet shift reg and clock
				VGA_X <= U2_B1_X;
				VGA_Y <= U2_B1_Y;
				plot_enable <= U2_B1_plot_enable;
				VGA_COLOR <= U2_B1_color;
			end		
		end
		else begin
			VGA_COLOR <= background_color;
			VGA_X <= XC;
			VGA_Y <= YC;
			plot_enable <= 1'b1;
		end
	end
	
endmodule

module gamestate_FSM(CLOCK_50, rstn, start_game_en, user1_end_game_en, user2_end_game_en, end_over, paint_done,//input
                    game_display_en, home_plot_en, end_plot_en, erase_home_en, user1_win, user2_win);//output

    input CLOCK_50, rstn;
    input start_game_en, end_over, paint_done, user1_end_game_en, user2_end_game_en;

    output game_display_en, home_plot_en, end_plot_en, erase_home_en, user1_win, user2_win;

    parameter[4:0] Shome = 4'b0001, ShomeErase = 4'b0010, Sgame = 4'b0100, Su1end = 5'b01000, Su2end = 5'b10000;
    reg [4:0] y, Y;

    always@ (posedge CLOCK_50, negedge rstn)
    begin
				if (!rstn)
					y <= Shome;
				else
					y <= Y;  
    end

    always@ (y, start_game_en, user1_end_game_en, user2_end_game_en, end_over, paint_done)
    begin
        case(y)
            Shome: if(start_game_en) Y = ShomeErase;
                    else Y = Shome;
			ShomeErase: if(paint_done) Y = Sgame;
							else Y = ShomeErase;
            Sgame: if(user1_end_game_en) Y = Su2end;
					else if (user2_end_game_en) Y = Su1end;
                    else Y = Sgame;
            Su1end: if(end_over) Y = Shome;
                    else Y = Su1end;
			Su2end: if(end_over) Y = Shome;
					else Y = Su2end;

            default: Y = Shome;
        endcase
    end
	 
	 assign home_plot_en = y[0];
	 assign erase_home_en = y[1];
	 assign game_display_en = y[2];
	 assign end_plot_en = y[3] || y[4];
	 assign user1_win = y[3];
	 assign user2_win = y[4];
endmodule

module five_sec_counter(CLOCK_50, enable, end_over);

    input CLOCK_50, enable;
    output end_over;
    reg [29:0] Q;

    always@ (posedge CLOCK_50)
    begin
        if(end_over)
            Q <= 28'd250000000;
        else if (enable)
            Q <= Q - 1'b1;
    end

    assign end_over = (Q == 28'b0)? 1:0;
endmodule

module counter (Clock, Resetn, load, Enable, Q);

//Citation: This module is modified based on the count module in the vga_demo of VGA animation made by Prof. Brown

//To count X_currentLoc, n = 5
//To count Y_currentLoc, n = 5

    parameter n = 5;
    input Clock, Resetn, load, Enable;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
		  else if (load)
				Q <= 0;
        else if (Enable)
            Q <= Q + 1;
endmodule

module ColorSelect(CLOCK_50, home_color, game_color, endgame_color, home_plot_en, end_plot_en, erase_home_en, VGA_Color);

	input home_plot_en, end_plot_en, erase_home_en, CLOCK_50;
	input [2:0] home_color, game_color, endgame_color;
	output reg [2:0] VGA_Color;
	
	always@(posedge CLOCK_50) begin
		if (home_plot_en)
			VGA_Color <= home_color;
		else if (erase_home_en)
			VGA_Color <= game_color;
		else if (end_plot_en)
			VGA_Color <= endgame_color;
	end
endmodule


