package FIFO_driver_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*; 
  import FIFO_sequence_item_pkg::*;
  import FIFO_config_obj_pkg::*;

  class FIFO_driver extends uvm_driver#(FIFO_seq_item);
    `uvm_component_utils(FIFO_driver)

    FIFO_seq_item stim_seq_item;
    virtual FIFO_if sh_vif;

    function new(string name = "FIFO_driver", uvm_component parent = null); 
      super.new(name, parent); 
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        // Create a new sequence item
        stim_seq_item = FIFO_seq_item::type_id::create("stim_seq_item");

        // Get transaction from sequencer
        seq_item_port.get_next_item(stim_seq_item);

        // Drive stimulus to DUT interface
        sh_vif.rst_n        = stim_seq_item.rst_n;
        sh_vif.wr_en        = stim_seq_item.wr_en;
        sh_vif.rd_en        = stim_seq_item.rd_en; 
        sh_vif.data_in      = stim_seq_item.data_in; 
      

        // Wait for one negative clock edge
        @(negedge sh_vif.clk); 

        // Capture DUT output
        stim_seq_item.wr_ack  = sh_vif.wr_ack; 
        stim_seq_item.overflow = sh_vif.overflow; 
         stim_seq_item.underflow = sh_vif.underflow; 
          stim_seq_item.full = sh_vif.full; 
           stim_seq_item.empty = sh_vif.empty; 
            stim_seq_item.almostfull = sh_vif.almostfull; 
             stim_seq_item.almostempty = sh_vif.almostempty; 
              stim_seq_item.data_out = sh_vif.data_out; 
        
        // Complete transaction
        seq_item_port.item_done();

        `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH) 
      end
    endtask
  endclass
endpackage
