`ifndef AXI_READ_MONITOR
`define AXI_READ_MONITOR

`define vif v_rintf.monitor_mp_r.monitor_cb_r

class read_monitor extends uvm_monitor#(transaction);
    `uvm_component_utils(read_monitor);

    virtual read_interface v_rintf;

    uvm_analysis_port#(transaction) monr2scor;

    semaphore sema new(2);

    function new (string name = "read_monitor", uvm_component parent = null);
        super.new(name,parent);
        monr2scor = new("monr2scor",this);
    endfunction

    function void build+phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual read_monitor)::get(this,"DATA",v_rintf))
            `uvm_fatal("*   (READ) MONITOR CONNECTION FAILED    *","");
        else
            `uvm_info("*    (READ) MONITOR CONNECTED SUCCESSFULLY   *",UVM_HIGH);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    int rdata_count;
    task run_phase(uvm_phase phase);
        transaction trans;
        forever begin
            if (v_rintf.rrst == 1) begin
                fork begin
                    begin : READ_ADDRESS_CHANNEL
                        @(posedge v_rintf.m_axi_rclk);
                        while (v_rintf.arvalid == 0 || v_rintf.arready == 0) begin
                            @(posedge v_rintf.m_axi_rclk);
                        end
                        trans.arvalid = `vif.arvalid;
                        trans.arready = `vif.arready;
                        trans.arlen = `vif.arlen;
                        trans.araddr = new[1];
                        trans.araddr[0] = `vif.araddr;
                        trans.rdata = new[trans.arlen + 1];
                        sema.put(1);
                    end : READ_ADDRESS_CHANNEL

                    begin : READ_DATA_CHANNEL
                        @(posedge v_rintf.m_axi_rclk);
                        rdata_count = 0;
                        repeat(v_rintf.rdata.size()) begin
                            while
                        end
                    end : READ_DATA_CHANNEL
                end
            end
        end 

endclass

`endif