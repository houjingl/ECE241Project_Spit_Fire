# Step 1: Create and clean the work library
if {[file exists work]} {
    vdel -all
}
vlib work

# Step 2: Compile the design files
vlog DisplayObj.v             ;# Compile the DUT
vlog testbench.v              ;# Compile the testbench

# Step 3: Load the testbench
vsim -voptargs="+acc" testbench


# Step 5: Apply waveform configuration (if available)
if {[file exists wave.do]} {
    do wave.do
} else {
    puts "Warning: wave.do file not found. Skipping waveform setup."
}

# Step 6: Run the simulation
run 1ms

# Step 8: Exit the simulation
quit -force
