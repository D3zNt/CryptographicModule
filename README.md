# CryptographicModule

A final project for Digital Design Circuit.
Created by: Nicolas, Fatih, Yohana, Rafael

This project implements a simplified AES-128 encryption module in VHDL. It is designed as part of the final assignment for the Digital Design course, focusing on building a working RTL hardware design of a cryptographic algorithm.

## Features
- AES-128 encryption core
- Fully synchronous design (clock + reset)
- Modular architecture (SubBytes, ShiftRows, MixColumns, KeyExpansion, etc.)
- Top-level `aes_top` wrapper for easy integration
- Testbench included

## Project Structure
```
/Final Code
  ├── /src
        ├── top_level.vhd
        ├── addroundkey.vhd
        ├── shiftrows.vhd
        ├── mixcolumns.vhd
        ├── key_expansion.vhd
        ├── sbox_comb.vhd
        └── utils.vhd
  └── /tb
        └── aes_tb.vhd

/Waveform_and_Synthesis
  ├── Waveform output.jpeg
  └── schematic.sch

Report.pdf
Presentation.pdf
README.md
```

## How It Works (High-Level)

### Input
- 128-bit plaintext
- 128-bit key
- `start` signal triggers encryption

### Top-Level (`top_level`) Responsibilities
- Loading inputs
- Running 10 AES rounds
- Generating round keys
- Producing a 128-bit ciphertext
- Raising `done` when encryption is complete

### Output
- `ciphertext` (128-bit)

## Simulation / Testing
Run the testbench using your preferred simulator or Vivado(Recommended):

```
vsim work.aes_top_tb
run -all
```

Expected output: ciphertext matches the NIST AES test vectors.

## Importing .sch Files in Vivado
To import a schematic file into a Vivado project:
- Open Vivado and load your project.
- In the top menu, navigate to:
File → Import → Schematic
- Browse to your .sch file and select it.
- Click OK to complete the import.
