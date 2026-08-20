module axi_fifo_wrapper #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 16,
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
	input wire [ADDR_WIDTh - 1:0]	s_axi_araddr,
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

initial begin
	if(WORD_SIZE * STRB_WIDTH != DATA_WIDTH) begin
		$error("Error: AXI data width not evenly divisible (instance %m)")
		$finish
	end
	if(2**$clog2(WORD_WIDTH) != WORD_WIDTH) begin
		$error("Error: AXI word width must be even power of two (instance %m)");
		$finish
	end
end

localparam READ_STATE_IDLE = 1'b0;
localparam READ_STATE_BURST = 1'b1;

localparam [1:0] WRITE_STATE_IDLE = 2'b00;
localparam [1:0] WRITE_STATE_BURST = 2'b01;
localparam [1:0] WRITE_STATE_RESP = 2'b10;

endmodule

