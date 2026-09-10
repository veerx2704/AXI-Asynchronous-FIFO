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
        `r_vifd.arburst <= trans.arburst;
        `r_vifd.arlock <= trans.arlock;
        `r_vifd.arcache <= trans.arcache;
        `r_vifd.arprot <= trans.arprot;
        `r_vifd.arvalid <= trans.arvalid;
      while (!(v_rintf.arready || v_rintf.arvalid)) begin
            @(posedge v_rintf.m_axi_rclk);
        $display("ARREADY not asserted yet");
           	  `uvm_info("DRV",
                        $sformatf("  ARREADY=%0b ARVALID=%0b RREADY=%0b RVALID=%0b",
            v_rintf.arready,
            v_rintf.arvalid,
            v_rintf.rready,
            v_rintf.rvalid),
        UVM_LOW);
      end
        @(posedge v_rintf.m_axi_rclk);
        `r_vifd.arid <= '0;
        `r_vifd.araddr <= '0;
        //`r_vifd.arvalid <= '0;
    endtask

    task read_data(read_transaction trans);
        repeat (trans.arlen + 1) begin
            @(posedge v_rintf.m_axi_rclk);
            `uvm_info("DRIVER - READ DATA CHANNEL","",UVM_HIGH);
          while (!(v_rintf.rvalid || v_rintf.rready)) begin
                @(posedge v_rintf.m_axi_rclk);
            $display("RVALID not asserted yet");
           	  `uvm_info("DRV",
                        $sformatf("  ARREADY=%0b ARVALID=%0b RREADY=%0b RVALID=%0b",
            v_rintf.arready,
            v_rintf.arvalid,
            v_rintf.rready,
            v_rintf.rvalid),
        UVM_LOW);
          end
            `r_vifd.rready <= trans.rready;
            @(posedge v_rintf.m_axi_rclk);
            `r_vifd.rready <= '0;
        end
    endtask

    task read_reset_logic;
//      `uvm_info("222222222222222222222222222222222222222222222222","",UVM_NONE);

        `r_vifd.arvalid <= '0;
        `r_vifd.rready <= '0;
    endtask

    task read_driver_logic(read_transaction trans);
//                `uvm_info("000000000000000000000000000000000000000000","",UVM_NONE);

        read_address(trans);
                //`uvm_info("000000000000000000000000000000000000000000","",UVM_NONE);

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
//          `uvm_info("111111111111111111111111111111111111111111","",UVM_NONE);
            seq_item_port.item_done();
            `uvm_info(" (READ) DRIVER - TRANSACTION NUMBER","",UVM_NONE);
        end
    endtask


endclass

`endif