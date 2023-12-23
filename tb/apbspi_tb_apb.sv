class apbspi_tb_apb;
    virtual apbspi_apb_if vif;
    semaphore s;

    function new(virtual apbspi_apb_if vif);
        s = new(1);
        this.vif = vif;
        vif.psel = 0;
        vif.paddr = 0;
        vif.pwrite = 0;
        vif.penable = 0;
        vif.pwdata = 0;
        vif.presetn = 0;
    endfunction

    integer num_trans = 0;

    task read(input integer [31:0] addr, output integer data);
        s.get(1);
        
        $display("(%6t) APB (%3d): REQUEST READ FROM 0x%x", $realtime, num_trans, addr);
        data = 0;

        @(posedge vif.pclk);
            vif.psel = 1;
            vif.paddr = addr;
            vif.pwrite = 0;

        @(posedge vif.pclk);
            vif.penable = 1;

        @(posedge vif.pclk);
            vif.psel = 0;
            vif.penable = 0;
            data = vif.prdata;

        if(vif.pslverr)
            $fatal("(%6t) APB (%3d): SLAVE ERROR", $realtime, num_trans);
        else
            $display("(%6t) APB (%3d): SUCCESSFULLY READ DATA 0x%x", $realtime, num_trans, vif.prdata);

        num_trans = num_trans + 1;

        s.put(1);
    endtask

    task write(input [31:0] addr, input [31:0] data);
        s.get(1);
        
        $display("(%6t) APB (%3d): REQUEST WRITE 0x%x TO 0x%x", $realtime, num_trans, data, addr);

        @(posedge vif.pclk);
            vif.psel = 1;
            vif.paddr = addr;
            vif.pwdata = data;
            vif.pwrite = 1;

        @(posedge vif.pclk);
            vif.penable = 1;

        @(posedge vif.pclk);
            vif.psel = 0;
            vif.penable = 0;

        if(vif.pslverr)
            $fatal("(%6t) APB (%3d): SLAVE ERROR", $realtime, num_trans);
        else
            $display("(%6t) APB (%3d): DATA SUCCESSFULLY WRITTEN", $realtime, num_trans);

        num_trans = num_trans + 1;

        s.put(1);
    endtask

    task write_assert(input [31:0] addr, input [31:0] data);
        integer buff = data;
        integer rdata = 'x;
        this.write(addr, data);
        this.read(addr, rdata);

        if(buff != rdata)
            $fatal("(%6t) APB WRITE ASSERTION FAILED: expected %8x, got %8x", $realtime, buff, rdata);
    endtask

endclass