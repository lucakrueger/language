import os

if __name__ == '__main__':
    os.system("python3 runtime/scripts/compile.py")
    print("> Executing: Runtime\n")
    os.system("bin/runtime")
    print("")