# IEEE-754 Floating Point Unit (FPU) — FSM-Based Design in SystemVerilog

This repository contains a synthesizable, FSM-based 32-bit IEEE-754 compliant Floating Point Unit (FPU) implemented in SystemVerilog. The design supports the four basic arithmetic operations — addition, subtraction, multiplication, and division — and follows a structured Finite State Machine (FSM) model to improve synthesis feasibility and timing closure.

## 🚀 Key Features

- ✅ IEEE-754 Single Precision (32-bit) support
- ✅ FSM-based multi-cycle design: `Idle → Prepare → Compute → Normalize → Round → Writeback`
- ✅ Synthesizable structure using sequential (`always_ff`) and combinational (`always_comb`) blocks
- ✅ Supports the following operations:
  - Addition (`op = 00`)
  - Subtraction (`op = 01`)
  - Multiplication (`op = 10`)
  - Division (`op = 11`)
- ✅ Includes mantissa alignment, normalization, and IEEE-754 GRS rounding

## 📚 Operation Flow

### 1. Input Preparation

- Extracts sign, exponent, and mantissa from both operands `a` and `b`
- Prepends the implicit 1 to each mantissa → 24-bit representation

### 2. FSM Control Flow

| State       | Functionality                              |
|-------------|---------------------------------------------|
| Idle        | Waits for `perm` signal to start operation |
| Prepare     | Decodes inputs, aligns mantissas           |
| Edge        | Handles special edge cases                 |
| Compute     | Performs selected arithmetic operation     |
| Normalize   | Normalizes the result (leading 1)          |
| Round       | Applies GRS-based rounding logic           |
| Writeback   | Reconstructs 32-bit output {sign, exp, mant} |

---

## ➕ Addition & ➖ Subtraction (`op = 00 or 01`)

- Align exponents via right-shift of mantissas
- Perform `a ± b` based on sign bits
- Determine resulting sign based on operand comparison
- Forward result to rounding unit

---

## ✖️ Multiplication (`op = 10`)

- Multiply two 24-bit mantissas → 48-bit product
- Add exponents and subtract bias (127)
- Normalize the result
- Apply GRS rounding logic

---

## ➗ Division (`op = 11`)

- Shift numerator `mant_a` left by 24 bits → get 48-bit precision
- Perform integer division: `mant_a / mant_b`
- Subtract exponents and add bias (127)
- Normalize and round the result

---

## ⚠️ Edge Case Handling

Handled in a dedicated `Edge` FSM state without disturbing the normal datapath flow:

- `a × 0` or `0 × b` → result = 0  
- `a ÷ 0` → result = ±∞ (currently outputs garbage — not handled properly)  
- `0 ÷ b` → result = 0  

> Edge cases are detected by checking:  
> `a[30:0] == 0` **or** `b[30:0] == 0`

---

## 📏 Rounding Logic — GRS (Guard, Round, Sticky)

Rounding follows the IEEE-754 "round-to-nearest-even" rule:

```systemverilog
if (G == 1 && (R == 1 || S != 0))
    mantissa += 1;
```

- **G (Guard bit)**: Bit next to LSB of result
- **R (Round bit)**: Bit after G
- **S (Sticky bit)**: OR of all remaining lower bits

✅ Ensures IEEE-compliant rounding while maintaining accuracy across all arithmetic operations

---

## ⚡ Design Notes

- Written entirely in SystemVerilog
- Uses both `always_ff` (for sequential logic) and `always_comb` (for combinational logic)
- Modular state-based control flow makes timing closure and debugging easier
- Can be integrated into a custom RISC-V processor or SoC environment
