package FIFO_scoreboard_pkg;

import FIFO_transaction_pkg::*;
import shared_pkg::*;

class FIFO_scoreboard;

  parameter FIFO_WIDTH = 16;
  parameter FIFO_DEPTH = 8;

  bit [FIFO_WIDTH-1:0] data_out_ref;
  bit wr_ack_ref, overflow_ref;
  bit full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

  int counter;                         // Tracks number of elements in the queue
  bit [FIFO_WIDTH-1:0] queue[$];       // Reference queue to model FIFO behavior

  FIFO_transaction obj = new();        // Transaction object

  /*********************** comb_flags *******************/
  function void comb_flags();
    full_ref        = (counter == FIFO_DEPTH)?1:0;
    empty_ref       = (counter == 0)?1:0;
    almostfull_ref  = (counter == FIFO_DEPTH - 1)?1:0;
    almostempty_ref = (counter == 1)?1:0;
  endfunction

  /*********************** check_data ********************/
  function void check_data(input FIFO_transaction obj);
    logic [6:0] flags_ref, flags_dut;

    reference_model(obj);  // Run golden model

    flags_ref = {wr_ack_ref, overflow_ref, full_ref, empty_ref, almostempty_ref, almostfull_ref, underflow_ref};
    flags_dut = {obj.wr_ack, obj.overflow, obj.full, obj.empty, obj.almostempty, obj.almostfull, obj.underflow};

    if ((obj.data_out !== data_out_ref) || (flags_dut !== flags_ref)) begin  
      $display("❌ MISMATCH at time = %0t: DUT outputs don't match reference model.", $time);
      error_count++;
    end else begin
      correct_count++;
      $display("✅ MATCH at time = %0t: Current queue = %p", $time, queue);
    end
  endfunction

  /*********************** reference_model *********************/
  function void reference_model(input FIFO_transaction obj_gold);

    fork
      // Write thread
      begin
        if (!obj_gold.rst_n) begin
          wr_ack_ref     = 0;
          overflow_ref   = 0;
          queue.delete();
        end else if (obj_gold.wr_en && counter < FIFO_DEPTH) begin
          queue.push_back(obj_gold.data_in);
          wr_ack_ref = 1;
        end else begin
          wr_ack_ref = 0;
          if (full_ref && obj_gold.wr_en)
            overflow_ref = 1;
          else
            overflow_ref = 0;
        end
      end

      // Read thread
      begin
        if (!obj_gold.rst_n) begin
          data_out_ref     = 0;
          underflow_ref    = 0;
          queue.delete();
        end else if (obj_gold.rd_en && counter > 0) begin
          data_out_ref = queue.pop_front();
          underflow_ref = 0;
        end else begin
          if (empty_ref && obj_gold.rd_en)
            underflow_ref = 1;
          else
            underflow_ref = 0;
        end
      end
    join

    // Update counter
    if (!obj_gold.rst_n) begin
      counter = 0;
    end else begin
      case ({obj_gold.wr_en, obj_gold.rd_en})
        2'b10: if (!full_ref)  counter++;
        2'b01: if (!empty_ref) counter--;
        2'b11: begin
          if (full_ref && !empty_ref) counter--; // writing when full, read takes priority
          else if (empty_ref && !full_ref) counter++;
          // else no change when full & empty are both 0 (balanced ops)
        end
      endcase
    end

    comb_flags();  // Update status flags after counter change

  endfunction

endclass

endpackage
