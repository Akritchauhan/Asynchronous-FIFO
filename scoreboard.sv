class scoreboard #(parameter data_width=8);
  
  bit [data_width-1:0]= expected_q[$];
  mailbox mon2scb;
  virtual fifo_if vif;
  
  function new(mailbox mon2scb, virtual fifo_if vif);
    this.mon2scb=mon2scb;
    this.vif=vif;
  endfunction
  
  task run();
    transaction tr;
    forever begin
      mon2scb.get(tr)
      
      if(tr.wr_en && !tr.rd_en)begin
        expected_q.push_back(tr.data);
        $display("[SCB] write: expected_q = %0d",tr.data);
      end
      
      else if(tr.rd_en && !tr.wr_en)begin
        if(expected_q.size()>0)begin
          bit [data_width-1:0] expected_val=expected_q.pop_front();
          if(tr.data!=expected_val)begin
            $display("[SCB][Fail] read mismatched! Expected: %0d, got %0d",expecetd_val,tr.data);
          end else begin
            $display("[SCB][Pass] Read matched = %0d ",tr.data);
          end
        end else begin
          $display("[Scb][Warn] underflow: Read occured with no expected value");
        end
      end
    end
  endtask
endclass
            
            
    
