module Object_To_Paint_Selector(CLOCK_50, rstn,
								User1_VGA_color, User1_VGA_X, User1_VGA_Y, User1_plot_enable,
                        User2_VGA_color, User2_VGA_X, User2_VGA_Y, User2_plot_enable,
								U1_B1_color, U1_B1_X, U1_B1_Y, U1_B1_plot_enable,
								U1_B2_color, U1_B2_X, U1_B2_Y, U1_B2_plot_enable,
								U1_B3_color, U1_B3_X, U1_B3_Y, U1_B3_plot_enable,
								U2_B1_color, U2_B1_X, U2_B1_Y, U2_B1_plot_enable,
								U2_B2_color, U2_B2_X, U2_B2_Y, U2_B2_plot_enable,
								U2_B3_color, U2_B3_X, U2_B3_Y, U2_B3_plot_enable,
								VGA_X, VGA_Y, plot_enable, VGA_COLOR
                                );

	input [2:0] User1_VGA_color, User2_VGA_color, U1_B1_color, U1_B2_color, U1_B3_color, U2_B1_color, U2_B2_color, U2_B3_color;
	input [8:0] User1_VGA_X, User2_VGA_X, U1_B1_X, U1_B2_X, U1_B3_X, U2_B1_X, U2_B2_X, U2_B3_X;
	input [7:0] User1_VGA_Y, User2_VGA_Y, U1_B1_Y, U1_B2_Y, U1_B3_Y, U2_B1_Y, U2_B2_Y, U2_B3_Y;
	input User1_plot_enable, User2_plot_enable;
	input U1_B1_plot_enable, U1_B2_plot_enable, U1_B3_plot_enable;
	input U2_B1_plot_enable, U2_B2_plot_enable, U2_B3_plot_enable;

	input CLOCK_50;
	input rstn;

	output reg [8:0] VGA_X;
	output reg [7:0] VGA_Y;
	output reg plot_enable;
	output reg [2:0] VGA_COLOR;

    // register & selection for choosing which bullet object to diplay on to the VGA display
	parameter [5:0] user1_bullet1 = 6'b000001, user1_bullet2 = 6'b000010, user1_bullet3 = 6'b000100, 
					user2_bullet1 = 6'b001000, user2_bullet2 = 6'b010000, user2_bullet3 = 6'b100000;

    wire slow_clock_trigger;
    reg [9:0] fast;
	assign slow_clock_trigger = (fast == 10'b0) ? 1:0;
// Rotational shift reg for large clock period
	reg [2:0] display_indicator;
	parameter [2:0] default_set = 3'b001;

// For selecting which object to display
	parameter [2:0] obj1 = 3'b001, obj2 = 3'b010, bullets = 3'b100;
	reg [0:0] bullet_display_en;    

// Fast Clock for bullet display
	reg [6:0] bullet_fast; //load = 7'b1111111 = 128
	parameter [6:0] load = 7'b1111111;

	wire bullet_slow;
	assign bullet_slow = (bullet_fast == 7'b0) ? 1:0;
// Rotational Shift reg for displaying bullet objects
	reg [5:0] bullet_display_indicator;
	parameter [5:0] default_ = 6'b000001;
	
	always@ (posedge CLOCK_50, negedge rstn)
	begin
		if(rstn == 1'b0)
			fast <= 10'b1111111111;
		else if(slow_clock_trigger == 1'b1)//
			fast <= 10'b1111111111;
		else
			fast <= fast - 1'b1;
	end

	always @ (posedge CLOCK_50, negedge rstn) begin
		if (!rstn)
			display_indicator <= default_set;
		else if (slow_clock_trigger)
			display_indicator <= {display_indicator[0], display_indicator[2:1]};
	end

  	always @(posedge CLOCK_50)begin
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
		else if (display_indicator == bullets) begin
			bullet_display_en <= 1'b1; // enabling the bullet shift reg and clock
			if(bullet_display_indicator == user1_bullet1) begin
				VGA_X <= U1_B1_X;
				VGA_Y <= U1_B1_Y;
				plot_enable <= U1_B1_plot_enable;
				VGA_COLOR <= U1_B1_color;
			end
			else if (bullet_display_indicator == user1_bullet2) begin
				VGA_X <= U1_B2_X;
				VGA_Y <= U1_B2_Y;
				plot_enable <= U1_B2_plot_enable;
				VGA_COLOR <= U1_B2_color;				
			end
			else if (bullet_display_indicator == user1_bullet3) begin
				VGA_X <= U1_B3_X;
				VGA_Y <= U1_B3_Y;
				plot_enable <= U1_B3_plot_enable;
				VGA_COLOR <= U1_B3_color;			
			end
			else if (bullet_display_indicator == user2_bullet1) begin
				VGA_X <= U2_B1_X;
				VGA_Y <= U2_B1_Y;
				plot_enable <= U2_B1_plot_enable;
				VGA_COLOR <= U2_B1_color;				
			end
			else if (bullet_display_indicator == user2_bullet2) begin
				VGA_X <= U2_B2_X;
				VGA_Y <= U2_B2_Y;
				plot_enable <= U2_B2_plot_enable;
				VGA_COLOR <= U2_B2_color;					
			end
			else if (bullet_display_indicator == user2_bullet3) begin
				VGA_X <= U2_B3_X;
				VGA_Y <= U2_B3_Y;
				plot_enable <= U2_B3_plot_enable;
				VGA_COLOR <= U2_B3_color;				
			end															
		end
	end

	always @ (posedge CLOCK_50, negedge rstn) begin
		if (!rstn)
			bullet_fast <= load;
		else if (bullet_slow || !bullet_display_en)
			bullet_fast <= load;
		else if (bullet_display_en)
			bullet_fast <= bullet_fast - 7'b1;		
	end

	always @ (posedge CLOCK_50, negedge rstn) begin
		if(!rstn)
			bullet_display_indicator <= default_;
		else if (!bullet_display_en)
			bullet_display_indicator <= default_;
		else if (bullet_display_en && bullet_slow)
			bullet_display_indicator <= {bullet_display_indicator[4:0], 1'b0};
	end


endmodule