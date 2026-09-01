import uvm_pkg::*;
`include "uvm_macros.svh"
`include "include_files.sv"

module tb_top;
bit wclk;
bit rclk;

write_interface wintf(.s_axi_wclk(wclk));
read_interface  rintf(.m_axi_rclk(rclk));

axi_fifo_wrapper inst(

   //GLOBAL CLOCK AND RESET
   .s_axi_wclk(wclk),
   .s_axi_wrst(wintf.wrst),
   .m_axi_rrst(rintf.rrst),
  .m_axi_rclk(rclk),
   
   //WRITE ADDRESS BUS
   .s_axi_awid    (wintf.awid),
   .s_axi_awaddr  (wintf.awaddr),
   .s_axi_awlen   (wintf.awlen),
   .s_axi_awsize  (wintf.awsize),
   .s_axi_awburst (wintf.awburst),
   .s_axi_awlock  (wintf.awlock),
   .s_axi_awcache (wintf.awcache),
   .s_axi_awprot  (wintf.awprot),
   .s_axi_awvalid (wintf.awvalid),
   .s_axi_awready (wintf.awready),
   
   //WRITE DATA BUS
   .s_axi_wdata   (wintf.wdata),
   .s_axi_wstrb   (wintf.wstrb),
   .s_axi_wlast   (wintf.wlast),
   .s_axi_wvalid  (wintf.wvalid),
   .s_axi_wready  (wintf.wready),
   
   //WRITE RESPONSE BUS
   .s_axi_bid     (wintf.bid),
   .s_axi_bresp   (wintf.bresp),
   .s_axi_bvalid  (wintf.bvalid),
   .s_axi_bready  (wintf.bready),
   
   //READ ADDRESS BUS
   .s_axi_arid    (rintf.arid),
   .s_axi_araddr  (rintf.araddr),
   .s_axi_arlen   (rintf.arlen),
   .s_axi_arsize  (rintf.arsize),
   .s_axi_arburst (rintf.arburst),
   .s_axi_arlock  (rintf.arlock),
   .s_axi_arcache (rintf.arcache),
   .s_axi_arprot  (rintf.arprot),
   .s_axi_arvalid (rintf.arvalid),
   .s_axi_arready (rintf.arready),
   
   //READ DATA BUS
   .s_axi_rid     (rintf.rid),
   .s_axi_rdata   (rintf.rdata),
   .s_axi_rresp   (rintf.rresp),
   .s_axi_rlast   (rintf.rlast),
   .s_axi_rvalid  (rintf.rvalid),
   .s_axi_rready  (rintf.rready)
);

initial begin
   uvm_config_db#(virtual axi_interface)::set(null,"*","DATA",intf);
end

initial begin
    wclk=0;
    rclk = 0;
end

always #5 wclk = ~wclk;
always #5 rclk = ~rclk;


initial begin
   run_test("test_case_1");
   //run_test("test_case_2");
   //run_test("test_case_3");
   //run_test("test_case_4");
   //run_test("test_case_5");
   //run_test("test_case_6");
   //run_test("test_case_7");
   //run_test("test_case_8");
end

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule
