# IEEE-754-Floating-Point-Unit-FPU-in-SystemVerilog

This repository contains a behavioral model of a **32-bit IEEE-754 compliant Floating Point Unit (FPU)** written in SystemVerilog. The module supports basic arithmetic operations: **addition, subtraction, multiplication, and division** on 32-bit floating point inputs as per IEEE-754 format.

## 🔧 Features

- **IEEE-754 Single Precision Support (32-bit)**
- Handles:
  - Floating-point **addition**
  - Floating-point **subtraction**
  - Floating-point **multiplication**
  - Floating-point **division**
- Implements:
  - **Exponent alignment** for addition/subtraction
  - **Mantissa multiplication and division** with normalization
  - **Rounding logic** using Guard (G), Round (R), and Sticky (S) bits
  - Partial **normalization and exponent adjustment** post operation
- Designed for simulation and prototyping purposes.

## 🧠 Operation Overview

IEEE-754 represents a 32-bit float as:

| Sign (1 bit) | Exponent (8 bits) | Mantissa (23 bits) |

markdown
Copy code

The FPU module follows the typical flow for each operation:

### 1. Extraction
- Extracts the sign, exponent, and mantissa from input operands.
- Implicit leading `1` is added to the mantissa to form a 24-bit number.

### 2. Operation Cases

- **Addition/Subtraction**
  - Aligns exponents by right-shifting the smaller operand’s mantissa.
  - Performs the operation based on the signs and magnitudes.

- **Multiplication**
  - Multiplies 24-bit mantissas → 48-bit product.
  - Adds exponents and subtracts bias (127).
  - Normalizes the result.
  - Applies rounding logic based on G/R/S bits.

- **Division**
  - Shifts numerator mantissa left by 24 bits for precision.
  - Divides 48-bit numerator by 24-bit denominator.
  - Subtracts exponents and adds bias (127).
  - Normalizes and rounds the result.

### 3. Rounding
Rounding is done using GRS (Guard, Round, Sticky) method:

if (G == 1 && (R == 1 || S == 1))
mantissa += 1

csharp
Copy code

This ensures correct rounding to the nearest even.

### 4. Final Assembly
Final output is reconstructed using:
```verilog
out = {sign, exp_result, mantissa_rounded};
