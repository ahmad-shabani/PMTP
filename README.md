<div align="center">

# PMTP

### A MAX-SAT-Based Hardware Trojan Detection Flow Using Propagation of Maximum Transition Probability

<p>
  <img alt="Hardware Security" src="https://img.shields.io/badge/Domain-Hardware%20Security-1f6feb?style=for-the-badge">
  <img alt="Method" src="https://img.shields.io/badge/Method-Max--SAT%20%2B%20DfT-8957e5?style=for-the-badge">
  <img alt="Language" src="https://img.shields.io/badge/Language-Perl-2ea44f?style=for-the-badge">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Linux-f0b429?style=for-the-badge">
</p>

**PMTP** identifies low-transition-probability nets in a gate-level design and inserts design-for-trust logic so rare Trojan-triggering conditions become easier to activate and observe.

</div>

---

## Why PMTP?

Hardware Trojans often hide behind **rarely switching internal nets**. Standard random simulation may never activate those trigger conditions, which makes detection through logic testing or side-channel analysis difficult.

PMTP addresses this by constructing controllable transition paths from rare nets toward primary inputs. The flow formulates the insertion-point selection as a **weighted MAX-SAT problem**, then uses the solver result to modify the design with PMTP-guided test points.

In practice, PMTP is intended to help researchers and students:

- identify low-transition-probability nets in gate-level Verilog,
- generate a MAX-SAT instance for PMTP-based design modification,
- insert test-point logic to improve Trojan activation likelihood,
- inspect probability, fanout, depth, transition, and SAT-solver reports,
- reproduce the basic methodology of the PMTP paper.

---

## Repository layout

```text
PMTP/
├── README.md                         # GitHub-ready documentation
├── Readme.txt                        # Original legacy README
├── PMTP_Method.out                   # Prebuilt Linux executable
├── ClearOutputs                      # Utility binary to clean generated files
├── Example/
│   ├── config.txt                    # Example configuration
│   ├── Design.v                      # Example gate-level design
│   ├── TB_Design.v                   # Example Verilog testbench
│   ├── PMTP_Method.out               # Example copy of executable
│   └── ClearOutputs                  # Example copy of cleaner
└── Source Code/
    ├── PMTP_Method.pl
    ├── Pre-processingSAT_mode1.pl
    ├── ProbablityComputing.pl
    ├── Verilog2CNF.pl
    └── VerilogHandeling.pl
```

> Note: the original source tree uses the historical folder name `Source Code` and historical filenames such as `ProbablityComputing.pl` and `VerilogHandeling.pl`. They are preserved to avoid breaking the original flow.

---

## Requirements

The original tool was developed and tested on **Ubuntu 16.04** using Perl and external EDA/SAT tools. Newer Linux distributions may work, but the prebuilt binary may require compatibility fixes.

### Required tools

| Tool | Purpose |
|---|---|
| Linux, preferably Ubuntu-compatible | Runtime environment |
| Perl | Source-code execution and scripting |
| ModelSim / QuestaSim | Gate-level simulation and VCD generation |
| `vcd2saif` | VCD-to-SAIF conversion for transition extraction |
| Open-WBO | Weighted MAX-SAT solving |

### Install Open-WBO

PMTP expects the Open-WBO executable to be available from your shell path.

```bash
git clone https://github.com/sat-group/open-wbo.git
cd open-wbo
make
```

Then add the generated executable directory to your `PATH`, for example:

```bash
export PATH=$PATH:/path/to/open-wbo
```

### Check required commands

Before running PMTP, make sure these commands are visible:

```bash
which vsim
which vcd2saif
which open-wbo
```

Depending on your Open-WBO build, the solver executable name may differ. If your binary has another name, create an alias or symbolic link expected by your local PMTP setup.

---

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/<your-user>/PMTP.git
cd PMTP
```

### 2. Make binaries executable

```bash
chmod +x PMTP_Method.out ClearOutputs
chmod +x Example/PMTP_Method.out Example/ClearOutputs
```

### 3. Run the included example

```bash
cd Example
./PMTP_Method.out
```

If your local flow expects the executable name `PMTP_Method`, you can create a symbolic link:

```bash
ln -s PMTP_Method.out PMTP_Method
./PMTP_Method
```

### 4. Clean generated outputs

```bash
./ClearOutputs
```

---

## Configuration file

PMTP reads its settings from `config.txt` in the working directory.

Example:

```text
Design_Name=Design.v
Test_Bench=TB_Design.v
Probability_Threshold=0.003
NumOfTest=1000
CycleTime=5
```

| Field | Meaning |
|---|---|
| `Design_Name` | Gate-level Verilog netlist under analysis |
| `Test_Bench` | Verilog testbench used to simulate the design |
| `Probability_Threshold` | Transition-probability threshold used to identify low-activity nets |
| `NumOfTest` | Number of test vectors used in simulation |
| `CycleTime` | Clock/test-vector period in nanoseconds |

### Choosing `Probability_Threshold`

A smaller threshold selects fewer, rarer nets. A larger threshold selects more candidate nets and may increase the number of insertion points and SAT constraints. Start with the example value and tune it based on the size and switching profile of your benchmark.

---

## How PMTP works

The PMTP flow follows this high-level pipeline:

```text
Gate-level Verilog + Testbench
        │
        ▼
ModelSim simulation
        │
        ▼
VCD generation
        │
        ▼
SAIF transition extraction
        │
        ▼
Low-transition net identification
        │
        ▼
PMTP rule and conflict analysis
        │
        ▼
CNF/WCNF generation
        │
        ▼
Open-WBO MAX-SAT solving
        │
        ▼
Modified design with insertion points
```

The central idea is not only to increase the transition probability of isolated rare nets, but also to propagate maximum transition probability through a valid path while resolving conflicts imposed by gate-level logic.

---

## Generated outputs

After a successful run, PMTP may generate the following files in the working directory:

| Output | Description |
|---|---|
| `Design_sec.v` | Modified gate-level netlist after PMTP insertion |
| `InfoGate.out` / `InfoGate.txt` | Net-level information: probability, depth, gate type, fanins, transition count, `T0`, `T1`, and transition rate |
| `SATSolver.txt` | MAX-SAT solver result |
| `Probablity.out` | Transition-probability information for circuit nets |
| `fanout.out` | Fanout information for circuit nets |
| `script.do` | ModelSim script generated by PMTP |
| `Design.map` | Mapping between circuit nets and integer SAT variables |
| `Design.vcd` | Value-change dump generated by simulation |
| `Design_bw.saif` | Backward SAIF file containing transition information |
| `Design.cnf` | CNF representation of circuit logic |
| `Design.wcnf` | Weighted CNF / partial MAX-SAT instance |

---

## Using PMTP with your own benchmark

1. Put your gate-level Verilog netlist in the working directory.
2. Add a compatible Verilog testbench.
3. Ensure the testbench dumps switching activity to `Design.vcd` or update the scripts accordingly.
4. Edit `config.txt`.
5. Run `./PMTP_Method.out`.
6. Inspect `InfoGate.out`, `Probablity.out`, `Design.wcnf`, `SATSolver.txt`, and `Design_sec.v`.
7. Re-simulate the modified design and compare Trojan activation or side-channel sensitivity against the original design.

### Expected input style

The parser is designed for simple gate-level Verilog netlists. For best compatibility:

- use flattened gate-level Verilog,
- avoid unsupported SystemVerilog constructs,
- keep module, input, output, wire, and gate-instantiation syntax simple,
- verify that primitive gate names match the supported patterns in the Perl source,
- keep the testbench module name consistent with the generated ModelSim script.

---

## Troubleshooting

### `Permission denied`

Run:

```bash
chmod +x PMTP_Method.out ClearOutputs
```

### `vsim: command not found`

ModelSim/QuestaSim is not in your `PATH`. Source your simulator setup script or add the simulator binary directory to `PATH`.

### `vcd2saif: command not found`

Make sure your EDA environment provides `vcd2saif` and that it is visible in the shell used to launch PMTP.

### Open-WBO is installed but PMTP cannot find it

Check the exact executable name generated by your Open-WBO build and add it to `PATH`. If needed, create a symbolic link with the name expected by the script.

### The binary does not run on a modern Linux distribution

The included `.out` executable is an old x86-64 Linux binary. Try one of these options:

```bash
# Option 1: run the Perl source directly from the source folder setup
perl "Source Code/PMTP_Method.pl"

# Option 2: use an Ubuntu 16.04/18.04 container or VM
# Option 3: rebuild/repackage the Perl scripts with your preferred Perl toolchain
```

### Perl reports missing `Switch.pm`

Some modern Perl installations no longer include the legacy `Switch` module by default. Install it with CPAN:

```bash
cpan Switch
```

or, on some distributions:

```bash
sudo apt-get install libswitch-perl
```

---

## Citation

If you use PMTP in academic work, please cite the original paper:

```bibtex
@article{shabani2020pmtp,
  author  = {Ahmad Shabani and Bijan Alizadeh},
  title   = {{PMTP}: A {MAX-SAT}-Based Approach to Detect Hardware Trojan Using Propagation of Maximum Transition Probability},
  journal = {IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems},
  volume  = {39},
  number  = {1},
  pages   = {25--33},
  year    = {2020},
  doi     = {10.1109/TCAD.2018.2889663}
}
```

Related papers by the authors:

```bibtex
@article{shabani2020podem,
  author  = {Ahmad Shabani and Bijan Alizadeh},
  title   = {{PODEM}: A Low-Cost Property-Based Design Modification for Detecting Hardware Trojans in Resource-Constraint {IoT} Devices},
  journal = {Journal of Network and Computer Applications},
  volume  = {167},
  pages   = {102713},
  year    = {2020},
  doi     = {10.1016/j.jnca.2020.102713}
}

@article{shabani2021shuffling,
  author  = {Ahmad Shabani and Bijan Alizadeh},
  title   = {Enhancing Hardware Trojan Detection Sensitivity Using Partition-Based Shuffling Scheme},
  journal = {IEEE Transactions on Circuits and Systems II: Express Briefs},
  volume  = {68},
  number  = {1},
  pages   = {266--270},
  year    = {2021},
  doi     = {10.1109/TCSII.2020.3001263}
}
```

---

## Recommended GitHub repository description

> PMTP: a MAX-SAT-based design-for-trust tool for improving hardware Trojan activation and detection by propagating maximum transition probability through gate-level circuits.

Suggested GitHub topics:

```text
hardware-security hardware-trojan maxsat design-for-trust eda gate-level-verilog verilog perl open-wbo trojan-detection side-channel-analysis
```

---

## Notes for maintainers

Before making the repository public, consider adding:

- a license file,
- a Dockerfile for reproducible execution,
- a tested modern installation guide,
- a small CI check for README links and script syntax,
- benchmark examples with expected output summaries,
- a cleaned source-code directory name such as `src/` while preserving the legacy archive.

---

## Authors

**Ahmad Shabani** and **Bijan Alizadeh**  
University of Tehran, Tehran, Iran

Original project contact:

- `ah.shabani@ut.ac.ir`
- `ahmadshabani89@gmail.com`
