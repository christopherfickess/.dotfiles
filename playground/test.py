#!/usr/bin/env python3
"""
Simple sanity check script to confirm Python is installed.
Run: python main.py
"""
import sys

def main():
    print("Python is installed.")
    print("Version:", sys.version)
    print("Running a simple computation: 1 + 2 =", 1 + 2)

if __name__ == "__main__":
    main()
