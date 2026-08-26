`ifndef AXI_READ_DRIVER
`define AXI_READ_DRIVER

`define vif v_rintf.driver_mp_r.driver_cb_r;


class read_driver extends uvm_driver #(transaction);
    `uvm_component_utils(read_driver);

    virtual read_interface v_rintf;

    function new(string name = "read_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual read_interface)::get(this,"DATA",v_rintf)) begin
            `uvm_fatal("*   (READ) DRIVER CONNECTION FAILED     *","");
        end
        else begin
            `uvm_info("*    (READ) DRIVER CONNECTED     *","",UVM_NONE);
        end

    endfunction

    task read_address(transaction trans);
        `uvm_info("DRIVER - READ ADDRESS CHANNEL","",UVM_HIGH);
        `vif.arid <= trans.arid;
        `vif.araddr <= trans.araddr[0];
        `vif.arlen <= trans.arlen;
        `vif.arsize <= trans.arsize;
        `vif.arburst <= trans.burst;
        `vif.arlock <= trans.arlock;
        `vif.arcache <= trans.arcache;
        `vif.arprot <= trans.arprot;
        `vif.arvalid <= trans.arvalid;
        while (trans.arready == 0) begin
            @(posedge v_rintnf.m_axi_rclk);
        end
        @(posedge v_rintf.m_axi_rclk);
        `vif.arid <= '0;
        `vif.araddr <= '0;
        `vif.arvalid <= '0;
    endtask

    task read_data(transaction trans);
        repeat (trans.rdata.size()) begin
            @(posedge v_rintf.m_axi_rclk);
            `uvm_info("DRIVER - READ DATA CHANNEL","",UVM_HIGH);
            while (`vif.rvalid == 0) begin
                @(posedge v_rintf.m_axi_rclk);
            end
            `vif.rready <= trans.rready;
            @(posedge v_rintf.m_axi_rclk);
            `vif.rready <= '0;
        end
    endtask

    task read_reset_logic;
        `vif.arvalid <= '0;
        `vif.rready <= '0;
    endtask

    task read_driver_logic(transaction trans);
        read_address(trans);
        read_data(trans);
    endtask

    task run_phase(uvm_phase phase);
        transaction trans;
        forever begin
            seq_item_port.get_next_item(trans);
            if(trans.rrst == 0) begin
                v_rintf.rrst <= '0;
                read_reset_logic();
            end
            else begin
                v_rintf.rrst <= '1;
                read_driver_logic(trans);
            end
            seq_item_port.item_done();
            `uvm_info(" (READ) DRIVER - TRANSACTION NUMBER","",UVM_NONE);
        end
    endtask


endclass

`endif