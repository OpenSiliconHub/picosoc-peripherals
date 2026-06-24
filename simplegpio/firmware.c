/*
 * Custom Single-Register GPIO Verification Payload
 * * Target Peripheral: simplegpio (OpenSiliconHub)
 * Register Mapping:
 * - 0x0400_0000 [Bits 7:4] : Output Latch (gpio_out)
 * - 0x0400_0000 [Bits 3:0] : Live Inputs   (gpio_in)
 */

#include <stdint.h>

// Define the single absolute 32-bit memory-mapped register location
#define GPIO_REG (*(volatile uint32_t*)0x04000000)

void main()
{
	// Initialize outputs to 0 (Upper nibble [7:4] = 0x0)
	GPIO_REG = 0x00;

	// Bare-metal processing loop
	while (1) {
		// 1. Read the unified register state
		uint32_t current_reg = GPIO_REG;

		// 2. Isolate the live inputs from the lower 4 bits [3:0]
		uint32_t live_inputs = current_reg & 0x0F;

		// 3. Process data in software (Example: Invert the 4-bit pattern)
		uint32_t processed_pattern = (~live_inputs) & 0x0F;

		// 4. Drive results directly to the custom output register bits [7:4]
		// Shift the 4-bit result left by 4 positions to line up with gpio_out
		GPIO_REG = (processed_pattern << 4);

		// Short clock cycle buffer execution delay for simulator stability
		for (volatile int i = 0; i < 20; i++);
	}
}
