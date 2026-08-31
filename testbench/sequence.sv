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
      transaction w_trans, r_trans;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         w_trans=transaction::type_id::create("w_trans");
         start_item(w_trans);
         w_trans.randomize with { 
                           reset==0;
                        };
         finish_item(w_trans);
      end  
      #30;
      repeat(1) begin
         w_trans=transaction::type_id::create("w_trans");
         start_item(w_trans);
         w_trans.randomize with {
                           reset==1;
                           awlen==6;
                           awlen==arlen;
                           awaddr.size==1;
                           awaddr[0]==araddr[0];
                           wstrb==4'b1111;
                           wdata.size==(awlen+1);

                           unique{wdata};
                        };
         finish_item(trans);
         `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
      end   
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
      transaction trans;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with { 
                           reset==1;
                        };
         finish_item(trans);
      end  
      #30;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 2","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
                           awlen==9;
                           reset==0;
                           arlen==5;
                           wstrb==4'b1111;
                           wdata.size==(awlen+1);
                           unique{wdata};
                           unique{awaddr};
                           awaddr[0]==araddr[0];
                        };
         finish_item(trans);
      end
      repeat(1) begin
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
                           awlen==5;
                           reset==0;
                           arlen==9;
                           wstrb==4'b1111;
                           wdata.size==(awlen+1);
                           unique{wdata};
                           unique{awaddr};
                           awaddr[0]==araddr[0];
                        };
         finish_item(trans);
         `uvm_info("SEQUENCE ENDED - 2","",UVM_HIGH);
      end 
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
      transaction trans;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with { 
                           reset==1;
                        };
         finish_item(trans);
      end  
      #30;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 3","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
                           awaddr[0]==122;
                           reset==0;
                           araddr[0]==120;
                           wstrb==4'b1111;
                           awlen==9;
                           awlen==arlen;
                           wdata.size==(awlen+1);
                           unique{wdata};
                        };
         finish_item(trans);
         `uvm_info("SEQUENCE ENDED - 3","",UVM_HIGH);
      end


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
      transaction trans;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with { 
                           reset==1;
                        };
         finish_item(trans);
      end  
      #30;
      repeat(10) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
                           awlen==0;
                           awburst==0;
                           reset==0;
                           arburst==0;
                           awlen==arlen;
                           wdata.size==(awlen+1);
                           unique{wdata};
                           unique{awaddr};
                           awaddr[0]%4==0;
                           awaddr[0]==araddr[0];
                        };
         finish_item(trans);
         `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
      end   
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
      transaction trans;
      repeat(1) begin
         `uvm_info("SEQUENCE STARTED - 1","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with { 
                           reset==1;
                        };
         finish_item(trans);
      end  
      #30;
      repeat(10) begin
         `uvm_info("SEQUENCE STARTED - 5","",UVM_HIGH);
         trans=transaction::type_id::create("trans");
         start_item(trans);
         trans.randomize with {
                           awlen==0;
                           reset==0;
                           awburst==0;
                           arburst==0;
                           awlen==arlen;
                           wdata.size==(awlen+1);
                           unique{wdata};
                           unique{awaddr};
                           awaddr[0]%4!=0;
                           awaddr[0]==araddr[0];
                           awaddr[0]%4==0 -> wstrb==4'b1111;
                           awaddr[0]%4==1 -> wstrb==4'b0111;
                           awaddr[0]%4==2 -> wstrb==4'b0011;
                           awaddr[0]%4==3 -> wstrb==4'b0001;
                        };
         finish_item(trans);
         `uvm_info("SEQUENCE ENDED - 5","",UVM_HIGH);
      end   
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
