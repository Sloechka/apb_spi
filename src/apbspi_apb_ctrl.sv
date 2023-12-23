`include "apbspi_defines.sv"

module apbspi_apb_ctrl 
#(
    parameter ADDR_WIDTH = 32
)
(
    apbspi_apb_if.slave apb_if,

    input spi_trx_done,
    input spi_busy,
    output logic spi_enable,
    output logic [31:0] spi_prescaler,
    output logic spi_cpha,
    output logic spi_cpol,
    
    input tx_fifo_empty,
    input rx_fifo_empty,
    input tx_fifo_full,
    input rx_fifo_full,
    input [31:0] rx_fifo_read_data,
    output logic [31:0] tx_fifo_write_data,
    output logic tx_fifo_push,
    output logic rx_fifo_pop,
    output logic tx_fifo_flush,
    output logic rx_fifo_flush,

    output logic irq
);

logic [31:0] irq_reg;

/* Address logic */

logic [ADDR_WIDTH-1:0] addr_truncated;
logic [`__REG_ADDR_WIDTH-1:0] addr_index;

assign addr_truncated = {{apb_if.paddr[ADDR_WIDTH-1:2]}, 2'b00};
assign addr_index = apb_if.paddr[`__REG_ADDR_WIDTH+2:2];

/* SPI control registers */

logic [31:0] spi_cr_reg;
logic [31:0] spi_irq_en;

assign spi_enable = spi_cr_reg[`REG_CR_SPIEN];
assign spi_cpha = spi_cr_reg[`REG_CR_CPHA];
assign spi_cpol = spi_cr_reg[`REG_CR_CPOL];

assign tx_fifo_flush = spi_cr_reg[`REG_CR_FLUSH_TX];
assign rx_fifo_flush = spi_cr_reg[`REG_CR_FLUSH_RX];

/* APB slave control */

always_ff @(posedge apb_if.pclk or negedge apb_if.presetn) begin
    if(!apb_if.presetn) begin
        // APB output signals
        apb_if.prdata <= 0;
        apb_if.pslverr <= 0;
        apb_if.pready <= 0;

        // FIFO output signals
        tx_fifo_push <= 0;
        rx_fifo_pop <= 0;

        // SPI control registers
        spi_cr_reg <= 0;
        spi_prescaler <= 0;
        spi_irq_en <= 0;
    end
    else begin
        apb_if.pslverr <= 0;
        apb_if.pready <= 0;

        tx_fifo_push <= 0;
        rx_fifo_pop <= 0;

        if(apb_if.psel & ~apb_if.penable) begin
            apb_if.pready <= 1;

            // APB master -> slave write
            if(apb_if.pwrite) begin
                case(addr_truncated)
                    `REG_DATA_TX: begin
                        if(~tx_fifo_full) begin
                            tx_fifo_push <= 1'b1;
                            tx_fifo_write_data <= apb_if.pwdata;
                        end
                    end
                    `REG_CR: begin
                        spi_cr_reg <= apb_if.pwdata;
                    end
                    `REG_PRESC: begin
                        spi_prescaler <= apb_if.pwdata;
                    end
                    `REG_IRQ_EN: begin
                        spi_irq_en <= apb_if.pwdata;
                    end
                    `REG_IRQ: begin 
                        // Logic is descibed elsewhere
                    end
                    default: begin
                        apb_if.pslverr <= 1'b1;
                    end
                endcase
            end
            // APB master <- slave read
            else begin
                apb_if.prdata <= 0;

                case(addr_truncated)
                    `REG_DATA_TX: begin
                        apb_if.prdata <= 0;
                    end
                    `REG_CR: begin
                        apb_if.prdata <= spi_cr_reg;
                    end
                    `REG_PRESC: begin
                        apb_if.prdata <= spi_prescaler;
                    end
                    `REG_IRQ_EN: begin
                        apb_if.prdata <= spi_irq_en;
                    end
                    `REG_SR: begin
                        apb_if.prdata[`REG_SR_BUSY]     <= spi_busy;
                        apb_if.prdata[`REG_SR_TX_EMPTY] <= tx_fifo_empty;
                        apb_if.prdata[`REG_SR_TX_FULL]  <= tx_fifo_full;
                        apb_if.prdata[`REG_SR_RX_EMPTY] <= rx_fifo_empty;
                        apb_if.prdata[`REG_SR_RX_FULL]  <= rx_fifo_full;
                    end
                    `REG_IRQ: begin
                        apb_if.prdata <= irq_reg;
                    end
                    `REG_DATA_RX: begin
                        if(~rx_fifo_empty) begin
                            rx_fifo_pop <= 1'b1;
                            apb_if.prdata <= rx_fifo_read_data;
                        end
                    end
                    default: begin
                        apb_if.pslverr <= 1'b1;
                    end
                endcase
            end
        end
    end    
end

/* IRQ logic */

`__CREATE_EVENT(tx_fifo_empty)
`__CREATE_EVENT(tx_fifo_full)
`__CREATE_EVENT(rx_fifo_empty)
`__CREATE_EVENT(rx_fifo_full)
`__CREATE_EVENT(spi_trx_done)

always_ff @(posedge apb_if.pclk or negedge apb_if.presetn) begin
    if(!apb_if.presetn) begin
        irq_reg <= 0;
    end
    else begin
        if(apb_if.psel & ~apb_if.penable & apb_if.pwrite & (addr_truncated == `REG_IRQ)) 
            irq_reg <= apb_if.pwdata;
        else begin
            `__BIND_IRQ(irq_reg, `REG_IRQ_TX_EMPTY, tx_fifo_empty_event)
            `__BIND_IRQ(irq_reg, `REG_IRQ_TX_FULL, tx_fifo_full_event)
            `__BIND_IRQ(irq_reg, `REG_IRQ_RX_EMPTY, rx_fifo_empty_event)
            `__BIND_IRQ(irq_reg, `REG_IRQ_RX_FULL, rx_fifo_full_event)
            `__BIND_IRQ(irq_reg, `REG_IRQ_TRX_DONE, spi_trx_done_event)
        end
    end
end

assign irq = |(irq_reg & spi_irq_en);

endmodule