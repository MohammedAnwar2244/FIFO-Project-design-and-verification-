vlib work 
vlog *v +cover 
vsim -voptargs=+acc work.FIFO_top -classdebug -uvmcontrol=all -cover 
add wave /FIFO_top/clk  
add wave /FIFO_top/if_obj/* 
coverage save FIFO_top.ucdb *onexit 
run -all 
quit -sim 
vcover report FIFO.ucdb -all -annotate -details  -output coverage.txt