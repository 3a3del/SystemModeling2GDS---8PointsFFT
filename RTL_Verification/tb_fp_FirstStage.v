`timescale 1ns / 1ps

module fft_FirstStage_tb;

    // Parameters
    parameter integer WIDTH = 16;
    parameter integer Q = 12;
    parameter real CLOCK_PERIOD = 10.0; // 10ns clock period (100MHz)
    
    // Test bench signals
    reg clk;
    reg rst_n;
    
    // Input signals - 8 complex numbers
    reg signed [WIDTH-1:0] x_in_0_real, x_in_0_imag;
    reg signed [WIDTH-1:0] x_in_1_real, x_in_1_imag;
    reg signed [WIDTH-1:0] x_in_2_real, x_in_2_imag;
    reg signed [WIDTH-1:0] x_in_3_real, x_in_3_imag;
    reg signed [WIDTH-1:0] x_in_4_real, x_in_4_imag;
    reg signed [WIDTH-1:0] x_in_5_real, x_in_5_imag;
    reg signed [WIDTH-1:0] x_in_6_real, x_in_6_imag;
    reg signed [WIDTH-1:0] x_in_7_real, x_in_7_imag;
    
    // Output signals - 8 complex numbers
    wire signed [WIDTH-1:0] x_out_0_real, x_out_0_imag;
    wire signed [WIDTH-1:0] x_out_1_real, x_out_1_imag;
    wire signed [WIDTH-1:0] x_out_2_real, x_out_2_imag;
    wire signed [WIDTH-1:0] x_out_3_real, x_out_3_imag;
    wire signed [WIDTH-1:0] x_out_4_real, x_out_4_imag;
    wire signed [WIDTH-1:0] x_out_5_real, x_out_5_imag;
    wire signed [WIDTH-1:0] x_out_6_real, x_out_6_imag;
    wire signed [WIDTH-1:0] x_out_7_real, x_out_7_imag;
    
    // Test control variables
    integer test_case;
    integer errors;
    
    // Fixed-point conversion functions
    function real fixed_to_real;
        input signed [WIDTH-1:0] fixed_val;
        begin
            fixed_to_real = $itor(fixed_val) / (2.0 ** Q);
        end
    endfunction
    
    function signed [WIDTH-1:0] real_to_fixed;
        input real real_val;
        begin
            real_to_fixed = $rtoi(real_val * (2.0 ** Q));
        end
    endfunction
    
    // Complex number display task
    task display_complex;
        input [8*20-1:0] name; // 20-character string
        input signed [WIDTH-1:0] real_part;
        input signed [WIDTH-1:0] imag_part;
        real r_real, r_imag;
        begin
            r_real = fixed_to_real(real_part);
            r_imag = fixed_to_real(imag_part);
            if (r_imag >= 0)
                $display("%s: %.6f + %.6fj", name, r_real, r_imag);
            else
                $display("%s: %.6f - %.6fj", name, r_real, -r_imag);
        end
    endtask
    
    // Set complex input task
    task set_complex_input;
        input integer index;
        input real real_val;
        input real imag_val;
        begin
            case(index)
                0: begin
                    x_in_0_real = real_to_fixed(real_val);
                    x_in_0_imag = real_to_fixed(imag_val);
                end
                1: begin
                    x_in_1_real = real_to_fixed(real_val);
                    x_in_1_imag = real_to_fixed(imag_val);
                end
                2: begin
                    x_in_2_real = real_to_fixed(real_val);
                    x_in_2_imag = real_to_fixed(imag_val);
                end
                3: begin
                    x_in_3_real = real_to_fixed(real_val);
                    x_in_3_imag = real_to_fixed(imag_val);
                end
                4: begin
                    x_in_4_real = real_to_fixed(real_val);
                    x_in_4_imag = real_to_fixed(imag_val);
                end
                5: begin
                    x_in_5_real = real_to_fixed(real_val);
                    x_in_5_imag = real_to_fixed(imag_val);
                end
                6: begin
                    x_in_6_real = real_to_fixed(real_val);
                    x_in_6_imag = real_to_fixed(imag_val);
                end
                7: begin
                    x_in_7_real = real_to_fixed(real_val);
                    x_in_7_imag = real_to_fixed(imag_val);
                end
            endcase
        end
    endtask
    
    // Display all inputs task
    task display_inputs;
        begin
            $display("\n=== INPUT COMPLEX NUMBERS ===");
            display_complex("x_in[0]           ", x_in_0_real, x_in_0_imag);
            display_complex("x_in[1]           ", x_in_1_real, x_in_1_imag);
            display_complex("x_in[2]           ", x_in_2_real, x_in_2_imag);
            display_complex("x_in[3]           ", x_in_3_real, x_in_3_imag);
            display_complex("x_in[4]           ", x_in_4_real, x_in_4_imag);
            display_complex("x_in[5]           ", x_in_5_real, x_in_5_imag);
            display_complex("x_in[6]           ", x_in_6_real, x_in_6_imag);
            display_complex("x_in[7]           ", x_in_7_real, x_in_7_imag);
        end
    endtask
    
    // Display all outputs task
    task display_outputs;
        begin
            $display("\n=== OUTPUT COMPLEX NUMBERS ===");
            display_complex("x_out[0]          ", x_out_0_real, x_out_0_imag);
            display_complex("x_out[1]          ", x_out_1_real, x_out_1_imag);
            display_complex("x_out[2]          ", x_out_2_real, x_out_2_imag);
            display_complex("x_out[3]          ", x_out_3_real, x_out_3_imag);
            display_complex("x_out[4]          ", x_out_4_real, x_out_4_imag);
            display_complex("x_out[5]          ", x_out_5_real, x_out_5_imag);
            display_complex("x_out[6]          ", x_out_6_real, x_out_6_imag);
            display_complex("x_out[7]          ", x_out_7_real, x_out_7_imag);
        end
    endtask
    
    // Initialize all inputs to zero
    task initialize_inputs;
        begin
            x_in_0_real = 0; x_in_0_imag = 0;
            x_in_1_real = 0; x_in_1_imag = 0;
            x_in_2_real = 0; x_in_2_imag = 0;
            x_in_3_real = 0; x_in_3_imag = 0;
            x_in_4_real = 0; x_in_4_imag = 0;
            x_in_5_real = 0; x_in_5_imag = 0;
            x_in_6_real = 0; x_in_6_imag = 0;
            x_in_7_real = 0; x_in_7_imag = 0;
        end
    endtask
    
    // Verify expected output task
    task verify_output;
        input integer out_index;
        input real expected_real;
        input real expected_imag;
        input real tolerance;
        real actual_real, actual_imag;
        real error_real, error_imag;
        begin
            case(out_index)
                0: begin
                    actual_real = fixed_to_real(x_out_0_real);
                    actual_imag = fixed_to_real(x_out_0_imag);
                end
                1: begin
                    actual_real = fixed_to_real(x_out_1_real);
                    actual_imag = fixed_to_real(x_out_1_imag);
                end
                2: begin
                    actual_real = fixed_to_real(x_out_2_real);
                    actual_imag = fixed_to_real(x_out_2_imag);
                end
                3: begin
                    actual_real = fixed_to_real(x_out_3_real);
                    actual_imag = fixed_to_real(x_out_3_imag);
                end
                4: begin
                    actual_real = fixed_to_real(x_out_4_real);
                    actual_imag = fixed_to_real(x_out_4_imag);
                end
                5: begin
                    actual_real = fixed_to_real(x_out_5_real);
                    actual_imag = fixed_to_real(x_out_5_imag);
                end
                6: begin
                    actual_real = fixed_to_real(x_out_6_real);
                    actual_imag = fixed_to_real(x_out_6_imag);
                end
                7: begin
                    actual_real = fixed_to_real(x_out_7_real);
                    actual_imag = fixed_to_real(x_out_7_imag);
                end
            endcase
            
            error_real = actual_real - expected_real;
            error_imag = actual_imag - expected_imag;
            
            if (error_real < 0) error_real = -error_real;
            if (error_imag < 0) error_imag = -error_imag;
            
            if (error_real > tolerance || error_imag > tolerance) begin
                $display("ERROR: x_out[%0d] - Expected: %.6f + %.6fj, Got: %.6f + %.6fj", 
                        out_index, expected_real, expected_imag, actual_real, actual_imag);
                errors = errors + 1;
            end else begin
                $display("PASS: x_out[%0d] - %.6f + %.6fj", out_index, actual_real, actual_imag);
            end
        end
    endtask
    
    // Reset sequence task
    task reset_sequence;
        begin
            rst_n = 0;
            repeat(3) @(posedge clk);
            rst_n = 1;
            repeat(2) @(posedge clk);
        end
    endtask
    
    // Wait and capture output
    task wait_and_capture;
        begin
            @(posedge clk);
            #1; // Small delay to ensure signals settle
        end
    endtask

    // Instantiate the FFT First Stage module
    fft_FirstStage #(
        .WIDTH(WIDTH),
        .Q(Q)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
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
        .x_out_7_real(x_out_7_real), .x_out_7_imag(x_out_7_imag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // Main test sequence
    initial begin
        // Initialize variables
        test_case = 0;
        errors = 0;
        
        // Display test information
        $display("=================================================================");
        $display("FFT First Stage Testbench");
        $display("Fixed-Point Format: Q%0d.%0d (%0d-bit)", WIDTH-Q, Q, WIDTH);
        $display("Clock Period: %.1f ns", CLOCK_PERIOD);
        $display("=================================================================");
        
        // Initialize inputs
        initialize_inputs();
        
        // Initial reset
        reset_sequence();
        
        // Test Case 1: Simple real inputs
        test_case = 1;
        $display("\n--- TEST CASE %0d: Simple Real Inputs ---", test_case);
        
        set_complex_input(0, 1.0, 0.0);    // 1.0 + 0.0j
        set_complex_input(1, 0.5, 0.0);    // 0.5 + 0.0j
        set_complex_input(2, 0.25, 0.0);   // 0.25 + 0.0j
        set_complex_input(3, 0.125, 0.0);  // 0.125 + 0.0j
        set_complex_input(4, -0.5, 0.0);   // -0.5 + 0.0j
        set_complex_input(5, -0.25, 0.0);  // -0.25 + 0.0j
        set_complex_input(6, -0.125, 0.0); // -0.125 + 0.0j
        set_complex_input(7, -0.0625, 0.0); // -0.0625 + 0.0j
        
        display_inputs();
        wait_and_capture();
        display_outputs();
        
        // Verify outputs with bit-reversed reordering (x_flag mapping)
        verify_output(0, 0.5, 0.0, 0.001);      // x_in[0] + x_in[4] = 1.0 + (-0.5)
        verify_output(1, 1.5, 0.0, 0.001);      // x_in[0] - x_in[4] = 1.0 - (-0.5)
        verify_output(2, 0.125, 0.0, 0.001);    // x_in[2] + x_in[6] = 0.25 + (-0.125)
        verify_output(3, 0.375, 0.0, 0.001);    // x_in[2] - x_in[6] = 0.25 - (-0.125)
        verify_output(4, 0.25, 0.0, 0.001);     // x_in[1] + x_in[5] = 0.5 + (-0.25)
        verify_output(5, 0.75, 0.0, 0.001);     // x_in[1] - x_in[5] = 0.5 - (-0.25)
        verify_output(6, 0.0625, 0.0, 0.001);   // x_in[3] + x_in[7] = 0.125 + (-0.0625)
        verify_output(7, 0.1875, 0.0, 0.001);   // x_in[3] - x_in[7] = 0.125 - (-0.0625)
        
        #(CLOCK_PERIOD * 2);
        
        // Test Case 2: Complex inputs with imaginary parts
        test_case = 2;
        $display("\n--- TEST CASE %0d: Complex Inputs ---", test_case);
        
        set_complex_input(0,  0.5000,  0.5000);  // 0.5000 + 0.5000j
        set_complex_input(1,  0.3000, -0.2000);  // 0.3000 - 0.2000j
        set_complex_input(2, -0.1001,  0.8000);  // -0.1001 + 0.8000j
        set_complex_input(3,  0.7000, -0.3999);  // 0.7000 - 0.3999j
        set_complex_input(4, -0.6001,  0.1001);  // -0.6001 + 0.1001j
        set_complex_input(5,  0.2000,  0.8999);  // 0.2000 + 0.8999j
        set_complex_input(6, -0.3999, -0.3000);  // -0.3999 - 0.3000j
        set_complex_input(7,  0.8000, -0.7000);  // 0.8000 - 0.7000j

        
        display_inputs();
        wait_and_capture();
        display_outputs();
        
        // Verify complex arithmetic with bit-reversed reordering
        verify_output(0, 0.375, 0.0, 0.001);      // (0.5+0.75j) + (-0.125-0.75j) = 0.375+0.0j
        verify_output(1, 0.625, 1.5, 0.001);      // (0.5+0.75j) - (-0.125-0.75j) = 0.625+1.5j
        verify_output(2, -0.375, 0.625, 0.001);   // (-0.375+0.125j) + (0.0+0.5j) = -0.375+0.625j
        verify_output(3, -0.375, -0.375, 0.001);  // (-0.375+0.125j) - (0.0+0.5j) = -0.375-0.375j
        verify_output(4, 1.125, -0.5, 0.001);     // (0.25-0.5j) + (0.875+0.0j) = 1.125-0.5j
        verify_output(5, -0.625, -0.5, 0.001);    // (0.25-0.5j) - (0.875+0.0j) = -0.625-0.5j
        verify_output(6, 0.375, 0.125, 0.001);    // (0.625+0.25j) + (-0.25-0.125j) = 0.375+0.125j
        verify_output(7, 0.875, 0.375, 0.001);    // (0.625+0.25j) - (-0.25-0.125j) = 0.875+0.375j
        
        #(CLOCK_PERIOD * 2);
        
        // Test Case 3: Maximum and minimum values
        test_case = 3;
        $display("\n--- TEST CASE %0d: Boundary Values ---", test_case);
        
        set_complex_input(0, 1.999, 1.999);      // Near maximum positive
        set_complex_input(1, -2.0, -2.0);        // Maximum negative  
        set_complex_input(2, 0.0, 0.0);          // Zero
        set_complex_input(3, 0.000244, 0.000244); // Near minimum positive (1 LSB)
        set_complex_input(4, 1.0, -1.0);         // Mixed signs
        set_complex_input(5, -1.0, 1.0);         // Mixed signs opposite
        set_complex_input(6, 0.5, -0.5);         // Symmetric
        set_complex_input(7, -0.5, 0.5);         // Symmetric opposite
        
        display_inputs();
        wait_and_capture();
        display_outputs();
        
        // Note: Some outputs may overflow, but we test the logic
        $display("INFO: Boundary value test - some overflow expected");
        
        #(CLOCK_PERIOD * 2);
        
        // Test Case 4: Reset functionality
        test_case = 4;
        $display("\n--- TEST CASE %0d: Reset Functionality ---", test_case);
        
        // Set some inputs
        set_complex_input(0, 1.0, 1.0);
        set_complex_input(1, 1.0, 1.0);
        set_complex_input(2, 1.0, 1.0);
        set_complex_input(3, 1.0, 1.0);
        set_complex_input(4, 1.0, 1.0);
        set_complex_input(5, 1.0, 1.0);
        set_complex_input(6, 1.0, 1.0);
        set_complex_input(7, 1.0, 1.0);
        
        display_inputs();
        
        // Apply reset
        rst_n = 0;
        @(posedge clk);
        #1;
        
        $display("\nAfter Reset (outputs should be zero):");
        display_outputs();
        
        // Verify all outputs are zero
        verify_output(0, 0.0, 0.0, 0.001);
        verify_output(1, 0.0, 0.0, 0.001);
        verify_output(2, 0.0, 0.0, 0.001);
        verify_output(3, 0.0, 0.0, 0.001);
        verify_output(4, 0.0, 0.0, 0.001);
        verify_output(5, 0.0, 0.0, 0.001);
        verify_output(6, 0.0, 0.0, 0.001);
        verify_output(7, 0.0, 0.0, 0.001);
        
        rst_n = 1;
        #(CLOCK_PERIOD * 2);
        
        // Test Case 5: Unity impulse (useful for FFT verification)
        test_case = 5;
        $display("\n--- TEST CASE %0d: Unity Impulse ---", test_case);
        
        initialize_inputs();
        set_complex_input(0, 1.0, 0.0);  // Unity impulse at index 0
        
        display_inputs();
        wait_and_capture();
        display_outputs();
        
        // For unity impulse with bit-reversed reordering, expect specific pattern
        verify_output(0, 1.0, 0.0, 0.001);   // x_in[0] + x_in[4] = 1 + 0
        verify_output(1, 1.0, 0.0, 0.001);   // x_in[0] - x_in[4] = 1 - 0
        verify_output(2, 0.0, 0.0, 0.001);   // x_in[2] + x_in[6] = 0 + 0
        verify_output(3, 0.0, 0.0, 0.001);   // x_in[2] - x_in[6] = 0 - 0
        verify_output(4, 0.0, 0.0, 0.001);   // x_in[1] + x_in[5] = 0 + 0
        verify_output(5, 0.0, 0.0, 0.001);   // x_in[1] - x_in[5] = 0 - 0
        verify_output(6, 0.0, 0.0, 0.001);   // x_in[3] + x_in[7] = 0 + 0
        verify_output(7, 0.0, 0.0, 0.001);   // x_in[3] - x_in[7] = 0 - 0
        
        #(CLOCK_PERIOD * 5);
        
        // Test summary
        $display("\n=================================================================");
        $display("TEST SUMMARY");
        $display("=================================================================");
        $display("Total Test Cases: %0d", test_case);
        $display("Total Errors: %0d", errors);
        
        if (errors == 0) begin
            $display("*** ALL TESTS PASSED! ***");
        end else begin
            $display("*** %0d TESTS FAILED! ***", errors);
        end
        
        $display("=================================================================");
        
        // End simulation
        #(CLOCK_PERIOD * 10);
        $finish;
    end
    
    // Simulation control
    initial begin
        // Create waveform dump for viewing
        $dumpfile("fft_FirstStage_tb.vcd");
        $dumpvars(0, fft_FirstStage_tb);
        
        // Timeout protection
        #100000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end
    
    // Monitor critical signals
    initial begin
        $monitor("Time: %0t | RST: %b | CLK: %b | Test Case: %0d", 
                 $time, rst_n, clk, test_case);
    end

endmodule
