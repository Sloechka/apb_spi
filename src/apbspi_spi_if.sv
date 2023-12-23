interface apbspi_spi_if;

    logic miso, mosi, cs, sck;

    modport master (
        input miso,
        output mosi, cs, sck
    );

    modport slave (
        output mosi,
        input miso, cs, sck
    );
    
endinterface