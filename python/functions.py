import matplotlib.pyplot as plt
import scipy
import numpy as np
import pyvisa

# For test purposes
def test_connection(address):
    try:
        instrument = rm.open_resource(address)
        identity = instrument.query("*IDN?")
        print("Connected to:", identity)
        return True
    except pyvisa.VisaIOError as e:
        print("Connection failure:", e)
        return False
    finally:
        instrument.close()


# To be used in a main() as a checkpoint
def test_instrument_connection(address):
    rm = pyvisa.ResourceManager()
    try:
        instrument = rm.open_resource(address)
        instrument.query("*IDN?")
        instrument.close()
        return True
    except pyvisa.VisaIOError:
        return False


    
