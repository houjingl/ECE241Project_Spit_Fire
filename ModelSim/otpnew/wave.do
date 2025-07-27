# Clear existing wave configurations
onerror {resume}
wave clear
quietly WaveActivateNextPane {} 0

# Add clock and reset signals
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label rstn -radix binary /testbench/rstn

# Divider: Inputs
add wave -noupdate -divider Inputs

# Add object-related inputs
add wave -noupdate -label User1_VGA_color -radix binary /testbench/User1_VGA_color
add wave -noupdate -label User1_VGA_X -radix decimal /testbench/User1_VGA_X
add wave -noupdate -label User1_VGA_Y -radix decimal /testbench/User1_VGA_Y
add wave -noupdate -label User1_plot_enable -radix binary /testbench/User1_plot_enable

add wave -noupdate -label User2_VGA_color -radix binary /testbench/User2_VGA_color
add wave -noupdate -label User2_VGA_X -radix decimal /testbench/User2_VGA_X
add wave -noupdate -label User2_VGA_Y -radix decimal /testbench/User2_VGA_Y
add wave -noupdate -label User2_plot_enable -radix binary /testbench/User2_plot_enable

# Add bullet-related inputs
add wave -noupdate -divider Bullet_Inputs
add wave -noupdate -label U1_B1_color -radix binary /testbench/U1_B1_color
add wave -noupdate -label U1_B1_X -radix decimal /testbench/U1_B1_X
add wave -noupdate -label U1_B1_Y -radix decimal /testbench/U1_B1_Y
add wave -noupdate -label U1_B1_plot_enable -radix binary /testbench/U1_B1_plot_enable

add wave -noupdate -label U1_B2_color -radix binary /testbench/U1_B2_color
add wave -noupdate -label U1_B2_X -radix decimal /testbench/U1_B2_X
add wave -noupdate -label U1_B2_Y -radix decimal /testbench/U1_B2_Y
add wave -noupdate -label U1_B2_plot_enable -radix binary /testbench/U1_B2_plot_enable

add wave -noupdate -label U2_B1_color -radix binary /testbench/U2_B1_color
add wave -noupdate -label U2_B1_X -radix decimal /testbench/U2_B1_X
add wave -noupdate -label U2_B1_Y -radix decimal /testbench/U2_B1_Y
add wave -noupdate -label U2_B1_plot_enable -radix binary /testbench/U2_B1_plot_enable

add wave -noupdate -label U2_B3_color -radix binary /testbench/U2_B3_color
add wave -noupdate -label U2_B3_X -radix decimal /testbench/U2_B3_X
add wave -noupdate -label U2_B3_Y -radix decimal /testbench/U2_B3_Y
add wave -noupdate -label U2_B3_plot_enable -radix binary /testbench/U2_B3_plot_enable

# Divider: Outputs
add wave -noupdate -divider Outputs

# Add VGA Outputs
add wave -noupdate -label VGA_X -radix decimal /testbench/VGA_X
add wave -noupdate -label VGA_Y -radix decimal /testbench/VGA_Y
add wave -noupdate -label VGA_COLOR -radix binary /testbench/VGA_COLOR
add wave -noupdate -label plot_enable -radix binary /testbench/plot_enable

# Divider: Debugging Signals
add wave -noupdate -divider Debugging

# Add internal signals from the DUT (OTPMUX)
add wave -noupdate -label display_indicator -radix binary /testbench/display_indicator
add wave -noupdate -label bullet_display_indicator -radix binary /testbench/bullet_display_indicator
add wave -noupdate -label bullet_display_en -radix binary /testbench/bullet_display_en
add wave -noupdate -label fast -radix decimal /testbench/fast
add wave -noupdate -label bullet_fast -radix decimal /testbench/bullet_fast
add wave -noupdate -label bullet_slow -radix binary /testbench/bullet_slow

# Tree and cursor setup
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1

# Waveform viewer configuration
configure wave -namecolwidth 80
configure wave -valuecolwidth 38
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns

# Zoom to fit all simulation data
wave zoom range 0
