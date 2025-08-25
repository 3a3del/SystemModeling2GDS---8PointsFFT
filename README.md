# SystemModeling2GDS||-8PointsFFT
A high-performance, fully pipelined Fast Fourier Transform (FFT) implementation using Radix-2 Decimation in Time (DIT) algorithm based on the Cooley-Tukey method.

🚀 Features

8-point FFT with 16-bit fixed-point arithmetic
Fully pipelined architecture with 3-stage pipeline for high throughput
Low latency: 5 clock cycles
Radix-2 DIT algorithm for optimal performance
Lint-clean RTL design
Comprehensive verification with MATLAB cross-validation
FPGA and ASIC implementation ready

📊 Performance Metrics
Speed Advantage

85x faster than direct DFT for N=1024
341x faster than direct DFT for N=4096
Complexity improvement: O(N²) → O(N log N)

Signal Quality

Average SQNR: 78.28 dB
Minimum SQNR: 77.80 dB
Maximum SQNR: 78.72 dB
Maximum error: 4.88e-04
Mean error: 5.12e-05

🏗️ Architecture
The design consists of three main processing stages:

First Stage (fft_FirstStage)
Second Stage (fft_SecondStage)
Third Stage (fft_ThirdStage)

Each stage is fully pipelined to achieve maximum throughput while maintaining minimal latency.
🔧 Implementation Results
FPGA Implementation (Xilinx Artix-7)

Target Device: xc7a200tfbg676-2 (AC701 Evaluation Platform)
Maximum Frequency: 143 MHz
Resource Utilization:

Slice LUTs: 606 (0.45%)
Slice Registers: 389 (0.14%)
CARRY4: 170 cells
Total cells: 275
I/O ports: 261



ASIC Implementation
OpenLane (SkyWater 130nm)

Maximum Frequency: 118 MHz
Design Area: 197,894 μm²
Utilization: 5%
Total Power: 0.295 W

ICC (Nangate 45nm)

Maximum Frequency: 1 GHz
Design Area: 20,360 μm²
Utilization: 30%
Total Power: 13.45 mW

ASIC Impl files : https://drive.google.com/drive/folders/1zvHCn5AC-Wqilq5PWotKmar8CP48mm4J?usp=drive_link

✅ Verification
The design has been thoroughly verified through:

Individual stage testing: All three stages pass verification
System-level testing: 7 comprehensive test scenarios
MATLAB cross-validation: 50/50 seeds passed (100% success rate)
Code coverage: Complete functional coverage achieved

Test Scenarios

Complex Mix
DC Signal (All ones)
Alternating Signal (+1, -1, +1, -1, ...)
Single Impulse
Single Complex Tone (Cos [0 : 7π/4:π/4])
Pure Imaginary Inputs
Ramp Signal

📁 Repository Structure
fft-implementation/
├── rtl/
│   ├── fft_FirstStage.v
│   ├── fft_SecondStage.v
│   ├── fft_ThirdStage.v
│   └── fft_8point_top.v
├── testbench/
│   ├── fft_FirstStage_tb.v
│   ├── tb_fft_SecondStage.v
│   ├── fft_ThirdStage_tb.v
│   └── tb_fft_8point_tb.v
├── verification/
│   └── fft_8point_top_MatlabVerification/
├── fpga/
│   └── artix7_implementation/
├── asic/
│   ├── openlane/
│   └── icc/
└── docs/
    └── FFT_Implementation_Report.pdf
🚦 Getting Started
Prerequisites

Verilog simulator (ModelSim, VCS, or similar)
MATLAB (for verification)
Xilinx Vivado (for FPGA implementation)
OpenLane or ICC (for ASIC implementation)

Running the Simulation
bash# Compile and run testbench
vlog rtl/*.v testbench/tb_fft_8point_tb.v
vsim tb_fft_8point_tb
run -all
FPGA Synthesis
bash# Using Vivado
vivado -mode batch -source fpga/synthesis_script.tcl
📈 Applications
This FFT implementation is suitable for:

Digital Signal Processing applications
Communications systems
Audio/Video processing
Radar and sonar systems
Medical imaging
Scientific computing

🛠️ Technical Specifications

Input/Output: 8 complex samples, 16-bit each (real + imaginary)
Algorithm: Radix-2 Decimation in Time (DIT)
Pipeline Stages: 3
Latency: 5 clock cycles
Throughput: 1 FFT per clock cycle (after initial latency)

Summary:
- **Algorithm Selection:** Chose Radix-2 DIT FFT for its efficiency.
- **System Modeling:** Verified the FFT algorithm and optimized fixed-point sizing through simulation and error analysis.
- **RTL Design:** Translated the system model into hardware description language (HDL) for synthesis, focusing on individual FFT stages.
- **Design Verification:** Rigorously tested the RTL design using various test cases and MATLAB comparisons, analyzing latency and code coverage.
- **FPGA Implementation:** Synthesized and implemented the verified RTL design onto an FPGA for prototyping, evaluating resource utilization and timing.
- **ASIC Implementation:** Synthesized and implemented the design as an ASIC using Openlane and ICC flows, optimizing for performance, area, and power, and performing comparative analysis.


Derivation of the Radix-2 FFT Algorithm
DFT and FFT Concepts Forum

🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

⭐ Acknowledgments
Analog Devices, Inc. for supporting this implementation

