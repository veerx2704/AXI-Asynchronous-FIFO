`ifndef AXI_READ_INTERFACE
`define AXI_READ_INTERFACE

interface read_interface(input m_axi_rclk)
	parameter DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 16;
	parameter BURST_LEN  = 8;
	parameter STRB_WIDTH = (DATA_WIDTH)/8;
	parameter ID_WIDTH = 8;
	parameter PIPELINE_OUTPUT = 0;	

    logic rrst;

    //READ ADDRESS CHANNEL
    logic [ID_WIDTH-1:0]    arid;
    logic [ADDR_WIDTH-1:0]  araddr;
    logic [7:0]             arlen;
    logic [2:0]             awsize;
    logic [1:0]             arburst;
    logic                   arlock;
    logic [3:0]             arcache;
    logic [2:0]             arprot;
    logic                   arvalid;
    logic                   arready;

    //READ DATA CHANNEL
    logic [ID_WIDTH-1:0]    rid;
    logic [DATA_WIDTH-1:0]  rdata;
    logic [1:0]             rresp;
    logic                   rlast;
    logic                   rvalid;
    logic                   rready;


    clocking driver_cb_r @(posedge m_axi_rclk)

    //READ ADDRESS CHANNEL
    input arready;
    output arid, araddt, arlen, arsize, arburst, arvalid, arcache,arprot, arlock;

    //READ DATA CHANNEL
    input rid, rdata, rvalid, rresp, rlast;
    output rready;

    endclocking

    modport driver_mp_r(clocking driver_cb_r, input m_axi_rclk, rrst)

    clocking monitor_cb_r @(posedge m_axi_rclk);

    //READ ADDRESS CHANNEL
    input arready;
    input arid, araddr, arlen, arsize, arburst, arvalid, arcache, arprot, arlock;

    //READ DATA CHANNEL
    input rid, rdata, rresp, rlast, rvalid;
    input rready;

    endclocking

    modport monitor_mp_r(clocking monitor_cb_r, input m_axi_rclk, rrst);

    property arready_arvalid;
        @(posedge m_axi_rclk) disable iff(rrst==0) arvalid |-> ##[0:2] arready;
    endproperty

    assertion1: assert property (arready_arvalid) begin
        `uvm_info("*** ASSERTION PASED *** - ARREADY && ARVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_info("ASSERTION FAILED - ARREADY && ARVALID","",UVM_NONE);
    end

    property rready_rvalid;
        @(posedge m_axi_rclk) disable iff(rrst==0) rvalid |-> ##[0:2] rready;
    endproperty

    assertion2: assert property (rready_rvalid) begin
        `uvm_info("*** ASSERTION PASED *** - RREADY && RVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_info("ASSERTION FAILED - RREADY && RVALID","",UVM_NONE);
    end

endinterface

`endif