module fft_8point_top #(
  parameter integer WIDTH = 16,
  parameter integer Q_inputs= 12,
  parameter integer Q_outputs= 11
)(
  input  wire                   clk,
  input  wire                   rst_n,
  input  wire                   start,        // Start FFT computation
  
  // Input samples (time domain)
  input  wire signed [WIDTH-1:0] x_in_0_real,
  input  wire signed [WIDTH-1:0] x_in_0_imag,
  input  wire signed [WIDTH-1:0] x_in_1_real,
  input  wire signed [WIDTH-1:0] x_in_1_imag,
  input  wire signed [WIDTH-1:0] x_in_2_real,
  input  wire signed [WIDTH-1:0] x_in_2_imag,
  input  wire signed [WIDTH-1:0] x_in_3_real,
  input  wire signed [WIDTH-1:0] x_in_3_imag,
  input  wire signed [WIDTH-1:0] x_in_4_real,
  input  wire signed [WIDTH-1:0] x_in_4_imag,
  input  wire signed [WIDTH-1:0] x_in_5_real,
  input  wire signed [WIDTH-1:0] x_in_5_imag,
  input  wire signed [WIDTH-1:0] x_in_6_real,
  input  wire signed [WIDTH-1:0] x_in_6_imag,
  input  wire signed [WIDTH-1:0] x_in_7_real,
  input  wire signed [WIDTH-1:0] x_in_7_imag,

  // Output samples (frequency domain)
  output wire signed [WIDTH-1:0] x_out_0_real,
  output wire signed [WIDTH-1:0] x_out_0_imag,
  output wire signed [WIDTH-1:0] x_out_1_real,
  output wire signed [WIDTH-1:0] x_out_1_imag,
  output wire signed [WIDTH-1:0] x_out_2_real,
  output wire signed [WIDTH-1:0] x_out_2_imag,
  output wire signed [WIDTH-1:0] x_out_3_real,
  output wire signed [WIDTH-1:0] x_out_3_imag,
  output wire signed [WIDTH-1:0] x_out_4_real,
  output wire signed [WIDTH-1:0] x_out_4_imag,
  output wire signed [WIDTH-1:0] x_out_5_real,
  output wire signed [WIDTH-1:0] x_out_5_imag,
  output wire signed [WIDTH-1:0] x_out_6_real,
  output wire signed [WIDTH-1:0] x_out_6_imag,
  output wire signed [WIDTH-1:0] x_out_7_real,
  output wire signed [WIDTH-1:0] x_out_7_imag,
  
  // Control outputs
  output reg                    valid_out,    // Output data is valid
  output reg                    done          // FFT computation complete
);

  // Inter-stage connections
  // First Stage to Second Stage
  wire signed [WIDTH-1:0] stage1_to_stage2_0_real, stage1_to_stage2_0_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_1_real, stage1_to_stage2_1_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_2_real, stage1_to_stage2_2_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_3_real, stage1_to_stage2_3_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_4_real, stage1_to_stage2_4_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_5_real, stage1_to_stage2_5_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_6_real, stage1_to_stage2_6_imag;
  wire signed [WIDTH-1:0] stage1_to_stage2_7_real, stage1_to_stage2_7_imag;

  // Second Stage to Third Stage
  wire signed [WIDTH-1:0] stage2_to_stage3_0_real, stage2_to_stage3_0_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_1_real, stage2_to_stage3_1_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_2_real, stage2_to_stage3_2_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_3_real, stage2_to_stage3_3_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_4_real, stage2_to_stage3_4_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_5_real, stage2_to_stage3_5_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_6_real, stage2_to_stage3_6_imag;
  wire signed [WIDTH-1:0] stage2_to_stage3_7_real, stage2_to_stage3_7_imag;

  // Pipeline control registers
  reg [2:0] pipeline_counter;
  reg computation_active;

  // First Stage: Bit-reversal and first butterfly operations
  fft_FirstStage #(.WIDTH(WIDTH) , .Q(Q_inputs)) stage1 ( 
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
    .x_out_0_real(stage1_to_stage2_0_real), .x_out_0_imag(stage1_to_stage2_0_imag),
    .x_out_1_real(stage1_to_stage2_1_real), .x_out_1_imag(stage1_to_stage2_1_imag),
    .x_out_2_real(stage1_to_stage2_2_real), .x_out_2_imag(stage1_to_stage2_2_imag),
    .x_out_3_real(stage1_to_stage2_3_real), .x_out_3_imag(stage1_to_stage2_3_imag),
    .x_out_4_real(stage1_to_stage2_4_real), .x_out_4_imag(stage1_to_stage2_4_imag),
    .x_out_5_real(stage1_to_stage2_5_real), .x_out_5_imag(stage1_to_stage2_5_imag),
    .x_out_6_real(stage1_to_stage2_6_real), .x_out_6_imag(stage1_to_stage2_6_imag),
    .x_out_7_real(stage1_to_stage2_7_real), .x_out_7_imag(stage1_to_stage2_7_imag)
  );

  // Second Stage: Second butterfly operations with twiddle factors
  fft_SecondStage #(.WIDTH(WIDTH) , .Q_IN(Q_inputs) , .Q_OUT(Q_outputs) ) stage2 (
    .clk(clk),
    .rst_n(rst_n),
    .x_in_0_real(stage1_to_stage2_0_real), .x_in_0_imag(stage1_to_stage2_0_imag),
    .x_in_1_real(stage1_to_stage2_1_real), .x_in_1_imag(stage1_to_stage2_1_imag),
    .x_in_2_real(stage1_to_stage2_2_real), .x_in_2_imag(stage1_to_stage2_2_imag),
    .x_in_3_real(stage1_to_stage2_3_real), .x_in_3_imag(stage1_to_stage2_3_imag),
    .x_in_4_real(stage1_to_stage2_4_real), .x_in_4_imag(stage1_to_stage2_4_imag),
    .x_in_5_real(stage1_to_stage2_5_real), .x_in_5_imag(stage1_to_stage2_5_imag),
    .x_in_6_real(stage1_to_stage2_6_real), .x_in_6_imag(stage1_to_stage2_6_imag),
    .x_in_7_real(stage1_to_stage2_7_real), .x_in_7_imag(stage1_to_stage2_7_imag),
    .x_out_0_real(stage2_to_stage3_0_real), .x_out_0_imag(stage2_to_stage3_0_imag),
    .x_out_1_real(stage2_to_stage3_1_real), .x_out_1_imag(stage2_to_stage3_1_imag),
    .x_out_2_real(stage2_to_stage3_2_real), .x_out_2_imag(stage2_to_stage3_2_imag),
    .x_out_3_real(stage2_to_stage3_3_real), .x_out_3_imag(stage2_to_stage3_3_imag),
    .x_out_4_real(stage2_to_stage3_4_real), .x_out_4_imag(stage2_to_stage3_4_imag),
    .x_out_5_real(stage2_to_stage3_5_real), .x_out_5_imag(stage2_to_stage3_5_imag),
    .x_out_6_real(stage2_to_stage3_6_real), .x_out_6_imag(stage2_to_stage3_6_imag),
    .x_out_7_real(stage2_to_stage3_7_real), .x_out_7_imag(stage2_to_stage3_7_imag)
  );

  // Third Stage: Final butterfly operations with twiddle factors
  fft_ThirdStage #(.WIDTH(WIDTH) , .Q(Q_outputs)) stage3 (
    .clk(clk),
    .rst_n(rst_n),
    .x_in_0_real(stage2_to_stage3_0_real), .x_in_0_imag(stage2_to_stage3_0_imag),
    .x_in_1_real(stage2_to_stage3_1_real), .x_in_1_imag(stage2_to_stage3_1_imag),
    .x_in_2_real(stage2_to_stage3_2_real), .x_in_2_imag(stage2_to_stage3_2_imag),
    .x_in_3_real(stage2_to_stage3_3_real), .x_in_3_imag(stage2_to_stage3_3_imag),
    .x_in_4_real(stage2_to_stage3_4_real), .x_in_4_imag(stage2_to_stage3_4_imag),
    .x_in_5_real(stage2_to_stage3_5_real), .x_in_5_imag(stage2_to_stage3_5_imag),
    .x_in_6_real(stage2_to_stage3_6_real), .x_in_6_imag(stage2_to_stage3_6_imag),
    .x_in_7_real(stage2_to_stage3_7_real), .x_in_7_imag(stage2_to_stage3_7_imag),
    .x_out_0_real(x_out_0_real), .x_out_0_imag(x_out_0_imag),
    .x_out_1_real(x_out_1_real), .x_out_1_imag(x_out_1_imag),
    .x_out_2_real(x_out_2_real), .x_out_2_imag(x_out_2_imag),
    .x_out_3_real(x_out_3_real), .x_out_3_imag(x_out_3_imag),
    .x_out_4_real(x_out_4_real), .x_out_4_imag(x_out_4_imag),
    .x_out_5_real(x_out_5_real), .x_out_5_imag(x_out_5_imag),
    .x_out_6_real(x_out_6_real), .x_out_6_imag(x_out_6_imag),
    .x_out_7_real(x_out_7_real), .x_out_7_imag(x_out_7_imag)
  );

  // Pipeline control logic
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pipeline_counter <= 3'b000;
      computation_active <= 1'b0;
      valid_out <= 1'b0;
      done <= 1'b0;
    end else begin
      if (start && !computation_active) begin
        // Start new FFT computation
        computation_active <= 1'b1;
        pipeline_counter <= 3'b001;
        valid_out <= 1'b0;
        done <= 1'b0;
      end else if (computation_active) begin
        // Count pipeline stages
        if (pipeline_counter < 3'b100) begin
          pipeline_counter <= pipeline_counter + 1'b1;
        end else begin
          // Pipeline complete
          valid_out <= 1'b1;
          done <= 1'b1;
          computation_active <= 1'b0;
          pipeline_counter <= 3'b000;
        end
      end else begin
        // Clear done signal after one cycle
        done <= 1'b0;
        if (!start) begin
          valid_out <= 1'b0;
        end
      end
    end
  end

endmodule