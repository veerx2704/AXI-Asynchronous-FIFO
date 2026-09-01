`ifndef AXI_SEQUENCE
`define AXI_SEQUENCE

class my_sequence extends uvm_sequence#(transaction);
   `uvm_object_utils(my_sequence)

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
   
   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
      write_transaction w_trans;
      read_transaction r_trans;
      `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
      fork begin
         begin : WRITE_CHANNEL
            repeat(1) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans);
               w_trans.randomize with { 
                                 wrst == 0;
                              };
               finish_item(w_trans);
            end  
            #30;
            repeat(1) begin
               w_trans=write_transaction::type_id::create("w_trans");
               start_item(w_trans);
               w_trans.randomize with {
                                 reset==1;
                                 awlen==6;   //6 data entities to be sent
                                 awaddr.size==1;
                                 awaddr[0] = 16'h2000;
                                 wstrb==4'b1111;
                                 wdata.size==(awlen+1);
                                 unique{wdata};
                              };
               finish_item(trans);
               `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
            end   
         end : WRITE_CHANNEL

         begin : READ_CHANNEL
            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans);
               r_trans.randomize with {
                  rrst = 0;
               };
               finish_item(r_trans);
            end

            repeat(1) begin
               r_trans = read_transaction::type_id::create("r_trans");
               start_item(r_trans);
               r_trans.randomize with {
                  rrst == 1;
                  arlen == 6;
                  araddr.size == 1;
                  araddr[0] == 16'h2000;
                  rstrb == 4'b1111;
                  rdata.size == arlen + 1;
               }
            end
         end : READ_CHANNEL
   endtask

endclass



//-------------------------------------------------------------//
//----------------------- SEQUENCE 2 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with different length of write and read transaction 
class sequence_2 extends my_sequence;
   `uvm_object_utils(sequence_2)
   
   
   function new(string name="sequence_2");
      super.new(name);
   endfunction

   task body();
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 3 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with write-only operation 
class sequence_3 extends my_sequence;
   `uvm_object_utils(sequence_3)
   
   
   function new(string name="sequence_3");
      super.new(name);
   endfunction

   task body();
 
   endtask

endclass


//-------------------------------------------------------------//
//----------------------- SEQUENCE 4 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with read-only operation
class sequence_4 extends my_sequence;
   `uvm_object_utils(sequence_4)
   
   
   function new(string name="sequence_1");
      super.new(name);
   endfunction

   task body();
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 5 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with incorrect address 
class sequence_5 extends my_sequence;
   `uvm_object_utils(sequence_5)
   
   
   function new(string name="sequence_5");
      super.new(name);
   endfunction

   task body();
   endtask

endclass

//-------------------------------------------------------------//
//----------------------- SEQUENCE 6 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with incorrect address


//-------------------------------------------------------------//
//----------------------- SEQUENCE 7 --------------------------//
//-------------------------------------------------------------//
//verification of fixed burst with singular long singular read/write bursts


`endif
