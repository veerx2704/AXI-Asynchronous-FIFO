`ifndef AXI_READ_MONITOR
`define AXI_READ_MONITOR

`define r_vifm v_rintf.monitor_mp_r.monitor_cb_r

class read_monitor extends uvm_monitor#(read_transaction);
    `uvm_component_utils(read_monitor);

    virtual read_interface v_rintf;

    uvm_analysis_port#(read_transaction) monr2scor;

    semaphore sema = new(2);

    function new (string name = "read_monitor", uvm_component parent = null);
        super.new(name,parent);
        monr2scor = new("monr2scor",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual read_interface)::get(this,"","DATA",v_rintf)) begin
            `uvm_fatal("*   (READ) MONITOR CONNECTION FAILED    *","");
        end
        else begin
            `uvm_info("*    (READ) MONITOR CONNECTED SUCCESSFULLY   *","",UVM_HIGH);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    int rdata_count;
    task run_phase(uvm_phase phase);
        read_transaction trans;
        forever begin
            if (v_rintf.rrst == 1) begin
                trans = read_transaction::type_id::create("trans",this);
                fork
                    begin : READ_ADDRESS_CHANNEL
                        @(posedge v_rintf.m_axi_rclk);
                        while (v_rintf.arvalid == 0 || v_rintf.arready == 0) begin
                            @(posedge v_rintf.m_axi_rclk);
                        end
                        trans.arvalid = `r_vifm.arvalid;
                        trans.arready = `r_vifm.arready;
                        trans.arlen = `r_vifm.arlen;
                        trans.araddr = new[1];
                        trans.araddr[0] = `r_vifm.araddr;
                        trans.rdata = new[trans.arlen + 1];
                        sema.put(1);
                    end : READ_ADDRESS_CHANNEL

                    begin : READ_DATA_CHANNEL
                        @(posedge v_rintf.m_axi_rclk);
                        rdata_count = 0;
                        repeat(v_rintf.rdata.size()) begin
                            while (v_rintf.rvalid == 0 || v_rintf.rready == 0) begin
                                @(posedge v_rintf.m_axi_rclk);
                            end
                            trans.rvalid = `r_vifm.rvalid;
                            trans.rready = `r_vifm.rready;
                            trans.rdata[rdata_count] = `r_vifm.rdata;
                            rdata_count++;
                            @(posedge v_rintf.m_axi_rclk);
                        end
                        sema.put(1);
                    end : READ_DATA_CHANNEL

                    begin : MONITOR_WRITE_SCOREBOARD
                        sema.get(2);
                        monr2scor.write(trans);
                        `uvm_info(" (READ) MONITOR PACKETS SENT", $sformatf("%0s",trans.sprint),UVM_HIGH);
                        `uvm_info(" DATA CHECK: ", $sformatf("\n\n rdata == %p \n rsize == %0d",trans.rdata,trans.rdata.size),UVM_NONE);
                    end : MONITOR_WRITE_SCOREBOARD
                

                join_none
                wait fork;
            end
            else begin
                @(posedge v_rintf.m_axi_rclk);
                trans = read_transaction::type_id::create("trans",this);
                trans.rrst = v_rintf.rrst;
                monr2scor.write(trans);
            end
        end 
    endtask

endclass

`endif