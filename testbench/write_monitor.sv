`ifndef AXI_WRITE_MONITOR
`define AXI_WRITE_MONITOR

`define vif v_wintf.monitor_mp_w.monitor_cb_w

class write_monitor extends uvm_monitor#(transaction);
    `uvm_component_utils(write_monitor);

    virtual write_interface v_wintf;

    uvm_analysis_port#(transaction) monw2scor;

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
        transaction trans;
        forever begin
            if (v_wintf.wrst == 1) begin
                trans = transaction::type_id::create("trans",this);
            end
        end
        fork begin
            begin
                @(posedge v_wintf.s_axi_wclk)
                while (v_wintf.awvalid == 0 || v_wintf.awready == 0) begin
                    @(posedge v_wintf.s_axi_wclk);
                end
                trans.awvalid   =   `vif.awvalid;
                trans.awready   =   `vif.awready;
                trans.awlen     =   `vif.awlen;
                trans.awaddr    =   `vif.awaddr;
                trans.awaddr[0] =   new[trans.awlen+1];

            end
        end

endclass

`endif