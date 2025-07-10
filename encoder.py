import argparse
import sys
import os

decoder = """?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R?p4R!0_R#0SU?@SR?`SR@PCR:0MReDcWeDcWeDcWeDcWeTcWeTcWeTcWeTcWeDcWeDcWeDcWeDcWeDcWeDcWeDcWeDcWeTcWeTcWeTcWeTcW!0MRGA3Y0P4Rz`DRf`FR-`FRvtOP!0WUu43P!0GU8tWP!0WUu43P!0GU8tWP!0WUx43P!0GE@`4BN`FR6tGP!0WUu43P!0GU8tWP!0WUu43P!0GU8tWP!0WUu43P!0GUZ`DR6tGP!0WUu43Px43P!0GE8tW@!0WUu43Px43P!0GE8tW@!0WUu43Px43P!0GE8tW@8tWP!0WUu43P!0GU8tWP!0WUu43P!0GU8tWP!0WUx43P!0GE8tW@8tWPtd7P8dVP8dVPt4XP20`O!04B!0WU?0SR&00Jc74P8tWP!PWU?PURe:3P8tWP!PWU?PURe=3P8tWP!PWU?PUR543P8tWP!0FUc4$P"0FUc4$P#0FU8dVP8dVP8dVP*00Z20`O"""

# Template that prints to stdout
template_shellcode = b"\x18\x10\x8f\xe2\x18\x20\xa0\xe3\x01\x00\xa0\xe3\x04\x70\xa0\xe3\x00\x00\x00\xef\x01\x70\xa0\xe3\x00\x00\xa0\xe3\x00\x00\x00\xef\x48\x65\x6c\x6c\x6f\x2c\x20\x41\x52\x4d\x76\x37\x20\x53\x68\x65\x6c\x6c\x63\x6f\x64\x65\x21\x0a"

template_c_code = """#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>

unsigned char shellcode[] = "{shellcode}";

int main() {{
    uintptr_t addr=(uintptr_t)shellcode;
    uintptr_t pagestart  =  addr & ~4095;

    mprotect((void *)pagestart, 16384, PROT_READ | PROT_WRITE | PROT_EXEC);
    (*(void (*)())shellcode)();
    return 0;
}}
"""

def encode(p: bytes) -> str:
    if len(p) % 3 != 0:
        p = p + (3 - len(p) % 3) * b"\x90"
    e = ""
    for i in range(len(p) // 3):
        e += chr((p[3 * i] >> 2) + 0x3F)
        e += chr(((p[3 * i] & 0b11) << 4) + (p[3 * i + 1] >> 4) + 0x3F)
        e += chr(((p[3 * i + 1] & 0b1111) << 2) + (p[3 * i + 2] >> 6) + 0x3F)
        e += chr((p[3 * i + 2] & 0b111111) + 0x3F)
    return decoder + e + "&"

def hexlify(e: str) -> str:
    res = ""
    for i in e:
        res += "\\x" + hex(ord(i))[2:]
    return res

def generateCFile(e: str):
    temp = template_c_code.format(shellcode=hexlify(e))
    with open("run.c", "w") as f:
        f.write(temp)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="Lycan", formatter_class=argparse.RawTextHelpFormatter,
                                     description="Lycan -- a tool that implements the least information redundancy algorithm of printable shellcode encoding for x86",
                                     epilog="Examples:\n"
                                            "python3 Lycan.py -e \"\\xde\\xad\\xbe\\xef\"\n"
                                            "python3 Lycan.py -H -g -e \\xde\\xad\\xbe\\xef\n"
                                            "python3 Lycan.py -H -e 'DeadBeef'\n"
                                            "python3 Lycan.py -g -t\n"
                                            "python3 Lycan.py -f sample.bin -o")

    group = parser.add_mutually_exclusive_group()
    group.add_argument("-e", "--encode", metavar="", type=str,
                       help="encode the original shellcode")
    group.add_argument("-t", "--template", default=False, action=argparse.BooleanOptionalAction,
                       help="use the Lycan's default template shellcode")
    group.add_argument("-f", "--file", metavar="", type=str,
                       help="path to a .bin file whose content will be encoded")

    parser.add_argument("-H", "--hex", default=False, action=argparse.BooleanOptionalAction,
                        help="output the encoded shellcode in hex format")
    parser.add_argument("-g", "--generate", default=False, action=argparse.BooleanOptionalAction,
                        help="generate template C code in temp.c and compile it to temp")
    parser.add_argument("-o", "--output-bin", default=False, action=argparse.BooleanOptionalAction,
                        help="write the encoded output to <filename>_encoded.bin (only applies with --file)")

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    if args.template:
        plain = template_shellcode
        input_filename = None
    elif args.file:
        if not os.path.exists(args.file):
            print("[-] Error: File does not exist.")
            sys.exit(1)
        if not args.file.endswith(".bin"):
            print("[-] Error: Only .bin files are supported.")
            sys.exit(1)
        with open(args.file, "rb") as f:
            plain = f.read()
        input_filename = args.file
    elif args.encode:
        plain = bytes.fromhex(args.encode.replace("\\", "").replace("x", ""))
        input_filename = None
    else:
        print("[-] Error: No input provided. Use -e, -t, or -f.")
        sys.exit(1)

    encoded_str = encode(plain)

    if args.hex:
        print(hexlify(encoded_str))
    else:
        print(encoded_str)

    if args.generate:
        generateCFile(encoded_str)

    if args.output_bin and args.file:
        out_file = input_filename.rsplit(".bin", 1)[0] + "_encoded.bin"
        with open(out_file, "wb") as f:
            f.write(encoded_str.encode())
        print(f"[+] Encoded output written to: {out_file}")

