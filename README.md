# Automatic Printable Shellcode Generation for ARMv7 systems

In modern systems, if we want to inject something malicious into the memory address space of program, there may exist certain filters that automatically drop those bytes which are not printable (Bytes, which have its value between 33 to 126).

Thus, to inject vulnerabilities into such system is not so straightforward task.

To address this, I developed a tool that can create a sequence of printable bytes, but when executed on CPU (of ARMv7 architecture), it can do some operations, like spawning  a shell and making a TCP connection to remote device.

### Usage

1. Write the operations youu want to do in the assembly code and save it to file with `.s` extension. (2  demo assembly codes that prints content to stdout and  spawns a shell is  given, for  reference).

2. Use generate_binaries script provided here, that converts assembly instructions into binary machine code.
```console
./generate-binaries.sh ./hello_world.s
```

3. Encode that machine code with the `encodeer.py` file, and that will give the shellcode in printable format, that can decode the content and runtime, and do the intended operations.

4. Encoder will generate a `run.c` file. Run this as usual.
```console
gcc -o run ./run.c
./run
```