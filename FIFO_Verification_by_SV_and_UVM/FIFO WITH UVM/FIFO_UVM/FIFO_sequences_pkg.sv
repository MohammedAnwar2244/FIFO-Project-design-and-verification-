package FIFO_sequence_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import FIFO_sequence_item_pkg::*;

  //_________________________________________ 1 SEQUENCE _______________________________________//
  class FIFO_reset_sequence extends uvm_sequence#(FIFO_seq_item);
    `uvm_object_utils(FIFO_reset_sequence)
    FIFO_seq_item seq_item;

    function new(string name = "FIFO_reset_sequence");
      super.new(name);
    endfunction

    task body();
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      start_item(seq_item);
      seq_item.rst_n = 0;
      seq_item.wr_en = 0;
      seq_item.rd_en = 0;
      seq_item.data_in = 0;
      finish_item(seq_item);
    endtask
  endclass

  //_________________________________________ 2 SEQUENCE _______________________________________//
  class FIFO_write_only_sequence extends uvm_sequence#(FIFO_seq_item);
    `uvm_object_utils(FIFO_write_only_sequence)
    FIFO_seq_item seq_item;

    function new(string name = "FIFO_write_only_sequence");
      super.new(name);
    endfunction

    task body();
      repeat (100) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 1;
        seq_item.wr_en = 1;
        seq_item.rd_en = 0;
        seq_item.randomize();
        finish_item(seq_item);
      end
    endtask
  endclass

  //_________________________________________ 3 SEQUENCE _______________________________________//
  class FIFO_read_only_sequence extends uvm_sequence#(FIFO_seq_item);
    `uvm_object_utils(FIFO_read_only_sequence)
    FIFO_seq_item seq_item;

    function new(string name = "FIFO_read_only_sequence");
      super.new(name);
    endfunction

    task body();
      repeat (100) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 1;
        seq_item.wr_en = 0;
        seq_item.rd_en = 1;
        seq_item.randomize();
        finish_item(seq_item);
      end
    endtask
  endclass

  //_________________________________________ 4 SEQUENCE _______________________________________//
  class FIFO_read_write_sequence extends uvm_sequence#(FIFO_seq_item);
    `uvm_object_utils(FIFO_read_write_sequence)
    FIFO_seq_item seq_item;

    function new(string name = "FIFO_read_write_sequence");
      super.new(name);
    endfunction

    task body();
      repeat (100) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.randomize();
        finish_item(seq_item);
      end
    endtask
  endclass

  //_________________________________________ 5 SEQUENCE _______________________________________//
  class FIFO_read_write_empty_sequence extends uvm_sequence#(FIFO_seq_item);
    `uvm_object_utils(FIFO_read_write_empty_sequence)
    FIFO_seq_item seq_item;

    function new(string name = "FIFO_read_write_empty_sequence");
      super.new(name);
    endfunction

    task body();

      // Write until FIFO is full
      for (int i = 0; i < FIFO_DEPTH; i++) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 1;
        seq_item.wr_en = 1;
        seq_item.rd_en = 0;
        seq_item.randomize();
        finish_item(seq_item);
      end

      // Read until FIFO is empty
      for (int i = 0; i < FIFO_DEPTH; i++) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.rst_n = 1;
        seq_item.wr_en = 0;
        seq_item.rd_en = 1;
        seq_item.randomize();
        finish_item(seq_item);
      end

      // Final simultaneous read/write
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      start_item(seq_item);
      seq_item.rst_n = 1;
      seq_item.wr_en = 1;
      seq_item.rd_en = 1;
      seq_item.randomize();
      finish_item(seq_item);
    endtask
  endclass

endpackage
