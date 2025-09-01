# IEEE-754 Floating Point Unit (FPU) — FSM-Based Design in SystemVerilog

This repository contains a synthesizable, FSM-based 32-bit IEEE-754 compliant Floating Point Unit (FPU) implemented in SystemVerilog. The design supports the four basic arithmetic operations — addition, subtraction, multiplication, and division — and follows a structured Finite State Machine (FSM) model to improve synthesis feasibility and timing closure.

🚀 Key Features

✅ IEEE-754 Single Precision (32-bit) support

✅ FSM-based multi-cycle design (Idle → Prepare → Compute → Normalize → Round → Writeback)

✅ Synthesizable structure using sequential (always_ff) and combinational (always_comb) blocks

✅ Handles core floating-point operations:

Addition (op = 00)

Subtraction (op = 01)

Multiplication (op = 10)

Division (op = 11)

✅ Built-in mantissa alignment, normalization, and GRS-based rounding

📚 Operation Flow
1. Input Preparation

Extracts sign, exponent, and mantissa from both operands a and b

Prepends the implicit 1 to mantissas → converts them to 24-bit

2. FSM Control Flow
State	Functionality
Idle	Wait for perm signal to start operation
Prepare	Decode input fields, align mantissas
Compute	Perform selected arithmetic operation
Normalize	Shift result to normalize leading 1
Round	Apply IEEE-754 GRS rounding
Writeback	Reconstruct 32-bit float result {sign, exponent, mantissa}
3. Operation Details

➕ Addition & ➖ Subtraction

Align exponents via right-shift

Add or subtract mantissas

Forward result to rounding

✖️ Multiplication

Multiply 24-bit mantissas → 48-bit product

Add exponents and subtract bias (127)

Normalize product

Apply GRS rounding

➗ Division

Shift numerator (mant_a) left by 24 bits → 48-bit precision

Divide by mant_b

Subtract exponents and add bias (127)

Normalize and round

🔄 Rounding Logic (GRS Method)
if (G == 1 && (R == 1 || S != 0))
    mantissa += 1;


G = Guard bit (next to LSB)

R = Round bit (after G)

S = Sticky bit (OR of all lower bits)

Ensures round-to-nearest-even behavior per IEEE-754.

🛠️ Design Highlights

Written in SystemVerilog using always_ff and always_comb

Supports multi-cycle computation, allowing:

Reduced combinational path delay

Easier timing closure for synthesis on FPGAs or ASICs

Designed with clarity and modularity, suitable for integration into a RISC-V CPU or SoC
