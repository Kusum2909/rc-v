# P26 ALU operand selector - dossier

Answer in your own words; short answers are fine. Diagrams can be photos of
hand drawings (put them next to this file and link them).

## U1 Digital logic
a_zero    asel_pc     a(output) 
0           0           rs1
0           1           pc
1           0           0
1           1           0
boolean expression:
a(i)=(a_zero)'•((asel_pc)'•rs1(i) + asel_pc•pc(i)) 
b(i)=(bsel_imm)'•rs2(i) + bsel_imm•imm(i) 
Gates and flip flops are needed because this is purely combinational block it uses zero flip flops , at gate level each bit requires and, Or and Not gate. 


## U2 Digital components
•Three 4 bit 2×1 Multiplexers used, No adders, decoders and memory elements used. 
Connection:
•MUX1(pc vs rs1) =rs1 connects to input 0, pc connects to input 1 and asel_pc drives select line. 
MUX2(LUI zero override) =Output of MUX1 connects to input 0, constant 0 connects to input 1 and a_zero drives select line. 
MUX3(Operand B) =rs2 connects to input 0, imm connects to input 1 and bsel_imm drives select line. 

## U3 Data representation

In which step of the instruction cycle (fetch, decode, execute, memory,
write-back, interrupt) does your block do its work? Which instructions Three Test Vectors:**
  1. **R-type (`SUB`):** `a_zero=0, asel_pc=0, bsel_imm=0`, `rs1 = 0x0000000A` (`0000...1010`₂, `10`₁₀), `rs2 = 0x00000003` (`0000...0011`₂, `3`₁₀) -> `a = 0x0000000A` (`10`), `b = 0x00000003` (`3`).
  2. **Negative `ADDI`:** `a_zero=0, asel_pc=0, bsel_imm=1`, `rs1 = 0x00000100` (`256`₁₀), `imm = 0xFFFFFEF0` (`1111...1110_1111_0000`₂, `-272`₁₀ signed) -> `a = 0x00000100`, `b = 0xFFFFFEF0` (`-272`).
  3. **`LUI`:** `a_zero=1, asel_pc=0, bsel_imm=1`, `pc = 0x00000014` (`20`₁₀), `imm = 0xDEADC000` -> `a = 0x00000000` (`0`), `b = 0xDEADC000`.
* **Where overflow/sign extension could go wrong:** The muxes only route bits, so they cannot overflow. However, if the Immediate Generator zero-extends a negative 12-bit offset instead of sign-extending it, `b` passes the wrong positive number to the ALU. Also, when building constants with `LUI + ADDI`, forgetting to add `+1` to the `LUI` upper 20 bits when bit 11 is `1` causes an off-by-`0x1000` error.
# U4 Computer Organisation
Instruction cycle step:** **Execute** stage (between Register Read and the ALU).
* **Instructions that need it:** Almost all instructions:
  * **R-type (`ADD`, `SUB`, etc.):** `a = rs1`, `b = rs2`
  * **I-type ALU, Loads, Stores, `JALR`:** `a = rs1`, `b = imm`
  * **`AUIPC`, Branches, `JAL`:** `a = pc`, `b = imm`
  * **`LUI`:** `a = 0`, `b = imm`


## U5 Processors
How would a CISC processor, a stack machine or a GPU do the job of your
block differently? (Look at the RISC-V vs Mano comparison in docs/ARCHITECTURE.md.)
answer:
* **CISC (e.g., Mano's basic computer):** Uses complex memory addressing modes and multi-cycle microprogrammed steps with temporary registers (`AR`, `DR`, `AC`) instead of single-cycle register/immediate muxes.
* **Stack machine:** Has no `rs1`/`rs2` or immediate muxes; operands are implicitly popped from the top two stack slots directly into the ALU.
* **GPU:** Runs thousands of threads in lockstep (SIMT) using wide vector register files, operand collectors, and lane masks instead of a single scalar mux pair.


## U6 Memory and I/O
How does your block take part in a memory access or an I/O transfer? If it
does not, explain which neighbouring block does and how data reaches it.
Answer:
**Memory/I/O role:** Does not connect directly to RAM or I/O. During Loads, Stores, and memory-mapped I/O, it routes `a = rs1` (base) and `b = imm` (offset) into the **ALU**, which computes the effective address sent to the **Data Memory / I/O bus**.


## E1 Instruction trace: SUB
Trace one **SUB** instruction through the whole RC-V processor,
block by block (use docs/ARCHITECTURE.md and the simulator's --trace output).
List the blocks it passes through and the value on the main signals.
Answer:
Trace for `sub x5, x6, x7` (`0x407302B3`) at `PC = 0x00000000` with `x6 = 10` (`0xA`) and `x7 = 3` (`0x3`):

1. **PC:** Outputs `0x00000000`.
2. **IMEM:** Fetches `0x407302B3` (`rs1=6`, `rs2=7`, `rd=5`).
3. **Control Unit:** Sets `a_zero=0`, `asel_pc=0`, `bsel_imm=0`, `alu_op=SUB`, `mem_read=0`, `mem_write=0`, `wb_sel=ALU`, `reg_write=1`.
4. **Register File:** Outputs `rs1 = 0x0000000A`, `rs2 = 0x00000003`.
5. **P26 (`p26_opab_mux`):** Outputs `a = 0x0000000A` and `b = 0x00000003`.
6. **ALU:** Computes `10 - 3 = 0x00000007`.
7. **DMEM:** Idle (`mem_read=0`, `mem_write=0`).
8. **Write-Back (P25) & RegFile:** Writes `0x00000007` into `x5`.
9. **Next-PC (P15):** Updates `PC` to `0x00000004`.


## E2 Neighbour review
Review the pull requests of P25 (Write-back selector) and P15 (Next-PC selector). Paste the links to your review
comments here.
***

* **P25 (Write-back selector):** TODO - paste PR review comment link
* **P15 (Next-PC selector):** TODO - paste PR review comment link

## E3 Where my block sits
In two or three sentences: which layer of the computer is your block in
(gates / components / datapath / control / instruction set / memory / I/O),
which blocks feed it and which blocks use its output?
Answer:
My block sits in the **datapath** layer (built from **combinational multiplexer components**) in the Execute stage. It receives data from the **Register File** (`rs1`, `rs2`), **PC** (`pc`), and **Immediate Generator** (`imm`), plus control signals (`a_zero`, `asel_pc`, `bsel_imm`) from the **Control Unit**, and sends operands `a` and `b` directly into the **ALU**.


## E4 Syllabus map
Tick every syllabus topic your work touched (main units: Unit 4, Unit 5).

- [*] Logic gates, Boolean algebra, K-maps
- [*] Combinational circuits (adders, decoders, encoders, multiplexers)
- [ ] Flip-flops, registers, counters
- [ ] Memory (RAM, ROM)
- [*] Number systems, complements, signed arithmetic
- [*] Bus organisation, instruction codes and formats
- [*] Instruction cycle, hardwired vs microprogrammed control
- [ ] Interrupts and the interrupt cycle
- [ ] Pipelining
- [*] Register organisation, stack, addressing modes
- [*] RISC vs CISC, multicore, GPU
- [ ] Memory hierarchy, cache
- [ ] I/O interface, programmed / interrupt-driven I/O, DMA
