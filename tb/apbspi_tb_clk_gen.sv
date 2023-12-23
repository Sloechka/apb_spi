module apbspi_tb_clk_gen(output logic clk);

process clk_task;

task automatic do_clk();
    input integer period;
    begin
        if(clk_task != null)
            clk_task.kill();
        
        if(period <= 0) 
            $error("Non-positive clock period value.");

        clk_gen(period);
    end
endtask

task automatic clk_gen();
    input integer period;
    begin
        $display("Running clock with period = %d", period);
        
        clk = 0;
        fork
            forever #period clk = ~clk;
        join_none
        
        clk_task = process::self();
    end
endtask

endmodule
