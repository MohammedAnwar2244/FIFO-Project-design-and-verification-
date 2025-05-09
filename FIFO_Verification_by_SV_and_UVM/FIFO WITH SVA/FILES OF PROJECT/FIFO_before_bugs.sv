////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT if_obj);

localparam max_fifo_addr = $clog2(if_obj.FIFO_DEPTH);

reg [if_obj.FIFO_WIDTH-1:0] mem [if_obj.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		wr_ptr <= 0;
	end
	else if (if_obj.wr_en && count < if_obj.FIFO_DEPTH) begin
		mem[wr_ptr] <= if_obj.data_in;
		if_obj.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		if_obj.wr_ack <= 0; 
		if (if_obj.full & if_obj.wr_en)
			if_obj.overflow <= 1;
		else
			if_obj.overflow <= 0;
	end
end

always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		rd_ptr <= 0;
	end
	else if (if_obj.rd_en && count != 0) begin
		if_obj.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({if_obj.wr_en, if_obj.rd_en} == 2'b10) && !if_obj.full) 
			count <= count + 1;
		else if ( ({if_obj.wr_en, if_obj.rd_en} == 2'b01) && !if_obj.empty)
			count <= count - 1;
	end
end

assign if_obj.full = (count == if_obj.FIFO_DEPTH)? 1 : 0;
assign if_obj.empty = (count == 0)? 1 : 0;
assign if_obj.underflow = (if_obj.empty && if_obj.rd_en)? 1 : 0; 
assign if_obj.almostfull = (count == if_obj.FIFO_DEPTH-2)? 1 : 0; 
assign if_obj.almostempty = (count == 1)? 1 : 0;


///==========================================================
// Assertions + Cover Properties
//==========================================================
//`ifdef ASSERT_ON

// SVA 1 – Reset behavior
property p_reset;
  @(posedge if_obj.clk) !if_obj.rst_n |=> (wr_ptr == 0 && rd_ptr == 0 && count == 0);
endproperty
a1: assert property(p_reset);
c1: cover property(p_reset);

// SVA 2 – Write ACK
property p_wr_ack;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.wr_en && !if_obj.full) |=> if_obj.wr_ack;
endproperty
a2: assert property(p_wr_ack);
c2: cover property(p_wr_ack);

// SVA 3 – Overflow
property p_overflow;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.wr_en && if_obj.full) |=> if_obj.overflow;
endproperty
a3: assert property(p_overflow);
c3: cover property(p_overflow);

// SVA 4 – Underflow
property p_underflow;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (if_obj.rd_en && if_obj.empty) |=> if_obj.underflow;
endproperty
a4: assert property(p_underflow);
c4: cover property(p_underflow);

// SVA 5 – Empty flag
property p_empty;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (count == 0) |-> if_obj.empty;
endproperty
a5: assert property(p_empty);
c5: cover property(p_empty);

// SVA 6 – Full flag
property p_full;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (count == if_obj.FIFO_DEPTH) |-> if_obj.full;
endproperty
a6: assert property(p_full);
c6: cover property(p_full);

// SVA 7 – Almost empty
property p_almostempty;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (count == if_obj.FIFO_DEPTH - 1) |-> if_obj.almostfull;
endproperty
a7: assert property(p_almostempty);
c7: cover property(p_almostempty);

// SVA 8 – Almost full
property p_almostfull;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (count == 1) |-> if_obj.almostempty;
endproperty
a8: assert property(p_almostfull);
c8: cover property(p_almostfull);

// SVA 9 – Counter increases when both en = 1 and not full
property p_count_inc;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (!if_obj.full && if_obj.wr_en && !if_obj.rd_en) |=> (count == $past(count) + 1);
endproperty
a9: assert property(p_count_inc);
c9: cover property(p_count_inc);

// SVA 10 – Counter decreases when both en = 1 and not empty
property p_count_dec;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (!if_obj.empty && !if_obj.wr_en && if_obj.rd_en) |=> (count == $past(count) - 1);
endproperty
a10: assert property(p_count_dec);
c10: cover property(p_count_dec);

// SVA 11 – Pointer and counter limits
property p_limit;
  @(posedge if_obj.clk) disable iff(!if_obj.rst_n)
    (wr_ptr < if_obj.FIFO_DEPTH && rd_ptr < if_obj.FIFO_DEPTH && count <= if_obj.FIFO_DEPTH);
endproperty
a11: assert property(p_limit);
c11: cover property(p_limit);

//`endif

endmodule 