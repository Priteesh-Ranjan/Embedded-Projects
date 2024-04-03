// Main FIR filter module
module filterfir(
    input clk,      // Clock input
    input rst,      // Reset input
    input [7:0] x,  // Input data
    output reg [9:0] dataout  // Output data
);

    // Internal wires for intermediate results
    wire [7:0] d1, d2, d3;
    wire [7:0] m1, m2, m3, m4, m5;
    wire [7:0] d11, d12, d13, d14;

    // Filter coefficients
    parameter h0 = 3'b101;
    parameter h1 = 3'b100;
    parameter h2 = 3'b011;
    parameter h3 = 3'b010;
    parameter h4 = 3'b001;

    // First stage of the filter
    assign m1 = x >> h0;  // Shift input data
    dff u2(clk, rst, x, d11);  // D flip-flop
    assign m2 = d11 >> h1;  // Shifted data from flip-flop

    // Second stage of the filter
    assign d1 = m1 + m2;  // Add results of the first two stages
    dff u4(clk, rst, d11, d12);  // D flip-flop
    assign m3 = d12 >> h2;  // Shifted data from flip-flop

    // Third stage of the filter
    assign d2 = d1 + m3;  // Add result from the third stage
    dff u6(clk, rst, d12, d13);  // D flip-flop
    assign m4 = d13 >> h3;  // Shifted data from flip-flop

    // Fourth stage of the filter
    assign d3 = d2 + m4;  // Add result from the fourth stage
    dff u8(clk, rst, d13, d14);  // D flip-flop
    assign m5 = d14 >> h4;  // Shifted data from flip-flop

    // Final output data
    always @* begin
        dataout = d3 + m5;  // Add result from the fifth stage
    end

endmodule

// D flip-flop submodule
module dff(
    input clk,     // Clock input
    input rst,     // Reset input
    input [7:0] d, // Data input
    output reg [7:0] q // Data output
);

    // Sequential logic to store data
    always @(posedge clk) begin
        if (rst == 1) begin
            q <= 8'h00;  // Reset condition
        end
        else begin
            q <= d;  // Store data
        end
    end

endmodule
