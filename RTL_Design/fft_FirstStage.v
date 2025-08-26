module fft_FirstStage #(
  parameter integer WIDTH = 16,
  parameter integer Q = 12
)(
  input wire signed                    clk,
  input  wire signed                    rst_n,
  input  wire signed    [WIDTH-1:0] x_in_0_real,
  input  wire signed    [WIDTH-1:0] x_in_1_real,
  input  wire signed    [WIDTH-1:0] x_in_2_real,
  input  wire signed    [WIDTH-1:0] x_in_3_real,
  input  wire signed    [WIDTH-1:0] x_in_4_real,
  input  wire signed    [WIDTH-1:0] x_in_5_real,
  input  wire signed    [WIDTH-1:0] x_in_6_real,
  input  wire signed    [WIDTH-1:0] x_in_7_real,

  input  wire signed    [WIDTH-1:0] x_in_0_imag,
  input  wire signed    [WIDTH-1:0] x_in_1_imag,
  input  wire signed    [WIDTH-1:0] x_in_2_imag,
  input  wire signed    [WIDTH-1:0] x_in_3_imag,
  input  wire signed    [WIDTH-1:0] x_in_4_imag,
  input  wire signed    [WIDTH-1:0] x_in_5_imag,
  input  wire signed    [WIDTH-1:0] x_in_6_imag,
  input  wire signed    [WIDTH-1:0] x_in_7_imag,

  output reg signed     [WIDTH-1:0] x_out_0_real,
  output reg signed     [WIDTH-1:0] x_out_1_real,
  output reg signed     [WIDTH-1:0] x_out_2_real,
  output reg signed     [WIDTH-1:0] x_out_3_real,
  output reg signed     [WIDTH-1:0] x_out_4_real,
  output reg signed     [WIDTH-1:0] x_out_5_real,
  output reg signed     [WIDTH-1:0] x_out_6_real,
  output reg signed     [WIDTH-1:0] x_out_7_real,

  output reg signed     [WIDTH-1:0] x_out_0_imag,
  output reg signed     [WIDTH-1:0] x_out_1_imag,
  output reg signed     [WIDTH-1:0] x_out_2_imag,
  output reg signed     [WIDTH-1:0] x_out_3_imag,
  output reg signed     [WIDTH-1:0] x_out_4_imag,
  output reg signed     [WIDTH-1:0] x_out_5_imag,
  output reg signed     [WIDTH-1:0] x_out_6_imag,
  output reg signed     [WIDTH-1:0] x_out_7_imag
);

  // Stage-1 registers: hold the reordered inputs
  wire signed   [WIDTH-1:0] x_flag_0_real,x_flag_0_imag, x_flag_1_real,x_flag_1_imag, x_flag_2_real,x_flag_2_imag, x_flag_3_real,x_flag_3_imag;
  wire signed   [WIDTH-1:0] x_flag_4_real,x_flag_4_imag, x_flag_5_real,x_flag_5_imag, x_flag_6_real,x_flag_6_imag, x_flag_7_real,x_flag_7_imag;
  
  // Input reordering (bit-reversed order for radix-2 FFT)
  assign x_flag_0_real = x_in_0_real;
  assign x_flag_0_imag = x_in_0_imag;

  assign x_flag_1_real = x_in_4_real;
  assign x_flag_1_imag = x_in_4_imag;

  assign x_flag_2_real = x_in_2_real;
  assign x_flag_2_imag = x_in_2_imag;

  assign x_flag_3_real = x_in_6_real;
  assign x_flag_3_imag = x_in_6_imag;

  assign x_flag_4_real = x_in_1_real;
  assign x_flag_4_imag = x_in_1_imag;

  assign x_flag_5_real = x_in_5_real;
  assign x_flag_5_imag = x_in_5_imag;

  assign x_flag_6_real = x_in_3_real;
  assign x_flag_6_imag = x_in_3_imag;

  assign x_flag_7_real = x_in_7_real;
  assign x_flag_7_imag = x_in_7_imag;


  // Stage-2 registers: register the computed outputs
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
      x_out_0_real <=x_flag_0_real +x_flag_1_real;
      x_out_0_imag <=x_flag_0_imag +x_flag_1_imag;
      
      x_out_1_real <=x_flag_0_real -x_flag_1_real;
      x_out_1_imag <=x_flag_0_imag -x_flag_1_imag;
      
      x_out_2_real <=x_flag_2_real +x_flag_3_real;
      x_out_2_imag <=x_flag_2_imag +x_flag_3_imag;
      
      x_out_3_real <=x_flag_2_real -x_flag_3_real;
      x_out_3_imag <=x_flag_2_imag -x_flag_3_imag;
      
      x_out_4_real <=x_flag_4_real +x_flag_5_real;
      x_out_4_imag <=x_flag_4_imag +x_flag_5_imag;

      x_out_5_real <=x_flag_4_real -x_flag_5_real;
      x_out_5_imag <=x_flag_4_imag -x_flag_5_imag;
      
      x_out_6_real <=x_flag_6_real +x_flag_7_real;
      x_out_6_imag <=x_flag_6_imag +x_flag_7_imag;

      x_out_7_real <=x_flag_6_real -x_flag_7_real;
      x_out_7_imag <=x_flag_6_imag -x_flag_7_imag;
    end
  end
endmodule