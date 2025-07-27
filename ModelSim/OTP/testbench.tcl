# Tcl script for automating ModelSim simulation of testbench.v and OTPselector.v

# Clear the ModelSim environment
vlib work                          ;# Create the work library if not already created

# Step 1: Compile the design files
vlog OTPselector.v                 ;# Compile the DUT (Object To Paint Selector)
vlog testbench.v                   ;# Compile the testbench

# Step 2: Load the testbench
vsim -voptargs="+acc" testbench    ;# Load the testbench with full access to internal signals

# Step 3: Apply the wave.do script for waveform setup
do wave.do                         ;# Load the waveform configuration file

# Step 4: Run the simulation
run 1ms                            ;# Run the simulation for 1 millisecond

# Step 5: Optional - Save the waveform to a WLF file for later analysis
quietly write wave -window .wave -format wlf wave_output.wlf

# Print a message to indicate the simulation completed successfully
puts "Simulation completed. Waveform saved to 'wave_output.wlf'."

# Exit the simulation
quit -force
