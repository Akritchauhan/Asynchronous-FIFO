class driver
  virtual fifo_if vif;
  mailbox grn2drv;
  
  function new(virtual fifo_if vif, mailbox gen2drv);
    this.vif=vif;
    this.gen2drv=gen2drv;
  endfunction
  task run();
    transaction tr;
    
    forever begin
      gen2drv.get(tr);
      
      if(tr.wr_en)begin
        @(posedge vif.wr_clk);
        if(!vif.full && !vif.wr_rst)begin
          vif.wr_en <=1;
          vif.data_in <=tr.data;
          @(posedge vif.wr_clk);
          vif.wr_en <=0;
          $display("[DRV] write:data=%0d @ %0t",tr.data,$time);
        end else begin
          $display("[DRV] write skipped: FULL or RESET @ %0t",$time);
        end
      end
      
      if (tr.rd_en) begin
        repeat(3) @(posedge vif.rd_clk);
        if(!vif.empty && !vif.rd_rst)begin
          vif.rd_en <=1;
          @(posedge vif.rd_clk);
          vif.rd_en<=0;
          $display("[DRV] Read triggered @ %0t",$time);
        end else begin
          $dislay("[DRV Read sjipped: EMPTY or RESET @ %0t",$time);
        end
      end
    end
  endtask
endclass
