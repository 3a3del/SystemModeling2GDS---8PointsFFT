`timescale 1ns / 1ps

module fft_8point_top_MatlabVerification();

    // Parameters
    parameter integer WIDTH = 16;
    parameter integer Q_inputs = 12;
    parameter integer Q_outputs = 11;
    parameter real TOLERANCE = 0.1; // Tolerance for floating point comparison
    
    // Clock and reset
    reg clk;
    reg rst_n;
    reg start;
    
    // Input signals (time domain)
    reg signed [WIDTH-1:0] x_in_0_real, x_in_0_imag;
    reg signed [WIDTH-1:0] x_in_1_real, x_in_1_imag;
    reg signed [WIDTH-1:0] x_in_2_real, x_in_2_imag;
    reg signed [WIDTH-1:0] x_in_3_real, x_in_3_imag;
    reg signed [WIDTH-1:0] x_in_4_real, x_in_4_imag;
    reg signed [WIDTH-1:0] x_in_5_real, x_in_5_imag;
    reg signed [WIDTH-1:0] x_in_6_real, x_in_6_imag;
    reg signed [WIDTH-1:0] x_in_7_real, x_in_7_imag;
    
    // Output signals (frequency domain)
    wire signed [WIDTH-1:0] x_out_0_real, x_out_0_imag;
    wire signed [WIDTH-1:0] x_out_1_real, x_out_1_imag;
    wire signed [WIDTH-1:0] x_out_2_real, x_out_2_imag;
    wire signed [WIDTH-1:0] x_out_3_real, x_out_3_imag;
    wire signed [WIDTH-1:0] x_out_4_real, x_out_4_imag;
    wire signed [WIDTH-1:0] x_out_5_real, x_out_5_imag;
    wire signed [WIDTH-1:0] x_out_6_real, x_out_6_imag;
    wire signed [WIDTH-1:0] x_out_7_real, x_out_7_imag;
    
    // Control signals
    wire valid_out;
    wire done;
    
    // Test variables
    real input_test_cases [0:49][0:15]; // 50 test cases, 8 complex numbers (16 real values)
    real expected_outputs [0:49][0:15];  // Expected outputs
    real actual_outputs [0:15];          // Actual outputs converted to real
    
    integer test_case;
    integer errors;
    integer total_tests;
    
    // File handles
    integer input_file, output_file;
    
    // DUT instantiation
    fft_8point_top #(
        .WIDTH(WIDTH),
        .Q_inputs(Q_inputs),
        .Q_outputs(Q_outputs)
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
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Function to convert real number to fixed point
    function signed [WIDTH-1:0] real_to_fixed;
        input real value;
        input integer q_format;
        begin
            real_to_fixed = value * (2.0 ** q_format);
        end
    endfunction
    
    // Function to convert fixed point to real
    function real fixed_to_real;
        input signed [WIDTH-1:0] value;
        input integer q_format;
        begin
            fixed_to_real = $itor(value) / (2.0 ** q_format);
        end
    endfunction
    
    // Function to parse complex number string
    function automatic integer parse_complex;
        input string complex_str;
        output real real_part;
        output real imag_part;
        integer plus_pos, j_pos, len;
        string real_str, imag_str;
        begin
            len = complex_str.len();
            
            // Find the position of 'j' at the end
            j_pos = len - 1;
            
            // Find the position of '+' or '-' that separates real and imaginary parts
            plus_pos = -1;
            for (integer i = 1; i < j_pos; i++) begin
                if (complex_str[i] == "+" || complex_str[i] == "-") begin
                    plus_pos = i;
                end
            end
            
            if (plus_pos > 0) begin
                real_str = complex_str.substr(0, plus_pos-1);
                imag_str = complex_str.substr(plus_pos, j_pos-1);
                real_part = real_str.atoreal();
                imag_part = imag_str.atoreal();
            end else begin
                real_part = 0.0;
                imag_part = 0.0;
            end
            
            parse_complex = 1;
        end
    endfunction
    
    // Task to load test cases from file
    task load_test_cases;
        string line;
        string complex_nums[8];
        real real_part, imag_part;
        integer i, j, comma_pos, start_pos;
        begin
            input_file = $fopen("seed1_test_cases.txt", "r");
            if (input_file == 0) begin
                $display("ERROR: Could not open seed1_test_cases.txt");
                $finish;
            end
            
            for (i = 0; i < 50; i++) begin
                if ($fgets(line, input_file)) begin
                    // Parse the line to extract 8 complex numbers
                    start_pos = 0;
                    for (j = 0; j < 8; j++) begin
                        comma_pos = -1;
                        // Find next comma or end of line
                        for (integer k = start_pos; k < line.len(); k++) begin
                            if (line[k] == "," || k == line.len()-1) begin
                                comma_pos = k;
                                break;
                            end
                        end
                        
                        if (comma_pos > start_pos) begin
                            if (j == 7 && comma_pos == line.len()-1) begin
                                complex_nums[j] = line.substr(start_pos, comma_pos);
                            end else begin
                                complex_nums[j] = line.substr(start_pos, comma_pos-1);
                            end
                            
                            // Parse complex number
                            parse_complex(complex_nums[j], real_part, imag_part);
                            input_test_cases[i][j*2] = real_part;
                            input_test_cases[i][j*2+1] = imag_part;
                            
                            start_pos = comma_pos + 2; // Skip comma and space
                        end
                    end
                end
            end
            $fclose(input_file);
            $display("Loaded 50 input test cases");
        end
    endtask
    
    // Task to load expected outputs
    task load_expected_outputs;
        string line;
        string complex_nums[8];
        real real_part, imag_part;
        integer i, j, comma_pos, start_pos;
        begin
            output_file = $fopen("seed1_test_outputs.txt", "r");
            if (output_file == 0) begin
                $display("ERROR: Could not open seed1_test_outputs.txt");
                $finish;
            end
            
            for (i = 0; i < 50; i++) begin
                if ($fgets(line, output_file)) begin
                    // Parse the line to extract 8 complex numbers
                    start_pos = 0;
                    for (j = 0; j < 8; j++) begin
                        comma_pos = -1;
                        // Find next comma or end of line
                        for (integer k = start_pos; k < line.len(); k++) begin
                            if (line[k] == "," || k == line.len()-1) begin
                                comma_pos = k;
                                break;
                            end
                        end
                        
                        if (comma_pos > start_pos) begin
                            if (j == 7 && comma_pos == line.len()-1) begin
                                complex_nums[j] = line.substr(start_pos, comma_pos);
                            end else begin
                                complex_nums[j] = line.substr(start_pos, comma_pos-1);
                            end
                            
                            // Parse complex number
                            parse_complex(complex_nums[j], real_part, imag_part);
                            expected_outputs[i][j*2] = real_part;
                            expected_outputs[i][j*2+1] = imag_part;
                            
                            start_pos = comma_pos + 2; // Skip comma and space
                        end
                    end
                end
            end
            $fclose(output_file);
            $display("Loaded 50 expected output cases");
        end
    endtask
    
    // Task to apply test case
    task apply_test_case;
        input integer tc;
        begin
            // Convert real inputs to fixed point and apply to DUT
            x_in_0_real = real_to_fixed(input_test_cases[tc][0], Q_inputs);
            x_in_0_imag = real_to_fixed(input_test_cases[tc][1], Q_inputs);
            x_in_1_real = real_to_fixed(input_test_cases[tc][2], Q_inputs);
            x_in_1_imag = real_to_fixed(input_test_cases[tc][3], Q_inputs);
            x_in_2_real = real_to_fixed(input_test_cases[tc][4], Q_inputs);
            x_in_2_imag = real_to_fixed(input_test_cases[tc][5], Q_inputs);
            x_in_3_real = real_to_fixed(input_test_cases[tc][6], Q_inputs);
            x_in_3_imag = real_to_fixed(input_test_cases[tc][7], Q_inputs);
            x_in_4_real = real_to_fixed(input_test_cases[tc][8], Q_inputs);
            x_in_4_imag = real_to_fixed(input_test_cases[tc][9], Q_inputs);
            x_in_5_real = real_to_fixed(input_test_cases[tc][10], Q_inputs);
            x_in_5_imag = real_to_fixed(input_test_cases[tc][11], Q_inputs);
            x_in_6_real = real_to_fixed(input_test_cases[tc][12], Q_inputs);
            x_in_6_imag = real_to_fixed(input_test_cases[tc][13], Q_inputs);
            x_in_7_real = real_to_fixed(input_test_cases[tc][14], Q_inputs);
            x_in_7_imag = real_to_fixed(input_test_cases[tc][15], Q_inputs);
            
            $display("Applied test case %0d inputs", tc);
        end
    endtask
    
   task check_outputs;
    input integer tc;
    integer i;
    real error;
    integer case_errors;
    begin
        case_errors = 0;

        // Convert fixed point outputs to real
        actual_outputs[0]  = fixed_to_real(x_out_0_real, Q_outputs);
        actual_outputs[1]  = fixed_to_real(x_out_0_imag, Q_outputs);
        actual_outputs[2]  = fixed_to_real(x_out_1_real, Q_outputs);
        actual_outputs[3]  = fixed_to_real(x_out_1_imag, Q_outputs);
        actual_outputs[4]  = fixed_to_real(x_out_2_real, Q_outputs);
        actual_outputs[5]  = fixed_to_real(x_out_2_imag, Q_outputs);
        actual_outputs[6]  = fixed_to_real(x_out_3_real, Q_outputs);
        actual_outputs[7]  = fixed_to_real(x_out_3_imag, Q_outputs);
        actual_outputs[8]  = fixed_to_real(x_out_4_real, Q_outputs);
        actual_outputs[9]  = fixed_to_real(x_out_4_imag, Q_outputs);
        actual_outputs[10] = fixed_to_real(x_out_5_real, Q_outputs);
        actual_outputs[11] = fixed_to_real(x_out_5_imag, Q_outputs);
        actual_outputs[12] = fixed_to_real(x_out_6_real, Q_outputs);
        actual_outputs[13] = fixed_to_real(x_out_6_imag, Q_outputs);
        actual_outputs[14] = fixed_to_real(x_out_7_real, Q_outputs);
        actual_outputs[15] = fixed_to_real(x_out_7_imag, Q_outputs);

        // Print inputs for this test case
        $display("Inputs:");
        for (i = 0; i < 16; i = i + 2) begin
            $display("  X[%0d] = %f + %fj", i/2, 
                     input_test_cases[tc][i], input_test_cases[tc][i+1]);
        end

        // Compare with expected outputs
        $display("Expected vs DUT Output:");
        for (i = 0; i < 16; i = i + 2) begin
            error = actual_outputs[i] - expected_outputs[tc][i];
            if (error < 0) error = -error;
            if (error > TOLERANCE) begin
                $display("  ERROR: Out[%0d] Real: Exp=%f, DUT=%f, Err=%f", 
                         i/2, expected_outputs[tc][i], actual_outputs[i], error);
                case_errors++;
                errors++;
            end else begin
                $display("  PASS : Out[%0d] Real: Exp=%f, DUT=%f", 
                         i/2, expected_outputs[tc][i], actual_outputs[i]);
            end

            error = actual_outputs[i+1] - expected_outputs[tc][i+1];
            if (error < 0) error = -error;
            if (error > TOLERANCE) begin
                $display("  ERROR: Out[%0d] Imag: Exp=%f, DUT=%f, Err=%f", 
                         i/2, expected_outputs[tc][i+1], actual_outputs[i+1], error);
                case_errors++;
                errors++;
            end else begin
                $display("  PASS : Out[%0d] Imag: Exp=%f, DUT=%f", 
                         i/2, expected_outputs[tc][i+1], actual_outputs[i+1]);
            end
        end

        if (case_errors == 0) begin
            $display("  PASS: Test case %0d passed", tc);
        end else begin
            $display("  FAIL: Test case %0d failed with %0d errors", tc, case_errors);
        end
    end
endtask
    
    // Main test sequence
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        errors = 0;
        total_tests = 50;
        
        // Initialize all inputs to zero
        x_in_0_real = 0; x_in_0_imag = 0;
        x_in_1_real = 0; x_in_1_imag = 0;
        x_in_2_real = 0; x_in_2_imag = 0;
        x_in_3_real = 0; x_in_3_imag = 0;
        x_in_4_real = 0; x_in_4_imag = 0;
        x_in_5_real = 0; x_in_5_imag = 0;
        x_in_6_real = 0; x_in_6_imag = 0;
        x_in_7_real = 0; x_in_7_imag = 0;
        
        $display("=== FFT 8-Point Testbench Started ===");
        
        // Load test data
        load_test_cases();
        load_expected_outputs();
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        // Run test cases
        for (test_case = 0; test_case < total_tests; test_case = test_case + 1) begin
            $display("\n--- Running Test Case %0d ---", test_case);
            
            // Apply test case inputs
            apply_test_case(test_case);
            
            // Start FFT computation
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Wait for computation to complete
            wait(done == 1);
            @(posedge clk);
            
            // Check outputs
            if (valid_out) begin
                check_outputs(test_case);
            end else begin
                $display("  ERROR: valid_out not asserted for test case %0d", test_case);
                errors = errors + 1;
            end
            
            // Wait a few cycles before next test
            #50;
        end
        
        // Final summary
        $display("\n=== Test Summary ===");
        $display("Total Test Cases: %0d", total_tests);
        $display("Total Errors: %0d", errors);
        if (errors == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("TESTS FAILED - %0d errors found", errors);
        end
        
        $display("=== FFT 8-Point Testbench Completed ===");
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #1000000; // 1ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule