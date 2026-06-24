 //========================================================================
 // OpenSiliconHub
 // =======================================================================
 // Module: simplegpio
 // Description: Dual-register Memory-Mapped I/O (MMIO) GPIO controller
 // for the PicoRV32/PicoSoC architecture.
 //
 // Registers:
 //  0x0400_0000 - GPIO_A_OUT [Read/Write] (8-bit output latch for LEDs)
 //  0x0400_0004 - GPIO_A_IN  [Read-Only]  (8-bit live input for Switches)
 // =======================================================================


module simplegpio (
	input clk,
	input resetn,

	// Native picosoc iomem bus interface
	input          iomem_valid,
	output         iomem_ready,
	input  [3:0]   iomem_wstrb,
	input  [31:0]  iomem_addr,
	input  [31:0]  iomem_wdata,
	output [31:0]  iomem_rdata,

	// Physical IO Pins
	output reg [3:0] gpio_out, // Maps to bits [7:4] of the register
	input      [3:0] gpio_in   // Maps to bits [3:0] of the register
);

	wire is_write   = |iomem_wstrb;
	
	// Single register select mapped to 0x0400_0000
	wire gpio_reg_sel = iomem_valid && (iomem_addr == 32'h 0400_0000);

	// Ready goes high instantly when this peripheral address is selected
	assign iomem_ready = gpio_reg_sel;

	// --- BUS READ LOGIC ---
	// Concatenate the upper 4 bits (output register state) and lower 4 bits (live input pins)
	assign iomem_rdata = gpio_reg_sel ? {24'h0, gpio_out, gpio_in} : 32'h 0000_0000;

	// --- BUS WRITE LOGIC ---
	always @(posedge clk) begin
		if (!resetn) begin
			gpio_out <= 4'b0000;
		end else if (is_write && gpio_reg_sel) begin
			// iomem_wstrb[0] corresponds to the lowest byte of the 32-bit word (bits [7:0])
			if (iomem_wstrb[0]) begin
				// We only capture wdata[7:4] to drive our output pins.
				// wdata[3:0] is ignored during a write because those bits map to physical inputs.
				gpio_out <= iomem_wdata[7:4];
			end
		end
	end

endmodule
