`ifndef AXI_ENVIRONMENT
`define AXI_ENVIRONMENT

class environment extends uvm_env;
    `uvm_component_utils(environment);

    write_agent w_agent_h;
    read_agent r_agent_h;
    scoreboard scoreboard_h;
    write_subscriber w_subscriber_h;
    read_subscriber r_subscriber_h;
    virtual_sequencer v_seqr;

    function new (string name = "environment", uvm_component parent = null);
        super.new(name,this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        w_agent_h = write_agent::type_id::create("w_agent_h",this);
        r_agent_h = read_agent::type_id::create("r_agent_h",this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
        w_subscriber_h = write_subscriber::type_id::create("w_subscriber_h",this);
        r_subscriber_h = read_subscriber::type_id::create("r_subscriber_h",this);
        v_seqr = virtual_sequencer::type_id::create("v_seqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        w_agent_h.monw2scor.connect(scoreboard_h.monw2scor.analysis_export);
        w_agent_h.monw2scor.connect(w_subscriber_h.monw2scor.analysis_export);
        r_agent_h.monr2scor.connect(scoreboard_h.monr2scor.analysis_export);
        r_agent_h.monr2scor.connect(r_subscriber_h.monr2scor.analysis_export);

        v_seqr.w_seqr = w_agent_h.sequencer_h;
        v_seqr.r_seqr = r_agent_h.sequencer_h;
    endfunction
endclass

`endif