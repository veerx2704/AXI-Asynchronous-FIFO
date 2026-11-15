module axi_compute #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter BURST_LENGTH = 8,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 8,
    parameter PIPELINE_OUTPUT = 0
) (
    input logic wclk,
    input logic wrst,
    
    // Write Address CHannel (AW)
    input logic awvalid,
    input logic [ADDR_WIDTH - 1:0] awaddr,
    input logic [ID_WIDTH - 1:0] awid,
    input logic [7:0] awlen,
    input logic [2:0] awsize,
    input logic [1:0] awburst,
    output logic awready,

    // Write data channel (W)
    input logic [DATA_WIDTH - 1:0] wdata,
    input logic wvalid,
    input logic wlast,
    input logic [STRB_WIDTH - 1:0] wstrb,
    output logic wready,

    // Write Response channel (B)
    output logic [ID_WIDTH - 1:0] bid,
    output logic bvalid,
    output logic [1:0] bresp,
    input logic bready,



    // Read Address Channel (AR)

    input logic rclk,
    input logic rrst,

    input logic [ID_WIDTH - 1:0] arid,
    input logic [ADDR_WIDTH - 1:0] araddr,
    input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic [1:0] arburst,
    input logic arvalid,
    output logic arready,

    // Read response channel (R)
    input logic rready,
    output logic [1:0] rresp,
    output logic rvalid,
    output logic [DATA_WIDTH - 1:0] rdata,
    output logic rlast,
    output logic [ID_WIDTH - 1:0] rid
);

parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
parameter WORD_WIDTH = STRB_WIDTH;
parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH; // 8 - a single byte
parameter FIFO_ADDRESS = 32'h00002000;


initial begin
    if (WORD_SIZE * WORD_WIDTH != DATA_WIDTH ) begin
        $error("Error: AXI data width is not evenly distributed (instance %m)");
    end
    if (2**$clog2(WORD_WIDTH) != WORD_WIDTH) begin
        $error("Error: Word width is not a power of 2 (instance %m)");
    end
end

parameter ALLOK = 2'b00;            // No problem in transaction
parameter FULLEMPTY = 2'b01;        // FIFO is empty or full, cannot accept request
parameter SLVERR = 2'b10;           // Internal failure
parameter DECERR = 2'b11;           // Channel Data is corrupt/incorrect


parameter READ_IDLE = 2'b00;
parameter READ_FETCH = 2'b01;
parameter READ_ERR = 2'b10;
parameter READ_RESPONSE = 2'b11;

parameter    WRITE_IDLE = 2'b00;
parameter    WRITE_BURST = 2'b01;
parameter    WRITE_RESPONSE = 2'b11;

localparam FIFO_DEPTH = 16;

logic [1:0] r_state, r_state_next;
logic [1:0] w_state, w_state_next;

logic awready_next, awready_reg;

logic [ID_WIDTH - 1:0] awid_next;
logic [ID_WIDTH - 1:0] awid_reg;

logic [ADDR_WIDTH - 1:0] awaddr_next;
logic [ADDR_WIDTH - 1:0] awaddr_reg;

logic [7:0] awlen_next;
logic [7:0] awlen_reg;

logic [2:0] awsize_next;
logic [2:0] awsize_reg;

logic [1:0] awburst_next;
logic [1:0] awburst_reg;

logic wready_next, wready_reg;

logic [STRB_WIDTH - 1:0] wstrb_next;
logic [STRB_WIDTH - 1:0] wstrb_reg;

logic [DATA_WIDTH - 1:0] wdata_queue [0:FIFO_DEPTH];

logic [DATA_WIDTH - 1:0] wdata_temp; 

logic [8:0] current_next;
logic [8:0] current_reg;

logic fill_data;

logic [8:0] fill_counter;
logic [8:0] fill_next;


logic [ID_WIDTH - 1:0] bid_reg;
logic [ID_WIDTH - 1:0] bid_next;

logic [STRB_WIDTH - 1:0] write_mask;
logic [STRB_WIDTH - 1:0] write_mask_reg;

logic [DATA_WIDTH - 1:0] wdata_to_fifo;

logic write_en_reg;
logic read_en_reg;


logic aw_captured;
logic aw_captured_reg;

logic signal_data_intake;
logic signal_intake_reg;

logic bvalid_next;
logic bvalid_reg;

logic [1:0] bresp_next;
logic [1:0] bresp_reg;
logic probe;

logic [ADDR_WIDTH - 1:0] araddr_next;
logic [ADDR_WIDTH - 1:0] araddr_reg;

logic [ID_WIDTH - 1:0] arid_next;
logic [ID_WIDTH - 1:0] arid_reg;

logic [ID_WIDTH - 1:0] rid_next;
logic [ID_WIDTH - 1:0] rid_reg;

logic rvalid_reg;
logic rvalid_next;

logic [7:0] arlen_next;
logic [7:0] arlen_reg;
logic [2:0] arsize_next;
logic [2:0] arsize_reg;

logic [1:0] arburst_reg;
logic [1:0] arburst_next;

logic [1:0] rresp_next;
logic [1:0] rresp_reg;

logic arready_next;
logic arready_reg;

//logic [8:0] awlen_ext_reg;

logic ar_captured;
logic ar_captured_reg;

logic r_captured;
logic r_captured_reg;

logic resp_normal;
logic resp_normal_reg;

logic [1:0] r_released;
logic [1:0] r_released_reg;

logic [DATA_WIDTH - 1:0] rdata_reg;

logic [7:0] read_current_next;
logic [7:0] read_current_reg;

logic rlast_reg;
logic rlast_next;

logic wlast_reg;

logic [DATA_WIDTH - 1:0] rdata_from_fifo;


logic fifo_wen;
logic fifo_ren;
logic fifo_full;
logic fifo_empty;
//logic fifo_wrst;
//logic fifo_rrst;

logic [$clog2(FIFO_DEPTH):0] fifo_rptr_out;
logic [$clog2(FIFO_DEPTH):0] fifo_wptr_out;


async_fifo #(.data_width(DATA_WIDTH), .N(FIFO_DEPTH)) FIFO_INST(.wdata(wdata_to_fifo),
														  .wptr_out(fifo_wptr_out),
														  .wen(write_en_reg),
														  .wclk(wclk),
														  .wrst(wrst),
														  .rrst(rrst),
														  .rclk(rclk),
														  .ren(read_en_reg),
														  .rptr_out(fifo_rptr_out),
														  .rdata(rdata_from_fifo),
														  .fifo_full(fifo_full),
														  .fifo_empty(fifo_empty));

logic [$clog2(FIFO_DEPTH):0] filled_entries;
logic [$clog2(FIFO_DEPTH):0] filled_entries_reg;
logic [$clog2(FIFO_DEPTH):0] available_entries;
logic [$clog2(FIFO_DEPTH):0] available_entries_reg;

logic wvalid_next;
logic wvalid_reg;



//To calculate available space in FIFO, subtract rptr from wptr.
//wptr will always be ahead of rptr (unless empty). 
//Diff = wptr - rptr

logic diff_borrow0, diff_borrow1;



adder #(.WIDTH($clog2(FIFO_DEPTH)+1)) LEN_FILLED (.SrcA(fifo_wptr_out),
										  .SrcB(~fifo_rptr_out),
										  .Cin(1'b1),
										  .Sum(filled_entries),
										  .Cout(diff_borrow0));

logic [$clog2(FIFO_DEPTH) :0] total_capacity = (1 << $clog2(FIFO_DEPTH)) - 1;

adder #(.WIDTH($clog2(FIFO_DEPTH)+1)) LEN_AVAILABLE (.SrcA(total_capacity),
										  .SrcB(~filled_entries),
										  .Cin(1'b1),
										  .Sum(available_entries),
										  .Cout(diff_borrow1));


assign wready = wready_reg;
assign awready = awready_reg;
assign bvalid = bvalid_reg;
assign bid = bvalid_reg ? bid_reg : '0;
assign bresp = bresp_reg;


assign rdata = rdata_reg;
assign rvalid = rvalid_reg;
assign rid = rid_reg;
assign rresp = rresp_reg;
assign rlast = rlast_reg;
assign arready = arready_reg;


//Handling AW, W and B channels
always_comb begin
    integer i;
    i = 0;
    current_next = current_reg + 1;
    awready_next = awready_reg;
    wready_next = wready_reg;

    awaddr_next = awaddr_reg;
    awid_next = awid_reg;
    awlen_next = awlen_reg;
    awsize_next = awsize_reg;
    awburst_next = awburst_reg;
    aw_captured = aw_captured_reg;

    wstrb_next = wstrb_reg;
    signal_data_intake = signal_intake_reg;

    w_state_next = w_state;
    bvalid_next = bvalid_reg;
    bresp_next = bresp_reg;
    bid_next = bid_reg;
    wdata_to_fifo = '0;
    write_mask = write_mask_reg;
    wvalid_next = wvalid_reg;

    fifo_wen = write_en_reg;
    probe = 1'b0;
    fill_data = 1'b0;
    
    fill_next = fill_counter ;
    

    case(w_state)
        WRITE_IDLE: begin
            // Always assert ready first
            
            awready_next = (~aw_captured_reg) & (~fifo_full);
            wready_next  = (~signal_intake_reg) & (~fifo_full);

            // Check for aw handshake, capture signals for registering
            if (awready_reg && awvalid) begin
                awready_next = 1'b0;
                awaddr_next = awaddr;
                awid_next = awid;
                awlen_next = awlen;
                awsize_next = awsize;
                awburst_next = awburst;
                bid_next = awid;        // Since this implementation is currently for non-pipelined protocol
                aw_captured = 1'b1;
            end

            // Check for w handshake, capture signals for registering, signal that data intake is starting.
            if(wready_reg && wvalid) begin
                wready_next = 1'b0;
                wstrb_next = wstrb;
                wvalid_next = 1'b1;
                signal_data_intake = 1'b1;
            end

            if (signal_intake_reg && aw_captured_reg) begin  // If aw signals are captured and this is the last signals, go to compute data and address validity, compatibility with system.
                if(wlast_reg) begin
                    w_state_next = WRITE_BURST;
                    signal_data_intake = 1'b0;
                end
            end


        end
        WRITE_BURST: begin

            //Assert wready in the beginning
            if (awaddr_reg != FIFO_ADDRESS) begin   // The requested address is not the FIFO base address
                bresp_next = DECERR;                 // PROBLEM in the data sent to Design
                bvalid_next = 1'b1;
                w_state_next = WRITE_RESPONSE;
            end

            else if (awburst_reg != 2'b00) begin                 // Burst type is not FIFO, not allowed
                bresp_next = DECERR;
                bvalid_next = 1'b1;
                w_state_next = WRITE_RESPONSE;
                current_next = '0;
            end

            else if (((1 << awsize_reg)* 8) > DATA_WIDTH) begin      // The requested data size is more than what the design can currently handle
                bresp_next = SLVERR;
                bvalid_next = 1'b1;
                w_state_next = WRITE_RESPONSE;
                current_next = '0;
            end
            
            else if (current_reg != awlen_reg + 1) begin
                bresp_next = DECERR;
                bvalid_next = 1'b1;
                w_state_next = WRITE_RESPONSE;
                current_next = '0;
            end
            
            else if ((awlen_reg) > total_capacity) begin
                bresp_next = SLVERR;
                bvalid_next = 1'b1;
                w_state_next = WRITE_RESPONSE;
                current_next = '0;
            end

            else if (((awlen_reg) > available_entries_reg[$clog2(FIFO_DEPTH):0])) begin      // The requested data cannot be accomodated in the remaining capacity of the FIFO
                bresp_next = FULLEMPTY;
                bvalid_next = 1'b1;
                probe = 1'b1;
                w_state_next = WRITE_RESPONSE;
                current_next = '0;
            end

            else begin                  // If the flow reaches this point, then there are no errors. The data can be safely stored inside FIFO
                // The burst size may or may not be equal to the DATA_WIDTH parameter.
                // A mask should be used in the following cases while writing data:
                //      1. The awsize field is less than 2 -> mask = 4'b0111 or 4'b0011 or 4'b0001
                //      2. The strobe value is not 4'b1111 -> mask = strobe
                //      Thus, mask = strobe[2** awsize - 1:0]
                write_mask = wstrb_reg & (( 1 << (1<< awsize_reg)) - 1);     // Write mask
                for (i = 0; i < STRB_WIDTH; i++) begin : WMASK
                    if (write_mask[i]) begin
                        wdata_to_fifo[(i*8) +:8] = wdata_queue[fill_counter - 1][(i*8) +: 8];      // Masking the next data according to strobe
                    end
                    else wdata_to_fifo[(i*8) +:8] = 8'b0;
                end :WMASK

                fifo_wen = 1'b1;
                fill_next = fill_counter + 1;
                fill_data = 1'b1;
                

                if (fill_counter == awlen_reg + 1) begin
                    fifo_wen = 1'b0;
                    bvalid_next = 1'b1;
                    bresp_next = ALLOK;
                    fill_data = 1'b0;
                    w_state_next = WRITE_RESPONSE;
                    fill_next = '0;
                    current_next = '0;
                    fifo_wen = 1'b0;
                end

            end
            




            
        end
        WRITE_RESPONSE: begin
            // After replying the valid response, signals go back to 0
            bvalid_next = 1'b1;
            if (bvalid_reg && bready) begin
                bvalid_next = 1'b0;
                bid_next = '0;
                awready_next = fifo_full ? 1'b0 : 1'b1;
                wready_next = fifo_full ? 1'b0 : 1'b1;
                current_next = '0;
                w_state_next = WRITE_IDLE;
                aw_captured = 1'b0;
                wvalid_next = 1'b0;
                bresp_next = '0;
            end
            
        end
    endcase
end

always_comb begin
    r_state_next = r_state;
    arready_next = arready_reg;
    araddr_next = araddr_reg;
    arid_next = arid_reg;
    arlen_next = arlen_reg;
    arsize_next = arsize_reg;
    arburst_next = arburst_reg;
    ar_captured = ar_captured_reg;

    rid_next = rid_reg;
    rvalid_next = rvalid_reg;
    rresp_next = rresp_reg;
    resp_normal = resp_normal_reg;
    
    read_current_next = read_current_reg;
  	rlast_next = rlast_reg;;
    fifo_ren = read_en_reg;
    
    r_captured = r_captured_reg;
    
    r_released = r_released_reg;
    case(r_state)
        READ_IDLE: begin        //Unlike write channels, AR channel will always be a single cycle. No need for using registered signals for control

            // Always assert ready first
            arready_next = (~ar_captured_reg) & (~fifo_empty);
            if (arready_reg && arvalid) begin
                arready_next = 1'b0;
                arid_next = arid;
                araddr_next = araddr;
                arsize_next = arsize;
                arlen_next = arlen;
                arburst_next = arburst;
                rid_next = arid;
                ar_captured = 1'b1;
                
                if (araddr != FIFO_ADDRESS) begin
                    r_released = DECERR;
//                    rvalid_next = 1'b1;
                    r_state_next = READ_ERR;
                end
                
                else if (arburst != 2'b00) begin
//                    rvalid_next = 1'b1;
                    r_released = DECERR;
                    r_state_next = READ_ERR;
                end    
                
                else if ((1 << arsize)*8 > DATA_WIDTH ) begin
//                    rid_next = arid;
//                    rvalid_next = 1'b1;
                    r_released = SLVERR;
                    r_state_next = READ_ERR;
                end
                    
                else if ((arlen) > filled_entries[$clog2(FIFO_DEPTH):0]) begin
//                    rid_next = arid_reg;;
//                    rvalid_next = 1'b1;
                    r_released = FULLEMPTY;
                    r_state_next = READ_ERR;
                end

                else begin
//                    rid_next = arid;
//                    rvalid_next = 1'b1;
                    r_released = ALLOK;
                    r_state_next = READ_FETCH;
//                    fifo_ren = 1'b1;
                end

            end

        end
        
        READ_FETCH: begin
            if (rready) begin                   // RVALID is asserted by the design when all the previous computation is done.
                                                // If RREADY is asserted, no need to check for handshake as the next state will inevitably require RVALID to be high.
                fifo_ren = 1'b1;
                r_state_next = READ_RESPONSE;
            end
        end
        
        READ_ERR: begin                         // If flow reaches here, then there was some sort of error
            if (rready) begin
                r_state_next = READ_RESPONSE;
            end
        end

        READ_RESPONSE: begin
            rvalid_next = 1'b1;
            rresp_next = r_released_reg;
//            rresp_next = r_released_reg;
//            if (rvalid_reg && rready) begin
//                r_captured = 1'b1;
//            end
//            if (r_captured_reg) begin
            if (read_en_reg) begin                          // if read_en_reg is high, it means all the previous data is actually valid and the transaction is perfectly normal
                rresp_next = rresp_reg;
                if (read_current_reg == arlen_reg) begin
                    rlast_next = 1'b1;
                    fifo_ren = 1'b0;
                end
                else begin
                    read_current_next = read_current_reg + 1;
                end
            end
            if (rlast_reg) begin
                fifo_ren = 1'b0;
                r_released = 1'b0;
                rlast_next = 1'b0;
                rvalid_next = 1'b0;
                r_state_next = READ_IDLE;
//                    r_captured = 1'b0;
                read_current_next = '0;
                resp_normal = 1'b0;
            end
            if (rresp_reg != ALLOK) begin
                rvalid_next = 1'b0;
//                if (rready) begin
//                    rvalid_next = 1'b1;
                    fifo_ren = 1'b0;
                    rlast_next = 1'b0;
                    rresp_next = '0;
                    r_state_next = READ_IDLE;
                    read_current_next = '0;
//                end
            end
        end            
//        end

        

    endcase
end

always_ff @(posedge rclk) begin
    if (!rrst) begin
        read_current_reg <= '0;
        arready_reg <= '0;
        araddr_reg <= '0;
        arid_reg <= '0;
        arlen_reg <= '0;
        arsize_reg <= '0;
        arburst_reg <= '0;
        
//        awlen_ext_reg <= '0;
        ar_captured_reg <= '0;
        r_state <= '0;
        resp_normal_reg <= '0;
      	rlast_reg <= '0;
      	read_en_reg <= '0;
      	r_captured_reg <= '0;
        
        rvalid_reg <= '0;
        rresp_reg <= '0;
        rid_reg <= '0;
        rdata_reg <= '0;
        
        r_released_reg <= '0;
        filled_entries_reg <= '0;
        
    end
    else begin
        read_current_reg <= read_current_next;
        arready_reg <= arready_next;
        arid_reg <= arid_next;
        arlen_reg <= arlen_next;
        arsize_reg <= arsize_next;
        arburst_reg <= arburst_next;
        rvalid_reg <= rvalid_next;
        
        r_captured_reg <= r_captured;
        rresp_reg <= rresp_next;
        
        r_released_reg <= r_released;
        
//        if (awvalid && awready_reg) begin
//            awlen_ext_reg <= {1'b0,awlen};
//        end
      	rlast_reg <= rlast_next;
        
        resp_normal_reg <= resp_normal;
//        if (r_state == READ_RESPONSE && rvalid_reg) begin
            rdata_reg <= rdata_from_fifo;
//        end
        rid_reg <= rid_next;
        r_state <= r_state_next;
        araddr_reg <= araddr_next;
        read_en_reg <= fifo_ren;
        ar_captured_reg <= ar_captured;
        
        if (arready_reg && arvalid) begin
            filled_entries_reg <= filled_entries;
        end
        
    end
end


always_ff @(posedge wclk) begin
    if (!wrst) begin
        awready_reg <= '0;
        awid_reg <= '0;
        awaddr_reg <= '0;
        awlen_reg <= '0;
        awsize_reg <= '0;
        awburst_reg <= '0;
        wstrb_reg <= '0;
        wready_reg <= '0;
        signal_intake_reg <= '0;
        current_reg <= '0;
        
        fill_counter <= '0;
        wdata_temp <= wdata;    // Does not affect the control logic at all, prevents storing o 0s in the first entry
        
        wlast_reg <= '0;
        aw_captured_reg <= '0;
        bresp_reg <= '0;
        bvalid_reg <= '0;
        w_state <= '0;
        wvalid_reg <= '0;
        write_mask_reg <= '0;
        write_en_reg <= '0;
        available_entries_reg <= '0;
        bid_reg <= '0;
    end
    else begin
        awready_reg <= awready_next;
        awid_reg <= awid_next;
        awaddr_reg <= awaddr_next;
        awlen_reg <= awlen_next;
        wdata_temp <= wdata;
        awsize_reg <= awsize_next;
        awburst_reg <= awburst_next;
        wready_reg <= wready_next;
        wlast_reg <= wlast;
        wvalid_reg <= wvalid_next;
        if (signal_intake_reg) begin
            wdata_queue[current_reg] <= wdata_temp;
            current_reg <= current_next;
        end
        if (fill_data) begin
            fill_counter <= fill_next;
        end
        wstrb_reg <= wstrb_next;
        signal_intake_reg <= signal_data_intake;
        aw_captured_reg <= aw_captured;
        bresp_reg <= bresp_next;
        bvalid_reg <= bvalid_next;
        w_state <= w_state_next;
        write_mask_reg <= write_mask;
        write_en_reg <= fifo_wen;
        bid_reg <= bid_next;
        if (!(awready_reg && awvalid)) begin
            available_entries_reg <= available_entries;
        end
    end
end

endmodule