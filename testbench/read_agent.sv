`ifndef AXI_READ_AGENT
`define AXI_READ_AGENT

class read_agent extends uvm_agent;
    `uvm_component_utils(read_agent);

    read_sequencer sequencer_h;
    read_driver driver_h;
    read_monitor monitor_h;

    uvm_analysis_port #(read_transaction) monr2scor;

    function new(string name = "read_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer_h = read_sequencer::type_id::create("sequencer_h",this);
        driver_h = read_driver::type_id::create("driver_h", this);
        monitor_h = read_monitor::type_id::create("monitor_h",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
        monitor_h.monr2scor.connect(monr2scor);
    endfunction

endclass
`endif