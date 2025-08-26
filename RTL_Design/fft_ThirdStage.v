module fft_ThirdStage #(
  parameter integer WIDTH = 16,
  parameter integer Q = 11
)(
  input  wire                   clk,
  input  wire                   rst_n,

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

  output reg  signed [WIDTH-1:0] x_out_0_real,
  output reg  signed [WIDTH-1:0] x_out_1_real,
  output reg  signed [WIDTH-1:0] x_out_2_real,
  output reg  signed [WIDTH-1:0] x_out_3_real,
  output reg  signed [WIDTH-1:0] x_out_4_real,
  output reg  signed [WIDTH-1:0] x_out_5_real,
  output reg  signed [WIDTH-1:0] x_out_6_real,
  output reg  signed [WIDTH-1:0] x_out_7_real,
  output reg  signed [WIDTH-1:0] x_out_0_imag,
  output reg  signed [WIDTH-1:0] x_out_1_imag,
  output reg  signed [WIDTH-1:0] x_out_2_imag,
  output reg  signed [WIDTH-1:0] x_out_3_imag,
  output reg  signed [WIDTH-1:0] x_out_4_imag,
  output reg  signed [WIDTH-1:0] x_out_5_imag,
  output reg  signed [WIDTH-1:0] x_out_6_imag,
  output reg  signed [WIDTH-1:0] x_out_7_imag
);

// Fixed-point twiddle factors (Q11 format for default Q=11)
// 0.7071 * 2^11 = 1448.9 ≈ 1449
localparam signed [WIDTH-1:0] w1_8_real = 1449;   // 0.7071 in Q11
localparam signed [WIDTH-1:0] w1_8_imag = -1449;  // -0.7071 in Q11
/////////////////////////
localparam signed [WIDTH-1:0] w2_8_real = 0;      // 0 
localparam signed [WIDTH-1:0] w2_8_imag = -(1 << Q); // -1 in Q11 = -2048
/////////////////////////
localparam signed [WIDTH-1:0] w3_8_real = -1449;  // -0.7071 in Q11
localparam signed [WIDTH-1:0] w3_8_imag = -1449;  // -0.7071 in Q11
/////////////////////////

  // Intermediate wires for complex multiplications
  wire signed [2*WIDTH-1:0] mult_temp_1_real, mult_temp_1_imag;
  wire signed [2*WIDTH-1:0] mult_temp_3_real, mult_temp_3_imag;
  wire signed [2*WIDTH-1:0] mult_temp_5_real, mult_temp_5_imag;
  wire signed [2*WIDTH-1:0] mult_temp_7_real, mult_temp_7_imag;

  // Complex multiplication: (a + jb) * (c + jd) = (ac - bd) + j(ad + bc)
  // For x_flag_1: x_in_1 + w1_8 * x_in_5
  assign mult_temp_1_real = (w1_8_real * x_in_5_real) - (w1_8_imag * x_in_5_imag);
  assign mult_temp_1_imag = (w1_8_real * x_in_5_imag) + (w1_8_imag * x_in_5_real);

  // For x_flag_3: x_in_3 + w3_8 * x_in_7
  assign mult_temp_3_real = (w3_8_real * x_in_7_real) - (w3_8_imag * x_in_7_imag);
  assign mult_temp_3_imag = (w3_8_real * x_in_7_imag) + (w3_8_imag * x_in_7_real);

  // For x_flag_5: x_in_1 - w1_8 * x_in_5
  assign mult_temp_5_real = (w1_8_real * x_in_5_real) - (w1_8_imag * x_in_5_imag);
  assign mult_temp_5_imag = (w1_8_real * x_in_5_imag) + (w1_8_imag * x_in_5_real);

  // For x_flag_7: x_in_3 - w3_8 * x_in_7
  assign mult_temp_7_real = (w3_8_real * x_in_7_real) - (w3_8_imag * x_in_7_imag);
  assign mult_temp_7_imag = (w3_8_real * x_in_7_imag) + (w3_8_imag * x_in_7_real);

  wire signed [WIDTH-1:0] x_flag_0_real;
  wire signed [WIDTH-1:0] x_flag_1_real;
  wire signed [WIDTH-1:0] x_flag_2_real;
  wire signed [WIDTH-1:0] x_flag_3_real;
  wire signed [WIDTH-1:0] x_flag_4_real;
  wire signed [WIDTH-1:0] x_flag_5_real;
  wire signed [WIDTH-1:0] x_flag_6_real;
  wire signed [WIDTH-1:0] x_flag_7_real;
  wire signed [WIDTH-1:0] x_flag_0_imag;
  wire signed [WIDTH-1:0] x_flag_1_imag;
  wire signed [WIDTH-1:0] x_flag_2_imag;
  wire signed [WIDTH-1:0] x_flag_3_imag;
  wire signed [WIDTH-1:0] x_flag_4_imag;
  wire signed [WIDTH-1:0] x_flag_5_imag;
  wire signed [WIDTH-1:0] x_flag_6_imag;
  wire signed [WIDTH-1:0] x_flag_7_imag;
  
/////////////////////////
assign x_flag_0_real = x_in_0_real + x_in_4_real;
assign x_flag_0_imag = x_in_0_imag + x_in_4_imag;

assign x_flag_1_real = x_in_1_real + (mult_temp_1_real >>> Q);
assign x_flag_1_imag = x_in_1_imag + (mult_temp_1_imag >>> Q);

assign x_flag_2_real = x_in_2_real + x_in_6_imag;
assign x_flag_2_imag = x_in_2_imag - x_in_6_real;

assign x_flag_3_real = x_in_3_real + (mult_temp_3_real >>> Q);
assign x_flag_3_imag = x_in_3_imag + (mult_temp_3_imag >>> Q);

assign x_flag_4_real = x_in_0_real - x_in_4_real;
assign x_flag_4_imag = x_in_0_imag - x_in_4_imag;

assign x_flag_5_real = x_in_1_real - (mult_temp_5_real >>> Q);
assign x_flag_5_imag = x_in_1_imag - (mult_temp_5_imag >>> Q);

assign x_flag_6_real = x_in_2_real - x_in_6_imag;
assign x_flag_6_imag = x_in_2_imag + x_in_6_real;

assign x_flag_7_real = x_in_3_real - (mult_temp_7_real >>> Q);
assign x_flag_7_imag = x_in_3_imag - (mult_temp_7_imag >>> Q);

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x_out_0_real <= 0;
        x_out_1_real <= 0;
        x_out_2_real <= 0;
        x_out_3_real <= 0;
        x_out_4_real <= 0;
        x_out_5_real <= 0;
        x_out_6_real <= 0;
        x_out_7_real <= 0;
        x_out_0_imag <= 0;
        x_out_1_imag <= 0;
        x_out_2_imag <= 0;
        x_out_3_imag <= 0;
        x_out_4_imag <= 0;
        x_out_5_imag <= 0;
        x_out_6_imag <= 0;
        x_out_7_imag <= 0;
    end
    else begin
        x_out_0_real <= x_flag_0_real;
        x_out_1_real <= x_flag_1_real;
        x_out_2_real <= x_flag_2_real;
        x_out_3_real <= x_flag_3_real;
        x_out_4_real <= x_flag_4_real;
        x_out_5_real <= x_flag_5_real;
        x_out_6_real <= x_flag_6_real;
        x_out_7_real <= x_flag_7_real;
        x_out_0_imag <= x_flag_0_imag;
        x_out_1_imag <= x_flag_1_imag;
        x_out_2_imag <= x_flag_2_imag;
        x_out_3_imag <= x_flag_3_imag;
        x_out_4_imag <= x_flag_4_imag;
        x_out_5_imag <= x_flag_5_imag;
        x_out_6_imag <= x_flag_6_imag;
        x_out_7_imag <= x_flag_7_imag;
    end
  end

endmodule