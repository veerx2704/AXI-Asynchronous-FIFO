`ifndef AXI_WRITE_DRIVER
`define AXI_WRITE_DRIVER

`define w_vifd v_wintf.driver_mp_w.driver_cb_w

class write_driver extends uvm_driver#(write_transaction);
    `uvm_component_utils(write_driver)

    virtual write_interface v_wintf;

    function new(string name = "write_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    if (!uvm_config_db#(virtual write_interface)::get(this,"","DATA",v_wintf)) begin
        `uvm_fatal("*   (WRITE) DRIVER CONNECTION FAILED    *","");
    end
    else begin
        `uvm_info("*    (WRITE) DIRVER CONNECTED    *","",UVM_NONE);
    end

    endfunction


    task write_address (write_transaction trans);
        `uvm_info("DRIVER - WRITE ADDRESS CHANNEL","",UVM_HIGH)
        @(posedge v_wintf.s_axi_wclk);
        `w_vifd.awid       <= trans.awid;
        `w_vifd.awaddr     <= trans.awaddr[0];
        `w_vifd.awlen      <= trans.awlen;
        `w_vifd.awsize     <= trans.awsize;
        `w_vifd.awburst    <= trans.awburst;
        `w_vifd.awlock     <= trans.awlock;
        `w_vifd.awcache    <= trans.awcache;
        `w_vifd.awprot     <= trans.awprot;
        `w_vifd.awvalid    <= trans.awvalid;
        
        while (!v_wintf.awready)
            @(posedge v_wintf.s_axi_wclk);

        @(posedge v_wintf.s_axi_wclk);
        `w_vifd.awaddr     <= '0;
        `w_vifd.awid       <= '0;
        `w_vifd.awvalid    <= '0;
    endtask

    int wdata_count;
    task write_data(write_transaction trans);
        wdata_count <= '0;
        repeat (trans.awlen + 1) begin
            @(posedge v_wintf.s_axi_wclk);
            `uvm_info("DRIVER - WRITE DATA CHANNEL","",UVM_HIGH);
            `w_vifd.wdata <= trans.wdata[wdata_count];
            `w_vifd.wstrb <= trans.wstrb;
            `w_vifd.wvalid <= trans.wvalid;
            if (wdata_count == trans.awlen) begin
                `w_vifd.wlast <= '1;
            end
            else begin
                `w_vifd.wlast <= '0;
            end
            while (v_wintf.wready == 0) begin
                @(posedge v_wintf.s_axi_wclk);
            end
            @(posedge v_wintf.s_axi_wclk);
            `w_vifd.wvalid <= '0;
            `w_vifd.wstrb <= 4'b1111;
            wdata_count++;
        end
        `w_vifd.wdata = 0;    
    endtask

    task write_response(write_transaction trans);
        `uvm_info("DRIVER - WRITE RESPONSE CHANNEL","",UVM_HIGH);
        `w_vifd.bready <= trans.bready;
        while(v_wintf.bvalid == 0) begin
            @(posedge v_wintf.s_axi_wclk);
        end
    endtask

    task write_reset_logic;
        `w_vifd.awvalid <= '0;
        `w_vifd.wvalid <= '0;
        `w_vifd.bready <= '0;
    endtask

    task write_driver_logic(write_transaction trans);
        write_address(trans);
        write_data(trans);
        write_response(trans);
    endtask

    task run_phase(uvm_phase phase);
        write_transaction trans;
        forever begin
            seq_item_port.get_next_item(trans);
            if(trans.wrst == 0) begin
                v_wintf.wrst <= 0;
                write_reset_logic();
            end
            else if (trans.wrst == 1) begin
                v_wintf.wrst = 1;
                write_driver_logic(trans);
            end
            seq_item_port.item_done();
            `uvm_info("(WRITE) DRIVER - TRANSACTION NUMBER","",UVM_NONE);
        end
    endtask


endclass

`endif