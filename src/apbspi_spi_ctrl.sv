
module apbspi_spi_ctrl (
    input nrst,
    input clk_p,

    apbspi_spi_if.master spi_if,

    input enable,
    input tx_fifo_empty,
    input [31:0] tx_fifo_read_data,
    output logic [31:0] rx_fifo_write_data,
    output logic tx_fifo_pop,
    output logic rx_fifo_push,
    output logic tx_fifo_flush,
    output logic rx_fifo_flush,
    output logic busy,
    output logic trx_done
);

logic [4:0] bit_cntr;
logic [31:0] tx_shift_reg;
logic [31:0] rx_shift_reg;

assign rx_fifo_write_data = rx_shift_reg;
assign spi_if.cs = ~enable;
assign spi_if.sck = busy & clk_p;
assign spi_if.mosi = tx_shift_reg[0];

always_ff @(negedge clk_p or negedge nrst) begin
    if(!nrst) begin
        bit_cntr <= 0;
        busy <= 0;
        trx_done <= 0;
    end
    else begin
        trx_done <= 0;
        
        if(enable) begin
            if(~|bit_cntr) begin
                if(~tx_fifo_empty) begin
                    busy <= 1'b1;
                    bit_cntr <= bit_cntr + 1'b1;
                end
                else begin
                    if(busy) trx_done <= 1'b1;
                    busy <= 0;
                end
            end
            else if(busy) bit_cntr <= bit_cntr + 1'b1;
        end
    end
end

always_ff @(negedge clk_p or negedge nrst) begin
    if(!nrst) begin
        tx_shift_reg <= 0;
        tx_fifo_pop <= 0;
    end
    else begin
        if(enable) begin
            tx_fifo_pop <= 0;
            if(~|bit_cntr & ~tx_fifo_empty) begin
                tx_shift_reg <= tx_fifo_read_data;
                tx_fifo_pop <= 1'b1;
            end
            else if(busy) tx_shift_reg <= {1'b0, tx_shift_reg[31:1]};
        end
    end
end

always_ff @(posedge clk_p or negedge nrst) begin
    if(!nrst) begin
        rx_shift_reg <= 0;
        rx_fifo_push <= 0;
    end
    else begin
        if(enable) begin
            rx_fifo_push <= 0;
            if(busy) begin
                rx_shift_reg <= {spi_if.miso, rx_shift_reg[31:1]};
                if(~|bit_cntr) rx_fifo_push <= 1'b1;
            end
        end
    end
end

endmodule