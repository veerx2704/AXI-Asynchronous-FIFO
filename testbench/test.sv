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
      int err_num, fatal_num;
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
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
         w_seq.start(environment_h.v_seqr.w_seqr);
         r_seq.start(environment_h.v_seqr.r_seqr);
      join_none
      wait fork;
      `uvm_info("SEQUENCE ENDED - 1","",UVM_HIGH);
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
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
//      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
      w_seq_inca w_seq;
      r_seq_inca r_seq;

      phase.raise_objection(this);

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
      w_seq_nfb w_seq;
      r_seq_nfb r_seq;

      phase.raise_objection(this);

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
      w_seq_fbel w_seq;
      r_seq_fbel r_seq;

      phase.raise_objection(this);

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
      #100;
      phase.drop_objection(this);
   endtask

endclass



`endif
