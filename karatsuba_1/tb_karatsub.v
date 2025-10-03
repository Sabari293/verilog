`timescale 1ns/1ps

module tb_karat;

    reg  [15:0] X, Y;
    wire [31:0] XY;

    karat uut (
        .X(X),
        .Y(Y),
        .XY(XY)
    );

    reg [31:0] expected;

    initial begin
        $display("Time\tX\tY\tXY (output)\tExpected");

        X = 16'd3; Y = 16'd5;
        expected = X * Y;
        #10 $display("%0dns\t%0d\t%0d\t%0d\t\t%0d", $time, X, Y, XY, expected);

        X = 16'd15; Y = 16'd7;
        expected = X * Y;
        #10 $display("%0dns\t%0d\t%0d\t%0d\t\t%0d", $time, X, Y, XY, expected);

        X = 16'd255; Y = 16'd255;
        expected = X * Y;
        #10 $display("%0dns\t%0d\t%0d\t%0d\t\t%0d", $time, X, Y, XY, expected);

        X = 16'd1234; Y = 16'd5678;
        expected = X * Y;
        #10 $display("%0dns\t%0d\t%0d\t%0d\t\t%0d", $time, X, Y, XY, expected);

        $finish;
    end

endmodule
