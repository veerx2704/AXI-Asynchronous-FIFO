`ifndef AXI_READ_SEQUENCER
`define AXI_READ_SEQUENCER

class read_sequencer extends uvm_sequencer #(write_transaction, read_transaction);
    `uvm_component_utils(read_sequencer);

    function new(string name = "read_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass

`endif