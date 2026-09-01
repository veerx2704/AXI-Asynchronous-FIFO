`ifndef AXI_SCOREBOARD
`define AXI_SCOREBOARD

`define OKAY 2'b00
`define EXOKAY 2'b01
`define SLVERR 2'b10
`define DECERR 2'b11

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard);

    uvm_tlm_analysis_fifo#(read_transaction) monr2scor;
    uvm_tlm_analysis_fifo#(write_transaction) monw2scor;

    write_transaction w_trans;
    read_transaction r_trans;
    bit [31:0] fifo_queue[$];

    bit [31:0] wdata[$];
    bit [31:0] rdata[$];

    function new (string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
        monw2scor = new("monw2scor",this);
        monr2scor = new("monr2scor",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    int wdata_count;
    int rdata_count;
    int awlen;
    int arlen;
    bit [31:0] data_inspect;
    bit data_valid;

    task run_phase(uvm_phase phase);
        fork
            forever begin
                wdata.delete();
                monw2scor.get(w_trans);
                `uvm_info("SCOREBOARD-PACKETS (WRITE) RECEIVED",$sformatf("%p",w_trans.wdata),UVM_HIGH);
                if (w_trans.bresp == `OKAY) begin                   //DATA WILL ONLY BE READ IF FIFO WILL NOT BECOME FULL (ALL OKAY)
                    for(int i = 0; i < w_trans.awlen; i++) begin
                        if (w_trans.wstrb == 4'b1111)
                            wdata[i] = w_trans.wdata[i];
                        else if (w_trans.wstrb == 4'b0111)
                            wdata[i][23:0] = w_trans.wdata[i][23:0];
                        else if (w_trans.wstrb == 4'b0011)
                            wdata[i][15:0] = w_trans.wdata[i][15:0];
                        else if (w_trans.wstrb == 4'b0001)
                            wdata[i][7:0] = w_trans.wdata[i][7:0];
                        fifo_queue.push_back(wdata[i]);
                    end
                end
                else if (w_trans.bresp == `EXOKAY) begin
                    `uvm_warning("*    SCOREBOARD    *","Cannot write to DUT, the buffer is / might become full");
                end
                else if (w_trans.bresp == `SLVERR) begin
                    `uvm_error("*    SCOREBOARD    *","The DUT is erroring out");
                end
                else if (w_trans.bresp == `DECERR) begin
                    `uvm_warning("*    SCOREBOARD    *","The transaction may not be intended for DUT, there is decoding error");
                end
            end

            forever begin
                monr2scor.get(r_trans);
                `uvm_info("SCOREBOARD-PACKETS (READ) RECEIVED",$sformatf("%p",r_trans.rdata),UVM_HIGH);        
                if (r_trans.rresp == `OKAY) begin                       // DATA WILL ONLY BE READ IF FIFO IS NOT EMPTY (ALL OKAY)
                    for(int i = 0; i < r_trans.arlen; i++) begin
                        rdata[i] = r_trans.rdata[i];
                        data_inspect = fifo_queue.pop_front();
                        data_valid = rdata[i]==(data_inspect);

                        if (data_valid) begin
                            `uvm_info("*    SCOREBOARD    *","COMPARE SUCCESSFUL",UVM_LOW);
                            `uvm_info("PACKET INFO:",$sformatf("Expected Data: %0h\t\tRead Data: %0h\n\n",data_inspect,rdata[i]),UVM_NONE);
                        end
                        else begin
                            `uvm_error("*    SCOREBOARD    *","COMPARE FAILED");
                            `uvm_info("PACKET INFO:",$sformatf("Expected Data: %0h\t\tRead Data: %0h\n\n",data_inspect,rdata[i]),UVM_NONE);
                        end
                    end
                end
                else if (r_trans.rresp == `EXOKAY) begin
                    `uvm_warning("*    SCOREBOARD    *","Cannot read from DUT, buffer is empty");
                end
                else if (r_trans.rresp == `SLVERR) begin
                    `uvm_error("*    SCOREBOARD    *","The DUT is erroring out");
                end
                else if (r_trans.rresp == `DECERR) begin
                    `uvm_warning("*    SCOREBOARD    *","The transaction may not be intended for DUT, there is decoding error");
                end
            end
        join_none
    endtask

endclass

`endif