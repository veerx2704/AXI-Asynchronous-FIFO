`ifndef AXI_WRITE_MONITOR
`define AXI_WRITE_MONITOR

`define w_vifm v_wintf.monitor_mp_w.monitor_cb_w

class write_monitor extends uvm_monitor#(write_transaction);
    `uvm_component_utils(write_monitor);

    virtual write_interface v_wintf;

    uvm_analysis_port#(write_transaction) monw2scor;

    semaphore sema = new(3);

    function new (string name = "write_monitor", uvm_component parent = null);
        super.new(name,parent);
        monw2scor = new("monw2scor",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual write_interface)::get(this,"","DATA",v_wintf)) begin
            `uvm_fatal("*   (WRITE) MONITOR CONNECTION FAILED   *","");
        end
        else begin
            `uvm_info("*    (WRITE) MONITOR CONNECTED SUCCESSFULLY  *","",UVM_NONE);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    int wdata_count;
  	logic w_handshake;
  	logic aw_handshake;
  	logic b_handshake;
    task run_phase(uvm_phase phase);
        write_transaction trans;
//       	b_handshake = 0;
//       	w_handshake = 0;
//       	aw_handshake = 0;
        forever begin
            if (v_wintf.wrst == 1) begin
                trans = write_transaction::type_id::create("trans",this);
              	
                fork
                    begin : WRITE_ADDRESS_CHANNEL
                        @(posedge v_wintf.s_axi_wclk)
                      if(aw_handshake) aw_handshake = 1;
                      if (v_wintf.awvalid && v_wintf.awready) aw_handshake = 1;
                      while (!aw_handshake) begin
//                         `uvm_info("HANDSHAKE_DEBUG","AWVALID && AWREADY",UVM_NONE);
                            @(posedge v_wintf.s_axi_wclk);
                        end
                        trans.awvalid   =   `w_vifm.awvalid;
                        trans.awready   =   `w_vifm.awready;
                        trans.awlen     =   `w_vifm.awlen;
                        trans.awaddr    =   new[1];
                      trans.awaddr[0] =   `w_vifm.awaddr;
                        trans.wdata     =   new[trans.awlen+1];
                    end : WRITE_ADDRESS_CHANNEL

                    begin : WRITE_DATA_CHANNEL
                        @(posedge v_wintf.s_axi_wclk);
                        wdata_count = 0;
                      	repeat(trans.awlen+1) begin
                          if (w_handshake) w_handshake = 1;
                          if (v_wintf.wvalid && v_wintf.wready) w_handshake = 1;
                          while(!w_handshake) begin
                            `uvm_info("HANDSHAKE_DEBUG","WVALID && WREADY",UVM_NONE);
                                @(posedge v_wintf.s_axi_wclk);
                            end
                            trans.wstrb = `w_vifm.wstrb;
                            trans.wvalid = `w_vifm.wvalid;
                            trans.wready = `w_vifm.wready;
                          trans.wdata[wdata_count] = `w_vifm.wdata;
                            wdata_count++;
                            @(posedge v_wintf.s_axi_wclk);
                        end
                    end : WRITE_DATA_CHANNEL
                join_none
                wait fork;

                    begin : WRITE_RESPONSE_CHANNEL
                      if (b_handshake) b_handshake = 1;
                      if (v_wintf.bvalid && v_wintf.bready) b_handshake = 1;
                      while (!b_handshake) begin
                        `uvm_info("HANDSHAKE_DEBUG","BVALID && BREADY",UVM_NONE);
                            @(posedge v_wintf.s_axi_wclk);
                        end
                        trans.bresp = `w_vifm.bresp;
                        trans.bready = `w_vifm.bready;
                        trans.bvalid = `w_vifm.bvalid;
                    end : WRITE_RESPONSE_CHANNEL

                    begin : MONITOR_WRITE_SCOREBOARD
                        monw2scor.write(trans);
                        `uvm_info(" (WRITE) MONITOR PACKETS SENT",$sformatf("%0s", trans.sprint),UVM_NONE);
                        `uvm_info("DATA CHECK: ",$sformatf("\n\n wdata == %p \n wsize == %0d",trans.wdata,trans.wdata.size),UVM_NONE);
                      $display("%0t AWVALID=%0b AWREADY=%0b WVALID=%0b WREADY=%0b",
         $time,
         v_wintf.awvalid,
         v_wintf.awready,
         v_wintf.wvalid,
         v_wintf.wready);
                    end : MONITOR_WRITE_SCOREBOARD
            end
            else begin
                @(posedge v_wintf.s_axi_wclk);
                trans = write_transaction::type_id::create("trans",this);
                trans.wrst = v_wintf.wrst;
                monw2scor.write(trans);
            end
        end
    endtask

    

endclass

`endif