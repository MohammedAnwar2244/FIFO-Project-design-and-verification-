package FIFO_test_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import FIFO_env_pkg::*;
  import FIFO_sequence_pkg::*;
  import FIFO_config_obj_pkg::*;

  class FIFO_test extends uvm_test;
    `uvm_component_utils(FIFO_test);

    FIFO_env env;
    virtual FIFO_if fifo_driver_vif;
    FIFO_object fifo_config_obj_test;  // Replace object with the correct config class type
    FIFO_reset_sequence reset_seq;
    FIFO_read_only_sequence read_seq;
    FIFO_write_only_sequence write_seq;
    FIFO_read_write_sequence rd_wr_seq;
    FIFO_read_write_empty_sequence  rd_wr_em_seq;
  //_________________________COSTRUCTOR________________________________//
    function new(string name = "FIFO_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    /******* BUILD PHASE *******/
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = FIFO_env::type_id::create("env", this);
      
      // Replace object with ALSU_config (the correct class type for the configuration object)
      fifo_config_obj_test = FIFO_object::type_id::create("fifo_config_obj_test", this); 
      // creat your five sequence 

      reset_seq = FIFO_reset_sequence::type_id::create("reset_seq");
       write_seq = FIFO_write_only_sequence::type_id::create("write_seq");
      read_seq = FIFO_read_only_sequence::type_id::create("read_seq"); 
      rd_wr_seq = FIFO_read_write_sequence::type_id::create("rd_wr_seq");
      rd_wr_em_seq=FIFO_read_write_empty_sequence::type_id::create("rd_wr_em_seq");
      // Retrieve the virtual interface from the config object
      if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "FIFO_IF", fifo_config_obj_test.fifo_config_vif)) begin
        `uvm_fatal("build_phase", "the test unable to get the virtual interface");
      end
       fifo_config_obj_test.sel_mod = UVM_ACTIVE;
    
      uvm_config_db #(FIFO_object)::set(this, "*", "CGO", fifo_config_obj_test);  // Set the config object in the DB
    endfunction

    /******* RUN PHASE *******/
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);

      // Reset sequence 
      `uvm_info("run_phase", "reset asserted", UVM_LOW); 
    reset_seq.start(env.agt.sqr);
      `uvm_info("run_phase", "reset deasserted", UVM_LOW); 

      // READ sequence 
      `uvm_info("run_phase", "WRITE started", UVM_LOW); 
      write_seq.start(env.agt.sqr); 
      `uvm_info("run_phase", "WRITE ended", UVM_LOW); 

      // WRITE sequence 
      `uvm_info("run_phase", "READ started", UVM_LOW); 
      read_seq.start(env.agt.sqr);    
      `uvm_info("run_phase", "READ ended", UVM_LOW); 


      //READ  WRITE sequence 
      `uvm_info("run_phase", "READ WRITE started", UVM_LOW); 
      rd_wr_seq.start(env.agt.sqr);    
      `uvm_info("run_phase", "READ WRITE ended", UVM_LOW); 

      
      // WRITE sequence 
      `uvm_info("run_phase", "READ WRITE EMPTY started", UVM_LOW); 
      rd_wr_em_seq.start(env.agt.sqr);    
      `uvm_info("run_phase", "READ WRITE EMPTY ended", UVM_LOW); 
     phase.drop_objection(this);
     
    endtask
  endclass
endpackage
