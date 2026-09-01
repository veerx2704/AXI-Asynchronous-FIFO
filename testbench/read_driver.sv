`ifndef AXI_READ_DRIVER
`define AXI_READ_DRIVER

`define r_vifd v_rintf.driver_mp_r.driver_cb_r


class read_driver extends uvm_driver #(read_transaction);
    `uvm_component_utils(read_driver);

    virtual read_interface v_rintf;

    function new(string name = "read_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual read_interface)::get(this,"","DATA",v_rintf)) begin
            `uvm_fatal("*   (READ) DRIVER CONNECTION FAILED     *","");
        end
        else begin
            `uvm_info("*    (READ) DRIVER CONNECTED     *","",UVM_NONE);
        end

    endfunction

    task read_address(read_transaction trans);
        `uvm_info("DRIVER - READ ADDRESS CHANNEL","",UVM_HIGH);
        `r_vifd.arid <= trans.arid;
        `r_vifd.araddr <= trans.araddr[0];
        `r_vifd.arlen <= trans.arlen;
        `r_vifd.arsize <= trans.arsize;
        `r_vifd.arburst <= trans.burst;
        `r_vifd.arlock <= trans.arlock;
        `r_vifd.arcache <= trans.arcache;
        `r_vifd.arprot <= trans.arprot;
        `r_vifd.arvalid <= trans.arvalid;
        while (trans.arready == 0) begin
            @(posedge v_rintnf.m_axi_rclk);
        end
        @(posedge v_rintf.m_axi_rclk);
        `r_vifd.arid <= '0;
        `r_vifd.araddr <= '0;
        `r_vifd.arvalid <= '0;
    endtask

    task read_data(read_transaction trans);
        repeat (trans.rdata.size()) begin
            @(posedge v_rintf.m_axi_rclk);
            `uvm_info("DRIVER - READ DATA CHANNEL","",UVM_HIGH);
            while (`r_vifd.rvalid == 0) begin
                @(posedge v_rintf.m_axi_rclk);
            end
            `r_vifd.rready <= trans.rready;
            @(posedge v_rintf.m_axi_rclk);
            `r_vifd.rready <= '0;
        end
    endtask

    task read_reset_logic;
        `r_vifd.arvalid <= '0;
        `r_vifd.rready <= '0;
    endtask

    task read_driver_logic(read_transaction trans);
        read_address(trans);
        read_data(trans);
    endtask

    task run_phase(uvm_phase phase);
        read_transaction trans;
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