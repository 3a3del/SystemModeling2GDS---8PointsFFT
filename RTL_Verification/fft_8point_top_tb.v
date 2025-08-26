`timescale 1ns / 1ps

//==============================================================================
// Enhanced FFT Debug Testbench with Stage-by-Stage Output Printing - FIXED
// 
// Fixed the Q-format display issue for stage 2 outputs
//==============================================================================

module tb_fft_8point_simple_debug();

    // Parameters
    parameter WIDTH = 16;
    parameter Q_STAGE1 = 12;
    parameter Q_STAGE2 = 12;        // Added: Q format for stage 2 outputs (usually same as stage 1)
    parameter Q_STAGE2_OUT = 11;    // This is for the module parameter
    parameter Q_STAGE3 = 11;        // Q format for final outputs (might need adjustment)
    parameter Q_FINAL_ACTUAL = 11;  // Added: Actual Q format of final outputs
    parameter CLK_PERIOD = 10.0;

    // Clock and reset
    reg clk;
    reg rst_n;
    reg start;

    // Test control
    integer test_num;
    integer error_count;
    integer pass_count;
    integer timeout_count;
    integer cycle_count;

    //--------------------------------------------------------------------------
    // DUT Interface
    //--------------------------------------------------------------------------
    
    // Input signals (Q12 format)
    reg signed [WIDTH-1:0] x_in_0_real, x_in_0_imag;
    reg signed [WIDTH-1:0] x_in_1_real, x_in_1_imag;
    reg signed [WIDTH-1:0] x_in_2_real, x_in_2_imag;
    reg signed [WIDTH-1:0] x_in_3_real, x_in_3_imag;
    reg signed [WIDTH-1:0] x_in_4_real, x_in_4_imag;
    reg signed [WIDTH-1:0] x_in_5_real, x_in_5_imag;
    reg signed [WIDTH-1:0] x_in_6_real, x_in_6_imag;
    reg signed [WIDTH-1:0] x_in_7_real, x_in_7_imag;

    // Output signals (Q11 format)
    wire signed [WIDTH-1:0] x_out_0_real, x_out_0_imag;
    wire signed [WIDTH-1:0] x_out_1_real, x_out_1_imag;
    wire signed [WIDTH-1:0] x_out_2_real, x_out_2_imag;
    wire signed [WIDTH-1:0] x_out_3_real, x_out_3_imag;
    wire signed [WIDTH-1:0] x_out_4_real, x_out_4_imag;
    wire signed [WIDTH-1:0] x_out_5_real, x_out_5_imag;
    wire signed [WIDTH-1:0] x_out_6_real, x_out_6_imag;
    wire signed [WIDTH-1:0] x_out_7_real, x_out_7_imag;

    wire valid_out;
    wire done;

    // Stage intermediate outputs - will be connected to internal signals
    wire signed [WIDTH-1:0] stage1_out_0_real, stage1_out_0_imag;
    wire signed [WIDTH-1:0] stage1_out_1_real, stage1_out_1_imag;
    wire signed [WIDTH-1:0] stage1_out_2_real, stage1_out_2_imag;
    wire signed [WIDTH-1:0] stage1_out_3_real, stage1_out_3_imag;
    wire signed [WIDTH-1:0] stage1_out_4_real, stage1_out_4_imag;
    wire signed [WIDTH-1:0] stage1_out_5_real, stage1_out_5_imag;
    wire signed [WIDTH-1:0] stage1_out_6_real, stage1_out_6_imag;
    wire signed [WIDTH-1:0] stage1_out_7_real, stage1_out_7_imag;

    wire signed [WIDTH-1:0] stage2_out_0_real, stage2_out_0_imag;
    wire signed [WIDTH-1:0] stage2_out_1_real, stage2_out_1_imag;
    wire signed [WIDTH-1:0] stage2_out_2_real, stage2_out_2_imag;
    wire signed [WIDTH-1:0] stage2_out_3_real, stage2_out_3_imag;
    wire signed [WIDTH-1:0] stage2_out_4_real, stage2_out_4_imag;
    wire signed [WIDTH-1:0] stage2_out_5_real, stage2_out_5_imag;
    wire signed [WIDTH-1:0] stage2_out_6_real, stage2_out_6_imag;
    wire signed [WIDTH-1:0] stage2_out_7_real, stage2_out_7_imag;

    // Stage done signals
    wire stage1_done, stage2_done;

    //--------------------------------------------------------------------------
    // DUT Instantiation
    //--------------------------------------------------------------------------
    fft_8point_top #(
        .WIDTH(WIDTH),
        .Q_inputs(Q_STAGE1),
        .Q_outputs(Q_STAGE2_OUT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        
        .x_in_0_real(x_in_0_real), .x_in_0_imag(x_in_0_imag),
        .x_in_1_real(x_in_1_real), .x_in_1_imag(x_in_1_imag),
        .x_in_2_real(x_in_2_real), .x_in_2_imag(x_in_2_imag),
        .x_in_3_real(x_in_3_real), .x_in_3_imag(x_in_3_imag),
        .x_in_4_real(x_in_4_real), .x_in_4_imag(x_in_4_imag),
        .x_in_5_real(x_in_5_real), .x_in_5_imag(x_in_5_imag),
        .x_in_6_real(x_in_6_real), .x_in_6_imag(x_in_6_imag),
        .x_in_7_real(x_in_7_real), .x_in_7_imag(x_in_7_imag),
        
        .x_out_0_real(x_out_0_real), .x_out_0_imag(x_out_0_imag),
        .x_out_1_real(x_out_1_real), .x_out_1_imag(x_out_1_imag),
        .x_out_2_real(x_out_2_real), .x_out_2_imag(x_out_2_imag),
        .x_out_3_real(x_out_3_real), .x_out_3_imag(x_out_3_imag),
        .x_out_4_real(x_out_4_real), .x_out_4_imag(x_out_4_imag),
        .x_out_5_real(x_out_5_real), .x_out_5_imag(x_out_5_imag),
        .x_out_6_real(x_out_6_real), .x_out_6_imag(x_out_6_imag),
        .x_out_7_real(x_out_7_real), .x_out_7_imag(x_out_7_imag),
        
        .valid_out(valid_out),
        .done(done)
    );

    //--------------------------------------------------------------------------
    // Stage Output Connections
    // CUSTOMIZE THESE BASED ON YOUR FFT MODULE INSTANCE NAMES
    //--------------------------------------------------------------------------
    
    // Pattern 1: If your instances are named stage1, stage2
    assign stage1_out_0_real = dut.stage1.x_out_0_real;
    assign stage1_out_0_imag = dut.stage1.x_out_0_imag;
    assign stage1_out_1_real = dut.stage1.x_out_1_real;
    assign stage1_out_1_imag = dut.stage1.x_out_1_imag;
    assign stage1_out_2_real = dut.stage1.x_out_2_real;
    assign stage1_out_2_imag = dut.stage1.x_out_2_imag;
    assign stage1_out_3_real = dut.stage1.x_out_3_real;
    assign stage1_out_3_imag = dut.stage1.x_out_3_imag;
    assign stage1_out_4_real = dut.stage1.x_out_4_real;
    assign stage1_out_4_imag = dut.stage1.x_out_4_imag;
    assign stage1_out_5_real = dut.stage1.x_out_5_real;
    assign stage1_out_5_imag = dut.stage1.x_out_5_imag;
    assign stage1_out_6_real = dut.stage1.x_out_6_real;
    assign stage1_out_6_imag = dut.stage1.x_out_6_imag;
    assign stage1_out_7_real = dut.stage1.x_out_7_real;
    assign stage1_out_7_imag = dut.stage1.x_out_7_imag;
    
    assign stage2_out_0_real = dut.stage2.x_out_0_real;
    assign stage2_out_0_imag = dut.stage2.x_out_0_imag;
    assign stage2_out_1_real = dut.stage2.x_out_1_real;
    assign stage2_out_1_imag = dut.stage2.x_out_1_imag;
    assign stage2_out_2_real = dut.stage2.x_out_2_real;
    assign stage2_out_2_imag = dut.stage2.x_out_2_imag;
    assign stage2_out_3_real = dut.stage2.x_out_3_real;
    assign stage2_out_3_imag = dut.stage2.x_out_3_imag;
    assign stage2_out_4_real = dut.stage2.x_out_4_real;
    assign stage2_out_4_imag = dut.stage2.x_out_4_imag;
    assign stage2_out_5_real = dut.stage2.x_out_5_real;
    assign stage2_out_5_imag = dut.stage2.x_out_5_imag;
    assign stage2_out_6_real = dut.stage2.x_out_6_real;
    assign stage2_out_6_imag = dut.stage2.x_out_6_imag;
    assign stage2_out_7_real = dut.stage2.x_out_7_real;
    assign stage2_out_7_imag = dut.stage2.x_out_7_imag;

    //--------------------------------------------------------------------------
    // Clock Generation
    //--------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //--------------------------------------------------------------------------
    // Cycle Counter for Timing Analysis
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            cycle_count <= 0;
        end else if (start) begin
            cycle_count <= 1;
        end else if (cycle_count > 0 && !done) begin
            cycle_count <= cycle_count + 1;
        end
    end

    //--------------------------------------------------------------------------
    // Signal Monitoring for Basic Debug
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (start) begin
            $display("  [DEBUG] FFT computation started at cycle %0d, time %0t", cycle_count, $time);
        end
        
        if (valid_out && !done) begin
            $display("  [DEBUG] Valid output asserted at cycle %0d, time %0t", cycle_count, $time);
        end
        
        if (done) begin
            $display("  [DEBUG] FFT computation completed at cycle %0d, time %0t", cycle_count, $time);
            $display("  [DEBUG] Total computation cycles: %0d", cycle_count);
        end
    end

    //--------------------------------------------------------------------------
    // Display Tasks
    //--------------------------------------------------------------------------
    
    task display_test_header;
        input [200*8-1:0] test_name;
        input [300*8-1:0] description;
        begin
            $display("\n================================================================================");
            $display("TEST: %s", test_name);
            $display("DESC: %s", description);
            $display("================================================================================");
        end
    endtask

    task display_complex_number;
        input signed [WIDTH-1:0] real_part;
        input signed [WIDTH-1:0] imag_part;
        input integer q_format;
        input [50*8-1:0] label;
        real real_val, imag_val, magnitude;
        begin
            real_val = $itor(real_part) / (2.0 ** q_format);
            imag_val = $itor(imag_part) / (2.0 ** q_format);
            magnitude = $sqrt(real_val*real_val + imag_val*imag_val);
            
            if (imag_val >= 0.0)
                $display("  %s = %8.4f + j%8.4f |%8.4f| (0x%04x, 0x%04x)", 
                        label, real_val, imag_val, magnitude, real_part, imag_part);
            else
                $display("  %s = %8.4f - j%8.4f |%8.4f| (0x%04x, 0x%04x)", 
                        label, real_val, -imag_val, magnitude, real_part, imag_part);
        end
    endtask

    task display_inputs;
        begin
            $display("\n--- INPUTS (Q%0d format) ---", Q_STAGE1);
            display_complex_number(x_in_0_real, x_in_0_imag, Q_STAGE1, "x[0]");
            display_complex_number(x_in_1_real, x_in_1_imag, Q_STAGE1, "x[1]");
            display_complex_number(x_in_2_real, x_in_2_imag, Q_STAGE1, "x[2]");
            display_complex_number(x_in_3_real, x_in_3_imag, Q_STAGE1, "x[3]");
            display_complex_number(x_in_4_real, x_in_4_imag, Q_STAGE1, "x[4]");
            display_complex_number(x_in_5_real, x_in_5_imag, Q_STAGE1, "x[5]");
            display_complex_number(x_in_6_real, x_in_6_imag, Q_STAGE1, "x[6]");
            display_complex_number(x_in_7_real, x_in_7_imag, Q_STAGE1, "x[7]");
        end
    endtask

    task display_stage1_outputs;
        begin
            $display("\n--- STAGE 1 OUTPUTS (Q%0d format) ---", Q_STAGE1);
            display_complex_number(stage1_out_0_real, stage1_out_0_imag, Q_STAGE1, "S1[0]");
            display_complex_number(stage1_out_1_real, stage1_out_1_imag, Q_STAGE1, "S1[1]");
            display_complex_number(stage1_out_2_real, stage1_out_2_imag, Q_STAGE1, "S1[2]");
            display_complex_number(stage1_out_3_real, stage1_out_3_imag, Q_STAGE1, "S1[3]");
            display_complex_number(stage1_out_4_real, stage1_out_4_imag, Q_STAGE1, "S1[4]");
            display_complex_number(stage1_out_5_real, stage1_out_5_imag, Q_STAGE1, "S1[5]");
            display_complex_number(stage1_out_6_real, stage1_out_6_imag, Q_STAGE1, "S1[6]");
            display_complex_number(stage1_out_7_real, stage1_out_7_imag, Q_STAGE1, "S1[7]");
        end
    endtask

    task display_stage2_outputs;
        begin
            $display("\n--- STAGE 2 OUTPUTS (Q%0d format) ---", Q_STAGE2);
            display_complex_number(stage2_out_0_real, stage2_out_0_imag, Q_STAGE3, "S2[0]");
            display_complex_number(stage2_out_1_real, stage2_out_1_imag, Q_STAGE3, "S2[1]");
            display_complex_number(stage2_out_2_real, stage2_out_2_imag, Q_STAGE3, "S2[2]");
            display_complex_number(stage2_out_3_real, stage2_out_3_imag, Q_STAGE3, "S2[3]");
            display_complex_number(stage2_out_4_real, stage2_out_4_imag, Q_STAGE3, "S2[4]");
            display_complex_number(stage2_out_5_real, stage2_out_5_imag, Q_STAGE3, "S2[5]");
            display_complex_number(stage2_out_6_real, stage2_out_6_imag, Q_STAGE3, "S2[6]");
            display_complex_number(stage2_out_7_real, stage2_out_7_imag, Q_STAGE3, "S2[7]");
        end
    endtask

    task display_final_outputs;
        real total_power;
        begin
            $display("\n--- STAGE 3 OUTPUTS (Final FFT) (Q%0d format) ---", Q_FINAL_ACTUAL);
            display_complex_number(x_out_0_real, x_out_0_imag, Q_STAGE3, "X[0]");
            display_complex_number(x_out_1_real, x_out_1_imag, Q_STAGE3, "X[1]");
            display_complex_number(x_out_2_real, x_out_2_imag, Q_STAGE3, "X[2]");
            display_complex_number(x_out_3_real, x_out_3_imag, Q_STAGE3, "X[3]");
            display_complex_number(x_out_4_real, x_out_4_imag, Q_STAGE3, "X[4]");
            display_complex_number(x_out_5_real, x_out_5_imag, Q_STAGE3, "X[5]");
            display_complex_number(x_out_6_real, x_out_6_imag, Q_STAGE3, "X[6]");
            display_complex_number(x_out_7_real, x_out_7_imag, Q_STAGE3, "X[7]");
            
            // Calculate total power for verification
            total_power = (($itor(x_out_0_real)**2 + $itor(x_out_0_imag)**2) +
                          ($itor(x_out_1_real)**2 + $itor(x_out_1_imag)**2) +
                          ($itor(x_out_2_real)**2 + $itor(x_out_2_imag)**2) +
                          ($itor(x_out_3_real)**2 + $itor(x_out_3_imag)**2) +
                          ($itor(x_out_4_real)**2 + $itor(x_out_4_imag)**2) +
                          ($itor(x_out_5_real)**2 + $itor(x_out_5_imag)**2) +
                          ($itor(x_out_6_real)**2 + $itor(x_out_6_imag)**2) +
                          ($itor(x_out_7_real)**2 + $itor(x_out_7_imag)**2)) / (2.0**(2*Q_STAGE3));
            
            $display("  Total Output Power: %f", total_power);
        end
    endtask

    // NEW: Task to help determine the correct Q format for your design
    task debug_q_formats;
        begin
            $display("\n--- Q-FORMAT DEBUGGING ---");
            $display("Current parameter settings:");
            $display("  Q_STAGE1 (inputs/stage1): %0d", Q_STAGE1);
            $display("  Q_STAGE2 (stage2): %0d", Q_STAGE2);
            $display("  Q_FINAL_ACTUAL (final outputs): %0d", Q_FINAL_ACTUAL);
            $display("  Q_STAGE2_OUT (module param): %0d", Q_STAGE2_OUT);
            $display("\nIf stage values look wrong, try adjusting:");
            $display("  Stage 2: Q_STAGE2 = 11 if 2x too large, = 13 if 0.5x too small");
            $display("  Final:   Q_FINAL_ACTUAL = 12 if 0.5x too large, = 10 if 2x too small");
            $display("  Common patterns:");
            $display("    - All stages same Q: Q12 -> Q12 -> Q12");
            $display("    - Scaling down: Q12 -> Q12 -> Q11");
            $display("    - Heavy scaling: Q12 -> Q11 -> Q10");
        end
    endtask

    //--------------------------------------------------------------------------
    // Test Execution Tasks
    //--------------------------------------------------------------------------
    
    task apply_test_input;
        input signed [WIDTH-1:0] in0_r, in0_i, in1_r, in1_i, in2_r, in2_i, in3_r, in3_i;
        input signed [WIDTH-1:0] in4_r, in4_i, in5_r, in5_i, in6_r, in6_i, in7_r, in7_i;
        begin
            x_in_0_real = in0_r; x_in_0_imag = in0_i;
            x_in_1_real = in1_r; x_in_1_imag = in1_i;
            x_in_2_real = in2_r; x_in_2_imag = in2_i;
            x_in_3_real = in3_r; x_in_3_imag = in3_i;
            x_in_4_real = in4_r; x_in_4_imag = in4_i;
            x_in_5_real = in5_r; x_in_5_imag = in5_i;
            x_in_6_real = in6_r; x_in_6_imag = in6_i;
            x_in_7_real = in7_r; x_in_7_imag = in7_i;
        end
    endtask

    task run_fft_computation_with_stage_debug;
        begin
            $display("\n>>> Starting FFT computation...");
            cycle_count = 0;
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;
            
            // Show all stage outputs during computation
            repeat(5) @(posedge clk); // Wait a few cycles
            $display("\n>>> Showing intermediate stage outputs...");
            display_stage1_outputs();
            display_stage2_outputs();
            
            // Wait for completion with timeout
            timeout_count = 0;
            while (!done && timeout_count < 200) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;
            end
            
            if (timeout_count >= 200) begin
                $display("ERROR: FFT computation timeout after %0d cycles!", timeout_count);
                error_count = error_count + 1;
            end else begin
                $display(">>> FFT computation completed successfully in %0d cycles", cycle_count);
            end
            
            @(posedge clk);
        end
    endtask

    //--------------------------------------------------------------------------
    // Main Test Sequence
    //--------------------------------------------------------------------------
    initial begin

        // Initialize
        test_num = 0;
        error_count = 0;
        pass_count = 0;

        // Reset
        rst_n = 0;
        start = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(3) @(posedge clk);

        // Display Q-format debug info
        debug_q_formats();

        // Test: Complex Mix with Stage Debug
        test_num = 1;
        display_test_header("Complex_Mixed_with_Stage_Debug", "Mixed complex signal with stage-by-stage analysis");
        
        apply_test_input(
            16'd2048,  16'd2048,    // x[0] = 0.5 + j0.5
            16'd1229, -16'd819,     // x[1] = 0.3 - j0.2
            -16'd410,  16'd3277,    // x[2] = -0.1 + j0.8
            16'd2867, -16'd1638,    // x[3] = 0.7 - j0.4
            -16'd2458, 16'd410,     // x[4] = -0.6 + j0.1
            16'd819,   16'd3686,    // x[5] = 0.2 + j0.9
            -16'd1638, -16'd1229,   // x[6] = -0.4 - j0.3
            16'd3277, -16'd2867     // x[7] = 0.8 - j0.7
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Complex spectrum with distributed energy");
        $display("Analysis: Check progression through each stage");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 2: DC Signal (All ones)
        test_num = 2;
        display_test_header("DC_Signal_Test", "All samples = 1.0, energy should concentrate in X[0]");
        
        apply_test_input(
            16'd4096, 16'd0,    // x[0] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[1] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[2] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[3] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[4] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[5] = 1.0 + j0.0
            16'd4096, 16'd0,    // x[6] = 1.0 + j0.0
            16'd4096, 16'd0     // x[7] = 1.0 + j0.0
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Large X[0], all other outputs ~0");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 3: Alternating Signal (+1, -1, +1, -1, ...)
        test_num = 3;
        display_test_header("Alternating_Signal_Test", "Alternating +1/-1, energy should concentrate in X[4] (Nyquist)");
        
        apply_test_input(
            16'd4096,  16'd0,    // x[0] = +1.0
            -16'd4096, 16'd0,    // x[1] = -1.0
            16'd4096,  16'd0,    // x[2] = +1.0
            -16'd4096, 16'd0,    // x[3] = -1.0
            16'd4096,  16'd0,    // x[4] = +1.0
            -16'd4096, 16'd0,    // x[5] = -1.0
            16'd4096,  16'd0,    // x[6] = +1.0
            -16'd4096, 16'd0     // x[7] = -1.0
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Large X[4] (Nyquist frequency), others ~0");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 4: Single Impulse
        test_num = 4;
        display_test_header("Impulse_Response_Test", "Single impulse at x[0], flat spectrum expected");
        
        apply_test_input(
            16'd4096, 16'd0,    // x[0] = 1.0 (impulse)
            16'd0,    16'd0,    // x[1] = 0.0
            16'd0,    16'd0,    // x[2] = 0.0
            16'd0,    16'd0,    // x[3] = 0.0
            16'd0,    16'd0,    // x[4] = 0.0
            16'd0,    16'd0,    // x[5] = 0.0
            16'd0,    16'd0,    // x[6] = 0.0
            16'd0,    16'd0     // x[7] = 0.0
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: All outputs should have equal magnitude (flat spectrum)");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 5: Single Complex Tone (frequency bin 1)
        test_num = 5;
        display_test_header("Single_Tone_Test", "cos(2πk/8) for k=1, energy should concentrate in X[1]");
        
        // Pre-computed values for cos(2πn/8) at n=0,1,2,3,4,5,6,7
        // cos(0)=1, cos(π/4)=0.707, cos(π/2)=0, cos(3π/4)=-0.707, cos(π)=-1, etc.
        apply_test_input(
            16'd4096,  16'd0,    // x[0] = cos(0) = 1.0
            16'd2896,  16'd0,    // x[1] = cos(π/4) ≈ 0.707
            16'd0,     16'd0,    // x[2] = cos(π/2) = 0
            -16'd2896, 16'd0,    // x[3] = cos(3π/4) ≈ -0.707
            -16'd4096, 16'd0,    // x[4] = cos(π) = -1.0
            -16'd2896, 16'd0,    // x[5] = cos(5π/4) ≈ -0.707
            16'd0,     16'd0,    // x[6] = cos(3π/2) = 0
            16'd2896,  16'd0     // x[7] = cos(7π/4) ≈ 0.707
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Large X[1] and X[7], others ~0");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 6: Pure Imaginary Inputs
        test_num = 6;
        display_test_header("Pure_Imaginary_Test", "All inputs purely imaginary");
        
        apply_test_input(
            16'd0, 16'd2048,     // x[0] = j0.5
            16'd0, 16'd4096,     // x[1] = j1.0
            16'd0, -16'd1024,    // x[2] = -j0.25
            16'd0, 16'd3072,     // x[3] = j0.75
            16'd0, -16'd2048,    // x[4] = -j0.5
            16'd0, 16'd1536,     // x[5] = j0.375
            16'd0, -16'd3072,    // x[6] = -j0.75
            16'd0, 16'd1024      // x[7] = j0.25
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Complex spectrum with phase information");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 7: Ramp Signal
        test_num = 7;
        display_test_header("Ramp_Signal_Test", "Linear ramp from 0 to 7");
        
        apply_test_input(
            16'd0,     16'd0,    // x[0] = 0
            16'd585,   16'd0,    // x[1] = 1/7 ≈ 0.143
            16'd1170,  16'd0,    // x[2] = 2/7 ≈ 0.286
            16'd1755,  16'd0,    // x[3] = 3/7 ≈ 0.429
            16'd2340,  16'd0,    // x[4] = 4/7 ≈ 0.571
            16'd2925,  16'd0,    // x[5] = 5/7 ≈ 0.714
            16'd3511,  16'd0,    // x[6] = 6/7 ≈ 0.857
            16'd4096,  16'd0     // x[7] = 7/7 = 1.0
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: DC component in X[0], decreasing higher frequencies");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 8: Symmetry Test (Real Even Function)
        test_num = 8;
        display_test_header("Real_Even_Symmetry_Test", "Real even function - should produce real FFT");
        
        apply_test_input(
            16'd4096,  16'd0,    // x[0] = 1.0
            16'd2048,  16'd0,    // x[1] = 0.5
            16'd1024,  16'd0,    // x[2] = 0.25
            16'd512,   16'd0,    // x[3] = 0.125
            16'd512,   16'd0,    // x[4] = 0.125 (symmetric)
            16'd1024,  16'd0,    // x[5] = 0.25
            16'd2048,  16'd0,    // x[6] = 0.5
            16'd4096,  16'd0     // x[7] = 1.0 (wraps to x[0])
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: All imaginary parts should be ~0 (real FFT)");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 9: Maximum Positive Values
        test_num = 9;
        display_test_header("Max_Positive_Test", "Test with maximum positive Q12 values");
        
        apply_test_input(
            16'd32767, 16'd0,    // Maximum positive
            16'd32767, 16'd0,
            16'd32767, 16'd0,
            16'd32767, 16'd0,
            16'd32767, 16'd0,
            16'd32767, 16'd0,
            16'd32767, 16'd0,
            16'd32767, 16'd0
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Large DC component, test for overflow handling");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Test 10: Checkerboard Pattern in Complex Plane
        test_num = 10;
        display_test_header("Complex_Checkerboard_Test", "Alternating complex pattern");
        
        apply_test_input(
            16'd2896,  16'd2896,    // x[0] = 0.707 + j0.707 (1st quadrant)
            -16'd2896, 16'd2896,    // x[1] = -0.707 + j0.707 (2nd quadrant)
            -16'd2896, -16'd2896,   // x[2] = -0.707 - j0.707 (3rd quadrant)
            16'd2896,  -16'd2896,   // x[3] = 0.707 - j0.707 (4th quadrant)
            16'd2896,  16'd2896,    // x[4] = 0.707 + j0.707 (repeat pattern)
            -16'd2896, 16'd2896,    // x[5] = -0.707 + j0.707
            -16'd2896, -16'd2896,   // x[6] = -0.707 - j0.707
            16'd2896,  -16'd2896    // x[7] = 0.707 - j0.707
        );
        
        display_inputs();
        run_fft_computation_with_stage_debug();
        display_final_outputs();
        
        $display("Expected: Pattern in frequency domain showing 2-sample periodicity");
        pass_count = pass_count + 1;
        repeat(5) @(posedge clk);

        // Update test count for summary
        test_num = 10;

        //----------------------------------------------------------------------
        // Final Summary
        //----------------------------------------------------------------------
        $display("\n====================================================================================================");
        $display("STAGE-BY-STAGE DEBUG TEST SUMMARY");
        $display("====================================================================================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", error_count);
        
        if (error_count == 0)
            $display("ALL TESTS COMPLETED SUCCESSFULLY!");
        else
            $display("WARNING: %0d test(s) had issues", error_count);
            
        $display("\nNOTE: If stage values look incorrect, adjust Q format parameters:");
        $display("      Q_STAGE2 for stage 2, Q_FINAL_ACTUAL for final outputs");
        $display("      Check the debug_q_formats() output for guidance.");
            
        $finish;
        end
endmodule