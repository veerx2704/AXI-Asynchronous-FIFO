create_clock -name wclk -period 3.50 [get_ports s_axi_wclk]
create_clock -name rclk -period 3.50 [get_ports m_axi_rclk]

set_clock_groups -asynchronous \
    -group [get_clocks wclk] \
    -group [get_clocks rclk]


set_input_delay -clock wclk -max 0.5 [get_ports {s_axi_awaddr[*] s_axi_awburst[*] s_axi_awcache[*] s_axi_awid[*] s_axi_awlen[*] s_axi_awprot[*] s_axi_awsize[*] s_axi_wdata[*] s_axi_wstrb[*] s_axi_awlock s_axi_awvalid s_axi_bready s_axi_wlast s_axi_wrst s_axi_wvalid}]
set_input_delay -clock wclk -min 0.0 [get_ports {s_axi_awaddr[*] s_axi_awburst[*] s_axi_awcache[*] s_axi_awid[*] s_axi_awlen[*] s_axi_awprot[*] s_axi_awsize[*] s_axi_wdata[*] s_axi_wstrb[*] s_axi_awlock s_axi_awvalid s_axi_bready s_axi_wlast s_axi_wrst s_axi_wvalid}]


set_input_delay -clock rclk -max 0.5 [get_ports {m_axi_rrst m_axi_araddr[*] m_axi_arburst[*] m_axi_arcache[*] m_axi_arid[*] m_axi_arlen[*] m_axi_arprot[*] m_axi_arsize[*] m_axi_arlock m_axi_arvalid m_axi_rready}]
set_input_delay -clock rclk -min 0.0 [get_ports {m_axi_rrst m_axi_araddr[*] m_axi_arburst[*] m_axi_arcache[*] m_axi_arid[*] m_axi_arlen[*] m_axi_arprot[*] m_axi_arsize[*] m_axi_arlock m_axi_arvalid m_axi_rready}]

