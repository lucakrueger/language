import os
from os import listdir, walk
from os.path import isfile, join

def assemble_files(path):
    filenames = next(walk(path), (None, None, []))[2]
    return filenames

def constructGCC(path, files, out):
    cmd = "gcc  "
    for file in files:
        if file.split(".")[1] == "c":
            cmd += path + file + " "
    cmd += "-o " + out
    return cmd

if __name__ == '__main__':
    path = "./runtime/"
    files = assemble_files(path)
    print("> Compiler: GCC")
    gcc = constructGCC(path, files, "./bin/runtime")
    print("> " + gcc)
    os.system(gcc)
    print("")