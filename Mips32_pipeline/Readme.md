# Design of 5-stage Pipelined MIPS32 RISC Processor

## Pipelined Datapath
![image](https://github.com/user-attachments/assets/6bcc50d2-b16f-4025-8f28-02a7c1447673)

## Stages of the Pipeline

1. **Instruction Fetch (IF)**: The instruction is fetched from memory.
2. **Instruction Decode (ID)**: The fetched instruction is decoded.
3. **Execute (EX)**: The decoded instruction is executed.
4. **Memory (MEM)**: Data is read from or written to memory.
5. **Write Back (WB)**: The result of the execution is written back to the register file.

## Modules

- **Register File**: Holds the registers.
- **ALU**: Performs arithmetic and logic operations.
- **Memory**: Stores instructions and data.
- **Control Unit**: Generates control signals.
- **Forwarding Unit**: Resolves data hazards.

## Testbench for MIPS32 Processor

The testbench (`test_mips32`) tests the functionality of the 5-stage pipelined MIPS32 RISC processor.

### Clock Generation

Generates a two-phase clock signal (`clk1` and `clk2`) with a period of 10ns for each phase.

### Initial Setup

1. **Register Initialization**: Registers `Reg[0]` to `Reg[30]` are initialized with their respective indices.
2. **Memory Initialization**: Memory is loaded with a sequence of instructions including `ADDI`, `OR`, `ADD`, and `HLT`.

## Usage

To use the Verilog modules, include them in your project and instantiate them in your top-level design.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
