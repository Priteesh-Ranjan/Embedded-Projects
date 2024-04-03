module FIR(
    input clk,                            // Clock input
    input reset,                          // Reset input
    input signed [15:0] s_axis_fir_tdata, // Input data from FIR stream
    input [3:0] s_axis_fir_tkeep,        // Keep signal from FIR stream
    input s_axis_fir_tlast,               // Last signal from FIR stream
    input s_axis_fir_tvalid,              // Valid signal from FIR stream
    input m_axis_fir_tready,              // Ready signal to FIR stream
    output reg m_axis_fir_tvalid,         // Valid signal to FIR stream
    output reg s_axis_fir_tready,         // Ready signal from FIR stream
    output reg m_axis_fir_tlast,          // Last signal to FIR stream
    output reg [3:0] m_axis_fir_tkeep,    // Keep signal to FIR stream
    output reg signed [31:0] m_axis_fir_tdata // Output data to FIR stream
);

    // Always block to set the keep signal to all ones
    always @ (posedge clk) begin
        m_axis_fir_tkeep <= 4'hf;
    end

    // Always block to handle the last signal
    always @ (posedge clk) begin
        if (s_axis_fir_tlast == 1'b1) begin
            m_axis_fir_tlast <= 1'b1;
        end else begin
            m_axis_fir_tlast <= 1'b0;
        end
    end
    
    // Define parameters and signals for FIR operation
    reg enable_fir, enable_buff;
    reg [3:0] buff_cnt;
    reg signed [15:0] in_sample; 
    reg signed [15:0] buff0, buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8, buff9, buff10, buff11, buff12, buff13, buff14; 
    wire signed [15:0] tap0, tap1, tap2, tap3, tap4, tap5, tap6, tap7, tap8, tap9, tap10, tap11, tap12, tap13, tap14; 
    reg signed [31:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11, acc12, acc13, acc14; 

    /* Taps for LPF running @ 1MSps with a cutoff freq of 400kHz*/
    // Define tap values
    assign tap0 = 16'hFC9C;  // twos(-0.0265 * 32768) = 0xFC9C
    assign tap1 = 16'h0000;  // 0
    assign tap2 = 16'h05A5;  // 0.0441 * 32768 = 1445.0688 = 1445 = 0x05A5
    assign tap3 = 16'h0000;  // 0
    assign tap4 = 16'hF40C;  // twos(-0.0934 * 32768) = 0xF40C
    assign tap5 = 16'h0000;  // 0
    assign tap6 = 16'h282D;  // 0.3139 * 32768 = 10285.8752 = 10285 = 0x282D
    assign tap7 = 16'h4000;  // 0.5000 * 32768 = 16384 = 0x4000
    assign tap8 = 16'h282D;  // 0.3139 * 32768 = 10285.8752 = 10285 = 0x282D
    assign tap9 = 16'h0000;  // 0
    assign tap10 = 16'hF40C; // twos(-0.0934 * 32768) = 0xF40C
    assign tap11 = 16'h0000; // 0
    assign tap12 = 16'h05A5; // 0.0441 * 32768 = 1445.0688 = 1445 = 0x05A5
    assign tap13 = 16'h0000; // 0
    assign tap14 = 16'hFC9C; // twos(-0.0265 * 32768) = 0xFC9C
    
    /* This loop sets the tvalid flag on the output of the FIR high once 
     * the circular buffer has been filled with input samples for the 
     * first time after a reset condition. */
    always @ (posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            buff_cnt <= 4'd0;
            enable_fir <= 1'b0;
            in_sample <= 8'd0;
        end else if (m_axis_fir_tready == 1'b0 || s_axis_fir_tvalid == 1'b0) begin
            enable_fir <= 1'b0;
            buff_cnt <= 4'd15;
            in_sample <= in_sample;
        end else if (buff_cnt == 4'd15) begin
            buff_cnt <= 4'd0;
            enable_fir <= 1'b1;
            in_sample <= s_axis_fir_tdata;
        end else begin
            buff_cnt <= buff_cnt + 1;
            in_sample <= s_axis_fir_tdata;
        end
    end   

    // Update ready and valid signals
    always @ (posedge clk) begin
        if(reset == 1'b0 || m_axis_fir_tready == 1'b0 || s_axis_fir_tvalid == 1'b0) begin
            s_axis_fir_tready <= 1'b0;
            m_axis_fir_tvalid <= 1'b0;
            enable_buff <= 1'b0;
        end else begin
