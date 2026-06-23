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

	input         iomem_valid,
	output        iomem_ready,
	input  [3:0]  iomem_wstrb,
	input  [31:0] iomem_addr,
	input  [31:0] iomem_wdata,
	output [31:0] iomem_rdata,

  output reg [7:0] gpio_a_out, // Mapped to 0x0400_0000 (Writeable/Readable)
  input      [7:0] gpio_a_in   // Mapped to 0x0400_0004 (Read-Only)
);

	wire is_write   = |iomem_wstrb;

  wire reg_out_sel = iomem_valid && (iomem_addr == 32'h 0400_0000); // Address: 0x0400_0000
  wire reg_in_sel  = iomem_valid && (iomem_addr == 32'h 0400_0004); // Address: 0x0400_0004

	wire module_active = reg_out_sel || reg_in_sel;

	assign iomem_ready = module_active;

	// --- BUS READ LOGIC ---
	assign iomem_rdata = reg_out_sel ? {24'h0, gpio_a_out} : //Read back what outputs are set to
	                     reg_in_sel  ? {24'h0, gpio_a_in}  : //Read live states of button/switches
	                     32'h 0000_0000;						         //Default safe fallback value

	// --- BUS WRITE LOGIC ---
	always @(posedge clk) begin
		if (!resetn) begin
			gpio_a_out <= 8'b0000_0000;
		end else if (is_write) begin
			if (reg_out_sel && iomem_wstrb[0]) begin
				gpio_a_out <= iomem_wdata[7:0];
			end

			// NOTE: There is no write condition here for reg_in_sel (0x03000004)
      // because physical buttons/switches cannot be written to by software.
		end
	end
endmodule
