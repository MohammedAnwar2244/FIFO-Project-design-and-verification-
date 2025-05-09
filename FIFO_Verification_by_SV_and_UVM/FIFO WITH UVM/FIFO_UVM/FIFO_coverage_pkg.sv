package FIFO_coverage_pkg; 
`include "uvm_macros.svh" 
import uvm_pkg::*;
import FIFO_sequence_item_pkg::*; 
class FIFO_coverage extends uvm_component; 
        `uvm_component_utils(FIFO_coverage); 
         uvm_analysis_export #(FIFO_seq_item) cov_export; 
         uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo; 
        FIFO_seq_item seq_item_cov; 


         covergroup cg ;

// Here we create cover point for each signal to be used in the cross coverage
wr_en_cp : coverpoint seq_item_cov.wr_en;
rd_en_cp : coverpoint seq_item_cov.rd_en;
wr_ack_cp : coverpoint seq_item_cov.wr_ack;
full_cp	: coverpoint seq_item_cov.full;
empty_cp : coverpoint seq_item_cov.empty;
almostfull_cp : coverpoint seq_item_cov.almostfull;
almostempty_cp : coverpoint seq_item_cov.almostempty;
overflow_cp	: coverpoint seq_item_cov.overflow;
underflow_cp : coverpoint seq_item_cov.underflow;

// Here we create cross coverage for each output with read enable & write enable except(dout)
wr_rd_wr_ack_cross : cross wr_en_cp , rd_en_cp , wr_ack_cp 
		{ 
			ignore_bins write_active_with_wr_ack = ! binsof(wr_en_cp) intersect {1} && binsof(wr_ack_cp) intersect {1};
			ignore_bins read_write_active_with_wr_ack = ! binsof(wr_en_cp) intersect {1} && binsof(rd_en_cp) intersect {1} && binsof(wr_ack_cp) intersect {1}; 
		}

wr_rd_full_cross : cross wr_en_cp , rd_en_cp , full_cp 
		{ 
			ignore_bins write_active_with_full = ! binsof(wr_en_cp) intersect {1} && binsof(full_cp) intersect {1};
			ignore_bins read_active_with_full = binsof(rd_en_cp) intersect {1} && binsof(full_cp) intersect {1};
		}

wr_rd_empty_cross : cross wr_en_cp , rd_en_cp , empty_cp 
		{ 
			ignore_bins read_active_with_empty = ! binsof(rd_en_cp) intersect {1} && binsof(empty_cp) intersect {1};
		}

wr_rd_overflow_cross : cross wr_en_cp , rd_en_cp , overflow_cp 
		{ 
			ignore_bins write_active_with_overflow = ! binsof(wr_en_cp) intersect {1} && binsof(overflow_cp) intersect {1}; 
		}

wr_rd_underflow_cross : cross wr_en_cp , rd_en_cp , underflow_cp 
		{ 
			ignore_bins read_active_with_underflow = ! binsof(rd_en_cp) intersect {1} && binsof(underflow_cp) intersect {1};  
		}

wr_rd_almostfull_cross : cross wr_en_cp , rd_en_cp , almostfull_cp 
		{ 
			ignore_bins write_active_with_almostfull = ! binsof(wr_en_cp) intersect {1} && binsof(almostfull_cp) intersect {1};
			ignore_bins read_write_active_with_almostfull = ! binsof(wr_en_cp) intersect {1} && binsof(rd_en_cp) intersect {1} && binsof(almostfull_cp) intersect {1};  
		}

wr_rd_almostempty_cross : cross wr_en_cp , rd_en_cp , almostempty_cp
		{ 
			ignore_bins read_active_with_almostempty = ! binsof(rd_en_cp) intersect {1} && binsof(almostempty_cp) intersect {1};
			ignore_bins read_write_active_with_almostempty = ! binsof(wr_en_cp) intersect {1} && binsof(rd_en_cp) intersect {1} && binsof(almostempty_cp) intersect {1};
		}

endgroup


         function new(string name ="FIFO_coverage",uvm_component parent = null); 
            super.new(name,parent); 
            cg=new(); 
        endfunction 


        function void build_phase (uvm_phase phase); 
            super.build_phase(phase); 
            cov_export=new("cov_export",this); 
            cov_fifo=new("cov_fifo",this); 
        endfunction 


        function void connect_phase(uvm_phase phase); 
            super.connect_phase(phase); 
            cov_export.connect(cov_fifo.analysis_export); 
        endfunction 


        task run_phase (uvm_phase phase); 
        super.run_phase(phase); 
            forever begin 
               cov_fifo.get(seq_item_cov); 
               cg.sample(); 
            end 
        endtask  
endclass 
endpackage  