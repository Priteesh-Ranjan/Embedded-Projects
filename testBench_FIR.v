module tb_FIR;

    // Inputs
    reg clk, reset, s_axis_fir_tvalid, m_axis_fir_tready;
    reg signed [15:0] s_axis_fir_tdata;
    
    // Outputs
    wire m_axis_fir_tvalid;
    wire [3:0] m_axis_fir_tkeep;
    wire [31:0] m_axis_fir_tdata;
    
    /*
     * 100Mhz (10ns) clock 
     */
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end
    
    // Generate reset
    always begin
        reset = 1; #20;
        reset = 0; #50;
        reset = 1; #1000000;
    end
    
    // Generate s_axis_fir_tvalid signal
    always begin
        s_axis_fir_tvalid = 0; #100;
        s_axis_fir_tvalid = 1; #1000;
        s_axis_fir_tvalid = 0; #50;
        s_axis_fir_tvalid = 1; #998920;
    end
    
    // Generate m_axis_fir_tready signal
    always begin
        m_axis_fir_tready = 1; #1500;
        m_axis_fir_tready = 0; #100;
        m_axis_fir_tready = 1; #998400;
    end
    
    /* Instantiate FIR module to test. */
    FIR FIR_i(
        .clk(clk),
        .reset(reset),
        .s_axis_fir_tdata(s_axis_fir_tdata),   
        .s_axis_fir_tkeep(s_axis_fir_tkeep),   
        .s_axis_fir_tlast(s_axis_fir_tlast),   
        .s_axis_fir_tvalid(s_axis_fir_tvalid), 
        .m_axis_fir_tready(m_axis_fir_tready),
        .m_axis_fir_tvalid(m_axis_fir_tvalid), 
        .s_axis_fir_tready(s_axis_fir_tready), 
        .m_axis_fir_tlast(m_axis_fir_tlast),   
        .m_axis_fir_tkeep(m_axis_fir_tkeep),   
        .m_axis_fir_tdata(m_axis_fir_tdata));  
        
    // State and counter variables
    reg [4:0] state_reg;
    reg [3:0] cntr;
    
    parameter wvfm_period = 4'd4;
    
    parameter init               = 5'd0;
    parameter sendSample0        = 5'd1;
    parameter sendSample1        = 5'd2;
    parameter sendSample2        = 5'd3;
    parameter sendSample3        = 5'd4;
    parameter sendSample4        = 5'd5;
    parameter sendSample5        = 5'd6;
    parameter sendSample6        = 5'd7;
    parameter sendSample7        = 5'd8;
    
    /* This state machine generates a 200kHz sinusoid. */
    always @ (posedge clk or posedge reset) begin
        if (reset == 1'b0) begin
            cntr <= 4'd0;
            s_axis_fir_tdata <= 16'd0;
            state_reg <= init;
        end else begin
            case (state_reg)
                init : //0
                    begin
                        cntr <= 4'd0;
                        s_axis_fir_tdata <= 16'h0000;
                        state_reg <= sendSample0;
                    end
