module apbspi_edge_detector(
    input clk,
    input nrst,
    input signal,
    output signal_event
);

logic signal_q;
assign signal_event = ~signal_q & signal;

always_ff @(posedge clk or negedge nrst) begin
    if(!nrst)
        signal_q <= 0;
    else
        signal_q <= signal;
end

endmodule