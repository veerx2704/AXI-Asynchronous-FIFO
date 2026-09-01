`ifndef AXI_WRITE_INTERFACE
`define AXI_WRITE_INTERFACE

interface write_interface(input s_axi_wclk);
	parameter DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 16;
	parameter BURST_LEN  = 8;
	parameter STRB_WIDTH = (DATA_WIDTH)/8;
	parameter ID_WIDTH = 8;
	parameter PIPELINE_OUTPUT = 0;	

    logic wrst;

    //WRITE ADDRESS CHANNEL
    logic [ID_WIDTH-1:0]    awid;
    logic [ADDR_WIDTH-1:0]  awaddr;
    logic [7:0]             awlen;
    logic [2:0]             awsize;
    logic [1:0]             awburst;
    logic                   awlock;
    logic [3:0]             awcache;
    logic [2:0]             awprot;
    logic                   awvalid;
    logic                   awready;

    //WRITE DATA CHANNEL
    logic [DATA_WIDTH-1:0]  wdata;
    logic [STRB_WIDTH-1:0]  wstrb;
    logic                   wlast;
    logic                   wvalid;
    logic                   wready;

    //WRITE RESPONSE CHANNEL
    logic [ID_WIDTH-1:0]    bid;
    logic [1:0]             bresp;
    logic                   bvalid;
    logic                   bready;

    clocking driver_cb_w @(posedge s_axi_wclk);

    //WRITE ADDRESS CHANNEL
    input awready;
    output awid, awaddr, awlen, awsize, awburst, awvalid, awcache, awprot, awlock;

    //WRITE DATA CHANNEL
    input wready;
    output wdata, wstrb, wlast, wvalid;

    //WRITE RESPONSE CHANNEL
    input bid, bresp, bvalid;
    output bready;

    endclocking
    clocking monitor_cb_w @(posedge s_axi_wclk);

    //WRITE ADDRESS CHANNEL
    input awready;
    input awid, awaddr, awlen, awsize, awburst, awvalid, awprot, awcache, awlock;

    //WRITE DATA CHANNEL
    input wready;
    input wdata, wstrb, wlast, wvalid;

    //WRITE RESPONSE CHANNEL
    input bid, bresp, bvalid;
    input bready;

    endclocking
    modport driver_mp_w(clocking driver_cb_w, input s_axi_wclk, wrst);
    modport monitor_mp_w(clocking monitor_cb_w, input s_axi_wclk, wrst);

    property awready_awvalid;
        @(posedge s_axi_wclk) disable iff(wrst==0) awvalid |-> ##[0:2] awready;
    endproperty

    assertion1: assert property (awready_awvalid) begin
        `uvm_info("*** ASSERTION PASED *** - AWREADY && AWVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_info("ASSERTION FAILED - AWREADY && AWVALID","",UVM_NONE);
    end

    property wready_wvalid;
        @(posedge s_axi_wclk) disable iff(wrst==0) wvalid |-> ##[0:2] wready;
    endproperty

    assertion2: assert property (wready_wvalid) begin
        `uvm_info("*** ASSERTION PASED *** - WREADY && WVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_info("ASSERTION FAILED - WREADY && WVALID","",UVM_NONE);
    end

    property bready_bvalid;
        @(posedge s_axi_wclk) disable iff(wrst==0) bvalid |-> ##[0:2] bready;
    endproperty

    assertion3: assert property (bready_bvalid) begin
        `uvm_info("*** ASSERTION PASED *** - BREADY && BVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_info("ASSERTION FAILED - BREADY && BVALID","",UVM_NONE);
    end


endinterface

`endif