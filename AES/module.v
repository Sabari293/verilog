module Encrypt(
    input [63:0]  plaintext  ,
    input [63:0]  secretKey  ,
    output [63:0] ciphertext 
);
    wire [63:0] L [0:10];
    wire [63:0] N [0:10];
    AddRoundKey A1(plaintext,secretKey,L[0]);
    assign N[0]=secretKey;
    genvar i;
    generate
        for(i=1;i<11;i=i+1)begin
            NextKey Nx(N[i-1],N[i]);
            Round Ro(L[i-1],N[i],L[i]);
        end
    endgenerate
    assign ciphertext=L[10];
endmodule

module Round(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
    wire [63:0] out1,out2,out3;
    genvar j;
    generate
        for(j=3;j<64;j=j+4) begin
            SBox S((currentState[j:j-3]),(out1[j:j-3]));
        end
    endgenerate
    ShiftRows SR(out1,out2);
    assign out3=out2;
    AddRoundKey AR(out3,roundKey,nextState);

endmodule

module SBox(
    input [3:0]in ,
    output [3:0]out
);
    assign out[3]=(in[0] & ~in[1] & ~in[2] & ~in[3])|(~in[0] & ~in[1] & in[2] & ~in[3])|(in[0] & ~in[1] & in[2] & in[3])|(~in[0] & ~in[1] & ~in[2] & in[3])|(in[0] & in[1] & in[2] & ~in[3])|(~in[0] & in[2] & ~in[3])|(in[0] & in[1] & in[3]);
    assign out[2]=(~in[0] & ~in[1] & ~in[2] & ~in[3])|(in[0] & ~in[1] & in[2] & in[3])|(in[0] & in[1] & ~in[2] & ~in[3])|(~in[0] & in[1] & in[2] & ~in[3])|(~in[0] & ~in[1] & in[2] )|(in[1] & ~in[2] & in[3]);
    assign out[1]=(~in[0] & in[1] & in[2] & ~in[3])|(~in[0] & in[1]  & ~in[2] & in[3])|(in[0] & ~in[1])|(~in[0] & ~in[1] & ~in[2] );
    assign out[0]=(~in[0] & ~in[1] & in[2] )|(in[0] & ~in[1] & ~in[3])|(in[1] & in[2] & in[3])|(~in[0] & in[1] & in[2] & ~in[3])|(~in[0] & in[1] & ~in[2] & in[3]);
endmodule

module NextKey(
    input  [63:0] currentKey,
    output [63:0] nextKey
);
    assign nextKey[63:4]=currentKey[59:0];
    assign nextKey[3:0]=currentKey[63:60];
endmodule

module ShiftRows(
    input  [63:0] currentState ,
    output [63:0] nextState    
);
    assign nextState[15:0]=currentState[15:0];
    assign nextState[27:16]=currentState[31:20];
    assign nextState[31:28]=currentState[19:16];
    assign nextState[39:32]=currentState[47:40];
    assign nextState[47:40]=currentState[39:32];
    assign nextState[51:48]=currentState[63:60];
    assign nextState[63:52]=currentState[59:48];
endmodule

module AddRoundKey(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
    assign nextState=roundKey ^ currentState;
endmodule
