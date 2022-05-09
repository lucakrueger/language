import sys
import os

if __name__ == '__main__':
    os.system("npm start " + sys.argv[1])
    os.system("python3 runtime/scripts/test.py")