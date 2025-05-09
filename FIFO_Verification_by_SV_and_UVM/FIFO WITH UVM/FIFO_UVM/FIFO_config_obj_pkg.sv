package FIFO_config_obj_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*; // Corrected the package name from unm_pkg to uvm_pkg

class FIFO_object extends uvm_object;
    `uvm_object_utils(FIFO_object);

    virtual FIFO_if fifo_config_vif;
    uvm_active_passive_enum sel_mod;

    function new(string name = "FIFO_object");
        super.new(name);
    endfunction //new()
endclass //FIFO_object   
endpackage
