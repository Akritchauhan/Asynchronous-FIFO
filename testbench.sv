`include "interface.sv"
`include "environment.sv"


module top;


parameter data_width = 8;
parameter addr_width = 4;


logic wr_clk = 0;
logic rd_clk = 0;


always #5 wr_clk = ~wr_clk;
always #5 rd_clk = ~rd_clk;



fifo_if #(data_width) intf(
    .wr_clk(wr_clk),
    .rd_clk(rd_clk)
);



async_fifo #(
    .data_width(data_width),
    .addr_width(addr_width)
) dut (

    .data_in(intf.data_in),
    .wr_en(intf.wr_en),
    .wr_clk(intf.wr_clk),
    .wr_rst(intf.wr_rst),

    .full(intf.full),

    .data_out(intf.data_out),
    .rd_en(intf.rd_en),
    .rd_clk(intf.rd_clk),
    .rd_rst(intf.rd_rst),

    .empty(intf.empty)

);



environment env;



//================ RESET TEST =================

task reset_test();

begin

    $display("=================================");
    $display("        RESET TEST START");
    $display("=================================");


    intf.wr_rst = 1;
    intf.rd_rst = 1;

    intf.wr_en = 0;
    intf.rd_en = 0;

    intf.data_in = 0;


    #20;


    if((intf.empty == 1) && (intf.full == 0))

        $display("[RESET TEST] PASS : FIFO reset successful");

    else

        $display("[RESET TEST] FAIL : FIFO reset failed");



    intf.wr_rst = 0;
    intf.rd_rst = 0;


    #20;


    $display("[RESET TEST] COMPLETED");

    $display("=================================");


end

endtask



//================ TEST START =================


initial begin


    $dumpfile("fifo.vcd");
    $dumpvars(0,top);



    env = new(intf);

    env.run();



    reset_test();



    #200;


    $finish;


end



endmodule
