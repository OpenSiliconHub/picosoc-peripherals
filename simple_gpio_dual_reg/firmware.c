/*
 * Custom Multi-Register GPIO Verification Payload
 */

#include <stdint.h>

// Define both absolute 32-bit memory-mapped register locations
#define GPIO_OUT_REG ((volatile uint32_t*)0x04000000)
#define GPIO_IN_REG  ((volatile uint32_t*)0x04000004)

void main()
{
	// Bare-metal processing loop
	while (1) {
		// 1. Read the live states of physical external buttons/switches
		uint32_t live_inputs = *GPIO_IN_REG;

		// 2. Process data in software (Example: Shift patterns or invert them)
		uint32_t inverted_pattern = ~live_inputs;

		// 3. Drive the results directly to your custom output register (LEDs)
		*GPIO_OUT_REG = inverted_pattern;

		// Short clock cycle buffer execution delay for simulator stability
		for (volatile int i = 0; i < 20; i++);
	}
}
