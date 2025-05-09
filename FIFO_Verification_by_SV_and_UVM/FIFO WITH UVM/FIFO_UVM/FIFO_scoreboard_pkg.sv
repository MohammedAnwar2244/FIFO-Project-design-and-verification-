package FIFO_scoreboard_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;
import FIFO_sequence_item_pkg::*;
import FIFO_shared_pkg::*;

class FIFO_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(FIFO_scoreboard)

    localparam FIFO_WIDTH = 16;
    localparam FIFO_DEPTH = 8;

    uvm_analysis_export #(FIFO_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
    FIFO_seq_item seq_item_sb;

    logic [FIFO_WIDTH-1:0] fifo_ref[$];
    integer fifo_count = 0;
    logic [FIFO_WIDTH-1:0] data_out_ref;

    int correct_count = 0;
    int error_count = 0;

    // Constructor
    function new(string name = "FIFO_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export", this);
        sb_fifo = new("sb_fifo", this);
    endfunction

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            sb_fifo.get(seq_item_sb);
            reference_model(seq_item_sb);
            #2;
            if (seq_item_sb.data_out !== data_out_ref) begin
                `uvm_error("run_phase", $sformatf(
                    "Comparison failed: DUT output = %0h, Reference output = %0h | Stimulus = %s",
                    seq_item_sb.data_out, data_out_ref, seq_item_sb.convert2string_stimulus()))
                error_count++;
            end else begin
                correct_count++;
                `uvm_info("run_phase", $sformatf("Correct transaction: %s", seq_item_sb.convert2string()), UVM_HIGH);
            end
        end
    endtask

    // Reference model
    function void reference_model(input FIFO_seq_item F_tx);
        if (!F_tx.rst_n) begin
            fifo_ref <= {};
            fifo_count = 0;
    
        end else begin
            if (F_tx.wr_en && fifo_count < FIFO_DEPTH) begin
                fifo_ref.push_back(F_tx.data_in);
                fifo_count <= fifo_ref.size();
            end
            if (F_tx.rd_en && fifo_count != 0) begin
                data_out_ref <= fifo_ref.pop_front();
                fifo_count <= fifo_ref.size();
            end 
            
        end
    endfunction

    // Report phase
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM);
        `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM);
    endfunction

endclass

endpackage
