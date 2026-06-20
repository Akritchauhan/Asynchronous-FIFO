`include "transaction.sv"


class monitor;


virtual fifo_if vif;

mailbox mon2scb;



function new(virtual fifo_if vif, mailbox mon2scb);

this.vif=vif;
this.mon2scb=mon2scb;

endfunction



task run();


fork

monitor_write();

monitor_read();

join_none


endtask



task monitor_write();


transaction tr;


forever

begin


@(posedge vif.wr_clk);


if(vif.wr_en && !vif.full)

begin


tr=new();

tr.wr_en=1;

tr.data=vif.data_in;


mon2scb.put(tr.copy());


end


end


endtask




task monitor_read();


transaction tr;


forever

begin


@(posedge vif.rd_clk);


if(vif.rd_en && !vif.empty)

begin


@(posedge vif.rd_clk);


tr=new();

tr.rd_en=1;

tr.data=vif.data_out;


mon2scb.put(tr.copy());


end


end


endtask


endclass
