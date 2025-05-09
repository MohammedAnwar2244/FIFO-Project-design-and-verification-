import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_test_pkg::*;
module FIFO_top();
    bit clk;
initial begin
    clk=0;
    forever begin
        #1 clk = ~clk;
end
end
FIFO_if if_obj(clk);
FIFO DUT(if_obj);


bind FIFO FIFO_SVA SAV(if_obj);
initial begin
    uvm_config_db#(virtual FIFO_if)::set(null,"uvm_test_top","FIFO_IF",if_obj);
    run_test("FIFO_test");
end
    
endmodule