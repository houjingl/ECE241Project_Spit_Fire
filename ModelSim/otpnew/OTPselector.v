module Object_To_Paint_Selector(
    input CLOCK_50, 
    input rstn, 
    input [2:0] background_color, 
    input game_display_en, 
    input [8:0] XC, 
    input [7:0] YC,
    input [2:0] User1_VGA_color, 
    input [8:0] User1_VGA_X, 
    input [7:0] User1_VGA_Y, 
    input User1_plot_enable,
    input [2:0] User2_VGA_color, 
    input [8:0] User2_VGA_X, 
    input [7:0] User2_VGA_Y, 
    input User2_plot_enable,
    input [2:0] U1_B1_color, 
    input [8:0] U1_B1_X, 
    input [7:0] U1_B1_Y, 
    input U1_B1_plot_enable, 
    input [2:0] U2_B1_color, 
    input [8:0] U2_B1_X,
    input [7:0] U2_B1_Y, 
    input U2_B1_plot_enable, 
    output reg [8:0] VGA_X, 
    output reg [7:0] VGA_Y, 
    output reg plot_enable, 
    output reg [2:0] VGA_COLOR
);

    // Internal registers and wires
    reg [14:0] fast;
    reg [3:0] display_indicator;
    reg bullet_display_en;

    // Parameters
    parameter [3:0] default_set = 4'b0001;
    parameter [3:0] obj1 = 4'b0001, obj2 = 4'b0010, U1bullet1 = 4'b0100, U2bullet1 = 4'b1000;

    // Clock divider logic for slow clock generation
    always @(posedge CLOCK_50 or negedge rstn) begin
        if (!rstn)
            fast <= 15'd255; // Reset the clock divider
        else if (fast == 0)
            fast <= 15'd255; // Reset counter when trigger occurs
        else
            fast <= fast - 1;
    end

    wire slow_clock_trigger = (fast == 0);

    // Rotational shift register for display indicator
    always @(posedge CLOCK_50 or negedge rstn) begin
        if (!rstn)
            display_indicator <= default_set; // Reset to default
        else if (slow_clock_trigger)
            display_indicator <= {display_indicator[0], display_indicator[3:1]};
    end

    // Object selection and VGA output logic
    always @(posedge CLOCK_50 or negedge rstn) begin
        if (!rstn) begin
            VGA_X <= 9'b0;
            VGA_Y <= 8'b0;
            plot_enable <= 1'b0;
            VGA_COLOR <= 3'b0;
            bullet_display_en <= 1'b0;
        end else if (game_display_en) begin
            case (display_indicator)
                obj1: begin
                    VGA_X <= User1_VGA_X;
                    VGA_Y <= User1_VGA_Y;
                    plot_enable <= User1_plot_enable;
                    VGA_COLOR <= User1_VGA_color;
                    bullet_display_en <= 1'b0;    
                end
                obj2: begin
                    VGA_X <= User2_VGA_X;
                    VGA_Y <= User2_VGA_Y;
                    plot_enable <= User2_plot_enable;
                    VGA_COLOR <= User2_VGA_color;
                    bullet_display_en <= 1'b0;    
                end
                U1bullet1: begin
                    bullet_display_en <= 1'b1; // Enable bullet display
                    VGA_X <= U1_B1_X;
                    VGA_Y <= U1_B1_Y;
                    plot_enable <= U1_B1_plot_enable;
                    VGA_COLOR <= U1_B1_color;
                end
                U2bullet1: begin
                    bullet_display_en <= 1'b1; // Enable bullet display
                    VGA_X <= U2_B1_X;
                    VGA_Y <= U2_B1_Y;
                    plot_enable <= U2_B1_plot_enable;
                    VGA_COLOR <= U2_B1_color;
                end
                default: begin
                    VGA_X <= 9'b0;
                    VGA_Y <= 8'b0;
                    plot_enable <= 1'b0;
                    VGA_COLOR <= 3'b0;
                end
            endcase
        end else begin
            VGA_X <= XC;
            VGA_Y <= YC;
            VGA_COLOR <= background_color;
            plot_enable <= 1'b1;
        end
    end

endmodule
