`timescale 1ns / 1ps

module tb_fft_SecondStage();

  // Parameters
  parameter WIDTH = 16;
  parameter Q_IN = 12;
  parameter Q_OUT = 11;
  parameter PERIOD = 10; // 100MHz clock
  
  // Testbench signals
  reg clk;
  reg rst_n;
  
  // Input signals (Q12.4 format)
  reg signed [WIDTH-1:0] x_in_0_real, x_in_1_real, x_in_2_real, x_in_3_real;
  reg signed [WIDTH-1:0] x_in_4_real, x_in_5_real, x_in_6_real, x_in_7_real;
  reg signed [WIDTH-1:0] x_in_0_imag, x_in_1_imag, x_in_2_imag, x_in_3_imag;
  reg signed [WIDTH-1:0] x_in_4_imag, x_in_5_imag, x_in_6_imag, x_in_7_imag;
  
  // Output signals (Q11.5 format)
  wire signed [WIDTH-1:0] x_out_0_real, x_out_1_real, x_out_2_real, x_out_3_real;
  wire signed [WIDTH-1:0] x_out_4_real, x_out_5_real, x_out_6_real, x_out_7_real;
  wire signed [WIDTH-1:0] x_out_0_imag, x_out_1_imag, x_out_2_imag, x_out_3_imag;
  wire signed [WIDTH-1:0] x_out_4_imag, x_out_5_imag, x_out_6_imag, x_out_7_imag;
  
  // Test variables
  integer i;
  real input_real_val, input_imag_val;
  real output_real_val, output_imag_val;
  
  // Clock generation
  initial begin
    clk = 0;
    forever #(PERIOD/2) clk = ~clk;
  end
  
  // DUT instantiation
  fft_SecondStage #(
    .WIDTH(WIDTH),
    .Q_IN(Q_IN),
    .Q_OUT(Q_OUT)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    
    .x_in_0_real(x_in_0_real), .x_in_1_real(x_in_1_real),
    .x_in_2_real(x_in_2_real), .x_in_3_real(x_in_3_real),
    .x_in_4_real(x_in_4_real), .x_in_5_real(x_in_5_real),
    .x_in_6_real(x_in_6_real), .x_in_7_real(x_in_7_real),
    
    .x_in_0_imag(x_in_0_imag), .x_in_1_imag(x_in_1_imag),
    .x_in_2_imag(x_in_2_imag), .x_in_3_imag(x_in_3_imag),
    .x_in_4_imag(x_in_4_imag), .x_in_5_imag(x_in_5_imag),
    .x_in_6_imag(x_in_6_imag), .x_in_7_imag(x_in_7_imag),
    
    .x_out_0_real(x_out_0_real), .x_out_1_real(x_out_1_real),
    .x_out_2_real(x_out_2_real), .x_out_3_real(x_out_3_real),
    .x_out_4_real(x_out_4_real), .x_out_5_real(x_out_5_real),
    .x_out_6_real(x_out_6_real), .x_out_7_real(x_out_7_real),
    
    .x_out_0_imag(x_out_0_imag), .x_out_1_imag(x_out_1_imag),
    .x_out_2_imag(x_out_2_imag), .x_out_3_imag(x_out_3_imag),
    .x_out_4_imag(x_out_4_imag), .x_out_5_imag(x_out_5_imag),
    .x_out_6_imag(x_out_6_imag), .x_out_7_imag(x_out_7_imag)
  );
  
  // Fixed-point conversion functions for display
  function real fixed_to_real_q12_4;
    input signed [15:0] fixed_val;
    begin
      fixed_to_real_q12_4 = $itor(fixed_val) / (2.0**12);
    end
  endfunction
  
  function real fixed_to_real_q11_5;
    input signed [15:0] fixed_val;
    begin
      fixed_to_real_q11_5 = $itor(fixed_val) / (2.0**11);
    end
  endfunction
  
  function signed [15:0] real_to_fixed_q12_4;
    input real real_val;
    begin
      real_to_fixed_q12_4 = $rtoi(real_val * (2.0**12));
    end
  endfunction
  
  // Task to apply test vector
  task apply_test_vector;
    input real r0_r, r0_i, r1_r, r1_i, r2_r, r2_i, r3_r, r3_i;
    input real r4_r, r4_i, r5_r, r5_i, r6_r, r6_i, r7_r, r7_i;
    begin
      // Convert real values to Q12.4 fixed-point
      x_in_0_real = real_to_fixed_q12_4(r0_r); x_in_0_imag = real_to_fixed_q12_4(r0_i);
      x_in_1_real = real_to_fixed_q12_4(r1_r); x_in_1_imag = real_to_fixed_q12_4(r1_i);
      x_in_2_real = real_to_fixed_q12_4(r2_r); x_in_2_imag = real_to_fixed_q12_4(r2_i);
      x_in_3_real = real_to_fixed_q12_4(r3_r); x_in_3_imag = real_to_fixed_q12_4(r3_i);
      x_in_4_real = real_to_fixed_q12_4(r4_r); x_in_4_imag = real_to_fixed_q12_4(r4_i);
      x_in_5_real = real_to_fixed_q12_4(r5_r); x_in_5_imag = real_to_fixed_q12_4(r5_i);
      x_in_6_real = real_to_fixed_q12_4(r6_r); x_in_6_imag = real_to_fixed_q12_4(r6_i);
      x_in_7_real = real_to_fixed_q12_4(r7_r); x_in_7_imag = real_to_fixed_q12_4(r7_i);
      
      @(posedge clk); // Wait for one clock cycle
    end
  endtask
  
  // Task to display results
  task display_results;
    begin
      $display("\n=== Test Results ===");
      $display("Time: %0t", $time);
      
      $display("Inputs (Q12.4 format):");
      $display("x[0] = %f + j%f", fixed_to_real_q12_4(x_in_0_real), fixed_to_real_q12_4(x_in_0_imag));
      $display("x[1] = %f + j%f", fixed_to_real_q12_4(x_in_1_real), fixed_to_real_q12_4(x_in_1_imag));
      $display("x[2] = %f + j%f", fixed_to_real_q12_4(x_in_2_real), fixed_to_real_q12_4(x_in_2_imag));
      $display("x[3] = %f + j%f", fixed_to_real_q12_4(x_in_3_real), fixed_to_real_q12_4(x_in_3_imag));
      $display("x[4] = %f + j%f", fixed_to_real_q12_4(x_in_4_real), fixed_to_real_q12_4(x_in_4_imag));
      $display("x[5] = %f + j%f", fixed_to_real_q12_4(x_in_5_real), fixed_to_real_q12_4(x_in_5_imag));
      $display("x[6] = %f + j%f", fixed_to_real_q12_4(x_in_6_real), fixed_to_real_q12_4(x_in_6_imag));
      $display("x[7] = %f + j%f", fixed_to_real_q12_4(x_in_7_real), fixed_to_real_q12_4(x_in_7_imag));
      
      $display("\nOutputs (Q11.5 format):");
      $display("y[0] = %f + j%f", fixed_to_real_q11_5(x_out_0_real), fixed_to_real_q11_5(x_out_0_imag));
      $display("y[1] = %f + j%f", fixed_to_real_q11_5(x_out_1_real), fixed_to_real_q11_5(x_out_1_imag));
      $display("y[2] = %f + j%f", fixed_to_real_q11_5(x_out_2_real), fixed_to_real_q11_5(x_out_2_imag));
      $display("y[3] = %f + j%f", fixed_to_real_q11_5(x_out_3_real), fixed_to_real_q11_5(x_out_3_imag));
      $display("y[4] = %f + j%f", fixed_to_real_q11_5(x_out_4_real), fixed_to_real_q11_5(x_out_4_imag));
      $display("y[5] = %f + j%f", fixed_to_real_q11_5(x_out_5_real), fixed_to_real_q11_5(x_out_5_imag));
      $display("y[6] = %f + j%f", fixed_to_real_q11_5(x_out_6_real), fixed_to_real_q11_5(x_out_6_imag));
      $display("y[7] = %f + j%f", fixed_to_real_q11_5(x_out_7_real), fixed_to_real_q11_5(x_out_7_imag));
      
      $display("\nRaw hex values:");
      $display("Inputs:  %h %h %h %h %h %h %h %h", x_in_0_real, x_in_1_real, x_in_2_real, x_in_3_real, x_in_4_real, x_in_5_real, x_in_6_real, x_in_7_real);
      $display("Outputs: %h %h %h %h %h %h %h %h", x_out_0_real, x_out_1_real, x_out_2_real, x_out_3_real, x_out_4_real, x_out_5_real, x_out_6_real, x_out_7_real);
    end
  endtask
  
  // Main test sequence
  initial begin
    $display("Starting FFT Second Stage Testbench");
    $display("Input format: Q12.4, Output format: Q11.5");
    
    // Initialize
    rst_n = 0;
    x_in_0_real = 0; x_in_1_real = 0; x_in_2_real = 0; x_in_3_real = 0;
    x_in_4_real = 0; x_in_5_real = 0; x_in_6_real = 0; x_in_7_real = 0;
    x_in_0_imag = 0; x_in_1_imag = 0; x_in_2_imag = 0; x_in_3_imag = 0;
    x_in_4_imag = 0; x_in_5_imag = 0; x_in_6_imag = 0; x_in_7_imag = 0;
    
    // Reset sequence
    #(PERIOD*5);
    rst_n = 1;
    #(PERIOD*2);
    
    // Test 8: Small fractional values
    $display("\n=== Test 8: Small Fractional Values ===");
    apply_test_vector(0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0,
                      0.0625, 0.1875, 0.3125, 0.4375, 0.5625, 0.6875, 0.8125, 0.9375);
    @(posedge clk);
    display_results();
    
    // Wait a few more cycles
    #(PERIOD*10);
    
    $display("\n=== Testbench Completed Successfully ===");
    $finish;
  end
  
  
endmodule