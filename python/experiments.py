
from functions import zero_check_and_corr
import time

def test_func():
    print("test")

# Current measurement experiment
def current_measurements(instance):
    """
    The purpose of this experiment is to measure the current between 2 leads at a set voltage

    Equipment needed:
    - Picoammeter
    - DC Power Supply

    Hardware Setup:
    - Positive into +6v out from power supply to DUT
    - Negative into COM from power supply

    - Negative from CAT1 on picoammeter to COM lead from power supply
    - Positive from CAT1 on picoammeter to DUT
    """

    """
    Prompt to keep power source off

    Ask for parameters:
    - Voltage being used
    - Number of cycles
    - Frequency of tests
    - (Voltage step)
    Check zero check setting
    If off - Enable zero check
    Perform zero correction
    Prompt to turn power source
    Disable zero check
    """
    print("\nPlease ensure that power source is off...")
    
    input_voltage = input("\nWhat voltage is being supplied: ")
    n_cycles = input("\nHow many measurements to take: ")
    sampfreq = input("\nHow many tests per second: ")

    #Zero Check and Zero Correct
    zero_check_and_corr(instance)



def single_current_measurement(instance):
    instance.write("*RST")
    instance.write("SYST:ZCH ON")
    instance.write("CURR:RANG 2e-9")
    time.sleep(2)
    instance.write("INIT")
    instance.write("SYST:ZCOR:ACQ")
    instance.write("SYST:ZCOR ON")
    instance.write("CURR:RANG:AUTO ON")
    instance.write("SYST:ZCH OFF")
    instance.query("READ?")









