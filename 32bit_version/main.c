#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// external assembly routine
extern void uquantize(unsigned char *pixels, int width, int height, int stride, int levels);

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <input.bmp> <output.bmp> <levels>\n", argv[0]);
        return 1;
    }

    const char *input_file_name = argv[1];
    const char *output_file_name = argv[2];
    int levels = atoi(argv[3]);

    if (levels <= 0 || levels > 256) {
        printf("Error: levels must be between 1 and 256\n");
        return 1;
    }

    FILE *input_file = fopen(input_file_name, "rb");
    if (!input_file) {
        printf("Error: Cannot open input file %s\n", input_file_name);
        return 1;
    }

    fseek(input_file, 0, SEEK_END);
    long file_size = ftell(input_file);
    rewind(input_file);

    unsigned char *buffer = (unsigned char *)malloc(file_size);
    if (!buffer) {
        printf("Error: Memory allocation failed.\n");
        fclose(input_file);
        return 1;
    }

    fread(buffer, 1, file_size, input_file);
    fclose(input_file);

    // Validate BMP Header
    if (buffer[0] != 'B' || buffer[1] != 'M') {
        printf("Error: Not a valid BMP file.\n");
        free(buffer);
        return 1;
    }

    uint32_t data_offset;
    int32_t width, height;
    uint16_t bpp;

    memcpy(&data_offset, &buffer[10], 4);
    memcpy(&width, &buffer[18], 4);
    memcpy(&height, &buffer[22], 4);
    memcpy(&bpp, &buffer[28], 2);

    if (bpp != 24) {
        printf("Error: Only 24 bpp BMP images are supported. (This image is %d bpp)\n", bpp);
        free(buffer);
        return 1;
    }

    int abs_height = (height < 0) ? -height : height;
    int stride = ((width * 3) + 3) & ~3;

    unsigned char *pixels = buffer + data_offset; // pixel array start
    uquantize(pixels, width, abs_height, stride, levels);

    FILE *output_file = fopen(output_file_name, "wb");
    if (!output_file) {
        printf("Error: Cannot create output file %s\n", output_file_name);
        free(buffer);
        return 1;
    }

    fwrite(buffer, 1, file_size, output_file);
    fclose(output_file);

    free(buffer);
    printf("Success: Image quantized to %d levels and saved to %s\n", levels, output_file_name);

    return 0;
}