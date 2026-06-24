# Simple GPIO Custom Peripheral for PicoSoC

A lightweight, memory-mapped General Purpose Input/Output (GPIO) peripheral designed for the PicoSoC framework. 

To minimize hardware footprint and maintain simplicity, the pin directions are fixed at compile-time, making it ideal for standard interface tasks without the overhead of runtime direction configuration.

## Features

* **8 Total GPIO Pins:** Configured statically as 4 inputs and 4 outputs.
* **Fixed Direction:** Eliminates dynamic direction control registers to minimize logic gate overhead.
* **Memory-Mapped Interface:** Unified control through a single 32-bit register.
* **Scalable Architecture:** Easily adjust the input-to-output pin ratio within the hardware description code.
* **System Base Address:** Assigned to `0x04000000`.

---

# Memory Map

| Address      | Access     | Bits     | Description                   |
| ------------ | ---------- | -------- | ----------------------------- |
| `0x04000000` | Read/Write | `[7:4]`  | Output GPIO pins (`gpio_out`) |
| `0x04000000` | Read-Only  | `[3:0]`  | Input GPIO pins (`gpio_in`)   |
| `0x04000000` | Reserved   | `[31:8]` | Always reads as `0`           |


### Notes

* Writing to bits `[7:4]` updates the output pins.
* Bits `[3:0]` always reflect the live state of the input pins.
* Writes to bits `[3:0]` are ignored by hardware.
* Reserved bits `[31:8]` return `0` when read.

---

# Repository Setup

Clone the PicoRV32 repository:

```bash
git clone https://github.com/YosysHQ/picorv32.git
cd picorv32
```

Place your ```simplegpio.v``` source file inside the PicoSoC environment subfolder:

```text
picorv32/
└── picosoc/
    └── simplegpio.v
```

---

# PicoSoC Integration

## 1. Add GPIO Ports

Modify the `picosoc` module declaration:

```verilog
module picosoc (
    // Existing ports...

    input  [3:0] gpio_in,
    output [3:0] gpio_out
);
```

---

## 2. Peripheral Instantiation

Instantiate the GPIO peripheral inside `picosoc.v`:

```verilog
simplegpio u_simplegpio (
    .clk         (clk),
    .resetn      (resetn),

    .iomem_valid (gpio_iomem_valid),
    .iomem_ready (gpio_iomem_ready),
    .iomem_wstrb (iomem_wstrb),
    .iomem_addr  (iomem_addr),
    .iomem_wdata (iomem_wdata),
    .iomem_rdata (gpio_iomem_rdata),

    .gpio_out    (gpio_out),
    .gpio_in     (gpio_in)
);
```

---
# Board-Level integration
---

### HX8K Demo Board Pin Mapping Details

To map the GPIO lines to the physical hardware pins on the Lattice iCE40-HX8K Breakout Board, you must declare them in your Pin Constraint File (`hx8kdemo.pcf`) and connect them through the top wrapper (`hx8kdemo.v`).

1. Append the pin allocations to `hx8kdemo.pcf` (Example using Header J3 pins):

   ```
   set_io gpio_in[0]  B10
   set_io gpio_in[1]  B11
   set_io gpio_in[2]  A10
   set_io gpio_in[3]  A11
   set_io gpio_out[0] B14
   set_io gpio_out[1] C14
   set_io gpio_out[2] B15
   set_io gpio_out[3] C15
   ```

2. Add the ports to the `hx8kdemo.v` top module declaration:

   ```
   input [3:0] gpio_in,
   output [3:0] gpio_out,
   ```

3. Pass them into the `picosoc` instance inside `hx8kdemo.v`:

   ```
   picosoc soc (
       // ... existing connections ...
       .gpio_in  (gpio_in ),
       .gpio_out (gpio_out)
   );
   ```

---

### Icebreaker Board Pin Mapping Details

For the iCE40UP5K Icebreaker board, the easiest way to expose these pins is by mapping them to the onboard unpopulated PMOD connectors (like `PMOD1A` or `PMOD1B`) via the `icebreaker.pcf` file.

1. Append the pin allocations to `icebreaker.pcf` (Example using PMOD1A):

   ```
   set_io gpio_in[0]  4   # PMOD1A_PIN1
   set_io gpio_in[1]  2   # PMOD1A_PIN2
   set_io gpio_in[2]  47  # PMOD1A_PIN3
   set_io gpio_in[3]  45  # PMOD1A_PIN4
   set_io gpio_out[0] 3   # PMOD1A_PIN7
   set_io gpio_out[1] 48  # PMOD1A_PIN8
   set_io gpio_out[2] 46  # PMOD1A_PIN9
   set_io gpio_out[3] 44  # PMOD1A_PIN10
   ```

2. Add the ports to the `icebreaker.v` top module declaration:

   ```
   input [3:0] gpio_in,
   output [3:0] gpio_out,
   ```

3. Pass them into the `picosoc` instance inside `icebreaker.v`:

   ```
   picosoc soc (
       // ... existing connections ...
       .gpio_in  (gpio_in ),
       .gpio_out (gpio_out)
   );
   ```

---

# Build System Integration

Update your board simulation target rules within the respective directory Makefile to recognize ```simplegpio.v``` as a dependency.
> ⚠️ Note to Developers: Compilation lines inside Makefiles require a true literal Tab character indentation prefix. Ensure your code editor doesn't accidentally convert tabs to spaces.

## HX8K Makefile

```make
hx8kdemo_tb.vvp: \
	hx8kdemo_tb.v \
	hx8kdemo.v \
	spimemio.v \
	simpleuart.v \
	picosoc.v \
	../picorv32.v \
	spiflash.v \
	simplegpio.v
	iverilog -s testbench -o $@ $^ `yosys-config --datadir/ice40/cells_sim.v` -DNO_ICE40_DEFAULT_ASSIGNMENTS
```

---

## Icebreaker Makefile

```make
icebreaker_tb.vvp: \
	icebreaker_tb.v \
	icebreaker.v \
	ice40up5k_spram.v \
	spimemio.v \
	simpleuart.v \
	picosoc.v \
	../picorv32.v \
	spiflash.v \
	simplegpio.v
	iverilog -s testbench -o $@ $^ `yosys-config --datadir/ice40/cells_sim.v` -DNO_ICE40_DEFAULT_ASSIGNMENTS
```

---

# Verification

Clean previous build artifacts:

```bash
make clean
```

### HX8K Simulation

```bash
make hx8ksim
```

### Icebreaker Simulation

```bash
make icebsim
```

# Firmware Implementation

A complete, practical implementation example demonstrating volatile register mapping, C-pointer addressing, bitwise operations, and real-time pin cross-mirroring is provided in the ```firmware.c``` file located in this directory.
