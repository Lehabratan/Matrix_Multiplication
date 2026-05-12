`timescale 1ns / 1ps

module matrix_crypto_top (

    input wire clk,
    input wire reset,

    input wire load,
    input wire [3:0] load_idx,
    input wire [15:0] A_in,
    input wire [15:0] B_in,
    input wire [15:0] X_in,

    output reg done
);

    localparam DEPTH = 16;

    localparam S_IDLE = 3'd0;
    localparam S_CALC = 3'd1;
    localparam S_XOR  = 3'd2;
    localparam S_DEC  = 3'd3;
    localparam S_DONE = 3'd4;

    reg [2:0] state;
    reg [3:0] idx;

    reg [15:0] A [0:15];
    reg [15:0] B [0:15];
    reg [15:0] X [0:15];

    reg [15:0] C [0:15];
    reg [15:0] D [0:15];
    reg [15:0] E [0:15];

    integer i;
    integer r;
    integer c;
    integer k;

    reg [31:0] prod;

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state <= S_IDLE;
            idx <= 0;
            done <= 0;

            for (i = 0; i < DEPTH; i = i + 1) begin
                A[i] <= 0;
                B[i] <= 0;
                X[i] <= 0;
                C[i] <= 0;
                D[i] <= 0;
                E[i] <= 0;
            end

        end
        else begin

            // =========================
            // LOAD FROM TESTBENCH
            // =========================
            if (load) begin

                A[load_idx] <= A_in;
                B[load_idx] <= B_in;
                X[load_idx] <= X_in;

                if (load_idx == 15) begin
                    state <= S_CALC;
                    idx <= 0;
                end
            end

            else begin

                case(state)

                    // =========================
                    // MATRIX MULTIPLICATION
                    // =========================
                    S_CALC: begin

                        r = idx / 4;
                        c = idx % 4;

                        prod = 0;

                        for (k = 0; k < 4; k = k + 1) begin
                            prod = prod +
                                (A[r*4 + k] * B[k*4 + c]);
                        end

                        // MOD 65536
                        C[idx] <= prod[15:0];

                        if (idx == DEPTH-1) begin
                            idx <= 0;
                            state <= S_XOR;
                        end
                        else begin
                            idx <= idx + 1;
                        end
                    end

                    // =========================
                    // XOR
                    // =========================
                    S_XOR: begin

                        D[idx] <= C[idx] ^ X[idx];

                        if (idx == DEPTH-1) begin
                            idx <= 0;
                            state <= S_DEC;
                        end
                        else begin
                            idx <= idx + 1;
                        end
                    end

                    // =========================
                    // DECRYPT
                    // =========================
                    S_DEC: begin

                        E[idx] <= D[idx] ^ X[idx];

                        if (idx == DEPTH-1) begin
                            state <= S_DONE;
                            done <= 1'b1;
                        end
                        else begin
                            idx <= idx + 1;
                        end
                    end

                    S_DONE: begin
                        done <= 1'b1;
                    end

                endcase
            end
        end
    end

endmodule