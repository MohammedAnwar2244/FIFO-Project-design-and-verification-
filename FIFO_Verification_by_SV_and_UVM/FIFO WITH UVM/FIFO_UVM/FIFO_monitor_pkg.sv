package FIFO_monitor_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;
import FIFO_sequence_item_pkg::*;

class FIFO_monitor extends uvm_monitor;
    `uvm_component_utils(FIFO_monitor);

    virtual FIFO_if sh_vif;
    FIFO_seq_item rsp_seq_item;
    uvm_analysis_port #(FIFO_seq_item) mon_ap;

    function new(string name = "FIFO_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction // new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            rsp_seq_item = FIFO_seq_item::type_id::create("rsp_seq_item");

            // Ensure you have correct field names here that match those in the FIFO_SEQ_ITEM class
            @(negedge sh_vif.clk);

            rsp_seq_item.rst_n = sh_vif.rst_n;
            rsp_seq_item.wr_en = sh_vif.wr_en;
            rsp_seq_item.rd_en = sh_vif.rd_en;
            rsp_seq_item.data_in = sh_vif.data_in;
            rsp_seq_item.data_out = sh_vif.data_out;
            rsp_seq_item.wr_ack = sh_vif.wr_ack;
            rsp_seq_item.overflow = sh_vif.overflow;
            rsp_seq_item.underflow = sh_vif.underflow;
            rsp_seq_item.full = sh_vif.full;
            rsp_seq_item.empty= sh_vif.empty;
            rsp_seq_item.almostfull = sh_vif.almostfull;
            rsp_seq_item.almostempty = sh_vif.almostempty;
           
            // Write the sequence item to the analysis port
            mon_ap.write(rsp_seq_item);

            // Log the converted string
            `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH);
        end
    endtask
endclass

endpackage
