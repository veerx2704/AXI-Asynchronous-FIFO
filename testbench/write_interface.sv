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
        @(posedge s_axi_wclk) disable iff(!wrst) awvalid |-> ##20 awready;
    endproperty

    property wready_wvalid;
        @(posedge s_axi_wclk) disable iff(!wrst) wvalid |-> ##20 wready;
    endproperty

    property aw_handshake_valid_stable;    // AWVALID must remain asserted until AWREADY is asserted
        @(posedge s_axi_wclk) disable iff (!wrst) (awvalid && !awready) |=> awvalid;
    endproperty

    property w_handshake_valid_stable;  // WVALID must remain asserted until RREADY is asserted
        @(posedge s_axi_wclk) disable iff (!wrst) (wvalid && !wready) |=> wvalid;
    endproperty

    property aw_handshake;
        @(posedge s_axi_wclk) disable iff (!wrst) (awvalid && awready) |-> ##[1:2] !awvalid;
    endproperty

    property w_handshake;
        @(posedge s_axi_wclk) disable iff (!wrst) (wvalid && wready && awvalid && awready) |-> ##[1:2] !wvalid
    endproperty

    property aw_payload_stable;
        @(posedge s_axi_wclk) disable iff (!wrst) (awvalid && !awready) |=> 
                                                            $stable(awaddr) && $stable(awlen) && $stable(awid) &&
                                                            $stable(awsize) && $stable(awburst);
    endproperty

    property w_payload_stable;
        @(posedge s_axi_wclk) disable iff (!wrst) (wvalid && !wready) |=>
                                                            $stable(wdata) && $stable(bresp) &&
                                                            $stable(wlast) && $stable(wstrb) && $stable (bid);
    endproperty

    property aw_burst_legal;
        @(posedge s_axi_wclk) disable iff (!wrst) awvalid |-> (awburst ==2'b00);
    endproperty

    property aw_size_legal;
        @(posedge s_axi_wclk) disable iff (!wrst) awvalid |-> ((DATA_WIDTH/8) >= (1 << awsize));
    endproperty

    property aw_length_legal;
        @(posedge s_axi_wclk) disable iff (!wrst) (awvalid && awburst == 2'b00) |-> (awlen inside {1, 3, 7, 15});
    endproperty

    property reset_n;
        @(posedge s_axi_wclk) !wrst |-> (!awvalid && !wvalid);
    endproperty

    property bready_bvalid;
      @(posedge s_axi_wclk) disable iff(!wrst) bvalid |-> ##20 bready;
    endproperty

    property b_handshake_valid_stable;
        @(posedge s_axi_wclk) disable iff (!wrst) (awready && awvalid && wvalid && wready) |=> bvalid;
    endproperty

    property b_valid_stable;
        @(posedge s_axi_wclk) disable iff (!wrst) (bvalid && !bready) |=> bvalid;
    endproperty

    property b_handshake;
        @(posedge s_axi_wclk) disable iff (!wrst) (bvalid && bready) |-> ##[1:2] !bvalid;
    endproperty

    assertion1: assert property (awready_awvalid) begin
        `uvm_info("*** ASSERTION PASED *** - AWREADY && AWVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_error("ASSERTION FAILED","AWREADY && AWVALID");
    end

    assertion2: assert property (wready_wvalid) begin
        `uvm_info("*** ASSERTION PASED *** - WREADY && WVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_error("ASSERTION FAILED","WREADY && WVALID");
    end

    assertion3: assert property (aw_handshake_valid_stable)
    else begin
        `uvm_error("ASSERTION FAILED","AWVALID STABLE UNTIL AWREADY");
    end

    assertion4: assert property (w_handshake_valid_stable)
    else begin
        `uvm_error("ASSERTION FAILED","WVALID STABLE UNTIL RREADY");
    end

    assertion5: assert property (aw_handshake)
    else begin
        `uvm_error("ASSERTION FAILED","AWVALID NOT DEASSERTED AFTER HANDSHAKE");
    end

    assertion6: assert property (w_handshake)
    else begin
        `uvm_error("ASSERTION FAILED","WVALID NOT DEASSERTED AFTER HANDSHAKE");
    end

    assertion7: assert property (aw_payload_stable)
    else begin
        `uvm_error("ASSERTION FAILED","AW CHANNEL NOT STABLE BEFORE HANDSHAKE");
    end

    assertion8: assert property (w_payload_stable)
    else begin
        `uvm_error("ASSERTION FAILED","W CHANNEL NOT STABLE BEFORE HANDSHAKE");
    end

    assertion9: assert property (aw_burst_legal)
    else begin
        `uvm_error("ASSERTION FAILED","WRITE BURST TYPE IS NOT LEGAL");
    end
    
    assertion10: assert property (aw_size_legal)
    else begin
        `uvm_error("ASSERTION FAILED","WRITE SIZE IS NOT LEGAL");
    end
    
    assertion11: assert property (aw_length_legal)
    else begin
        `uvm_error("ASSERTION FAILED","WRITE LENGTH IS NOT LEGAL");
    end

    assertion12: assert property (reset_n)
    else begin
        `uvm_error("ASSERTION FAILED","ALL SIGNALS MUST BE RESET");
    end

    assertion13: assert property (bready_bvalid) begin
        `uvm_info("*** ASSERTION PASSED *** - BREADY && BVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_error("ASSERTION FAILED","BREADY && BVALID");
    end

    assertion14: assert property (b_handshake_valid_stable)
    else begin
       `uvm_error("ASSERTION FAILED","BREADY NOT ASSERTED AFTER HANDSHAKE"); 
    end

    assertion15: assert property (b_handshake)
    else begin
        `uvm_error("ASSERTION FAILED","BVALID NOT DEASSERTED AFTER BREADY");
    end

    assertion16: assert property (b_valid_stable)
    else begin
        `uvm_error("ASSERTION FAILED","BVALID NOT STABLE UNTIL READY");
    end


endinterface

`endif