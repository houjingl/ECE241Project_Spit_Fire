module new_keyboard (
    input reset,
    input wire CLOCK_50,

    inout wire PS2_CLK,
    inout wire PS2_DAT,

    output reg key_w,
    output reg key_a,
    output reg key_s,
    output reg key_d,
    output reg key_i,
    output reg key_j,
    output reg key_k,
    output reg key_l,
    output reg key_enter,
    output reg key_space,
    output reg key_esc
    );

    // Internal signals
    wire [7:0] received_data;
    wire received_data_en;
    reg [7:0] last_data;

    // Flags to track extended key codes and break code
    reg break_code;

    // Instantiate PS2_Controller with INITIALIZE_MOUSE set to 0
    PS2_Controller #(0) ps2_keyboard (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .the_command(8'h00),            // No command for basic key detection
        .send_command(1'b0),            // Not sending any commands
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .command_was_sent(),
        .error_communication_timed_out(),
        .received_data(received_data),
        .received_data_en(received_data_en)
    );

    // Key scan codes
    localparam BREAK_CODE = 8'hF0;
    localparam KEY_W_CODE = 8'h1D;
    localparam KEY_A_CODE = 8'h1C;
    localparam KEY_S_CODE = 8'h1B;
    localparam KEY_D_CODE = 8'h23;
    localparam KEY_I_CODE = 8'h43;
    localparam KEY_J_CODE = 8'h3B;
    localparam KEY_K_CODE = 8'h42;
    localparam KEY_L_CODE = 8'h4B;
    localparam KEY_Enter = 8'h5A;
    localparam KEY_space = 8'h29;
    localparam KEY_ESC = 8'h76;

    // Detect key presses and releases
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            // Reset all key states and flags
            key_w <= 1'b0;
            key_a <= 1'b0;
            key_s <= 1'b0;
            key_d <= 1'b0;
            key_i <= 1'b0;
            key_j <= 1'b0;
            key_k <= 1'b0;
            key_l <= 1'b0;
            key_enter <= 1'b0;
            key_space <= 1'b0;
            key_esc <= 1'b0;
            break_code <= 1'b0;
            last_data <= 8'h00;
        end else if (received_data_en) begin
            if (received_data == BREAK_CODE) begin
                // Set the break_code flag when a break code (F0) is received
                break_code <= 1'b1;
            end else if (break_code) begin
                // Handle key release events
                case (received_data)
                    KEY_W_CODE: key_w <= 1'b0;
                    KEY_A_CODE: key_a <= 1'b0;
                    KEY_S_CODE: key_s <= 1'b0;
                    KEY_D_CODE: key_d <= 1'b0;
                    KEY_I_CODE: key_i <= 1'b0;
                    KEY_J_CODE: key_j <= 1'b0;
                    KEY_K_CODE: key_k <= 1'b0;
                    KEY_L_CODE: key_l <= 1'b0;
                    KEY_Enter: key_enter <= 1'b0;
                    KEY_space: key_space <= 1'b0;
                    KEY_ESC: key_esc <= 1'b0;
                endcase
                break_code <= 1'b0;
            end else begin
                // Handle key press events
                case (received_data)
                    KEY_W_CODE: key_w <= 1'b1;
                    KEY_A_CODE: key_a <= 1'b1;
                    KEY_S_CODE: key_s <= 1'b1;
                    KEY_D_CODE: key_d <= 1'b1;
                    KEY_I_CODE: key_i <= 1'b1;
                    KEY_J_CODE: key_j <= 1'b1;
                    KEY_K_CODE: key_k <= 1'b1;
                    KEY_L_CODE: key_l <= 1'b1;
                    KEY_Enter: key_enter <= 1'b1;
                    KEY_space: key_space <= 1'b1;
                    KEY_ESC: key_esc <= 1'b1;
                endcase
            end
            // Update last_data for debugging or reference
            last_data <= received_data;
        end
    end

endmodule
