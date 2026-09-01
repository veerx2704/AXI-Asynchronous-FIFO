`ifndef AXI_SUBSCRIBER
`define AXI_SUBSCRIBER

class subscriber extends uvm_subscriber#(write_transaction, read_transaction);
    `uvm_component_utils(subscriber);

    write_transaction w_trans;
    read_transaction r_trans;

    uvm_tlm_analysis_fifo#(read_transaction) monr2scor;
    uvm_tlm_analysis_fifo#(write_transaction) monw2scor;

    function new (string name = "subscriber", uvm_component parent = null);
        super.new(name,parent);
        axi_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monw2scor = new("monw2scor",this);
        monr2scor = new("monr2scor",this);
    endfunction

    function void w_write(T t);
        axi_cg.sample();
    endfunction

    int wdata_count;
    int rdata_count;
bit wrst;
bit rrst;


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

//READ ADDRESS CHANNEL
bit [15:0] araddr;
bit [7:0]  arlen;
bit [2:0]  arsize;
bit [1:0]  arburst;
// bit             arlock;
// bit [3:0]       arcache;
// bit [2:0]       arprot;
bit        arvalid;
bit        arready;

//READ DATA CHANNEL
bit [31:0]      rdata;
bit [3:0]       rstrb;
bit             rlast;
bit [1:0]       rresp;
bit             rvalid;
bit             rready; 

    task run_phase(uvm_phase phase);
        fork begin
            forever begin
                monr2scor.get(r_trans);
                repeat(r_trans.arlen + 1) begin
                    araddr = r_trans.araddr;
                    arlen = r_trans.arlen;
                    arsize = r_trans.arsize;
                    arburst = r_trans.arburst;
                    arvalid = r_trans.arvalid;
                    arready = r_trans.arready;

                    rdata = r_trans.rdata[rdata_count];
                    rstrb = r_trans.rstrb;
                    rlast = r_trans.rlast;
                    rvalid = r_trans.rvalid;
                    rready = r_trans.rready;

                    rresp = r_trans.rresp;
                    rready = r_trans.rready;
                    rvalid = r_trans.rvalid;
                    
                    rdata_count++;
                    r_write(r_trans);
                end
            end

            forever begin
                monw2scor.get(w_trans);
                repeat(w_trans.awlen + 1) begin
                    awaddr = w_trans.awaddr;
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
                    w_write(w_trans);
                end
            end
        end
        join_none
    endtask

    covergroup axi_cg;
        cp1:  coverpoint rdata      {bins b1 = {[0:32'hffff_ffff]};}
        cp2:  coverpoint araddr     {bins b2 = {[0:16'hffff]};}
        cp3:  coverpoint arlen      {bins b3 = {[0:8'hff]};}
        cp4:  coverpoint arsize     {bins b4 = {[0:3'b111]};}
        cp5:  coverpoint arburst    {bins b5 = {[0:2'b11]}};
        cp6:  coverpoint arvalid    {bins b6 = {[0:1'b1]};}
        cp7:  coverpoint arready    {bins b7 = {[0:1'b1]};}
        cp8:  coverpoint rlast      {bins b8 = {[0:1'b1]};}
        cp9:  coverpoint rstrb      {bins b9 = {4'b0001,4'b0011,4'b0111,4'b1111};}
        cp10: coverpoint rready     {bins b10 = {0,1'b1};}
        cp11: coverpoint rvalid     {bins b11 = {0,1'b1};}
        cp12: coverpoint rresp      {bins b12 = {[0:2'b11]};}

        cp13: coverpoint wdata      {bins b13 = {[0:32'hffff_ffff]};}
        cp14: coverpoint awaddr     {bins b14 = {[0:16'hffff]};}
        cp15: coverpoint awlen      {bins b15 = {[0:8'hff]};}
        cp16: coverpoint awsize     {bins b16 = {[0:3'b111]};}
        cp17: coverpoint awburst    {bins b17 = {[0:2'b11]}};
        cp18: coverpoint awvalid    {bins b18 = {[0:1'b1]};}
        cp19: coverpoint awready    {bins b19 = {[0:1'b1]};}
        cp20: coverpoint wlast      {bins b20 = {[0:1'b1]};}
        cp21: coverpoint wstrb      {bins b21 = {4'b0001,4'b0011,4'b0111,4'b1111};}
        cp22: coverpoint wready     {bins b22 = {0,1'b1};}
        cp23: coverpoint wvalid     {bins b23 = {0,1'b1};}
        cp24: coverpoint bresp      {bins b24 = {[0:2'b11]};}
        cp25: coverpoint bvalid     {bins b25 = {0,1'b1};}
        cp26: coverpoint bready     {bins b26 = {0,1'b1};}
    endgroup

    function void check_phase(uvm_phase phase);
        $display("---------------------------------------------------------------");
        `uvm_info("*    COVERAGE    *",$sformatf("Write Channel Coverage %0d \%",axi_cg.get_coverage()),UVM_NONE);
        $display("---------------------------------------------------------------");
    endfunction

endclass

`endif
