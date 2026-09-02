`ifndef AXI_READ_SUBSCRIBER
`define AXI_READ_SUBSCRIBER

class read_subscriber extends uvm_subscriber;
    `uvm_component_utils(read_subscriber);

    read_transaction r_trans;

    uvm_tlm_analysis_fifo#(read_transaction) monr2scor;

    function new (string name = "read_subscriber", uvm_component parent = null);
        super.new(name,parent);
        axi_r_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monr2scor = new("monr2scor",this);
    endfunction


    function void write(read_transaction r);
        axi_r_cg.sample();
    endfunction
    int rdata_count;
bit rrst;

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
bit             rlast;
bit [1:0]       rresp;
bit             rvalid;
bit             rready; 

    task run_phase(uvm_phase phase);
        forever begin
            monr2scor.get(r_trans);
            repeat(r_trans.arlen + 1) begin
                araddr = r_trans.araddr[0];
                arlen = r_trans.arlen;
                arsize = r_trans.arsize;
                arburst = r_trans.arburst;
                arvalid = r_trans.arvalid;
                arready = r_trans.arready;

                rdata = r_trans.rdata[rdata_count];
                rlast = r_trans.rlast;
                rvalid = r_trans.rvalid;
                rready = r_trans.rready;

                rresp = r_trans.rresp;
                rready = r_trans.rready;
                rvalid = r_trans.rvalid;
                
                rdata_count++;
                write(r_trans);
            end
        end

    endtask

    covergroup axi_r_cg;
        cp1:  coverpoint rdata      {bins b1 = {[0:32'hffff_ffff]};}
        cp2:  coverpoint araddr     {bins b2 = {[0:16'hffff]};}
        cp3:  coverpoint arlen      {bins b3 = {[0:8'hff]};}
        cp4:  coverpoint arsize     {bins b4 = {[0:3'b111]};}
        cp5:  coverpoint arburst    {bins b5 = {[0:2'b11]};}
        cp6:  coverpoint arvalid    {bins b6 = {[0:1'b1]};}
        cp7:  coverpoint arready    {bins b7 = {[0:1'b1]};}
        cp8:  coverpoint rlast      {bins b8 = {[0:1'b1]};}
        cp10: coverpoint rready     {bins b10 = {0,1'b1};}
        cp11: coverpoint rvalid     {bins b11 = {0,1'b1};}
        cp12: coverpoint rresp      {bins b12 = {[0:2'b11]};}
    endgroup


    function void check_phase(uvm_phase phase);
        $display("---------------------------------------------------------------");
        `uvm_info("*    COVERAGE    *",$sformatf("Read Channel Coverage %0d \%",axi_r_cg.get_coverage()),UVM_NONE);
        $display("---------------------------------------------------------------");
    endfunction

endclass

`endif
