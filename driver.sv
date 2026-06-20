`include "transaction.sv"

class driver;


virtual fifo_if vif;

mailbox gen2drv;



function new(virtual fifo_if vif, mailbox gen2drv);

this.vif=vif;
this.gen2drv=gen2drv;

endfunction



task run();


transaction tr;


forever

begin


gen2drv.get(tr);



if(tr.wr_en)

begin

@(posedge vif.wr_clk);


if(!vif.full && !vif.wr_rst)

begin


vif.wr_en<=1;
vif.data_in<=tr.data;


@(posedge vif.wr_clk);


vif.wr_en<=0;


$display("[DRV] WRITE %0d",tr.data);


end


end




if(tr.rd_en)

begin


@(posedge vif.rd_clk);


if(!vif.empty && !vif.rd_rst)

begin


vif.rd_en<=1;


@(posedge vif.rd_clk);


vif.rd_en<=0;


$display("[DRV] READ");

end


end



end


endtask


endclass
