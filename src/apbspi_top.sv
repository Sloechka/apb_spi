`include "apbspi_defines.sv"

module apbspi_top
#(
    APB_ADDR_WIDTH = 32    
)
(
    apbspi_apb_if.slave apb_if,
    apbspi_spi_if.master spi_if,
    output irq
);

/* FIFOs */

logic tx_fifo_push;
logic tx_fifo_pop;
logic [31:0] tx_fifo_write_data;
logic [31:0] tx_fifo_read_data;
logic tx_fifo_empty;
logic tx_fifo_full;
logic tx_fifo_flush;

`__CREATE_EVENT(tx_fifo_push)
`__CREATE_EVENT(tx_fifo_pop)
`__CREATE_EVENT(tx_fifo_flush)

apbspi_fifo tx_fifo (
    .clk(apb_if.pclk),
    .nrst(apb_if.presetn),
    .push(tx_fifo_push_event),
    .pop(tx_fifo_pop_event),
    .write_data(tx_fifo_write_data),
    .read_data(tx_fifo_read_data),
    .empty(tx_fifo_empty),
    .full(tx_fifo_full),
    .flush(tx_fifo_flush_event)
);

logic rx_fifo_push;
logic rx_fifo_pop;
logic [31:0] rx_fifo_write_data;
logic [31:0] rx_fifo_read_data;
logic rx_fifo_empty;
logic rx_fifo_full;
logic rx_fifo_flush;

`__CREATE_EVENT(rx_fifo_push)
`__CREATE_EVENT(rx_fifo_pop)
`__CREATE_EVENT(rx_fifo_flush)

apbspi_fifo rx_fifo (
    .clk(apb_if.pclk),
    .nrst(apb_if.presetn),
    .push(rx_fifo_push_event),
    .pop(rx_fifo_pop_event),
    .write_data(rx_fifo_write_data),
    .read_data(rx_fifo_read_data),
    .empty(rx_fifo_empty),
    .full(rx_fifo_full),
    .flush(rx_fifo_flush_event)
);

/* APB Slave ctrl */

logic spi_trx_done;
logic spi_busy;
logic spi_enable;
logic [31:0] spi_prescaler;
logic spi_cpha;
logic spi_cpol;

apbspi_apb_ctrl apb_slave_ctrl(
    .apb_if(apb_if),
    
    .spi_trx_done(spi_trx_done),
    .spi_busy(spi_busy),
    .spi_enable(spi_enable),
    .spi_prescaler(spi_prescaler),
    .spi_cpha(spi_cpha),
    .spi_cpol(spi_cpol),

    .tx_fifo_empty(tx_fifo_empty),
    .rx_fifo_empty(rx_fifo_empty),
    .tx_fifo_full(tx_fifo_full),
    .rx_fifo_full(rx_fifo_full),
    .tx_fifo_write_data(tx_fifo_write_data),
    .rx_fifo_read_data(rx_fifo_read_data),
    .tx_fifo_push(tx_fifo_push),
    .rx_fifo_pop(rx_fifo_pop),
    .tx_fifo_flush(tx_fifo_flush),
    .rx_fifo_flush(rx_fifo_flush),

    .irq(irq)
);

/* Prescaler */

logic clk_p;

apbspi_clk_div spi_clk_div(
    .clk(apb_if.pclk),
    .nrst(apb_if.presetn),
    .prescaler(spi_prescaler),
    .clk_p(clk_p)
);

/* SPI Master Ctrl */

apbspi_spi_ctrl spi_master_ctrl(
    .nrst(apb_if.presetn),
    .clk_p(clk_p),
    .spi_if(spi_if.master),
    .enable(spi_enable),
    .tx_fifo_empty(tx_fifo_empty),
    .tx_fifo_read_data(tx_fifo_read_data),
    .rx_fifo_write_data(rx_fifo_write_data),
    .tx_fifo_pop(tx_fifo_pop),
    .rx_fifo_push(rx_fifo_push),
    .busy(spi_busy),
    .trx_done(spi_trx_done)
);

endmodule