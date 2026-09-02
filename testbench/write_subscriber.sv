`ifndef AXI_WRITE_SUBSCRIBER
`define AXI_WRITE_SUBSCRIBER

class write_subscriber extends uvm_subscriber#(write_transaction);
    `uvm_component_utils(write_subscriber);

    write_transaction w_trans;

    uvm_tlm_analysis_fifo#(write_transaction) monw2scor;

    function new (string name = "write_subscriber", uvm_component parent = null);
        super.new(name,parent);
        axi_w_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monw2scor = new("monw2scor",this);
    endfunction

    function void write(T t);
        axi_w_cg.sample();
    endfunction


    int wdata_count;
bit wrst;


// WRITE ADDRESS CHANNEL
bit [15:0] awaddr;
bit [7:0]  awlen;
bit [2:0]  awsize;
bit [1:0]  awburst;

// bit         awlock;
// bit [3:0]   awcache;
// bit [2:0]   awprot;

bit         awvalid;
bit         awready;

//WRITE DATA CHANNEL
bit [31:0] wdata;
bit        wlast;
bit [3:0]  wstrb;
bit        wvalid;
bit        wready;

//WRITE RESPONSE CHANNEL
bit [1:0]   bresp;
bit         bvalid;
bit         bready;


    task run_phase(uvm_phase phase);
        forever begin
            monw2scor.get(w_trans);
            repeat(w_trans.awlen + 1) begin
                awaddr = w_trans.awaddr[0];
                awlen = w_trans.awlen;
                awsize = w_trans.awsize;
                awburst = w_trans.awburst;
                awvalid = w_trans.awvalid;
                awready = w_trans.awready;

                wdata = w_trans.wdata[wdata_count];
                wstrb = w_trans.wstrb;
                wlast = w_trans.wlast;
                wvalid = w_trans.wvalid;
                wready = w_trans.wready;

                bresp = w_trans.bresp;
                bready = w_trans.bready;
                bvalid = w_trans.bvalid;
                
                wdata_count++;
                write(w_trans);
            end
        end
    endtask
    covergroup axi_w_cg;

        cp1: coverpoint wdata      {bins b13 = {[0:32'hffff_ffff]};}
        cp2: coverpoint awaddr     {bins b14 = {[0:16'hffff]};}
        cp3: coverpoint awlen      {bins b15 = {[0:8'hff]};}
        cp4: coverpoint awsize     {bins b16 = {[0:3'b111]};}
        cp5: coverpoint awburst    {bins b17 = {[0:2'b11]};}
        cp6: coverpoint awvalid    {bins b18 = {[0:1'b1]};}
        cp7: coverpoint awready    {bins b19 = {[0:1'b1]};}
        cp8: coverpoint wlast      {bins b20 = {[0:1'b1]};}
        cp9: coverpoint wstrb      {bins b21 = {4'b0001,4'b0011,4'b0111,4'b1111};}
        cp10: coverpoint wready     {bins b22 = {0,1'b1};}
        cp11: coverpoint wvalid     {bins b23 = {0,1'b1};}
        cp12: coverpoint bresp      {bins b24 = {[0:2'b11]};}
        cp13: coverpoint bvalid     {bins b25 = {0,1'b1};}
        cp14: coverpoint bready     {bins b26 = {0,1'b1};}
    endgroup

    function void check_phase(uvm_phase phase);
        $display("---------------------------------------------------------------");
        `uvm_info("*    COVERAGE    *",$sformatf("Write Channel Coverage %0d ",axi_w_cg.get_coverage()),UVM_NONE);
        $display("---------------------------------------------------------------");
    endfunction

endclass

`endif
