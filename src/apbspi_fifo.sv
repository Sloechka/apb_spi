module apbspi_fifo
# (
    parameter width = 32, depth = 16
)
(
    input clk,
    input nrst,
    input push,
    input pop,
    input flush,
    input [width-1:0] write_data,
    output logic [width-1:0] read_data,
    output logic empty,
    output logic full
);

localparam pointer_width = $clog2(depth), extended_pointer_width = pointer_width + 1;

// Check that the depth is truly a power of two
initial assert ((1 << pointer_width) == depth);

logic [extended_pointer_width-1:0] ext_wr_ptr, ext_rd_ptr;
logic [pointer_width-1:0] wr_ptr;
logic [pointer_width-1:0] rd_ptr; 

assign wr_ptr = ext_wr_ptr [pointer_width - 1:0];
assign rd_ptr = ext_rd_ptr [pointer_width - 1:0];

logic [width-1:0] data [0:depth-1];

/* Pointer logic */

always_ff @(posedge clk or negedge nrst) begin
    if (!nrst | flush)
        ext_wr_ptr <= '0;
    else if (push)
        ext_wr_ptr <= ext_wr_ptr + 1'b1;
end

always_ff @(posedge clk or negedge nrst) begin
    if (!nrst | flush)
        ext_rd_ptr <= '0;
    else if (pop)
        ext_rd_ptr <= ext_rd_ptr + 1'b1;
end

/* I/O */

always_ff @(posedge clk or negedge nrst) begin
    if (push)
        data [wr_ptr] <= write_data;
end

assign read_data = data[rd_ptr];

/* Flags */

assign empty = (ext_rd_ptr == ext_wr_ptr);
assign full = (ext_rd_ptr[extended_pointer_width-1] ^ ext_wr_ptr[extended_pointer_width-1]) & (wr_ptr == rd_ptr);

endmodule
