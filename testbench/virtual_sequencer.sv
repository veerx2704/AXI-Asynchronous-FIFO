`ifndef AXI_VIRTUAL_SEQUENCER
`define AXI_VIRTUAL_SEQUENCER

class virtual_sequencer extends uvm_sequencer;

    write_sequencer w_seqr;
    read_sequencer r_seqr;

    function new(string name = "virtual_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    `uvm_component_utils(virtual_sequencer);
endclass

`endif
