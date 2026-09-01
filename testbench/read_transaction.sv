`ifndef AXI_READ_TRANSACTION
`define AXI_READ_TRANSACTION

class read_transaction extends uvm_sequence_item;
rand bit rrst;

//READ ADDRESS CHANNEL
rand bit [7:0]  arid;
rand bit [15:0] araddr[];
rand bit [7:0]  arlen;
rand bit [2:0]  arsize;
rand bit [1:0]  arburst;
bit             arlock;
bit [3:0]       arcache;
bit [2:0]       arprot;
rand bit        arvalid;
bit             arready;

//READ DATA CHANNEL
bit [7:0]       rid;
bit [31:0]      rdata[];
bit [3:0]       rstrb;
bit             rlast;
bit [1:0]       rresp;
bit             rvalid;
rand bit        rready;

constraint id_range {arid inside [1:20];}
constraint burst_type {arburst==0;}
constraint length_range {arlen inside [0:15];}
constraint strobe_type {rstrb inside {4'b0001, 4'b0011, 4'b0111, 4'b1111};}      //strobe should be coherent with byte selects
constraint size_val {arsize==2;}
constraint valid_handshake {arvalid==1}
constraint ready_when {soft rready == 1;}
constraint address {araddr.size() == 1; araddr[0] == 16'h2000;}
constraint read_depth {soft rdata.size() == arlen + 1;}

`uvm_object_utils_begin(read_transaction)

`uvm_field_int(rrst,UVM_ALL_ON)


// READ ADDRESS CHANNEL
   `uvm_field_int(arid,UVM_ALL_ON)
   `uvm_field_array_int(araddr,UVM_ALL_ON)
   `uvm_field_int(arlen,UVM_ALL_ON)
   `uvm_field_int(arsize,UVM_ALL_ON)
   `uvm_field_int(arburst,UVM_ALL_ON)
   `uvm_field_int(arlock,UVM_ALL_ON)
   `uvm_field_int(arcache,UVM_ALL_ON)
   `uvm_field_int(arprot,UVM_ALL_ON)
   `uvm_field_int(arvalid,UVM_ALL_ON)
   `uvm_field_int(arready,UVM_ALL_ON)

// READ DATA CHANNEL
   `uvm_field_int(rid,UVM_ALL_ON)
   `uvm_field_array_int(rdata,UVM_ALL_ON)
   `uvm_field_int(rresp,UVM_ALL_ON)
   `uvm_field_int(rlast,UVM_ALL_ON)
   `uvm_field_int(rvalid,UVM_ALL_ON)
   `uvm_field_int(rready,UVM_ALL_ON)

`uvm_object_utils_end

function new(string name = "read_transaction");
    super.new(name);
endfunction

endclass

`endif