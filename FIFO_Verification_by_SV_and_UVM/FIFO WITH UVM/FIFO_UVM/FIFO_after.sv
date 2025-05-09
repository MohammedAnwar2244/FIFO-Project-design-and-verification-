module FIFO(FIFO_if.DUT if_obj);

 
// declaration of Memory (FIFO)
reg [if_obj.FIFO_WIDTH-1:0] mem [if_obj.FIFO_DEPTH-1:0];

// Declaration of read & write pointers
reg [if_obj.max_fifo_addr-1:0] wr_ptr, rd_ptr;          
reg [if_obj.max_fifo_addr:0] count;              // extra bit to distinguish between full & empty flags & it represents the fill level of the FIFO

// always block specialized for writing operation
always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		wr_ptr <= 0;
		if_obj.overflow <= 0;
		if_obj.wr_ack <= 0;             // reset the sequential outputs as wr_ack , overflow
	end
	else if (if_obj.wr_en && count < if_obj.FIFO_DEPTH) begin
		mem[wr_ptr] <= if_obj.data_in;
		if_obj.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		if_obj.overflow <=0 ;
	end
	else begin 
		if_obj.wr_ack <= 0; 
		if (if_obj.full && if_obj.wr_en)
			if_obj.overflow <= 1;
		else
			if_obj.overflow <= 0;
	end
end

// always block specialized for reading operation
always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		rd_ptr <= 0;
		if_obj.underflow <= 0; 
		    
	end
	else if (if_obj.rd_en && count != 0) begin
		if_obj.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		if_obj.underflow <=0;
		end
	else
	begin
		if(if_obj.empty && if_obj.rd_en)
			if_obj.underflow  <= 1;
		else
			if_obj.underflow  <= 0;
	end
end

// always block specialized for counter signal
always @(posedge if_obj.clk or negedge if_obj.rst_n) begin
	if (!if_obj.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({if_obj.wr_en, if_obj.rd_en} == 2'b10) && !if_obj.full) 
			count <= count + 1;
		else if ( ({if_obj.wr_en, if_obj.rd_en} == 2'b01) && !if_obj.empty)
			count <= count - 1;
		else if (({if_obj.wr_en, if_obj.rd_en} == 2'b11) && if_obj.full)      // priority for write operation
			count <= count - 1;
		else if (({if_obj.wr_en, if_obj.rd_en} == 2'b11) && if_obj.empty)      // priority for read operation
			count <= count + 1;
	end
end

// continous assignment for the combinational outputs
assign if_obj.full = (count == if_obj.FIFO_DEPTH)? 1 : 0;            
assign if_obj.empty = (count == 0)? 1 : 0;                  
assign if_obj.almostfull = (count == if_obj.FIFO_DEPTH-1)? 1 : 0;           
assign if_obj.almostempty = (count == 1)? 1 : 0;

endmodule 