# AI Use Statement

I used AI assistance in a limited and appropriate manner for this assignment.

## How AI was used
- To clarify how RISC-V instruction fields are laid out (opcode, rd, rs1, rs2, funct3, funct7).
- To understand how different RISC-V immediate formats (I, S, B, U, J) are constructed and sign-extended.
- To learn correct SystemVerilog syntax and patterns for:
  - Bit slicing using continuous `assign` statements
  - Writing `always_comb` blocks
  - Using `$signed()` for sign extension
- To help generate and refine a **test assembly program (`mytest.S`)** that exercises many RV32I instructions for decode verification.

## How AI was NOT used
- AI did not generate the full decode logic solution without understanding.
- AI was not asked to directly complete or submit the assignment on my behalf.
- AI was not used to bypass learning objectives or to automatically produce a finished `cpu.sv` file without review and modification.

## Example prompts used
- “What are the bit positions for RISC-V instruction fields and immediates?”
- “How do I sign-extend immediates in SystemVerilog?”
- “What instructions should a test RV32I assembly program include to exercise decode logic?”

All final code was reviewed, understood, and integrated by me.
