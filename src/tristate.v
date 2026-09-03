module tristate(
    input drive,
    input transmit,
    output receive,
    inout pin 
);

    assign pin = drive ? transmit : 1'bz;
    assign receive = pin;

endmodule