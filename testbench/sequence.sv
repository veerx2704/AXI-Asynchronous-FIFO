`ifndef AXI_SEQUENCE
`define AXI_SEQUENCE

class my_sequence extends uvm_sequence;
   `uvm_object_utils(my_sequence);

   function new(string name="my_sequence");
      super.new(name);
   endfunction

endclass

class w_seq_fbel extends uvm_sequence #(write_transaction);
   `uvm_object_utils(w_seq_fbel);

   function new (string name = "w_seq_fbel");
      super.new(name);
   endfunction

   write_transaction trans;

   
   bit [15:0] addr;
   bit [7:0] len;
   bit [3:0] strb;
   bit [1:0] burst;
   int iteration;

   task body();
      repeat(1) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 1;
            awlen == len;
            wstrb == strb;
            awaddr[0] == addr;
            awburst == burst;
         };
         finish_item(trans);
      end
   endtask

endclass

class r_seq_fbel extends uvm_sequence #(read_transaction);
   `uvm_object_utils(r_seq_fbel);
   function new (string name = "r_seq_fbel");
      super.new(name);
   endfunction
   read_transaction trans;

   
   bit [15:0] addr;
   bit [7:0] len;
   bit [3:0] strb;
   bit [1:0] burst;
   int iteration;


   task body();
      repeat(1) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 1;
            arlen == len;
            araddr[0] == addr;
            arburst == burst;
         };
         finish_item(trans);
      end
   endtask

endclass

class w_seq_inca extends uvm_sequence #(write_transaction);
   `uvm_object_utils(w_seq_inca);

   function new (string name = "w_seq_inca");
      super.new(name);
   endfunction
   write_transaction trans;

   
   bit [7:0] len;
   bit [3:0] strb;
   bit [1:0] burst;
   int iteration;


   task body();
      repeat(1) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 1;
            awlen == len;
            wstrb == strb;
            awburst == burst;
         };
         finish_item(trans);
      end
   endtask

endclass

class r_seq_inca extends uvm_sequence #(read_transaction);
   `uvm_object_utils(r_seq_inca);

   function new (string name = "r_seq_inca");
      super.new(name);
   endfunction

   read_transaction trans;

   
   bit [7:0] len;
   bit [3:0] strb;
   bit [1:0] burst;
   int iteration;


   task body();
      repeat(1) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 1;
            arlen == len;
            arburst == burst;
         };
         finish_item(trans);
      end
   endtask

endclass

class w_seq_nfb extends uvm_sequence #(write_transaction);
   `uvm_object_utils(w_seq_nfb);

   function new (string name = "w_seq_nfb");
      super.new(name);
   endfunction

   write_transaction trans;

   
   bit [7:0] len;
   bit [3:0] strb;
   bit [15:0] addr;
   int iteration;


   task body();
      repeat(1) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = write_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            wrst == 1;
            awlen == len;
            wstrb == strb;
            awaddr[0] == addr;
         };
         finish_item(trans);
      end
   endtask

endclass


class r_seq_nfb extends uvm_sequence #(read_transaction);
   `uvm_object_utils(r_seq_nfb);

   function new (string name = "r_seq_nfb");
      super.new(name);
   endfunction

   read_transaction trans;

   
   bit [7:0] len;
   bit [3:0] strb;
   bit [15:0] addr;
   int iteration;


   task body();
      repeat(1) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 0;
         };
         finish_item(trans);
      end
      repeat(iteration) begin
         trans = read_transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
            rrst == 1;
            arlen == len;
            araddr[0] == addr;
         };
         finish_item(trans);
      end
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 1 --------------------------//
//-------------------------------------------------------------//
verification of fixed burst with equal length of write and read transaction 
class sequence_1 extends my_sequence;
   `uvm_object_utils(sequence_1)
      

   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      w_seq = w_seq_fbel::type_id::create("w_seq");
      r_seq = r_seq_fbel::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 6;
      w_seq.addr = 16'h2000;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 6;
      r_seq.addr = 16'h2000;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 1","READ AND WRITE WITH SAME BURST LENGTH",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
   endtask

endclass



// -------------------------------------------------------------//
// ----------------------- SEQUENCE 2 --------------------------//
// -------------------------------------------------------------//
// verification of fixed burst with different length of write and read transaction 
class sequence_2 extends my_sequence;
   `uvm_object_utils(sequence_2)
      

   
   function new(string name="sequence_2");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      w_seq = w_seq_fbel::type_id::create("w_seq");
      r_seq = r_seq_fbel::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 4;
      w_seq.addr = 16'h2000;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 9;
      r_seq.addr = 16'h2000;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 2","READ AND WRITE WITH DIFFERENT BURST LENGTH",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 2","",UVM_HIGH);
   endtask

endclass
//-------------------------------------------------------------//
//----------------------- SEQUENCE 3 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with different read and write burst lengths
class sequence_3 extends my_sequence;
   `uvm_object_utils(sequence_3)
      

   
   function new(string name="sequence_3");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      w_seq = w_seq_fbel::type_id::create("w_seq");
      r_seq = r_seq_fbel::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 9;
      w_seq.addr = 16'h2000;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 4;
      r_seq.addr = 16'h2000;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 3","READ AND WRITE WITH DIFFERENT BURST LENGTH",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 3","",UVM_HIGH);
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 4 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with write-only operation 
class sequence_4 extends my_sequence;
   `uvm_object_utils(sequence_4)
      

   
   function new(string name="sequence_3");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      w_seq = w_seq_fbel::type_id::create("w_seq");
      //r_seq = r_seq_fbel::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 18;
      w_seq.addr = 16'h2000;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      // r_seq.iteration = 1;
      // r_seq.len = 6;
      // r_seq.addr = 16'h2000;
      // r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 4","WRITE-ONLY OPERATION",UVM_HIGH);
//      fork
         w_seq.start(p_sequencer.w_seqr);
//         r_seq.start(p_sequencer.r_seqr);
//      join_none
//      wait fork;
      `uvm_info("SEQUENCE ENDED - 4","",UVM_HIGH);
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 5 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with read-only operation
class sequence_5 extends my_sequence;
   `uvm_object_utils(sequence_5)
      

   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

//      w_seq = w_seq_fbel::type_id::create("w_seq");
      r_seq = r_seq_fbel::type_id::create("r_seq");

      // w_seq.iteration = 1;
      // w_seq.len = 6;
      // w_seq.addr = 16'h2000;
      // w_seq.burst = 2'b00;
      // w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 6;
      r_seq.addr = 16'h2000;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 5","READ-ONLY OPERATION",UVM_HIGH);
      // fork
      //    w_seq.start(p_sequencer.w_seqr);
          r_seq.start(p_sequencer.r_seqr);
      // join_none
      // wait fork;
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 6 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with incorrect address 
class sequence_6 extends my_sequence;
   `uvm_object_utils(sequence_6)
      

   
   function new(string name="sequence_5");
      super.new(name);
   endfunction

   task body();
      w_seq_inca w_seq;
      r_seq_inca r_seq;

      w_seq = w_seq_inca::type_id::create("w_seq");
      r_seq = r_seq_inca::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 6;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 6;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 6","INCORRECT ADDRESS",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 7 --------------------------//
//-------------------------------------------------------------//
//verification of non-fixed burst with correct address

class sequence_7 extends my_sequence;
   `uvm_object_utils(sequence_7);
      

   function new(string name = "sequence_7");
      super.new(name);
   endfunction

   task body();
      w_seq_nfb w_seq;
      r_seq_nfb r_seq;

      w_seq = w_seq_nfb::type_id::create("w_seq");
      r_seq = r_seq_nfb::type_id::create("r_seq");

      w_seq.iteration = 1;
      w_seq.len = 6;
      w_seq.addr = 16'h2000;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 1;
      r_seq.len = 6;
      r_seq.addr = 16'h2000;


      `uvm_info("SEQUENCE STARTED - 7","NON-FIXED BURST",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
   endtask


endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 8 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with singular long singular read/write bursts with different

class sequence_8 extends my_sequence;
   `uvm_object_utils(sequence_8);
   

   function new(string name = "sequence_8");
      super.new(name);
   endfunction

   task body();
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      w_seq = w_seq_fbel::type_id::create("w_seq");
      r_seq = r_seq_fbel::type_id::create("r_seq");

      w_seq.iteration = 14;
      w_seq.len = 1;
      w_seq.addr = 16'h2000;
      w_seq.burst = 2'b00;
      w_seq.strb = 4'b1111;

      r_seq.iteration = 14;
      r_seq.len = 1;
      r_seq.addr = 16'h2000;
      r_seq.burst = 2'b00;


      `uvm_info("SEQUENCE STARTED - 8","MULTIPLE SINGLE BURSTS",UVM_HIGH);
      fork
         w_seq.start(p_sequencer.w_seqr);
         r_seq.start(p_sequencer.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 8","",UVM_HIGH);
   endtask
   

endclass

`endif
