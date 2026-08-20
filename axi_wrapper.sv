`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 04:09:09 PM
// Design Name: 
// Module Name: axi_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_wrapper #(parameter WIDTH = 32, parameter DEPTH = 16)(
    
    //write domain
    input wire s_axi_aclk,
    input wire s_axi_areset_n,
    
    //read domain
    input wire m_axi_aclk,
    input_wire m_axi_areset_n,
    
    //write address channel
    input wire [WIDTH-1:0] s_axi_awaddr,
    input wire [3:0] s_axi_awlen,
    input wire [2:0] s_axi_awsize,
    input wire [1:0] s_axi_awburst,
    input wire s_axi_awvalid,
    
    //write data channel
    input wire [WIDTH-1:0] s_axi_wdata,
    input wire [3:0] s_axi_wstrb,
    input wire s_axi_wlast,
    input wire s_axi_wvalid,
    
    //write response channel
    input wire s_axi_bready,

    
    //read address channel
    input wire [WIDTH-1:0] m_axi_araddr,
    input wire [3:0] m_axi_arlen,
    input wire [2:0] m_axi_arsize,
    input wire [1:0] m_axi_arburst,
    input wire m_axi_arvalid,
    
    //read data channel
    input wire m_axi_rready,    
    
    //write data channel
    output wire s_axi_wready,
    
    // write address channel
    output wire s_axi_awready,
    
    //read address channel
    output wire m_axi_arready,

    //write response channel
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,    
    
    //read data channel
    output wire [WIDTH-1:0] m_axi_rdata,    
    output wire [1:0] m_axi_rresp,    
//    output wire m_axi_rlast,    
    output wire m_axi_rvalid 
    
    );
    
    localparam OKAY = 2'b00;
    localparam EXOKAY = 2'b01;      //To be used as slave full or empty in our case
    localparam SLVERR = 2'b10;
    localparam DECERR = 2'b11;
    
    wire [WIDTH-1:0] wdata;
    wire [WIDTH-1:0] rdata;
    wire w_en;
    wire r_en;
    wire full;
    wire empty;
    
    //write data channel
    reg wready_reg;
    
    // write address channel
    reg awready_reg;
    
    //read address channel
    reg arready_reg;

    //write response channel
    reg [1:0] bresp_reg;
    reg bvalid_reg;
    
    //read data channel
    reg [1:0] rresp_reg;
//    reg rlast_reg;    
    reg rvalid_reg;
    
    //BURST TYPE
    localparam FIXED = 2'b00;
    localparam INCR = 2'b01;
    localparam WRAP = 2'b10;
    
    //Check address alignment
    // not needed for FIFO operations
//    wire [WIDTH-1:0] aligned_awaddr;
//    wire [WIDTH-1:0] aligned_araddr;
    
//    assign aligned_araddr = (s_axi_araddr >> s_axi_arsize) << s_axi_arsize;
//    assign aligned_awaddr = (s_axi_awaddr >> s_axi_awsize) << s_axi_awsize;
    
//    wire ar_aligned = aligned_araddr == s_axi_araddr;
//    wire aw_aligned = aligned_awaddr == s_axi_awaddr;
    
//    // Calculate burst length
//    wire [4:0] arburst_len = s_axi_arburst + 1;
//    wire [4:0] awburst_len = s_axi_awburst + 1;
    
    reg [1:0] ar_check_addr;
    reg [1:0] aw_check_addr;
    localparam READ_ADDRESS = 2'b00;
    localparam WRITE_ADDRESS = 2'b01;
    localparam STATUS_ADDRESS = 2'b10;
    //Handshake and dependencies
    
    //Read transaction
    // If ARVALID is asserted, slave may assert ARREADY
    // If ARREADY is asserted, master may assert ARVALID any time
    // If only both ARVALID and ARREADY are asserted, Read address is captured.
    // If RVALID is asserted, RREADY may be asserted
    // If both RREADY and RVALID are asserted, RDATA may be sent
    // Once both RREADY and RVALID are asserted, they are deasserted in next clock cycle
    // Once both ARREADY and ARVALID are asserted, they are deasserted in next clock cycle
    
    //Read address channel
    reg ar_config_err;
    always @(posedge m_axi_aclk) begin
        if (!m_axi_areset_n) begin
            arready_reg <= 1'b0;
            ar_config_err <= '0;
        end
        else begin
 //           if (m_axi_arburst == FIXED && m_axi_arlen == 0) begin       //for FIFO, burst type should be fixed and only 1 data element per transaction is needed
                ar_config_err <= '0;
                if (m_axi_arvalid && arready_reg) begin
                    ar_check_addr <= m_axi_araddr[3:2];
                    arready_reg <= '0;
                end
                else if (m_axi_arvalid) begin
                    arready_reg <= '1;                          //if ARVALID is asserted, assert ARREADY
                end
                if (arready_reg) begin
                    arready_reg <= '0;                          //deassert after 1 cycle
                end
//            end
//            else begin                                          //raise error if configuration does not match
//                arready_reg <= '0;
//                ar_config_err <= '1;
//            end
//            if (ar_config_err) ar_config_err <= '0;
        end
    end    
    //Read data channel
    reg [WIDTH-1:0] rdata_reg;
    wire [WIDTH-1:0] r_data_out;          //connected with fifo instantiation
    always @(posedge m_axi_aclk) begin
        if (!m_axi_areset_n) begin
            rvalid_reg <= '0;
            rresp_reg <= '0;
            rdata_reg <= '0;
        end
        else begin
            if (m_axi_rready && arready_reg) begin
                if (ar_check_addr == READ_ADDRESS && !empty) begin
                    rvalid_reg <= '1;                           //if RREADY is asserted, assert RVALID only if address matches read address, and fifo is not empty
                    rresp_reg <= OKAY;
                    rdata_reg <= r_data_out;
                end
                else if (ar_check_addr == STATUS_ADDRESS) begin
                    rvalid_reg <= '0;                             //If status of fifo is needed, no need to read from it
                    rresp_reg <= OKAY;                            //Only take the flags and report okay to reader
                    rdata_reg <= {{(WIDTH-2){1'b0}},empty,full};
                end                
                else begin
                    rvalid_reg <= '0;
                    rresp_reg <= DECERR;                      //if the address does not match read address, there should be no transaction and response should be noted
                    rdata_reg <= '0;
                end
            end
            else if(m_axi_rready && arready_reg && empty) begin
                    rvalid_reg <= '0;                         //if fifo is empty, don't assert valid
                    rresp_reg <= EXOKAY;                      //Tell reader it is empty
                    rdata_reg <= '0;
            end

        end
    end
assign r_en = m_axi_rready && !empty && arready_reg;             // read data only when rready is 1 and arready was 1 in previous cycle and fifo is not empty

    
    
    //Write transaction
    //If AWVALID is asserted, AWREADY may be asserted
    //If WVALID is asserted, WREADY may be asserted
    //AWVALID and WVALID may be asserted at the same time
    //Only if AWVALID, WVALID, AWREADY and WREADY are asserted, BVALID should be asserted
    //Deassert all the signals if they all are asserted, in the next cycle
    
    //Write address channel
    always @(posedge s_axi_aclk) begin
        if (!s_axi_areset_n) begin
            awready_reg <= '0;
        end
        else begin
            if (s_axi_awvalid) begin
                awready_reg <= '1;
            end
            else if (s_axi_awvalid && awready_reg) begin
                aw_check_addr <= s_axi_awaddr[3:2];
                awready_reg <= '0;
            end
        end
    end
    
    //Write data channel    
    always @(posedge s_axi_aclk) begin
        if (!s_axi_areset_n) begin
            wready_reg <= '0;
        end
        else begin
            if (s_axi_wvalid && !full) begin
                if(aw_check_addr == WRITE_ADDRESS) begin
                    wready_reg <= '1;               //assert WREADY only if WVALID is asserted and fifo is not full
                 end
            end
            else wready_reg <= '0;
        end
    end
    
    //Write response channel
    always @(posedge s_axi_aclk) begin
        if (!s_axi_areset_n) begin
            bresp_reg <= '0;
            bvalid_reg <= '0;
        end
        else begin
            if (s_axi_wvalid && s_axi_awvalid && awready_reg && wready_reg) begin
                bvalid_reg <= '1;
                bresp_reg <= OKAY;
            end
            else begin
                bvalid_reg <= '0;
                if (aw_check_addr != WRITE_ADDRESS) bresp_reg <= DECERR;        //Tell the writer that there has been a decode error due to wrong address
                else if (full) bresp_reg <= EXOKAY;                                  //Don't assert BVALID. Tell the writer that there is no error but the fifo is full
            end
        end
    end
assign w_en = s_axi_wvalid && wready_reg;               //assert w_en at the time when both write valid and ready are active


async_fifo #(.data_width(WIDTH), .N(DEPTH)) FIFO(  .wclk(s_axi_aclk),
                                                .wrst(s_axi_areset_n),
                                                .wen(w_en),
                                                .wdata(s_axi_wdata),
                                                .fifo_full(full),
                                                .rclk(m_axi_aclk),
                                                .rrst(m_axi_areset_n),
                                                .ren(r_en),
                                                .rdata(r_data_out),
                                                .fifo_empty(empty));

//outputs
//Read address channel
assign m_axi_arready = arready_reg;

//Read data channel
assign m_axi_rdata = rdata_reg;
assign m_axi_rresp = (rresp_reg != OKAY   && 
                     rresp_reg != DECERR && 
                     rresp_reg != EXOKAY) ? SLVERR : rresp_reg;          //keep response as SLVERR, rresp_reg is not among OKAY,EXOKAY and DECERR
assign m_axi_rvalid = rvalid_reg;

//Write Address channel
assign s_axi_awready = awready_reg;

//Write data channel
assign s_axi_wready = wready_reg;

//Write response channel
assign s_axi_bvalid = bvalid_reg;
assign s_axi_bresp = bresp_reg != OKAY   &&
                     bresp_reg != EXOKAY &&
                     bresp_reg != DECERR ? SLVERR : bresp_reg;

endmodule
