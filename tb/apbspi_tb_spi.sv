class apbspi_tb_spi;
    virtual apbspi_spi_if vif;
    integer read_data;
    integer write_data;
    integer write_q[$];

    int i = 0;

    function new(virtual apbspi_spi_if vif);
        this.vif = vif;
        vif.miso = 0;
    endfunction

    task monitor();
        wait(~vif.cs);
        while(~vif.cs) begin
            read_data = 0;
            for(int i = 0; i < 32; i++) begin
                @(posedge vif.sck) read_data[i] = vif.mosi;
            end
            $display("(%6t) SPI SLAVE READ: %x", $realtime, read_data);
        end
    endtask

    task write(integer num);
        $display("SPI SLAVE: Generating... %d packets", num);
        repeat(num) begin
            write_data = $urandom();
            write_q.push_back(write_data);
            $display("SPI SLAVE [QUEUE] %x", write_data);
        end

        for(int n = 0; n < num; n++) begin
            write_data = write_q.pop_front();
                if(n > 0) @(negedge vif.sck);
                vif.miso = write_data[0];
            for(int i = 1; i < 32; i++) begin
                @(negedge vif.sck); vif.miso = write_data[i];
            end
        end
    endtask

endclass