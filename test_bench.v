`timescale 1ns/1ps

module tb_matrix_multiplication;

    reg clk;
    reg reset;

    reg load;

    reg [3:0] load_idx;

    reg [15:0] A_in;
    reg [15:0] B_in;
    reg [15:0] X_in;

    wire done;

    integer i;

    matrix_crypto_top uut (

        .clk(clk),
        .reset(reset),

        .load(load),
        .load_idx(load_idx),

        .A_in(A_in),
        .B_in(B_in),
        .X_in(X_in),

        .done(done)
    );

    // CLOCK
    initial clk = 0;
    always #5 clk = ~clk;

    // MATRICES
    reg [15:0] A [0:15];
    reg [15:0] B [0:15];
    reg [15:0] X [0:15];

    initial begin

        // MATRIX A
        A[0]=256; A[1]=100; A[2]=124; A[3]=222;
        A[4]=111; A[5]=245; A[6]=195; A[7]=244;
        A[8]=111; A[9]=222; A[10]=233; A[11]=112;
        A[12]=154; A[13]=100; A[14]=101; A[15]=203;

        // MATRIX B
        B[0]=100; B[1]=101; B[2]=242; B[3]=254;
        B[4]=150; B[5]=220; B[6]=160; B[7]=120;
        B[8]=212; B[9]=131; B[10]=111; B[11]=222;
        B[12]=145; B[13]=121; B[14]=256; B[15]=123;

        // XOR MATRIX
        for (i = 0; i < 16; i = i + 1)
            X[i] = i + 1;

    end

    initial begin

        reset = 1;
        load = 0;

        A_in = 0;
        B_in = 0;
        X_in = 0;

        load_idx = 0;

        #20;
        reset = 0;

        // =========================
        // LOAD MATRICES
        // =========================
        for (i = 0; i < 16; i = i + 1) begin

            @(posedge clk);

            load = 1;

            load_idx = i;

            A_in = A[i];
            B_in = B[i];
            X_in = X[i];
        end

        @(posedge clk);
        load = 0;

        // WAIT FINISH
        wait(done);

        #20;

        $display("=========== RESULT MATRIX C ===========");

        for (i = 0; i < 16; i = i + 1)
            $display("C[%0d] = %0d", i, uut.C[i]);

        $display("=========== XOR MATRIX D ===========");

        for (i = 0; i < 16; i = i + 1)
            $display("D[%0d] = %0d", i, uut.D[i]);

        $display("=========== DECRYPTED MATRIX E ===========");

        for (i = 0; i < 16; i = i + 1)
            $display("E[%0d] = %0d", i, uut.E[i]);

        $finish;
    end

endmodule