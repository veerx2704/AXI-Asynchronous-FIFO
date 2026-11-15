module axi_fifo_wrapper #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter BURST_LENGTH = 8,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 8,
    parameter PIPELINE_OUTPUT = 0
) (
    input logic s_axi_wclk,
    input logic s_axi_wrst,
    
    // Write Address CHannel (AW)
    input logic s_axi_awvalid,
    input logic [ADDR_WIDTH - 1:0] s_axi_awaddr,
    input logic [ID_WIDTH - 1:0] s_axi_awid,
    input logic [7:0] s_axi_awlen,
    input logic [2:0] s_axi_awsize,
    input logic [1:0] s_axi_awburst,
    output logic s_axi_awready,

    // Write data channel (W)
    input logic [DATA_WIDTH - 1:0] s_axi_wdata,
    input logic s_axi_wvalid,
    input logic s_axi_wlast,
    input logic [STRB_WIDTH - 1:0] s_axi_wstrb,
    output logic s_axi_wready,

    // Write Response channel (B)
    output logic [ID_WIDTH - 1:0] s_axi_bid,
    output logic s_axi_bvalid,
    output logic [1:0] s_axi_bresp,
    input logic s_axi_bready,



    // Read Address Channel (AR)

    input logic m_axi_rclk,
    input logic m_axi_rrst,

    input logic [ID_WIDTH - 1:0] m_axi_arid,
    input logic [ADDR_WIDTH - 1:0] m_axi_araddr,
    input logic [7:0] m_axi_arlen,
    input logic [2:0] m_axi_arsize,
    input logic [1:0] m_axi_arburst,
    input logic m_axi_arvalid,
    output logic m_axi_arready,

    // Read response channel (R)
    input logic m_axi_rready,
    output logic [1:0] m_axi_rresp,
    output logic m_axi_rvalid,
    output logic [DATA_WIDTH - 1:0] m_axi_rdata,
    output logic m_axi_rlast,
    output logic [ID_WIDTH - 1:0] m_axi_rid
);


    axi_compute #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ADDR_WIDTH(ADDR_WIDTH),
                    .BURST_LENGTH(BURST_LENGTH),
                    .STRB_WIDTH(STRB_WIDTH),
                    .ID_WIDTH(ID_WIDTH),
                    .PIPELINE_OUTPUT(PIPELINE_OUTPUT)
    )   AXI (
                    .wclk(s_axi_wclk),
                    .wrst(s_axi_wrst),
                    
                    // Write Address CHannel (AW)
                    .awvalid(s_axi_awvalid),
                    .awaddr(s_axi_awaddr),
                    .awid(s_axi_awid),
                    .awlen(s_axi_awlen),
                    .awsize(s_axi_awsize),
                    .awburst(s_axi_awburst),
                    .awready(s_axi_awready),

                    // Write data channel (W)
                    .wdata(s_axi_wdata),
                    .wvalid(s_axi_wvalid),
                    .wlast(s_axi_wlast),
                    .wstrb(s_axi_wstrb),
                    .wready(s_axi_wready),

                    // Write Response channel (B)
                    .bid(s_axi_bid),
                    .bvalid(s_axi_bvalid),
                    .bresp(s_axi_bresp),
                    .bready(s_axi_bready),



                    // Read Address Channel (AR)

                    .rclk(m_axi_rclk),
                    .rrst(m_axi_rrst),

                    .arid(m_axi_arid),
                    .araddr(m_axi_araddr),
                    .arlen(m_axi_arlen),
                    .arsize(m_axi_arsize),
                    .arburst(m_axi_arburst),
                    .arvalid(m_axi_arvalid),
                    .arready(m_axi_arready),

                    // Read response channel (R)
                    .rready(m_axi_rready),
                    .rresp(m_axi_rresp),
                    .rvalid(m_axi_rvalid),
                    .rdata(m_axi_rdata),
                    .rlast(m_axi_rlast),
                    .rid(m_axi_rid)
    );


endmodule