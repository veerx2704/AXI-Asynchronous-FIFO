`ifndef AXI_READ_INTERFACE
`define AXI_READ_INTERFACE

interface read_interface(input m_axi_rclk);
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
    logic [2:0]             arsize;
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


    clocking driver_cb_r @(posedge m_axi_rclk);

    //READ ADDRESS CHANNEL
    input arready;
    output arid, araddr, arlen, arsize, arburst, arvalid, arcache,arprot, arlock;

    //READ DATA CHANNEL
    input rid, rdata, rvalid, rresp, rlast;
    output rready;

    endclocking

    modport driver_mp_r(clocking driver_cb_r, input m_axi_rclk, rrst);

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
        @(posedge m_axi_rclk) disable iff(!rrst) arvalid |-> ##20 arready;
    endproperty

    property rready_rvalid;
        @(posedge m_axi_rclk) disable iff(!rrst) rvalid |-> ##20 rready;
    endproperty

    property ar_handshake_valid_stable;    // ARVALID must remain asserted until ARREADY is asserted
        @(posedge m_axi_rclk) disable iff (!rrst) (arvalid && !arready) |=> arvalid;
    endproperty

    property r_handshake_valid_stable;  // RVALID must remain asserted until RREADY is asserted
        @(posedge m_axi_rclk) disable iff (!rrst) (rvalid && !rready) |=> rvalid;
    endproperty

    property ar_handshake;
        @(posedge m_axi_rclk) disable iff (!rrst) (arvalid && arready) |-> ##[1:2] !arvalid;
    endproperty

    property r_handshake;
        @(posedge m_axi_rclk) disable iff (!rrst) (rvalid && rready && arvalid && arready) |-> ##[1:2] !rvalid
    endproperty

    property ar_payload_stable;
        @(posedge m_axi_rclk) disable iff (!rrst) (arvalid && !arready) |=> 
                                                            $stable(araddr) && $stable(arlen) && $stable(arid) &&
                                                            $stable(arsize) && $stable(arburst);
    endproperty

    property r_payload_stable;
        @(posedge m_axi_rclk) disable iff (!rrst) (rvalid && !rready) |=>
                                                            $stable(rid) && $stable(rdata) && $stable(rresp) &&
                                                            $stable(rlast);
    endproperty

    property ar_burst_legal;
        @(posedge m_axi_rclk) disable iff (!rrst) arvalid |-> (arburst ==2'b00);
    endproperty

    property ar_size_legal;
        @(posedge m_axi_rclk) disable iff (!rrst) arvalid |-> ((DATA_WIDTH/8) >= (1 << arsize));
    endproperty

    property ar_length_legal;
        @(posedge m_axi_rclk) disable iff (!rrst) (arvalid && arburst == 2'b00) |-> (arlen inside {1, 3, 7, 15});
    endproperty

    property reset_n;
        @(posedge m_axi_rclk) !rrst |-> (!arvalid && !rvalid);
    endproperty

    assertion1: assert property (arready_arvalid) begin
        `uvm_info("*** ASSERTION PASED *** - ARREADY && ARVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_error("ASSERTION FAILED", "ARREADY && ARVALID");
    end

    assertion2: assert property (rready_rvalid) begin
        `uvm_info("*** ASSERTION PASED *** - RREADY && RVALID","",UVM_HIGH);    
    end
    else begin
        `uvm_error("ASSERTION FAILED","RREADY && RVALID");
    end

    assertion3: assert property (ar_handshake_valid_stable)
    else begin
        `uvm_error("ASSERTION FAILED","ARVALID STABLE UNTIL ARREADY");
    end

    assertion4: assert property (r_handshake_valid_stable)
    else begin
        `uvm_error("ASSERTION FAILED","RVALID STABLE UNTIL RREADY");
    end

    assertion5: assert property (ar_handshake)
    else begin
        `uvm_error("ASSERTION FAILED","ARVALID NOT DEASSERTED AFTER HANDSHAKE");
    end

    assertion6: assert property (r_handshake)
    else begin
        `uvm_error("ASSERTION FAILED","RVALID NOT DEASSERTED AFTER HANDSHAKE");
    end

    assertion7: assert property (ar_payload_stable)
    else begin
        `uvm_error("ASSERTION FAILED","AR CHANNEL NOT STABLE BEFORE HANDSHAKE");
    end

    assertion8: assert property (r_payload_stable)
    else begin
        `uvm_error("ASSERTION FAILED","R CHANNEL NOT STABLE BEFORE HANDSHAKE");
    end

    assertion9: assert property (ar_burst_legal)
    else begin
        `uvm_error("ASSERTION FAILED","READ BURST TYPE IS NOT LEGAL");
    end
    
    assertion10: assert property (ar_size_legal)
    else begin
        `uvm_error("ASSERTION FAILED","READ SIZE IS NOT LEGAL");
    end
    
    assertion11: assert property (ar_length_legal)
    else begin
        `uvm_error("ASSERTION FAILED","READ LENGTH IS NOT LEGAL");
    end

    assertion12: assert property (reset_n)
    else begin
        `uvm_error("ASSERTION FAILED","ALL SIGNALS MUST BE RESET");
    end

endinterface

`endif