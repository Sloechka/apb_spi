`include "apbspi_tb_clk_gen.sv"
`include "apbspi_tb_apb.sv"
`include "apbspi_tb_spi.sv"
`include "apbspi_defines.sv"

`define CLK_PERIOD 100
`define APB_ADDR_WIDTH 32
`define APB_PRESC_VALUE 32'd1
`define WRITE_PACKETS_NUM 20
`define READ_PACKETS_NUM 8

module apbspi_tb_top;

// Instantiate APB slave & interfaces
logic irq;

apbspi_apb_if #(.ADDR_WIDTH(`APB_ADDR_WIDTH)) apb_if();
apbspi_spi_if spi_if();
apbspi_top #(.APB_ADDR_WIDTH(`APB_ADDR_WIDTH)) dut(.apb_if(apb_if.slave), .spi_if(spi_if), .irq(irq));

// Clock generation
apbspi_tb_clk_gen clk_gen(.clk(apb_if.pclk));
initial clk_gen.do_clk(`CLK_PERIOD);

// APB master
apbspi_tb_apb apb_master = new(apb_if);

// SPI slave
apbspi_tb_spi spi_slave = new(spi_if);

// Global read_data variable for APB read operations
integer rdata = 0, wdata = 0;

integer write_q[$];
bit tx_blocked = 0;
bit tx_resumed = 0;

initial begin
    #(`CLK_PERIOD * 5) apb_if.presetn = 1;

    #(`CLK_PERIOD * 10);
    
    // Set prescaler
    $display("[TOP] Setting prescaler value to %d", `APB_PRESC_VALUE);
    apb_master.write_assert(`REG_PRESC, 32'd1);

    // Enable SPI
    $display("[TOP] Enabling SPI...");
    apb_master.write_assert(`REG_CR, (1'b1 << `REG_CR_SPIEN));

    // Enable trx_done & tx_full irq
    $display("[TOP] Enabling IRQs TRX_DONE & TX_FIFO_FULL...");
    apb_master.write_assert(`REG_IRQ_EN, (1'b1 << `REG_IRQ_EN_TRX_DONE) | (1'b1 << `REG_IRQ_EN_TX_FULL));

    // Generate data
    $display("[TOP] Generating %3d portions of data...", `WRITE_PACKETS_NUM);
    
    repeat(`WRITE_PACKETS_NUM) begin
        wdata = $urandom();
        write_q.push_back(wdata);
        $display("[TOP][QUEUE] %x", wdata);
    end

    // Write data
    $display("[TOP] Sending %3d packets...", `WRITE_PACKETS_NUM);
    
    fork
        begin
            spi_slave.monitor();
        end
        begin
            while(write_q.size()) begin
                wait(tx_blocked == 0) begin
                    if(!tx_resumed) wdata = write_q.pop_front();
                    else tx_resumed = 0;
                    apb_master.write(`REG_DATA_TX, wdata);
                end
            end
            // Wait for SPI ctrl to finish
            wait(irq);
            $display("[TOP] Caught IRQ");
            apb_master.read(`REG_IRQ, rdata);

            if((rdata >> `REG_IRQ_TRX_DONE) & 1'b1) begin
                $display("[TOP] Got TRX_DONE IRQ");
                $display("[TOP] Reset IRQ");
                apb_master.write(`REG_IRQ, 32'd0);
            end
        end
        begin
            forever begin
                wait(irq) tx_blocked = 1;
                $display("[TOP] Caught IRQ, blocking transactions");
                apb_master.read(`REG_IRQ, rdata);

                if((rdata >> `REG_IRQ_TRX_DONE) & 1'b1) begin
                    $display("[TOP] Got TRX_DONE IRQ");
                    $display("[TOP] Reset IRQ");
                    apb_master.write(`REG_IRQ, 32'd0);
                    $display("[TOP] Resuming transactions");
                    tx_blocked = 0;
                end
                if((rdata >> `REG_IRQ_EN_TX_FULL) & 1'b1) begin
                    $display("[TOP] Got TX_FIFO_FULL IRQ");
                    $display("[TOP] Reset IRQ");
                    apb_master.write(`REG_IRQ, 32'd0);
                    tx_resumed = 1;
                end
            end
        end
    join_any

    disable fork;

    #(`CLK_PERIOD * 500);

    // Disable SPI
    $display("[TOP] Disabling SPI...");
    apb_master.write_assert(`REG_CR, 32'd0);

    // Flush FIFO
    $display("[TOP] Flusing RX FIFO...");
    apb_master.write_assert(`REG_CR, (1'b1 << `REG_CR_FLUSH_RX));

    // Enable IRQ TRX_DONE only
    $display("[TOP] Enabling IRQ TRX_DONE...");
    apb_master.write_assert(`REG_IRQ_EN, (1'b1 << `REG_IRQ_EN_TRX_DONE)); 

    #(`CLK_PERIOD * 500);

    // Enable SPI
    $display("[TOP] Enabling SPI...");
    apb_master.write_assert(`REG_CR, (1'b1 << `REG_CR_SPIEN));

    // Force SPI slave to write 
    // Fix for read_packets_num > fifo_size, too lazy rn
    fork 
        begin
            spi_slave.write(`READ_PACKETS_NUM);
        end
        begin
            repeat(`READ_PACKETS_NUM) apb_master.write(`REG_DATA_TX, 32'd0); // Necessary
        end
    join_any

    wait(irq);
    $display("[TOP] Caught IRQ");
    apb_master.read(`REG_IRQ, rdata);

    if((rdata >> `REG_IRQ_TRX_DONE) & 1'b1) begin
        $display("[TOP] Got TRX_DONE IRQ");
        $display("[TOP] Reset IRQ");
        apb_master.write(`REG_IRQ, 32'd0);
    end

    repeat(`READ_PACKETS_NUM) begin
        apb_master.read(`REG_DATA_RX, rdata);
    end

    $finish();
end


endmodule
