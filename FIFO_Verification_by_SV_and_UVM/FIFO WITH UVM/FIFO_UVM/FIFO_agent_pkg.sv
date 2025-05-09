package FIFO_agent_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*; 
  import FIFO_driver_pkg::*;  
  import FIFO_sequencer_pkg::*; 
  import FIFO_sequence_item_pkg::*; 
  import FIFO_monitor_pkg::*; 
  import FIFO_config_obj_pkg::*;
  import FIFO_shared_pkg::*; 

  class FIFO_agent extends uvm_agent; 
    `uvm_component_utils(FIFO_agent); 

    FIFO_object fifo_config_obj_driver;   // ✅ Correct type
    FIFO_driver fifo_dr; 
    FIFO_sequencer sqr; 
    FIFO_monitor mon; 
    uvm_analysis_port #(FIFO_seq_item) agt_ap; 

    function new(string name = "FIFO_agen", uvm_component parent = null); // updated name
      super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase); 
      super.build_phase(phase); 
      
      if (!uvm_config_db #(FIFO_object)::get(this, "", "CGO", fifo_config_obj_driver)) begin 
        `uvm_fatal("build_phase", "DRIVER − unable to get the virtual interface"); 
      end  

     
      fifo_dr=FIFO_driver::type_id::create("fifo_dt",this);
      sqr =FIFO_sequencer::type_id::create("sqr",this);
      mon = FIFO_monitor::type_id::create("mon", this); 
      agt_ap = new("agt_ap", this); 
    endfunction

    function void connect_phase(uvm_phase phase); 
      super.connect_phase(phase); 
    fifo_dr.seq_item_port.connect(sqr.seq_item_export);
    fifo_dr.sh_vif=fifo_config_obj_driver.fifo_config_vif;
      mon.sh_vif = fifo_config_obj_driver.fifo_config_vif; 
      mon.mon_ap.connect(agt_ap); 
    endfunction 
  endclass
endpackage
