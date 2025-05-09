module FIFO_SVA (FIFO_if.DUT if_obj);

//==========================================================
// Assertions + Cover Properties
//==========================================================

// SVA1: Reset state checks
always_comb begin 
    if (!if_obj.rst_n) begin
        q1: assert final ((!if_obj.wr_ack) && (!if_obj.overflow) && (!if_obj.underflow) &&
                          (!FIFO.wr_ptr) && (!FIFO.rd_ptr) && (!FIFO.count));
        c1: cover final ((!if_obj.wr_ack) && (!if_obj.overflow) && (!if_obj.underflow) &&
                         (!FIFO.wr_ptr) && (!FIFO.rd_ptr) && (!FIFO.count));
    end
end

// SVA2: Full condition
always_comb begin
    if ((if_obj.rst_n) && (FIFO.count == if_obj.FIFO_DEPTH)) begin
        FULL_Assertion: assert final (if_obj.full);
        FULL_COVER: cover (if_obj.full);
    end
end

// SVA3: Empty condition
always_comb begin
    if ((if_obj.rst_n) && (FIFO.count == 0)) begin
        empty_Assertion: assert final (if_obj.empty);
        empty_COVER: cover (if_obj.empty);
    end
end

// SVA4: Almost full
always_comb begin
    if ((if_obj.rst_n) && (FIFO.count == if_obj.FIFO_DEPTH - 1)) begin
        almostfull_Assertion: assert final (if_obj.almostfull);
        almostfull_COVER: cover (if_obj.almostfull);
    end
end

// SVA5: Almost empty
always_comb begin
    if ((if_obj.rst_n) && (FIFO.count == 1)) begin
        almostempty_Assertion: assert final (if_obj.almostempty);
        almostempty_COVER: cover (if_obj.almostempty);
    end
end

// SVA6: Reset state (using property)
property p1;
    @(posedge if_obj.clk or negedge if_obj.rst_n)
    !if_obj.rst_n |-> ((!if_obj.wr_ack) && (!if_obj.overflow) && (!if_obj.underflow) &&
                       (!FIFO.wr_ptr) && (!FIFO.rd_ptr) && (!FIFO.count));
endproperty
q2: assert property(p1);
c2: cover property(p1);

// SVA7: Write pointer increment
property p2;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.wr_en && !if_obj.full) |=> 
        (if_obj.wr_ack && ((FIFO.wr_ptr == $past(FIFO.wr_ptr) + 1'b1) ||
                          (FIFO.wr_ptr == 0 && $past(FIFO.wr_ptr) + 1'b1 == 8)));
endproperty
q3: assert property(p2);
c3: cover property(p2);

// SVA8: Overflow check
property p3;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.wr_en && if_obj.full) |=> (if_obj.overflow);
endproperty
q4: assert property(p3);
c4: cover property(p3);

// SVA9: Read pointer increment
property p4;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.rd_en && FIFO.count != 0) |=> 
        ((FIFO.rd_ptr == $past(FIFO.rd_ptr) + 1) || 
         (FIFO.rd_ptr == 0 && $past(FIFO.rd_ptr) + 1'b1 == 8));
endproperty
q5: assert property(p4);
c5: cover property(p4);

// SVA10: Underflow check
property p5;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.rd_en && if_obj.empty) |=> (if_obj.underflow);
endproperty
q6: assert property(p5);
c6: cover property(p5);

// SVA11: FIFO count increment (write only)
property p6;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (({if_obj.wr_en, if_obj.rd_en} == 2'b10) && !if_obj.full) |=> 
        (FIFO.count == $past(FIFO.count) + 1'b1);
endproperty
q7: assert property(p6);
c7: cover property(p6);

// SVA12: FIFO count decrement (read only)
property p7;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (({if_obj.wr_en, if_obj.rd_en} == 2'b01) && !if_obj.empty) |=> 
        (FIFO.count == $past(FIFO.count) - 1'b1);
endproperty
q8: assert property(p7);
c8: cover property(p7);

// SVA13: Simultaneous write+read when full (count should decrement)
property p8;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (({if_obj.wr_en, if_obj.rd_en} == 2'b11) && if_obj.full) |=> 
        (FIFO.count == $past(FIFO.count) - 1'b1);
endproperty
q9: assert property(p8);
c9: cover property(p8);

// SVA14: Simultaneous write+read when empty (count should increment)
property p9;
    @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (({if_obj.wr_en, if_obj.rd_en} == 2'b11) && if_obj.empty) |=> 
        (FIFO.count == $past(FIFO.count) + 1'b1);
endproperty
q10: assert property(p9);
c10: cover property(p9);

endmodule
