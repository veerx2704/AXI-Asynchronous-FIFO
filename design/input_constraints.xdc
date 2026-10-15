create_clock -name wclk -period 5.00 [get_ports s_axi_wclk]
create_clock -name rclk -period 5.00 [get_ports m_axi_rclk]



set_clock_groups -asynchronous \
    -group [get_clocks wclk]	\
    -group [get_clocks rclk]
