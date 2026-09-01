`ifndef AXI_SEQUENCE
`define AXI_SEQUENCE

class my_sequence extends uvm_sequence#(write_transaction, read_transaction);
   `uvm_object_utils(my_sequence);

   function new(string name="my_sequence");
      super.new(name);
   endfunction

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 1 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with equal length of write and read transaction 
class sequence_1 extends my_sequence;
   `uvm_object_utils(sequence_1)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 1","READ AND WRITE WITH SAME BURST LENGTH",UVM_HIGH);
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with { 
                                 wrst == 0;
                              };
               finish_item(w_trans);
            end  
            #30;
            repeat(1) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                                 wrst==1;
                                 awburst == 2'b00;
                                 awlen==6;   //6 data entities to be sent
                                 awaddr[0] == 16'h2000;
                                 wstrb==4'b1111;
                                 wdata.size==(awlen+1);
                                 unique{wdata};
                              };
               finish_item(w_trans);
            end   
         end : WRITE_CHANNEL

         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end

            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  arlen == 6;
                  arburst == 2'b00;
                  araddr[0] == 16'h2000;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL
      join_none
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
   endtask

endclass



//-------------------------------------------------------------//
//----------------------- SEQUENCE 2 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with different length of write and read transaction 
class sequence_2 extends my_sequence;
   `uvm_object_utils(sequence_2)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_2");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 2","LESS WRITE BURST MORE READ BURST",UVM_HIGH);
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 0;
               };
               finish_item(w_trans);
            end
            #30;
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 1;
                  awaddr[0] == 16'h2000;
                  awlen == 4;
                  wstrb == 4'b1111;
                  awburst == 2'b00;
                  unique{wdata};
               };
               finish_item(w_trans);
            end
         end : WRITE_CHANNEL

         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end
            #30;
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  arlen == 7;
                  araddr == 16'h2000;
                  arburst == 2'b00;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL
      join_none
      `uvm_info("SEQUENCE ENDED - 2","",UVM_HIGH);
   endtask

endclass
//-------------------------------------------------------------//
//----------------------- SEQUENCE 3 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with different read and write burst lengths
class sequence_3 extends my_sequence;
   `uvm_object_utils(sequence_3)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_3");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 3","LESS READ BURST MORE WRITE BURST",UVM_HIGH);
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 0;
               };
               finish_item(w_trans);
            end
            #30;
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 1;
                  awaddr == 16'h2000;
                  awburst == 2'b00;
                  awlen == 9;
                  wstrb == 4'b1111;
                  unique{wdata};
               };
               finish_item(w_trans);
            end
         end : WRITE_CHANNEL

         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end
            #30;
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  araddr == 16'h2000;
                  arlen == 3;
                  arburst == 2'b00;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL
      join_none
      `uvm_info("SEQUENCE ENDED - 3","",UVM_HIGH);
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 4 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with write-only operation 
class sequence_4 extends my_sequence;
   `uvm_object_utils(sequence_3)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_3");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      `uvm_info("SEQUENCE STARTED - 4","",UVM_HIGH);
      repeat(1) begin
         w_trans = write_transaction::type_id::create("w_trans");
         start_item(w_trans,p_sequencer.w_seqr);
         w_trans.randomize with {
            wrst == 0;
         };
         finish_item(w_trans);
      end
      #30;
      repeat(1) begin
         w_trans = write_transaction::type_id::create("w_trans");
         start_item(w_trans,p_sequencer.w_seqr);
         w_trans.randomize with {
            wrst == 1;
            awaddr == 16'h2000;
            awlen == 20;
            awburst == 2'b00;
            wstrb == 4'b1111;
            unique{wdata};
         };
         finish_item(w_trans);
      end
      `uvm_info("SEQUENCE ENDED - 4","",UVM_HIGH);
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 5 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with read-only operation
class sequence_5 extends my_sequence;
   `uvm_object_utils(sequence_4)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 5","",UVM_HIGH);
      repeat(1) begin
         r_trans = read_transaction::type_id::create("r_trans");
         start_item(r_trans,p_sequencer.r_seqr);
         r_trans.randomize with {
            rrst == 0;
         };
         finish_item(r_trans);
      end
      #30;
      repeat(1) begin
         r_trans = read_transaction::type_id::create("r_trans");
         start_item(r_trans,p_sequencer.r_seqr);
         r_trans.randomize with {
            rrst == 1;
            arburst == 2'b00;
            araddr == 16'h2000;
            arlen == 20;
         };
         finish_item(r_trans);
      end
      `uvm_info("SEQUENCE ENDED - 5","",UVM_HIGH);
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 6 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with incorrect address 
class sequence_6 extends my_sequence;
   `uvm_object_utils(sequence_5)
      `uvm_declare_p_sequencer(virtual_sequencer);

   
   function new(string name="sequence_5");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 6","INCORRECT ADDRESSING",UVM_HIGH);
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 0;
               };
               finish_item(w_trans);
            end
            #30;
            repeat(18) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 1;
                  wstrb == 4'b1111;
                  awburst == 2'b00;
                  awlen == 1;
               };
               finish_item(w_trans);
            end
         end : WRITE_CHANNEL
         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end
            #30;
            repeat(18) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  arburst == 2'b00;
                  arlen == 1;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL         
      join_none
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 7 --------------------------//
//-------------------------------------------------------------//
//verification of non-fixed burst with correct address

class sequence_7 extends my_sequence;
   `uvm_object_utils(sequence_7);
      `uvm_declare_p_sequencer(virtual_sequencer);

   function new(string name = "sequence_7");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 0;
               };
               finish_item(w_trans);
            end
            #30;
            repeat(8) begin
               w_trans = write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                  wrst == 1;
                  awlen == 1;
                  awaddr[0] == 16'h2000;
                  wstrb == 4'b1111;
               };
               finish_item(w_trans);
            end
         end : WRITE_CHANNEL
         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end
            #30;
            repeat(18) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  araddr == 16'h2000;
                  arlen == 1;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL          
      join_none
      `uvm_info("SEQUENCE ENDED - 7", "", UVM_HIGH);
   endtask


endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 8 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with singular long singular read/write bursts with different

class sequence_8 extends my_sequence;
   `uvm_object_utils(sequence_8);
   `uvm_declare_p_sequencer(virtual_sequencer);

   function new(string name = "sequence_8");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 8","READ AND WRITE WITH SINGULAR BURST LENGTHS BUT DIFFERENT STROBES",UVM_HIGH);
      fork
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with { 
                                 wrst == 0;
                              };
               finish_item(w_trans);
            end  
            #30;
            repeat(25) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans,p_sequencer.w_seqr);
               w_trans.randomize with {
                                 wrst==1;
                                 awburst == 2'b00;
                                 awlen==1;
                                 awaddr[0] == 16'h2000;
                                 wdata.size==(awlen+1);
                                 unique{wdata};
                              };
               finish_item(w_trans);
            end   
         end : WRITE_CHANNEL

         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 0;
               };
               finish_item(r_trans);
            end

            repeat(25) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans,p_sequencer.r_seqr);
               r_trans.randomize with {
                  rrst == 1;
                  arlen == 1;
                  arburst == 2'b00;
                  araddr[0] == 16'h2000;
               };
               finish_item(r_trans);
            end
         end : READ_CHANNEL
      join_none
      `uvm_info("SEQUENCE ENDED - 8","",UVM_HIGH);
   endtask
   

endclass

`endif
