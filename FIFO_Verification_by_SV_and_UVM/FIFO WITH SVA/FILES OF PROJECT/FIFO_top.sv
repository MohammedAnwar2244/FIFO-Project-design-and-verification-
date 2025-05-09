module FIFO_top ();
    bit clk ;

    initial begin
        clk = 0;
        forever #25 clk = ~clk ;
    end

    FIFO_if if_obj(clk);
    FIFO dut(if_obj);
    FIFO_tb TB(if_obj);
    FIFO_monitor monitor(if_obj);
    
endmodule