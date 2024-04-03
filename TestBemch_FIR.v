module tb_filterfir;

  // Inputs
  reg clk;
  reg rst;
  reg [7:0] x;

  // Outputs
  wire [9:0] dataout;

  // Instantiate the Unit Under Test (UUT)
  filterfir uut (
    .clk(clk),
    .rst(rst),
    .x(x),
    .dataout(dataout)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Testbench stimulus
  initial begin
    // Initialize Inputs
    clk = 0;
    rst = 0;
    x = 0;
    #100;

    // Apply reset
    rst = 1;
    #100;

    // Release reset
    rst = 0;
    #100;

    // Apply test data
    x = 8'd5;
    #100;
    x = 8'd10;
    #100;
    x = 8'd12;
    #100;
    x = 8'd15;
    #100;
    x = 8'd16;
    #100;

    // End simulation
    $finish;
  end

endmodule

