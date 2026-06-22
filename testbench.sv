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



//================ One Write & One Read Test ================

task test_single_write_read();

    reg [data_width-1:0] write_data;

    begin

        $display("\n--- Single Write Read Test Started ---");


        write_data = 8'hA5;


        // Write data into FIFO

        @(posedge wr_clk);

        intf.wr_en   = 1;
        intf.data_in = write_data;

        @(posedge wr_clk);

        intf.wr_en = 0;


        $display("[TEST] Data written : %h", write_data);



        // Wait before reading

        repeat(2)
            @(posedge rd_clk);



        // Read data from FIFO

        @(posedge rd_clk);

        intf.rd_en = 1;

        @(posedge rd_clk);

        intf.rd_en = 0;



        // Check received data

        @(posedge rd_clk);

        if(intf.data_out == write_data)

            $display("[TEST] PASS : Read data = %h", intf.data_out);

        else

            $display("[TEST] FAIL : Expected = %h Received = %h",
                     write_data, intf.data_out);



        $display("--- Single Write Read Test Completed ---\n");


    end

endtask
  
//================ Multiple Write & Read Test ================

task test_multiple_write_read();

    reg [data_width-1:0] write_data;
    reg [data_width-1:0] expected_data;
    integer i;


    begin

        $display("\n--- Multiple Write Read Test Started ---");


        // Multiple write operation

        for(i=0; i<5; i=i+1)
        begin

            write_data = i + 8'h10;


            @(posedge wr_clk);

            intf.wr_en   = 1;
            intf.data_in = write_data;


            @(posedge wr_clk);

            intf.wr_en = 0;


            $display("[TEST] Write Data = %h",write_data);


        end



        // Wait before reading

        repeat(2)
            @(posedge rd_clk);



        // Multiple read operation

        for(i=0; i<5; i=i+1)
        begin


            @(posedge rd_clk);

            intf.rd_en = 1;


            @(posedge rd_clk);

            intf.rd_en = 0;



            @(posedge rd_clk);


            $display("[TEST] Read Data = %h",
                     intf.data_out);


        end



        $display("--- Multiple Write Read Test Completed ---\n");


    end

endtask

  
//================ FIFO Overflow Test ================

task test_overflow();

    reg [data_width-1:0] write_data;
    integer i;

    begin

        $display("\n--- FIFO Overflow Test Started ---");


        // Fill FIFO completely

        for(i=0; i<(1<<addr_width); i=i+1)
        begin

            write_data = i;


            @(posedge wr_clk);

            intf.wr_en   = 1;
            intf.data_in = write_data;


            @(posedge wr_clk);

            intf.wr_en = 0;


            $display("[TEST] Write Data = %h",write_data);

        end



        // Wait for full flag

        @(posedge wr_clk);


        if(intf.full)

            $display("[TEST] FIFO FULL reached");

        else

            $display("[TEST] FAIL : FIFO did not become full");



        // Extra write after FIFO is full

        write_data = 8'hFF;


        @(posedge wr_clk);

        intf.wr_en   = 1;
        intf.data_in = write_data;


        @(posedge wr_clk);

        intf.wr_en = 0;



        if(intf.full)

            $display("[TEST] PASS : Overflow prevented");

        else

            $display("[TEST] FAIL : Overflow condition not detected");



        $display("--- FIFO Overflow Test Completed ---\n");


    end

endtask
  
//================ FIFO Underflow Test ================

task test_underflow();

begin

    $display("\n--- FIFO Underflow Test Started ---");


    // Make sure FIFO is empty

    @(posedge rd_clk);


    if(intf.empty)

        $display("[TEST] FIFO is empty");

    else

        $display("[TEST] FAIL : FIFO is not empty");



    // Try reading from empty FIFO

    @(posedge rd_clk);

    intf.rd_en = 1;


    @(posedge rd_clk);

    intf.rd_en = 0;



    // Check empty condition

    @(posedge rd_clk);


    if(intf.empty)

        $display("[TEST] PASS : Underflow prevented");

    else

        $display("[TEST] FAIL : FIFO allowed invalid read");



    $display("--- FIFO Underflow Test Completed ---\n");


end

endtask

//================ Random Write Read Test ================

task test_random_write_read();

    reg [data_width-1:0] random_data;
    reg [data_width-1:0] expected_data;
    integer i;
    integer operation;


begin

    $display("\n--- Random Write Read Test Started ---");


    for(i=0; i<50; i=i+1)
    begin


        operation = $urandom_range(0,1);



        // Random WRITE

        if(operation == 1)
        begin

            random_data = $urandom_range(0,255);


            @(posedge wr_clk);

            if(!intf.full)
            begin

                intf.wr_en   = 1;
                intf.data_in = random_data;


                @(posedge wr_clk);

                intf.wr_en = 0;


                $display("[TEST] WRITE : Data = %h",
                         random_data);

            end

            else

                $display("[TEST] WRITE SKIPPED : FIFO FULL");


        end



        // Random READ

        else

        begin


            @(posedge rd_clk);


            if(!intf.empty)
            begin


                intf.rd_en = 1;


                @(posedge rd_clk);


                intf.rd_en = 0;


                @(posedge rd_clk);


                $display("[TEST] READ : Data = %h",
                         intf.data_out);


            end

            else

                $display("[TEST] READ SKIPPED : FIFO EMPTY");


        end


    end



    $display("--- Random Write Read Test Completed ---\n");


end

endtask

//================ TEST START =================


initial begin


    $dumpfile("fifo.vcd");
    $dumpvars(0,top);



    env = new(intf);

    env.run();



    reset_test();
    test_single_write_read();
    test_multiple_write_read();
    test_overflow();
    test_underflow();
    test_random_write_read();
  
    



    #200;


    $finish;


end



endmodule
