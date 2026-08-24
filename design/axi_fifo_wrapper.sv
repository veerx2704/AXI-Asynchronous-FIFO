`timescale 1ns / 1ps
module axi_fifo_wrapper #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 16,
	parameter BURST_LEN  = 8,
	parameter STRB_WIDTH = (DATA_WIDTH/8),
	parameter ID_WIDTH = 8,
	parameter PIPELINE_OUTPUT = 0	
) (
	input wire clk,
	input wire rst,
	
	//Write address channel
	input wire [ID_WIDTH - 1:0] 	s_axi_awid,
	input wire [ADDR_WIDTH - 1:0]	s_axi_awaddr,
	input wire [7:0]		s_axi_awlen,
	input wire [2:0]		s_axi_awsize,
	input wire [1:0]		s_axi_awburst,
	input wire 			s_axi_awlock,
	input wire [3:0]		s_axi_awcache,
	input wire [2:0]		s_axi_awprot,
	input wire 			s_axi_awvalid,
	output wire			s_axi_awready,
	
	//Write data channel
	input wire [DATA_WIDTH - 1:0]	s_axi_wdata,
	input wire [STRB_WIDTH - 1:0]	s_axi_wstrb,
	input wire 			s_axi_wlast,
	input wire			s_axi_wvalid,
	
	output wire			s_axi_wready,
	
	//Write response channel
	output wire [ID_WIDTH - 1:0]	s_axi_bid,
	output wire [1:0]		s_axi_bresp,
	output wire 			s_axi_bvalid,
	input wire			s_axi_bready,
	
	//Read address channel
	input wire [ID_WIDTH - 1:0]	s_axi_arid,
	input wire [ADDR_WIDTH - 1:0]	s_axi_araddr,
	input wire [7:0]		s_axi_arlen,
	input wire [2:0]		s_axi_arsize,
	input wire [1:0]		s_axi_arburst,
	input wire 			s_axi_arlock,
	input wire [3:0]		s_axi_arcache,
	input wire [2:0]		s_axi_arprot,
	input wire			s_axi_arvalid,
	
	output wire			s_axi_arready,
	
	//Read Data channel
	output wire [ID_WIDTH - 1:0]	s_axi_rid,
	output wire [DATA_WIDTH - 1:0]	s_axi_rdata,
	output wire [1:0]		s_axi_rresp,
	output wire 			s_axi_rlast,
	output wire 			s_axi_rvalid,
	
	input wire			s_axi_rready
);
parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
parameter WORD_WIDTH = STRB_WIDTH;
parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH;	//always 8
parameter FIFO_ADDRESS = 32'h02000000;			//Starting address of fifo

initial begin
	if(WORD_SIZE * STRB_WIDTH != DATA_WIDTH) begin
		$error("Error: AXI data width not evenly divisible (instance %m)");
		$finish;
	end
	if(2**$clog2(WORD_WIDTH) != WORD_WIDTH) begin
		$error("Error: AXI word width must be even power of two (instance %m)");
		$finish;
	end
end


localparam READ_STATE_IDLE = 1'b0;
localparam READ_STATE_BURST = 1'b1;

localparam [1:0] WRITE_STATE_IDLE = 2'b00;
localparam [1:0] WRITE_STATE_BURST = 2'b01;
localparam [1:0] WRITE_STATE_RESP = 2'b10;

localparam [1:0] OKAY   = 2'b00;
localparam [1:0] EXOKAY = 2'b01;	// This parameter is specifically to mention inoperability due to status of FIFO (full or empty)
localparam [1:0] SLVERR = 2'b10;	// None of the other options occur, but something might be wrong
localparam [1:0] DECERR = 2'b11;	// There has been some mistake in the data sent by master

reg read_state_reg = READ_STATE_IDLE, read_state_next;

reg [1:0] write_state_reg = WRITE_STATE_IDLE, write_state_next;


//READ ADDRESS CHANNEL REG SIGNALS
reg [ID_WIDTH - 1:0] read_id_reg = {ID_WIDTH{1'b0}}, read_id_next;

reg [ADDR_WIDTH - 1:0] read_addr_reg = {ADDR_WIDTH{1'b0}}, read_addr_next;

reg [7:0] read_count_reg = 8'd0, read_count_next;

reg [2:0] read_size_reg = 3'd0, read_size_next;

reg [1:0] read_burst_reg = 2'd0, read_burst_next;

reg s_axi_arready_reg = 1'b0, s_axi_arready_next;


//READ DATA CHANNEL REG SIGNALs

reg [ID_WIDTH - 1:0] s_axi_rid_reg = {ID_WIDTH{1'b0}}, s_axi_rid_next;

reg [DATA_WIDTH - 1:0] s_axi_rdata_reg = {DATA_WIDTH{1'b0}}, s_axi_rdata_next;

reg s_axi_rlast_reg = 1'b0, s_axi_rlast_next;

reg s_axi_rvalid_reg = 1'b0, s_axi_rvalid_next;

reg [ID_WIDTH - 1:0] s_axi_rid_pipe_reg = {ID_WIDTH{1'b0}};

reg [DATA_WIDTH - 1:0] s_axi_rdata_pipe_reg = {DATA_WIDTH{1'b0}};

reg s_axi_rlast_pipe_reg = 1'b0;

reg s_axi_rvalid_pipe_reg = 1'b0;

reg [1:0] rresp_reg = OKAY, rresp_next;

//WRITE ADDRESS CHANNEL REG SIGNALS

reg [ID_WIDTH - 1:0] write_id_reg = {ID_WIDTH{1'b0}}, write_id_next;

reg [ADDR_WIDTH - 1:0] write_addr_reg = {ADDR_WIDTH{1'b0}}, write_addr_next;

reg [7:0] write_count_reg = 8'd0, write_count_next;

reg [2:0] write_size_reg = 3'd0, write_size_next;

reg [1:0] write_burst_reg = 2'd0, write_burst_next;

reg s_axi_awready_reg = 1'b0, s_axi_awready_next;


//WRITE DATA CHANNEL REG SIGNALS

reg s_axi_wready_reg = 1'b0, s_axi_wready_next;


//WRITE RESPONSE CHANNEL REG SIGNALS

reg [ID_WIDTH - 1:0] s_axi_bid_reg = {ID_WIDTH{1'b0}}, s_axi_bid_next;

reg s_axi_bvalid_reg = 1'b0, s_axi_bvalid_next;

reg [1:0] bresp_reg = OKAY, bresp_next;


//READ ADDRESS CHANNEL WIRE SIGNALS

assign s_axi_arready = s_axi_arready_reg;


//READ DATA CHANNEL WIRE SIGNALS

assign s_axi_rid = PIPELINE_OUTPUT ? s_axi_rid_pipe_reg : s_axi_rid_reg;

assign s_axi_rdata = PIPELINE_OUTPUT ? s_axi_rdata_pipe_reg : s_axi_rdata_reg;

assign s_axi_rresp = rresp_reg;

assign s_axi_rlast = PIPELINE_OUTPUT ? s_axi_rlast_pipe_reg : s_axi_rlast_reg;

assign s_axi_rvalid = PIPELINE_OUTPUT ? s_axi_rvalid_pipe_reg : s_axi_rvalid_reg;


//WRITE ADDRESS CHANNEL WIRE SIGNALS

assign s_axi_awready = s_axi_awready_reg;


//WRITE DATA CHANNEL WIRE SIGNALS

assign s_axi_wready = s_axi_wready_reg;


//WRITE RESPONSE CHANNEL WIRE SIGNALS

assign s_axi_bid = s_axi_bid_reg;

assign s_axi_bresp = bresp_reg;

assign s_axi_bvalid = s_axi_bvalid_reg;

wire s_axi_bvalid_net = s_axi_bvalid_reg;

//Address validity is not necessarily a check that should be performed, since this is just a fifo.
//However, for the purpose of integration with a system, address validity can be performed to check the location of the fifo buffer in memory
//For that reason, address validation may be necessary.

localparam FIFO_DEPTH = 16;

reg fifo_wen;
reg fifo_ren;
reg fifo_full;
reg fifo_empty;
//reg fifo_wrst;
//reg fifo_rrst;
reg [$clog2(FIFO_DEPTH):0] fifo_rptr_out;
reg [$clog2(FIFO_DEPTH):0] fifo_wptr_out;

async_fifo #(.data_width(DATA_WIDTH), .N(FIFO_DEPTH)) FIFO_INST(.wdata(s_axi_wdata),
														  .wptr_out(fifo_wptr_out),
														  .wen(fifo_wen),
														  .wclk(clk),
														  .wrst(rst),
														  .rrst(rst),
														  .rclk(clk),
														  .ren(fifo_ren),
														  .rptr_out(fifo_rptr_out),
														  .rdata(s_axi_rdata_next),
														  .fifo_full(fifo_full),
														  .fifo_empty(fifo_empty));

wire [$clog2(FIFO_DEPTH):0] filled_entries;
wire [$clog2(FIFO_DEPTH):0] available_entries;

//To calculate available space in FIFO, subtract rptr from wptr.
//wptr will always be ahead of rptr (unless empty). 
//Diff = wptr - rptr

wire diff_borrow0, diff_borrow1;

adder #(.WIDTH($clog2(FIFO_DEPTH)+1)) LEN_FILLED (.SrcA(fifo_wptr_out),
										  .SrcB(~fifo_rptr_out),
										  .Cin(1'b1),
										  .Sum(filled_entries),
										  .Cout(diff_borrow0));
wire [$clog2(FIFO_DEPTH):0] total_capacity = '1 << $clog2(FIFO_DEPTH);
adder #(.WIDTH($clog2(FIFO_DEPTH)+1)) LEN_AVAILABLE (.SrcA(total_capacity),
										  .SrcB(~filled_entries),
										  .Cin(1'b1),
										  .Sum(available_entries),
										  .Cout(diff_borrow1));

always_comb begin
	write_state_next = WRITE_STATE_IDLE;
	fifo_wen = 1'b0;
	bresp_next = OKAY;

	write_id_next    = write_id_reg;
	write_addr_next  = write_addr_reg;
	write_count_next = write_count_reg;
	write_size_next  = write_size_reg;
	write_burst_next = write_burst_reg;

	s_axi_awready_next = 1'b0;
	s_axi_wready_next  = 1'b0;
	s_axi_bid_next     = s_axi_bid_reg;
	s_axi_bvalid_next  = s_axi_bvalid_reg && !s_axi_bready;	


	case (write_state_reg)
		WRITE_STATE_IDLE: begin
			s_axi_awready_next = 1'b1;		//FIFO is ready for writing when it is not full
			if (s_axi_awready && s_axi_awvalid)	begin			//Start operation only when handshake is complete
				write_id_next    = s_axi_awid;
				write_addr_next  = s_axi_awaddr;
				write_count_next = s_axi_awlen;				//Check later whether all the requested entries can be accommodated in the FIFO
				write_size_next  = s_axi_awsize < $clog2(STRB_WIDTH) ? s_axi_awsize : $clog2(STRB_WIDTH);
				write_burst_next = s_axi_awburst;

				s_axi_wready_next = 1'b1;
				bresp_next = OKAY;
				write_state_next = WRITE_STATE_BURST;
			end
		end	
		WRITE_STATE_BURST: begin
			s_axi_wready_next = fifo_full ? 1'b0 : 1'b1;
			if (write_addr_next == FIFO_ADDRESS) begin
				if (s_axi_wready && s_axi_wvalid) begin		
					if (s_axi_awlen > available_entries) begin		//The requested data cannot be all fitted into the fifo buffer
						bresp_next = EXOKAY;						//Indicate that FIFO can become full before completion of operation
						write_state_next = WRITE_STATE_RESP;		// Go to response state
					end
					else begin
						fifo_wen = 1'b1;
						if (write_burst_reg != 2'b00) begin
							bresp_next = DECERR;					// A FIFO specifically needs a fixed address
							write_state_next = WRITE_STATE_RESP;	// A decoding error has occured and must be reported back
						end
						write_count_next = write_count_reg - 1;
						if (write_count_reg > 0) begin
							if (!fifo_full) begin
								write_state_next = WRITE_STATE_BURST;
							end 
							else begin
								bresp_next = EXOKAY;
								write_state_next = WRITE_STATE_RESP;
							end
						end
						else begin
							s_axi_wready_next = 1'b0;
							if (s_axi_bready || !s_axi_bvalid_net) begin
								s_axi_bid_next = write_id_reg;
								s_axi_bvalid_next = 1'b1;
								s_axi_awready_next = 1'b1;
								write_state_next = WRITE_STATE_IDLE;
							end
							else begin
								write_state_next = WRITE_STATE_RESP;
							end
						end
					end
				end
				else begin
				    write_state_next = WRITE_STATE_BURST;
				end
			end
			else begin
				bresp_next = DECERR;
				write_state_next = WRITE_STATE_RESP;
			end
		end
		WRITE_STATE_RESP : begin
			if (s_axi_bready || !s_axi_bvalid_net) begin
				s_axi_bid_next = write_id_reg;
				s_axi_bvalid_next = 1'b1;
				s_axi_awready_next = 1'b1;
				write_state_next = WRITE_STATE_IDLE;
			end
			else begin
				write_state_next = WRITE_STATE_RESP;
			end
		end
	endcase
end

// Write channel register update
always_ff @(posedge clk) begin
	if (!rst) begin
		write_state_reg   <= WRITE_STATE_IDLE;
		write_id_reg      <= '0;
		write_count_reg   <= '0;
		write_size_reg    <= '0;
		write_burst_reg   <= '0;

		s_axi_awready_reg <= '0;
		s_axi_wready_reg  <= '0;
		s_axi_bid_reg     <= '0;
		s_axi_bvalid_reg  <= '0;

	end
	else begin
		write_state_reg   <= write_state_next;
		write_addr_reg    <= write_addr_next;
		write_id_reg      <= write_id_next;
		write_count_reg   <= write_count_next;
		write_size_reg    <= write_size_next;
		write_burst_reg   <= write_burst_next;

		s_axi_awready_reg <= s_axi_awready_next;
		s_axi_wready_reg  <= s_axi_wready_next;
		s_axi_bid_reg     <= s_axi_bid_next;
		s_axi_bvalid_reg  <= s_axi_bvalid_next;
	end
end

//READ CHANNEL CONTROL

always_comb begin
	read_state_next = READ_STATE_IDLE;

	fifo_ren = 1'b0;

	s_axi_rid_next    = s_axi_rid_reg;
	s_axi_rlast_next  = s_axi_rlast_reg;
	s_axi_rvalid_next = s_axi_rvalid_reg && !(s_axi_rready || (PIPELINE_OUTPUT && !s_axi_rvalid_pipe_reg));

	read_id_next    = read_id_reg;
	read_addr_next  = read_addr_reg;
	read_count_next = read_count_reg;
	read_size_next  = read_size_reg;
	read_burst_next = read_burst_reg;
	rresp_next      = OKAY;

	s_axi_arready_next = 1'b0;

	case(read_state_reg)
		READ_STATE_IDLE: begin
			s_axi_arready_next = 1'b1;												//Ready to read data if fifo is not already empty
			if(s_axi_arready && s_axi_arvalid) begin
				//if (filled_entries > s_axi_arlen || filled_entries == s_axi_arlen ) begin				//Proceed to Reading only if there is data filled in the fifo
					read_id_next    = s_axi_arid;
					read_addr_next  = s_axi_araddr;
					read_count_next = s_axi_arlen;														
					read_size_next  = s_axi_arsize < $clog2(STRB_WIDTH) ? s_axi_arsize : $clog2(STRB_WIDTH);
					read_burst_next = s_axi_arburst;

					s_axi_arready_next = 1'b0;
					read_state_next = READ_STATE_BURST;
				//end
			end
			else begin
				read_state_next = READ_STATE_IDLE;
			end
		end
		READ_STATE_BURST: begin
			if (read_addr_next == FIFO_ADDRESS) begin
				if (s_axi_rready || (PIPELINE_OUTPUT && !s_axi_rvalid_pipe_reg) || !s_axi_rvalid_reg) begin
					if(!(filled_entries < s_axi_arlen)) begin
						fifo_ren = fifo_empty ? 1'b0 : 1'b1;
						s_axi_rvalid_next = 1'b1;
						s_axi_rid_next = read_id_reg;
						s_axi_rlast_next = read_count_reg == 0;
						if(read_burst_reg != 2'b00) begin
							rresp_next = DECERR;					// The burst type should be 2'b00 for accessing FIFO
							read_state_next = READ_STATE_IDLE;
						end
						read_count_next = read_count_reg - '1;		// Start reading fifo entries
						if (read_count_reg > 0) begin
							read_state_next = READ_STATE_BURST;
						end
						else begin
							s_axi_arready_next = 1'b1;
							read_state_next = READ_STATE_IDLE;
						end
					end
					else begin
						fifo_ren = 1'b0;
						rresp_next = EXOKAY;						// The requested operation cannot be performed as there are not enough entries in FIFO as requested
						s_axi_rvalid_next = 1'b0;
						s_axi_rid_next = read_id_reg;
						s_axi_rlast_next = 1'b0;
						s_axi_arready_next = 1'b1;
						read_state_next = READ_STATE_IDLE;
					end	
				end
			end
			else begin
				rresp_next = DECERR;						//The provided address is not the same as starting address of FIFO
				read_state_next = READ_STATE_IDLE;
			end
		end
	endcase
end


always_ff @(posedge clk) begin
	if (!rst) begin
		read_state_reg <= READ_STATE_IDLE;

		s_axi_arready_reg     <= 1'b0;
		s_axi_rvalid_reg      <= 1'b0;
		s_axi_rvalid_pipe_reg <= 1'b0;
		s_axi_rdata_reg 	  <= '0;
		rresp_reg <= rresp_next;

		read_id_reg <= '0;
		read_count_reg <= '0;
		read_size_reg <= '0;
		read_burst_reg <= '0;

		s_axi_rid_pipe_reg 	   <= '0;
		s_axi_rdata_pipe_reg   <= '0;
		s_axi_rlast_pipe_reg   <= '0;
		s_axi_rvalid_pipe_reg  <= '0;
	end
		read_state_reg <= read_state_next;

		read_id_reg <= read_id_next;
		read_addr_reg <= read_addr_next;
		read_count_reg <= read_count_next;
		read_size_reg <= read_size_next;
		read_burst_reg <= read_burst_next;
		rresp_reg <= rresp_next;

		s_axi_arready_reg <= s_axi_arready_next;
		s_axi_rid_reg <= s_axi_rid_next;
		s_axi_rlast_reg <= s_axi_rlast_next;
		s_axi_rvalid_reg <= s_axi_rvalid_next;
		s_axi_rdata_reg <= s_axi_rdata_next;

		if (!s_axi_rvalid_pipe_reg || s_axi_rready) begin
			s_axi_rid_pipe_reg <= s_axi_rid_reg;
			s_axi_rdata_pipe_reg <= s_axi_rdata_reg;
			s_axi_rlast_pipe_reg <= s_axi_rlast_reg;
			s_axi_rvalid_pipe_reg <= s_axi_rvalid_reg;
		end
end

endmodule


