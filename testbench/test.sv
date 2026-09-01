`ifndef AXI_TEST
`define AXI_TEST

//===================================================//
//                  BASE TEST                        //
//===================================================//
class base_test extends uvm_test;
   `uvm_component_utils(base_test)

   environment environment_h;

   function new(string name="base_test",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      environment_h=environment::type_id::create("environment_h",this);
      uvm_top.set_timeout(1000000ns,0);

   endfunction
   function void report_phase(uvm_phase phase);
      uvm_report_server server;
      int err_num;
      super.report_phase(phase);

      server = get_report_server();
      err_num = server.get_severity_count(UVM_ERROR);
      fatal_num = server.get_severity_count(UVM_FATAL);

      if (err_num != 0 || fatal_num != 0) begin
         $display("TEST CASE FAILED");
      end
      else begin
         $display("TEST CASE PASSED");
      end
   endfunction   

endclass


//===================================================//
//                TEST CASE 1                        //
//===================================================//
class test_case_1 extends base_test;
   `uvm_component_utils(test_case_1)

   function new(string name="test_case_1",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_1 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_1::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass


//===================================================//
//                TEST CASE 2                        //
//===================================================//
class test_case_2 extends base_test;
   `uvm_component_utils(test_case_2)

   function new(string name="test_case_2",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_2 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_2::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass


//===================================================//
//                TEST CASE 3                        //
//===================================================//
class test_case_3 extends base_test;
   `uvm_component_utils(test_case_3)

   function new(string name="test_case_3",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_3 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_3::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass


//===================================================//
//                TEST CASE 4                        //
//===================================================//
class test_case_4 extends base_test;
   `uvm_component_utils(test_case_4)

   function new(string name="test_case_4",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_4 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_4::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass

//===================================================//
//                TEST CASE 5                        //
//===================================================//
class test_case_5 extends base_test;
   `uvm_component_utils(test_case_5)

   function new(string name="test_case_5",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_5 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_5::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass

//===================================================//
//                TEST CASE 6                        //
//===================================================//
class test_case_6 extends base_test;
   `uvm_component_utils(test_case_6)

   function new(string name="test_case_6",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_6 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_6::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass

//===================================================//
//                TEST CASE 7                        //
//===================================================//
class test_case_7 extends base_test;
   `uvm_component_utils(test_case_7)

   function new(string name="test_case_7",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_7 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_7::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass

//===================================================//
//                TEST CASE 8                        //
//===================================================//
class test_case_8 extends base_test;
   `uvm_component_utils(test_case_8)

   function new(string name="test_case_8",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   task run_phase(uvm_phase phase);
      sequence_8 sequence_h;
      phase.raise_objection(this);
      sequence_h=sequence_8::type_id::create("sequence_h",this);
      sequence_h.start(environment_h.v_seqr);
      #100;
      phase.drop_objection(this);
   endtask

endclass



`endif
