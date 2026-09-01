`ifndef AXI_WRITE_SEQUENCER
`define AXI_WRITE_SEQUENCER

class write_sequencer extends uvm_sequencer #(write_transaction, read_transaction);
    `uvm_component_utils(write_sequencer);

    function new(string name = "write_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass

`endif