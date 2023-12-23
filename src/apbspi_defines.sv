`ifndef __APBSPI_DEFINES
`define __APBSPI_DEFINES

/* Control registers */

// Data TX buffer
`define REG_DATA_TX         32'h0

// Control register
`define REG_CR              32'h4
`define REG_CR_SPIEN        5'd0
`define REG_CR_CPHA         5'd1
`define REG_CR_CPOL         5'd2
`define REG_CR_FLUSH_TX     5'd3
`define REG_CR_FLUSH_RX     5'd4

// Prescaler value
`define REG_PRESC           32'h8

// Interrupt enable
`define REG_IRQ_EN          32'hc
`define REG_IRQ_EN_TX_EMPTY 5'd0
`define REG_IRQ_EN_TX_FULL  5'd1
`define REG_IRQ_EN_RX_EMPTY 5'd2
`define REG_IRQ_EN_RX_FULL  5'd3
`define REG_IRQ_EN_TRX_DONE 5'd4

// Interrupts
`define REG_IRQ             32'h10
`define REG_IRQ_TX_EMPTY    5'd0
`define REG_IRQ_TX_FULL     5'd1
`define REG_IRQ_RX_EMPTY    5'd2
`define REG_IRQ_RX_FULL     5'd3
`define REG_IRQ_TRX_DONE    5'd4

/* Status registers */

// Status register
`define REG_SR              32'h14
`define REG_SR_BUSY         5'd0
`define REG_SR_TX_EMPTY     5'd1
`define REG_SR_TX_FULL      5'd2
`define REG_SR_RX_EMPTY     5'd3
`define REG_SR_RX_FULL      5'd4

// Data RX buffer
`define REG_DATA_RX         32'h18

/* Common */

`define __REG_SIZE 16
`define __REG_ADDR_WIDTH $clog2(`__REG_SIZE)

`define __REG_INDEX(ADDR) ``ADDR / 4

`define __CREATE_EVENT(var) \
    logic ``var``_event; \
    apbspi_edge_detector ``var``_edge_detector (.clk(apb_if.pclk), .nrst(apb_if.presetn), .signal(``var``), .signal_event(``var``_event));

`define __BIND_IRQ(REG, ADDR, EVENT) \
    if(``EVENT) \
        ``REG [``ADDR] <= 1'b1;

`endif