interface fifo_if #(parameter data_width=8)(
    input logic wr_clk,
    input logic rd_clk
);

logic [data_width-1:0] data_in;
logic [data_width-1:0] data_out;

logic wr_rst;
logic rd_rst;

logic wr_en;
logic rd_en;

logic full;
logic empty;


modport Tb(
    input wr_clk,
    input rd_clk,
    input full,
    input empty,
    input data_out,

    output wr_rst,
    output rd_rst,
    output wr_en,
    output rd_en,
    output data_in
);

endinterface
