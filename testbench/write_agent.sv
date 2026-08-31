`ifndef AXI_WRITE_AGENT
`define AXI_WRITE_AGENT

class write_agent extends uvm_agent;
    `uvm_component_utils(write_agent);
    sequencer sequencer_h;
    write_driver driver_h;
    write_monitor monitor_h;

    uvm_analysis_port #(transaction) monw2scor;

    function new(string name = "write_agent", uvm_component parent = null);
        super.new(name,parent);
        monw2scor = new("monw2scor",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer_h = sequencer::type_id::create("sequencer_h",this);
        driver_h = write_driver::type_id::create("driver_h",this);
        monitor_h = write_monitor::type_id::create("monitor_h",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
        monitor_h.monw2scor.connect(monw2scor);
    endfunction

endclass

`endif