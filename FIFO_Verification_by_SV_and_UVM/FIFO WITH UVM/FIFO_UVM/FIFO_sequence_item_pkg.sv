package FIFO_sequence_item_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Legal: declare parameters at package level
  parameter FIFO_WIDTH = 16;
  parameter FIFO_DEPTH = 8;
  localparam max_fifo_addr = $clog2(FIFO_DEPTH);

  class FIFO_seq_item extends uvm_sequence_item;
    `uvm_object_utils(FIFO_seq_item)
    
    //_______________ INPUT ______________________//
    rand bit [FIFO_WIDTH-1:0] data_in;
    rand bit rst_n, wr_en, rd_en;

    //_______________ OUTPUT _____________________//
    bit [FIFO_WIDTH-1:0] data_out;
    bit wr_ack, overflow;
    bit full, empty, almostfull, almostempty, underflow;

    // Control read/write enable bias (sum should not exceed 100)
    int RD_EN_ON_DIST = 30;
    int WR_EN_ON_DIST = 70;

    // Constructor
    function new(string name = "FIFO_seq_item");
      super.new(name);
    endfunction

    // Constraints
    constraint c_reset {
      rst_n dist {0:/5, 1:/95};
    }

    constraint c_write {
      wr_en dist {0 := (100 - WR_EN_ON_DIST), 1 := WR_EN_ON_DIST};
    }

    constraint c_read {
      rd_en dist {0 := (100 - RD_EN_ON_DIST), 1 := RD_EN_ON_DIST};
    }

    // Convert functions
    function string convert2string();
      return $sformatf("%s rst_n=0b%0b, data_in=0b%0b, wr_en=0b%0b, rd_en=0b%0b, data_out=0b%0d, wr_ack=0b%0d, overflow=0b%0d, underflow=0b%0d, full=0b%0d, empty=0b%0d, almostfull=0b%0d, almostempty=0b%0d",
        super.convert2string(), rst_n , data_in , wr_en , rd_en , data_out , wr_ack , overflow , underflow , full , empty , almostfull , almostempty );
    endfunction

    function string convert2string_stimulus();
      return $sformatf("%s rst_n=0b%0b, data_in=0b%0b, wr_en=0b%0b, rd_en=0b%0b",
        super.convert2string(), rst_n , data_in , wr_en , rd_en );
    endfunction

  endclass

endpackage
