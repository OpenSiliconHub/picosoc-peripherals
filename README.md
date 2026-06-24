<pre align="center">
 ██████╗ ███████╗██╗  ██╗
██╔═══██╗██╔════╝██║  ██║
██║   ██║███████╗███████║
██║   ██║╚════██║██╔══██║
╚██████╔╝███████║██║  ██║
 ╚═════╝ ╚══════╝╚═╝  ╚═╝
 
OSH-PICOSOC-PERIPHERALS
</pre>

Welcome to the **picosoc-peripherals** repository, a modular library of plug-and-play IP blocks managed by the **OpenSiliconHub** organization. 

Our initiative provides clean, verified hardware peripherals that anyone can easily integrate into the PicoRV32/PicoSoC framework without deep architectural knowledge.

## Our Design Philosophy

* **Zero Core Modifications:** We utilize PicoSoC's native external Memory-Mapped I/O (MMIO) expansion interface (`iomem_*`). This allows you to add peripherals seamlessly without modifying the core CPU or internal system buses.
* **Plug-and-Play Integration:** Peripherals connect directly to the external bus lines, minimizing hardware overhead and keeping the core SoC clean.
* **Firmware-Included:** Every IP block comes bundled with bare-metal C firmware examples and simulation test setups located right inside its folder.
* **Existing Verification Support:** Peripherals can be verified using the standard verification flow already provided by the PicoRV32/PicoSoC repository.

---

## Repository Structure

Each peripheral is completely isolated in its own folder containing its RTL code, firmware driver, and a dedicated integration guide:

```text
picosoc-peripherals/
├── README.md               # This master repository guide
└── simplegpio/             # Static 4-In / 4-Out GPIO Block
    ├── simplegpio.v        # Verilog RTL source
    ├── firmware.c          # C validation example
    └── README.md           # Dedicated integration guide
```

## Supported IP Blocks

| IP Block    | Base Address  | Description                                          | Documentation | Status   |
| ----------- | ------------- | ---------------------------------------------------- | ------------- | -------- |
| Simple GPIO | `0x0400_0000` | 4 Static Inputs / 4 Static Outputs (Single Register) | View Guide    | Verified |

## General Integration Steps

To add any peripheral from this repository to your PicoSoC project, follow these simple steps:

1. **Deploy the File:** Copy the peripheral's `.v` file into your `picorv32/picosoc/` folder.
2. **Update the SoC Ports:** Expose the external physical pins in your `picosoc.v` port declaration and instantiate the peripheral module.
3. **Bind Physical Pins:** Map the new pins out through your board's top wrapper (e.g., `hx8kdemo.v` or `icebreaker.v`) and define their hardware constraints in your `.pcf` file.
4. **Compile and Simulate:** Append the new `.v` file as a dependency in your platform's `Makefile`, run `make clean`, and launch your simulation via `make hx8ksim` or `make icebsim`.

For exact, copy-pasteable Verilog ports, pin mapping rules, and Makefile scripts, please navigate directly into the folder of the peripheral you want to use.
