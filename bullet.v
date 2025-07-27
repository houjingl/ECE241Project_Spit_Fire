module Bullet(CLOCK_50, rstn, fire, gunLoc_X, gunLoc_Y, leftRight,//input
                plot_EN, bulletLoc_X, bulletLoc_Y, bullet_color);//output

    input CLOCK_50, rstn;
    input fire; //fire_en in FSM
    input leftRight;
    input [8:0] gunLoc_X;//REMARK: needs to be calculated based on UserID, Obj_Init_X, Obj_Init_Y                     
    input [7:0] gunLoc_Y;        //in the MAIN file("VGADisplay2Obj.v")

    output plot_EN;//needs to be used in vga_adapter
    output [2:0] bullet_color;

    output [8:0] bulletLoc_X;
    output [7:0] bulletLoc_Y;
    assign bulletLoc_X = oldX_Loc + XC - offset;
    assign bulletLoc_Y = oldY_Loc;
		
    wire [8:0] oldX_Loc, newX_Loc;//no need for Y since it never changes
	 reg [7:0] oldY_Loc;
	 
    wire [2:0] XC;
    wire paint_done;
	 wire is_erase;
	 wire signed [1:0] offset;
	 
	 assign offset = (is_erase == 1'b1) ? 1 : 0;

    count bullet_len(CLOCK_50, rstn, plot_EN, ~plot_EN, XC);
    assign paint_done = (XC == 3'b111)? 1:0;

    bulletRegn X_InitialLOC (newX_Loc, fire, gunLoc_X, CLOCK_50, oldX_Loc);
		defparam X_InitialLOC.n = 9;
	 
    always @(posedge CLOCK_50)
    begin
        if (!fire) begin
            oldY_Loc <= gunLoc_Y;
			end
    end

    bulletCounter Xcount(oldX_Loc, shift_EN, load_shiftClk, leftRight, CLOCK_50, rstn, newX_Loc);

    //speedClk waitCounter(bullet_display_en, load_speedClk, speedClk_en, rstn, c);

    //wire paint_done;
    wire c;
    wire shift_EN, load_shiftClk/*, speedClk_en*/;//FSM output
	
	 wire idle;
    Bullet_FSM fsm(/*inputs*/CLOCK_50, fire, paint_done, rstn, oldX_Loc, /*bullet_display_en,*/
                    /*outputs*/ shift_EN, plot_EN, load_shiftClk, /*speedClk_en,*/ bullet_color, is_erase, idle);
endmodule

module Bullet_FSM(/*inputs*/CLOCK_50, fire_en, paint_done, rstn, bullet_x_loc, /*bullet_display_en,*/
                    /*outputs*/ shift_en, plot_enable, load_shiftClk, /*speedClk_en, */px_color, is_erase, idle);
    input CLOCK_50;
    input fire_en/*wired to a KEY*/,paint_done ,rstn;
	input [8:0] bullet_x_loc;
    //input bullet_display_en;

    output shift_en, plot_enable, load_shiftClk, is_erase /*,speedClk_en*/; //shift_en: enable the position counter, plot_en: enable the vga_adapter
    output reg [2:0] px_color;
	 output idle;
    reg destruct_en;

    parameter[4:0] Sidle = 5'b00001, Sdraw = 5'b00010, /*Swait = 6'b000100,*/ 
                    Serase = 5'b00100, Sshift = 5'b01000, Sdestruct = 5'b10000; 
    reg[4:0] y, Y;

    always@ (posedge CLOCK_50, negedge rstn)
    begin
        if(rstn == 0)
            y <= Sdestruct;
        else
            y <= Y;
    end

    always@ (y, fire_en, paint_done, bullet_x_loc)//no destruct enable?
    begin
        case(y)
            Sidle: if(fire_en == 1'b0) Y = Sdraw;
                    else Y = Sidle;

            Sdraw: if(paint_done) Y = Serase;
                    else Y = Sdraw;

            Serase: if(paint_done && destruct_en) Y = Sidle;
                    else if(paint_done && !destruct_en) Y = Sshift;
                    else Y = Serase;

            Sshift: if (bullet_x_loc == 9'd340) Y = Sdestruct;
                    else Y = Sdraw;

            Sdestruct: Y = Serase;
				
				default: Y = Serase;

        endcase
    end

    //output logic:
    assign plot_enable = y[1] || y[2];
    assign shift_en = y[3];
    assign load_shiftClk = ~y[3];
	 assign is_erase = y[2];
	 assign idle = y[4];
    //assign speedClk_en = y[2];

    //color selection
    always@(posedge CLOCK_50)
    begin
        if(y == Sdraw)
            px_color = 3'b111;
        else if(y == Serase)
            px_color = 3'b000;
    end

    //destruct state output:
    always@ (y) 
    begin
		case(y)	
			Sdestruct: destruct_en = 1'b1;
			Sidle: destruct_en = 1'b0;
		endcase
    end
endmodule

module bulletRegn(R, load_en, Load, Clock, Q);
//Caution: This n need to be redefine in the top level module
//Using: defparam U1.n = 7; //U1 is the name of the module

//Citation: This module is modified based on the regn module in the vga_demo of VGA animation made by Prof. Brown

    parameter n = 8;
    input [n-1:0] R, Load;
    input load_en, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!load_en)
            Q <= Load;
        else
            Q <= R;
endmodule

module bulletCounter(oldX_loc, shift_enable, load_en, LeftRight, clock, rstn, newX_Loc);

	input shift_enable, load_en, LeftRight;
	input clock, rstn;
   input [8:0] oldX_loc;

	output reg [8:0] newX_Loc;
	wire slow;

	reg[20:0] fast;

	always@ (posedge clock, negedge rstn)
	begin
		if(rstn == 1'b0)
			fast <= 15'b11111111111111;
		else if(slow == 1'b1)
			fast <= 15'b11111111111111;
		else 
			fast <= fast - 1'b1;
	end

	assign slow = (fast == 16'b0)? 1:0;

	always@(posedge clock) begin
		if (shift_enable && slow) begin
			if (LeftRight)
				newX_Loc <= oldX_loc + 1; //moving right
			else
				newX_Loc <= oldX_loc - 1; //moving left
		end
	end
endmodule

module count (Clock, Resetn, Enable, load, Q);

//Citation: This module is modified based on the count module in the vga_demo of VGA animation made by Prof. Brown

//To count X_currentLoc, n = 5
//To count Y_currentLoc, n = 5

    parameter n = 3;
    input Clock, Resetn, Enable, load;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
		  else if (load)
				Q <= 0;
        else if (Enable)
            Q <= Q + 1;
endmodule
