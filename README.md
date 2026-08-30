# SPI-PROTOCOL
Designing an SPI bus from scratch in SystemVerilog to master CPOL/CPHA timing, multi-slave tri-state routing, and register-transfer protocol verification.

## Overview

This project implements an SPI (Serial Peripheral Interface) communication system using SystemVerilog.

The design consists of:

* 1 SPI Master
* 4 SPI Slaves
* MOSI — Master Out Slave In
* MISO — Master In Slave Out
* SCLK — SPI clock
* 4 Slave Select signals
* Mode selection using `s0` and `s1`
* 8-bit data transmission and reception

The main purpose of this project is to understand how an SPI master communicates with multiple slaves and how the four SPI modes affect the clock and data transfer.

The design was simulated in Vivado using a SystemVerilog testbench.

---

## SPI Architecture

The master communicates with four slaves using a common `MOSI`, `MISO`, and `SCLK` line.

The master generates four separate slave-select signals:

* `ss1` → Slave 1
* `ss2` → Slave 2
* `ss3` → Slave 3
* `ss4` → Slave 4

Only the selected slave drives the `MISO` line. The other slaves keep their `MISO` output at high impedance (`Z`).

This allows multiple slaves to share the same SPI bus.

---

## Block-Level Working

The basic connection is:

Master → MOSI → All Slaves

Master ← MISO ← Selected Slave

Master → SCLK → All Slaves

Master → SS1 → Slave 1

Master → SS2 → Slave 2

Master → SS3 → Slave 3

Master → SS4 → Slave 4

The master decides which slave is active using `ss_in_0` and `ss_in_1`.

---

## Slave Selection

Two input signals are used to select one of the four slaves.

| `ss_in_0` | `ss_in_1` | Selected Slave |
| --------- | --------- | -------------- |
| 0         | 0         | Slave 1        |
| 0         | 1         | Slave 2        |
| 1         | 0         | Slave 3        |
| 1         | 1         | Slave 4        |

For example, if:

`ss_in_0 = 1`

`ss_in_1 = 0`

then:

`ss3 = 1`

and the master communicates with Slave 3.

---

## SPI Modes

The design supports all four standard SPI modes.

The mode is selected using `s0` and `s1`.

| Mode    | `s0` | `s1` | CPOL | CPHA |
| ------- | ---: | ---: | ---: | ---: |
| Mode 00 |    0 |    0 |    0 |    0 |
| Mode 01 |    0 |    1 |    0 |    1 |
| Mode 10 |    1 |    0 |    1 |    0 |
| Mode 11 |    1 |    1 |    1 |    1 |

### Mode 00

* CPOL = 0
* CPHA = 0
* Clock is normally LOW.
* Data transfer is performed with the corresponding leading edge and sampling behavior of Mode 00.

### Mode 01

* CPOL = 0
* CPHA = 1
* The first edge is used for data preparation.
* The following edge is used for data sampling.

### Mode 10

* CPOL = 1
* CPHA = 0
* Clock is normally HIGH.
* The leading edge is the falling edge.

### Mode 11

* CPOL = 1
* CPHA = 1
* Data changes and is sampled on the appropriate edges according to CPHA = 1 behavior.

---

## Master

The `spi_master` module is responsible for:

* Generating the SPI clock.
* Generating MOSI data.
* Receiving data through MISO.
* Selecting one of the four slaves.
* Handling all four SPI modes.
* Shifting transmitted and received data.
* Indicating the completion of a transaction using `done`.

The master contains an internal clock:

`clk_in`

which is used to generate the SPI clock.

The SPI clock is generated using:

`assign sclk = (s0) ? ~clk_in : clk_in;`

Therefore, `s0` controls the clock polarity.

---

## Data Transmission

The design uses an 8-bit shift register called:

`data_register`

The transmitted data is loaded into this register from:

`din`

The most significant bit is placed on MOSI first.

For example, if:

`din = A1`

the binary data is:

`10100001`

The first transmitted bit is:

`1`

The register is then shifted and the next bit is transmitted.

This continues until all 8 bits have been transferred.

---

## Data Reception

At the same time that the master sends data through MOSI, it receives data through MISO.

The received bit is inserted into the shift register after each appropriate clock edge.

After all 8 bits have been received:

`dout = data_register`

and:

`done = 1`

This means that SPI communication is full-duplex: transmission and reception happen at the same time.

---

## Slave Operation

Each `spi_slave` module receives:

* `MOSI`
* `SCLK`
* `SS`
* `din`
* `s0`
* `s1`

and produces:

* `MISO`
* `dout`
* `done`

When the slave is not selected:

`miso = 1'bz`

This is important because all four slaves are connected to the same MISO line.

Only the selected slave is allowed to drive that line.

---

## Why High Impedance (`Z`) Is Used

The four slaves share the same MISO connection.

If all four slaves drove MISO at the same time, there would be bus contention.

Therefore:

* Selected slave → drives MISO
* Unselected slaves → `Z`

For example, when Slave 2 is selected:

Slave 1 → MISO = Z

Slave 2 → MISO = data

Slave 3 → MISO = Z

Slave 4 → MISO = Z

This allows the master to receive only the selected slave's response.

---

## Testbench

The testbench connects one master with four slaves.

The following data values are assigned to the slaves:

* Slave 1 → `8'h11`
* Slave 2 → `8'h22`
* Slave 3 → `8'h33`
* Slave 4 → `8'h44`

The master sends different data values for every test.

The testbench checks:

1. All four SPI modes.
2. All four slaves.
3. Master transmission.
4. Master reception.
5. Slave reception.
6. Slave selection.
7. Transaction completion.

This results in:

4 SPI modes × 4 slaves = 16 test cases

---

## Simulation Results

All 16 test cases were successfully completed.

### Slave 1

Mode 00:

Master TX = `A1`

Master RX = `11`

Slave 1 RX = `A1`

Mode 01:

Master TX = `A2`

Master RX = `11`

Slave 1 RX = `A2`

Mode 10:

Master TX = `A3`

Master RX = `11`

Slave 1 RX = `A3`

Mode 11:

Master TX = `A4`

Master RX = `11`

Slave 1 RX = `A4`

---

### Slave 2

Mode 00:

Master TX = `B1`

Master RX = `22`

Slave 2 RX = `B1`

Mode 01:

Master TX = `B2`

Master RX = `22`

Slave 2 RX = `B2`

Mode 10:

Master TX = `B3`

Master RX = `22`

Slave 2 RX = `B3`

Mode 11:

Master TX = `B4`

Master RX = `22`

Slave 2 RX = `B4`

---

### Slave 3

Mode 00:

Master TX = `C1`

Master RX = `33`

Slave 3 RX = `C1`

Mode 01:

Master TX = `C2`

Master RX = `33`

Slave 3 RX = `C2`

Mode 10:

Master TX = `C3`

Master RX = `33`

Slave 3 RX = `C3`

Mode 11:

Master TX = `C4`

Master RX = `33`

Slave 3 RX = `C4`

---

### Slave 4

Mode 00:

Master TX = `D1`

Master RX = `44`

Slave 4 RX = `D1`

Mode 01:

Master TX = `D2`

Master RX = `44`

Slave 4 RX = `D2`

Mode 10:

Master TX = `D3`

Master RX = `44`

Slave 4 RX = `D3`

Mode 11:

Master TX = `D4`

Master RX = `44`

Slave 4 RX = `D4`

---

## Final Simulation Result

The simulation produced the expected results for all combinations of:

* 4 SPI modes
* 4 slave devices

Total:

**16/16 test cases completed successfully**

The received data from each slave also confirms that the correct slave was selected.

| Slave   | Data Returned to Master |
| ------- | ----------------------- |
| Slave 1 | `11`                    |
| Slave 2 | `22`                    |
| Slave 3 | `33`                    |
| Slave 4 | `44`                    |

The data received by the slaves also matched the data transmitted by the master.

---

## Waveform

## Simulation Waveform

The waveform shows the complete SPI communication between the master and four slave devices.

![Complete SPI Waveform](images/waveform_1.jpeg)


### Waveform Explanation

The simulation covers all four SPI modes and all four slave devices.

- 0–100 ns: Slave 1 is selected. Modes 00, 01, 10 and 11 are tested using data a1, a2, a3 and a4.
- 100–200 ns: Slave 2 is selected. Modes 00, 01, 10 and 11 are tested using data b1, b2, b3 and b4.
- 200–300 ns: Slave 3 is selected. Modes 00, 01, 10 and 11 are tested using data c1, c2, c3 and c4.
- 300–400 ns: Slave 4 is selected. Modes 00, 01, 10 and 11 are tested using data d1, d2, d3 and d4.

The master receives 11 from Slave 1, 22 from Slave 2, 33 from Slave 3 and 44 from Slave 4.

The done signal indicates the completion of each 8-bit SPI transaction.

## Project Structure

The project contains:

* `spi_master.sv` — SPI master implementation
* `spi_slave.sv` — SPI slave implementation
* `spi_tb.sv` — SystemVerilog testbench
* Simulation waveform — Used to verify the SPI transactions

---

## Tools Used

* SystemVerilog
* Xilinx Vivado
* Vivado Simulator

---

## What This Project Demonstrates

This project helped verify the following SPI concepts:

* SPI master-slave communication
* Full-duplex serial communication
* MOSI and MISO operation
* SPI clock generation
* CPOL and CPHA
* All four SPI modes
* Multiple slave devices
* Slave-select decoding
* Shift-register based data transfer
* High-impedance MISO for unselected slaves
* SystemVerilog tasks
* SystemVerilog testbench development
* Waveform-based verification

---

## Verification Summary

The testbench was designed to cover every combination of slave and SPI mode:

**4 slaves × 4 modes = 16 transactions**

Every transaction successfully showed:

**Master TX → Slave RX**

and

**Slave TX → Master RX**

The final simulation confirmed that the master, slave, slave-selection logic, SPI modes, and data transfer were working together as intended.

---

## Result

**ALL 16 SPI TESTS COMPLETED SUCCESSFULLY**

The project successfully demonstrates an 8-bit SPI master communicating with four SPI slaves while supporting all four standard SPI modes.
