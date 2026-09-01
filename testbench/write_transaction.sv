`ifndef AXI_WRITE_TRANSACTION
`define AXI_WRITE_TRANSACTION

class write_transaction extends uvm_sequence_item;
rand bit wrst;


// WRITE ADDRESS CHANNEL
rand bit [7:0]  awid;
rand bit [15:0] awaddr[];
rand bit [7:0]  awlen;
rand bit [2:0]  awsize;
rand bit [1:0]  awburst;

bit         awlock;
bit [3:0]   awcache;
bit [2:0]   awprot;

rand bit    awvalid;
bit         awready;

//WRITE DATA CHANNEL
rand bit [31:0] wdata[];
rand bit        wlast;
rand bit [3:0]  wstrb;
rand bit        wvalid;
bit             wready;

//WRITE RESPONSE CHANNEL
bit [7:0]   bid;
bit [1:0]   bresp;
bit         bvalid;
bit         bready;


constraint id_range {awid inside [1:20];}
constraint burst_type {awburst == 0;}
constraint length_range{awlen inside [0:15];}
constraint strobe_type {wstrb inside {4'b0001, 4'b0011, 4'b0111, 4'b1111};}      //strobe should be coherent with byte selects
constraint size_val {awsize == 2'b10;}                                                 //fixed 32-bit size
constraint valid_aw {soft awvalid == 1'b1;}
constraint valid_w {soft wvalid == 1'b1}
constraint ready_when {soft bready == 1;}
constraint address {awaddr.size() == 1; awaddr[0] == 16'h2000;}
constraint write_depth {wdata.size() == awlen + 1;}

`uvm_object_utils_begin(transaction)

`uvm_field_int(wrst,UVM_ALL_ON)

// WRITE ADDRESS CHANNEL
   `uvm_field_int(awid,UVM_ALL_ON)
   `uvm_field_array_int(awaddr,UVM_ALL_ON)
   `uvm_field_int(awlen,UVM_ALL_ON)
   `uvm_field_int(awsize,UVM_ALL_ON)
   `uvm_field_int(awburst,UVM_ALL_ON)
   `uvm_field_int(awlock,UVM_ALL_ON)
   `uvm_field_int(awcache,UVM_ALL_ON)
   `uvm_field_int(awprot,UVM_ALL_ON)
   `uvm_field_int(awvalid,UVM_ALL_ON)
   `uvm_field_int(awready,UVM_ALL_ON)

// WRITE DATA CHANNEL
   `uvm_field_array_int(wdata,UVM_ALL_ON)
   `uvm_field_int(wstrb,UVM_ALL_ON)
   `uvm_field_int(wlast,UVM_ALL_ON)
   `uvm_field_int(wvalid,UVM_ALL_ON)
   `uvm_field_int(wready,UVM_ALL_ON)

// WRITE RESPONSE CHANNEL
   `uvm_field_int(bid,UVM_ALL_ON)
   `uvm_field_int(bresp,UVM_ALL_ON)
   `uvm_field_int(bvalid,UVM_ALL_ON)
   `uvm_field_int(bready,UVM_ALL_ON)


`uvm_object_utils_end

function new(string name = "write_transaction");
    super.new(name);
endfunction

endclass

`endif