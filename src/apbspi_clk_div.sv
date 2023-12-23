module apbspi_clk_div(
    input clk,
    input nrst,
    input [31:0] prescaler,
    output logic clk_p
);

logic [31:0] clk_cntr;
logic clk_div;
logic prescaler_enabled;

assign prescaler_enabled = |prescaler;
assign clk_p = prescaler_enabled ? clk_div : clk;

always_ff @(posedge clk or negedge nrst) begin
    if(!nrst) begin
        clk_cntr <= 0;
        clk_div <= 0;
    end
    else begin
        if(prescaler_enabled) begin
            if(clk_cntr == prescaler) begin
                clk_cntr <= 0;
                clk_div <= ~clk_div;
            end
            else clk_cntr <= clk_cntr + 1'b1;
        end
        else clk_cntr <= 0;
    end
end

endmodule