# x86 Assembly BMP Color Quantizer

A high-performance image processing application that performs uniform color quantization on 24-bpp (bits per pixel) BMP images. The project combines a C driver for file I/O and BMP header validation with a high-performance x86 Assembly routine for direct pixel-level manipulation.

---

## Features

*   **Low-Level Optimization:** Uses pure x86 Assembly to execute the intensive pixel quantization math across image byte arrays.
*   **Minimized Memory Traffic:** Maximizes CPU register utilization within the inner loop (`col_loop`) to reduce latency. Invariant variables like interval lengths are calculated once outside the loop, minimizing slow data transfers between registers and main memory.
*   **Stride and Padding Aware:** Correctly calculates and handles row padding required by the BMP file format specifications.
*   **Dynamic Quantization Levels:** Accepts a variable number of quantization levels (1 to 256) at runtime to dynamically adjust color depth.
*   **Robust Header Validation:** Inspects the magic bytes (`BM`), data offset tables, and bits-per-pixel configuration before executing assembly code to ensure memory safety.

---

## Project Structure

*   **`main.c`**: Handles command-line arguments, memory allocation, BMP file parsing, and file output writing.
*   **`uquantize.asm`**: The 32-bit x86 Assembly implementation containing the core loop that reads, quantizes, and writes back pixel color values.
*   **`uquantize64.asm`**: The 64-bit alternative implementation utilizing updated register configurations.
*   **`Makefile`**: Automates compilation, links the assembly objects with the C driver using the `-m32` architecture flag, and generates listing files.

---

## Potential Performance Optimizations

### The bottleneck
A significant performance bottleneck in the current inner loop is the hardware division instruction (div). On x86 architectures, integer division is a high-latency operation, often consuming 10 to 40+ CPU cycles per execution depending on the processor generation. Because this division runs for every single color channel byte (Red, Green, Blue) of every pixel, it introduces massive overhead over millions of pixels.

### Solution - Precomputing Levels via Lookup Table
A lookup table completely sidesteps this math bottleneck by exploiting the fact that an 8-bit color channel is limited to 256 potential values. Instead of forcing the CPU to repeatedly calculate the same division math for every pixel, the program can compute the correct answers for all 256 options just once during initialization.

Inside the inner loop, the heavy division instruction is replaced with a single, lightweight base-index memory read that fetches the pre-calculated answer using the raw pixel value as an offset. Because a 256-byte array is exceptionally small, it is guaranteed to sit entirely within the CPU's ultra-fast L1 data cache after the very first pixel is processed.

---

## Prerequisites

To build and run this project, you need a C compiler and the Netwide Assembler (`nasm`).

On Ubuntu/Debian-based systems, install the required 32-bit development libraries and assembler:
```bash
sudo apt update
sudo apt install nasm gcc-multilib  
```
---

## Build
```bash
make
```

---

## Usage

Before running the program, you need to prepare your input images as 24-bpp uncompressed BMP files. You can easily export images to this specific format using an image editor like GIMP.

Once your image is ready, write the following to use the program:

```bash
./main <image.path> <output.file.path> <no_levels>
```

Example usage:
```bash
./main mointainssss.bmp gr.bmp 3
```