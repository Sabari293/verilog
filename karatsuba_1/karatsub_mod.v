module karat(
    input [15:0] X, Y,
    output [31:0] XY
);
    wire [7:0] XHL, YHL;
    wire cout_xhl, cout_yhl;
    wire [15:0] XLYL, XHYH, XYHL;
    wire [15:0] T1, T2;
    wire bout1, bout2;
    wire [31:0] P1, P2, P3, P12;
    wire cout_sum1, cout_sum2;

    nbit_adder #(8) xhl(.A(X[7:0]), .B(X[15:8]), .cin(1'b0), .Sum(XHL), .cout(cout_xhl));
    nbit_adder #(8) yhl(.A(Y[7:0]), .B(Y[15:8]), .cin(1'b0), .Sum(YHL), .cout(cout_yhl));

    karat_16 xlyl(X[7:0],  Y[7:0],  XLYL);
    karat_16 xhyh(X[15:8], Y[15:8], XHYH);
    karat_16 xyhl(XHL,     YHL,     XYHL);

    assign P3 = {XHYH, 16'b0};
    assign P2 = {16'b0, XLYL};

    nbit_subtractor #(16) t_sub(.A(XYHL), .B(XHYH), .Bin(1'b0), .Diff(T1), .Bout(bout1));
    nbit_subtractor #(16) p1_sub(.A(T1),   .B(XLYL), .Bin(1'b0), .Diff(T2), .Bout(bout2));
    assign P1 = {8'b0, T2, 8'b0};

    nbit_adder #(32) p_sum (.A(P3),  .B(P2), .cin(1'b0), .Sum(P12), .cout(cout_sum1));
    nbit_adder #(32) xy_sum(.A(P12), .B(P1), .cin(1'b0), .Sum(XY),  .cout(cout_sum2));

endmodule

module karat_16(
    input [7:0]X,Y,
    output [15:0]XY
);
    wire [15:0] P [0:7];

    assign P[0] = (Y[0] ? (X << 0) : 16'b0);
    assign P[1] = (Y[1] ? (X << 1) : 16'b0);
    assign P[2] = (Y[2] ? (X << 2) : 16'b0);
    assign P[3] = (Y[3] ? (X << 3) : 16'b0);
    assign P[4] = (Y[4] ? (X << 4) : 16'b0);
    assign P[5] = (Y[5] ? (X << 5) : 16'b0);
    assign P[6] = (Y[6] ? (X << 6) : 16'b0);
    assign P[7] = (Y[7] ? (X << 7) : 16'b0);

    wire [15:0]P01,P23,P45,P67;
    wire [15:0]P0123,P4567;

    adder16 P_01(.A(P[0]), .B(P[1]), .Cin(1'b0), .Sum(P01));
    adder16 P_23(.A(P[2]), .B(P[3]), .Cin(1'b0), .Sum(P23));
    adder16 P_45(.A(P[4]), .B(P[5]), .Cin(1'b0), .Sum(P45));
    adder16 P_67(.A(P[6]), .B(P[7]), .Cin(1'b0), .Sum(P67));

    adder16 P_1234(.A(P01), .B(P23), .Cin(1'b0), .Sum(P0123));
    adder16 P_4567(.A(P45), .B(P67), .Cin(1'b0), .Sum(P4567));

    adder16 Pf(.A(P0123), .B(P4567), .Cin(1'b0), .Sum(XY));


endmodule

module full_adder(
    input a,b,cin,
    output S,cout
);
    assign S=a^b^cin;
    assign cout=(a&b)|(b&cin)|(a&cin);
endmodule

module nbit_adder #(parameter N = 16)(
    input  [N-1:0] A, B,
    input  cin,
    output [N-1:0] Sum,
    output cout
);
    wire [N:0]c;
    assign c[0]=cin;
    
    genvar i;
    generate
        for(i=0;i<N;i=i+1)begin
            full_adder fa(A[i],B[i],c[i],Sum[i],c[i+1]);
        end
    endgenerate
    assign cout=c[N];
endmodule

module adder16 (
    input  [15:0] A, B,
    input  Cin,
    output [15:0] Sum
);
    wire Cout;
    nbit_adder #(16) a (A, B, Cin, Sum, Cout);
endmodule

module nbit_subtractor #(parameter N=16)(
    input [N-1:0] A, B,
    input Bin,
    output [N-1:0] Diff,
    output Bout
);
    wire [N:0] c;
    assign c[0] = Bin;

    genvar i;
    generate
        for(i=0;i<N;i=i+1) begin
            full_subtractor fs(.a(A[i]), .b(B[i]), .bin(c[i]), .diff(Diff[i]), .bout(c[i+1]));
        end
    endgenerate
    assign Bout = c[N];
endmodule

module full_subtractor(
    input a,b,bin,
    output diff,bout
);
    assign diff = a ^ b ^ bin;
    assign bout = (~a & b) | ((~a | b) & bin);
endmodule