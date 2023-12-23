`include "apbspi_defines.sv"

interface apbspi_apb_if #(
    parameter ADDR_WIDTH = 32
);
    logic pclk;
    logic presetn;
    logic [ADDR_WIDTH-1:0] paddr;
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
    logic pslverr;

    modport master (
        input prdata, pready, pslverr,
        output pclk, presetn, paddr, psel, penable, pwrite, pwdata
    );

    modport slave (
        input pclk, presetn, paddr, psel, penable, pwrite, pwdata,
        output prdata, pready, pslverr
    );

endinterface