import sys
import os

if __name__ == '__main__':
    cmd = "gcc temp/temp.c -w -o temp/out"
    print("> Compiler: GCC")
    print("> Compiling temporary files")
    os.system(cmd)
    print("")