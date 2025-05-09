# Create working library
vlib work

# Compile all files with code coverage enabled (branch, statement, toggle)
vlog +cover=bst FIFO_after.sv FIFO_interface.sv FIFO_top.sv \
     FIFO_transaction_pkg.sv FIFO_coverage_pkg.sv FIFO_scoreboard_pkg.sv \
     SHARED_pkg.sv FIFO_tb.sv Monitor.sv

# Simulate with coverage enabled
vsim -voptargs=+acc -coverage work.FIFO_top

# Add signals to waveform
add wave *
add wave -position insertpoint  \
 sim:/FIFO_top/if_obj/data_in \
 sim:/FIFO_top/if_obj/rst_n \
 sim:/FIFO_top/if_obj/wr_en \
 sim:/FIFO_top/if_obj/rd_en \
 sim:/FIFO_top/if_obj/data_out \
 sim:/FIFO_top/if_obj/wr_ack \
 sim:/FIFO_top/if_obj/overflow \
 sim:/FIFO_top/if_obj/full \
 sim:/FIFO_top/if_obj/empty \
 sim:/FIFO_top/if_obj/almostfull \
 sim:/FIFO_top/if_obj/almostempty \
 sim:/FIFO_top/if_obj/underflow \
 sim:/FIFO_top/monitor/obj_score

add wave /FIFO_top/dut/a1 /FIFO_top/dut/a2 /FIFO_top/dut/a3 /FIFO_top/dut/a4 \
         /FIFO_top/dut/a5 /FIFO_top/dut/a6 /FIFO_top/dut/a7 /FIFO_top/dut/a8 \
         /FIFO_top/dut/a9 /FIFO_top/dut/a10 /FIFO_top/dut/a11

# Save UCDB file with coverage data
coverage save FIFO_after.ucdb -onexit -du work.FIFO

# Run the full simulation
run -all

# Exit simulation
quit -sim
