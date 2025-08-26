module fft_SecondStage #(
  parameter integer WIDTH = 16,
  parameter integer Q_IN = 12,   // Input fractional bits
  parameter integer Q_OUT = 11   // Output fractional bits
)(
  input  wire                   clk,
  input  wire                   rst_n,

  input  wire signed [WIDTH-1:0] x_in_0_real,
  input  wire signed [WIDTH-1:0] x_in_1_real,
  input  wire signed [WIDTH-1:0] x_in_2_real,
  input  wire signed [WIDTH-1:0] x_in_3_real,
  input  wire signed [WIDTH-1:0] x_in_4_real,
  input  wire signed [WIDTH-1:0] x_in_5_real,
  input  wire signed [WIDTH-1:0] x_in_6_real,
  input  wire signed [WIDTH-1:0] x_in_7_real,

  input  wire signed [WIDTH-1:0] x_in_0_imag,
  input  wire signed [WIDTH-1:0] x_in_1_imag,
  input  wire signed [WIDTH-1:0] x_in_2_imag,
  input  wire signed [WIDTH-1:0] x_in_3_imag,
  input  wire signed [WIDTH-1:0] x_in_4_imag,
  input  wire signed [WIDTH-1:0] x_in_5_imag,
  input  wire signed [WIDTH-1:0] x_in_6_imag,
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

  // Intermediate results with extended width to prevent overflow
  wire signed [WIDTH:0] x_flag_0_real_ext, x_flag_0_imag_ext;
  wire signed [WIDTH:0] x_flag_1_real_ext, x_flag_1_imag_ext;
  wire signed [WIDTH:0] x_flag_2_real_ext, x_flag_2_imag_ext;
  wire signed [WIDTH:0] x_flag_3_real_ext, x_flag_3_imag_ext;
  wire signed [WIDTH:0] x_flag_4_real_ext, x_flag_4_imag_ext;
  wire signed [WIDTH:0] x_flag_5_real_ext, x_flag_5_imag_ext;
  wire signed [WIDTH:0] x_flag_6_real_ext, x_flag_6_imag_ext;
  wire signed [WIDTH:0] x_flag_7_real_ext, x_flag_7_imag_ext;

  // Rounded results for format conversion
  wire signed [WIDTH:0] x_flag_0_real_rounded, x_flag_0_imag_rounded;
  wire signed [WIDTH:0] x_flag_1_real_rounded, x_flag_1_imag_rounded;
  wire signed [WIDTH:0] x_flag_2_real_rounded, x_flag_2_imag_rounded;
  wire signed [WIDTH:0] x_flag_3_real_rounded, x_flag_3_imag_rounded;
  wire signed [WIDTH:0] x_flag_4_real_rounded, x_flag_4_imag_rounded;
  wire signed [WIDTH:0] x_flag_5_real_rounded, x_flag_5_imag_rounded;
  wire signed [WIDTH:0] x_flag_6_real_rounded, x_flag_6_imag_rounded;
  wire signed [WIDTH:0] x_flag_7_real_rounded, x_flag_7_imag_rounded;

  // FFT butterfly operations with sign extension
  assign x_flag_0_real_ext = $signed({x_in_0_real[WIDTH-1], x_in_0_real} + {x_in_2_real[WIDTH-1], x_in_2_real});
  assign x_flag_0_imag_ext = $signed({x_in_0_imag[WIDTH-1], x_in_0_imag} + {x_in_2_imag[WIDTH-1], x_in_2_imag});

  assign x_flag_1_real_ext = $signed({x_in_1_real[WIDTH-1], x_in_1_real} + {x_in_3_imag[WIDTH-1], x_in_3_imag});
  assign x_flag_1_imag_ext = $signed({x_in_1_imag[WIDTH-1], x_in_1_imag} - {x_in_3_real[WIDTH-1], x_in_3_real});

  assign x_flag_2_real_ext = $signed({x_in_0_real[WIDTH-1], x_in_0_real} - {x_in_2_real[WIDTH-1], x_in_2_real});
  assign x_flag_2_imag_ext = $signed({x_in_0_imag[WIDTH-1], x_in_0_imag} - {x_in_2_imag[WIDTH-1], x_in_2_imag});

  assign x_flag_3_real_ext = $signed({x_in_1_real[WIDTH-1], x_in_1_real} - {x_in_3_imag[WIDTH-1], x_in_3_imag});
  assign x_flag_3_imag_ext = $signed({x_in_1_imag[WIDTH-1], x_in_1_imag} + {x_in_3_real[WIDTH-1], x_in_3_real});

  assign x_flag_4_real_ext = $signed({x_in_4_real[WIDTH-1], x_in_4_real} + {x_in_6_real[WIDTH-1], x_in_6_real});
  assign x_flag_4_imag_ext = $signed({x_in_4_imag[WIDTH-1], x_in_4_imag} + {x_in_6_imag[WIDTH-1], x_in_6_imag});

  assign x_flag_5_real_ext = $signed({x_in_5_real[WIDTH-1], x_in_5_real} + {x_in_7_imag[WIDTH-1], x_in_7_imag});
  assign x_flag_5_imag_ext = $signed({x_in_5_imag[WIDTH-1], x_in_5_imag} - {x_in_7_real[WIDTH-1], x_in_7_real});

  assign x_flag_6_real_ext = $signed({x_in_4_real[WIDTH-1], x_in_4_real} - {x_in_6_real[WIDTH-1], x_in_6_real});
  assign x_flag_6_imag_ext = $signed({x_in_4_imag[WIDTH-1], x_in_4_imag} - {x_in_6_imag[WIDTH-1], x_in_6_imag});

  assign x_flag_7_real_ext = $signed({x_in_5_real[WIDTH-1], x_in_5_real} - {x_in_7_imag[WIDTH-1], x_in_7_imag});
  assign x_flag_7_imag_ext = $signed({x_in_5_imag[WIDTH-1], x_in_5_imag} + {x_in_7_real[WIDTH-1], x_in_7_real});

  // Add rounding bit (0.5 in fixed-point) before right shift
  // For Q12.4 to Q11.5 conversion, we need to right shift by 1 bit
  // Rounding bit = 2^(shift-1) = 2^0 = 1
  assign x_flag_0_real_rounded = $signed(x_flag_0_real_ext + 1'b1) ;
  assign x_flag_0_imag_rounded = $signed(x_flag_0_imag_ext + 1'b1) ;
  
  assign x_flag_1_real_rounded = $signed(x_flag_1_real_ext + 1'b1) ;
  assign x_flag_1_imag_rounded = $signed(x_flag_1_imag_ext + 1'b1) ;
  
  assign x_flag_2_real_rounded = $signed(x_flag_2_real_ext + 1'b1) ;
  assign x_flag_2_imag_rounded = $signed(x_flag_2_imag_ext + 1'b1) ;
  
  assign x_flag_3_real_rounded = $signed(x_flag_3_real_ext + 1'b1) ;
  assign x_flag_3_imag_rounded = $signed(x_flag_3_imag_ext + 1'b1) ;
  
  assign x_flag_4_real_rounded = $signed(x_flag_4_real_ext + 1'b1) ;
  assign x_flag_4_imag_rounded = $signed(x_flag_4_imag_ext + 1'b1) ;
  
  assign x_flag_5_real_rounded = $signed(x_flag_5_real_ext + 1'b1) ;
  assign x_flag_5_imag_rounded = $signed(x_flag_5_imag_ext + 1'b1) ;
  
  assign x_flag_6_real_rounded = $signed(x_flag_6_real_ext + 1'b1) ;
  assign x_flag_6_imag_rounded = $signed(x_flag_6_imag_ext + 1'b1) ;
  
  assign x_flag_7_real_rounded = $signed(x_flag_7_real_ext + 1'b1) ;
  assign x_flag_7_imag_rounded = $signed(x_flag_7_imag_ext + 1'b1) ;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      x_out_0_real <= 16'h0000; x_out_0_imag <= 16'h0000;
      x_out_1_real <= 16'h0000; x_out_1_imag <= 16'h0000;
      x_out_2_real <= 16'h0000; x_out_2_imag <= 16'h0000;
      x_out_3_real <= 16'h0000; x_out_3_imag <= 16'h0000;
      x_out_4_real <= 16'h0000; x_out_4_imag <= 16'h0000;
      x_out_5_real <= 16'h0000; x_out_5_imag <= 16'h0000;
      x_out_6_real <= 16'h0000; x_out_6_imag <= 16'h0000;
      x_out_7_real <= 16'h0000; x_out_7_imag <= 16'h0000;
    end
    else begin
      // Convert from Q12.4 to Q11.5 format by right shifting 1 bit with rounding
      x_out_0_real <= $signed( x_flag_0_real_rounded[WIDTH:1]) ;
      x_out_0_imag <= $signed( x_flag_0_imag_rounded[WIDTH:1]) ;
      
      x_out_1_real <= $signed( x_flag_1_real_rounded[WIDTH:1]) ;
      x_out_1_imag <= $signed( x_flag_1_imag_rounded[WIDTH:1]) ;
      
      x_out_2_real <= $signed( x_flag_2_real_rounded[WIDTH:1]) ;
      x_out_2_imag <= $signed( x_flag_2_imag_rounded[WIDTH:1]) ;
      
      x_out_3_real <= $signed( x_flag_3_real_rounded[WIDTH:1]) ;
      x_out_3_imag <= $signed( x_flag_3_imag_rounded[WIDTH:1]) ;
      
      x_out_4_real <= $signed( x_flag_4_real_rounded[WIDTH:1]) ;
      x_out_4_imag <= $signed( x_flag_4_imag_rounded[WIDTH:1]) ;
      
      x_out_5_real <= $signed( x_flag_5_real_rounded[WIDTH:1]) ;
      x_out_5_imag <= $signed( x_flag_5_imag_rounded[WIDTH:1]) ;
      
      x_out_6_real <= $signed( x_flag_6_real_rounded[WIDTH:1]) ;
      x_out_6_imag <= $signed( x_flag_6_imag_rounded[WIDTH:1]) ;
      
      x_out_7_real <= $signed( x_flag_7_real_rounded[WIDTH:1]) ;
      x_out_7_imag <= $signed( x_flag_7_imag_rounded[WIDTH:1]) ;
    end
  end

endmodule