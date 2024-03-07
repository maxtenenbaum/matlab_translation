import matplotlib.pyplot as plt
import scipy
import numpy as np
import pyvisa

def print_heading(heading):
    print("\n" + "=" * 40)
    print(heading.center(40))
    print("=" * 40 + "\n")

def zero_check_and_corr(instance):
    print("Performing zero check and zero correct...")
    instance.write("*RST")
    instance.write("SYST:RANG 2E-4")
    instance.query("INIT")
    instance.write("SYST:ZCOR:ACQ")
    instance.write("SYST:ZCH OFF")
    instance.write("SYST:ZCOR ON")


def list_experiments(experiments):
    num = 1
    for exp in experiments:
        print(f"\n{num}. {exp}")
        num += 1

#def initialization_sequence(instance):
    


    
