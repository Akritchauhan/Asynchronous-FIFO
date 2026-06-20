class transaction;

rand bit [7:0] data;
rand bit wr_en;
rand bit rd_en;

bit [7:0] expected_data;


function new();

    data=0;
    wr_en=0;
    rd_en=0;
    expected_data=0;

endfunction


function void display(string tag="");

$display("[%s] wr_en=%0b rd_en=%0b data=%0d",
tag,wr_en,rd_en,data);

endfunction


function transaction copy();

transaction t;

t=new();

t.data=this.data;
t.wr_en=this.wr_en;
t.rd_en=this.rd_en;
t.expected_data=this.expected_data;

return t;

endfunction


function bit compare(transaction t);

return(this.data == t.data);

endfunction


endclass
