package FIFO_env_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import FIFO_sequence_item_pkg::*;
import FIFO_agent_pkg ::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;

class FIFO_env extends uvm_env;
`uvm_component_utils(FIFO_env);
FIFO_agent agt;
FIFO_scoreboard sb;
FIFO_coverage cov;
uvm_analysis_port #(FIFO_seq_item)agt_ap;

function  new(string name ="FIFO_env", uvm_component parent=null);
super.new(name,parent);
endfunction
/*****************builed phase **************/
function void build_phase(uvm_phase phase);
super.build_phase(phase);
agt=FIFO_agent::type_id::create("agt",this);
sb=FIFO_scoreboard::type_id::create("sb",this);
cov=FIFO_coverage::type_id::create("cov",this);
agt_ap=new("agt_ap",this); 
endfunction

/*************** connect phase *************/
  function void connect_phase(uvm_phase phase); 
            super.connect_phase(phase); 
            agt.agt_ap.connect(sb.sb_export); 
            agt.agt_ap.connect (cov.cov_export); 
        endfunction 
    endclass 
endpackage 