`ifndef AXI_WRITE_MONITOR
`define AXI_WRITE_MONITOR

`define vif v_wintf.monitor_mp_w.monitor_cb_w

class write_monitor extends uvm_monitor#(write_transaction);
    `uvm_component_utils(write_monitor);

    virtual write_interface v_wintf;

    uvm_analysis_port#(write_transaction) monw2scor;

    semaphore sema new(3);

    function new (string name = "write_monitor", uvm_component parent = null);
        super.new(name,parent);
        monw2scor = new("monw2scor",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!`uvm_config_db#(virtual v_wintf)::get(this,"DATA",v_wintf))
            `uvm_fatal("*   (WRITE) MONITOR CONNECTION FAILED   *","");
        else
            `uvm_info("*    (WRITE) MONITOR CONNECTED SUCCESSFULLY  *",UVM_HIGH);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    int wdata_count;
    task run_phase(uvm_phase phase);
        write_transaction trans;
        forever begin
            if (v_wintf.wrst == 1) begin
                trans = write_transaction::type_id::create("trans",this);
                fork begin
                    begin : WRITE_ADDRESS_CHANNEL
                        @(posedge v_wintf.s_axi_wclk)
                        while (v_wintf.awvalid == 0 || v_wintf.awready == 0) begin
                            @(posedge v_wintf.s_axi_wclk);
                        end
                        trans.awvalid   =   `vif.awvalid;
                        trans.awready   =   `vif.awready;
                        trans.awlen     =   `vif.awlen;
                        trans.awaddr    =   new[1];
                        trans.awaddr[0] =   `vif.awaddr;
                        trans.wdata     =   new[trans.awlen+1];
                        sema.put(1);
                    end : WRITE_ADDRESS_CHANNEL

                    begin : WRITE_DATA_CHANNEL
                        @(posedge v_wintf.s_axi_wclk);
                        wdata_count = 0;
                        repeat(v_wintf.wdata.size()) begin
                            while(v_wintf.wvalid == 0 || v_wintf.wready == 0) begin
                                @(posedge v_wintf.s_axi_wclk);
                            end
                            trans.wstrb = `vif.wstrb;
                            trans.wvalid = `vif.wvalid;
                            trans.wready = `vif.wready;
                            trans.wdata[wdata_count] = `vif.wdata;
                            wdata_count++;
                            @(posedge v_wintf.s_axi_wclk);
                        end
                        sema.put(1);
                    end : WRITE_DATA_CHANNEL

                    begin : WRITE_RESPONSE_CHANNEL
                        while (v_wintf.bvalid == 0 || v_wintf.bready == 0) begin
                            @(posedge v_wintf.s_axi_wclk);
                        end
                        trans.bresp = `vif.bresp;
                        trans.bready = `vif.bready;
                        trans.bvalid = `vif.bvalid;
                        sema.put(1);
                    end : WRITE_RESPONSE_CHANNEL

                    begin : MONITOR_WRITE_SCOREBOARD
                        sema.get(3);
                        monw2scor.write(trans);
                        `uvm_info(" (WRITE) MONITOR PACKETS SENT",$sformatf("%0s", trans.sprint),UVM_HIGH);
                        `uvm_info("DATA CHECK: ",$sformatf("\n\n wdata == %p \n wsize == %0d",trans.wdata,trans.wdata.size),UVM_NONE);
                    end : MONITOR_WRITE_SCOREBOARD
                end
                join_none
                wait fork;
            end
            else begin
                @(posedge v_wintf.s_axi_wclk);
                trans = write_transaction::type_id::create("trans",this);
                trans.wrst = `vif.wrst;
                monw2scor.write(trans);
            end
        end
    endtask

    

endclass

`endif