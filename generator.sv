class generator
  bit random_mode;
  
  transaction user_queue[$];
  mailbox gen2drv;
  int num_transaction=10;
  
  function new(mailbox gen2drv);
    this.gen2drv=gen2drv;
    this.random_mode=1;
  endfunction
  
  task add_user_transaction(transaction tr);
    user_queue_push_back(tr);
  endtask
  
  task run();
    transaction tr;
    if(random_mode)begin
      $display("[Gen] running random mode");
      repeat(num_transaction)begin
        tr=new();
        assert(tr.randomize() with{(wr_en || rd_en);});
        tr.display("Gen");
        gen2drv.put(tr);
      end
    end else begin
      $display("[Gen] Running in user-defined mode");
      foreach(user_queue[i])begin
        user_queue[i].display("GEN");
        gen2drv.put(user_queue[i]);
      end
    end
  endtask
endclass
