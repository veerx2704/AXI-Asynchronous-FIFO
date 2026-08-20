create_clock -name wclk -period 10.00 [get_ports s_axi_aclk]
create_clock -name rclk -period 10.00 [get_ports m_axi_aclk]



set_clock_groups -asynchronous \
    -group [get_clocks wclk]	\
    -group [get_clocks rclk]
