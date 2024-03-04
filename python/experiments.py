
from functions import zero_check_and_corr
import time
import pandas as pd

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
    #print("\nPlease ensure that power source is off...")
    data = pd.DataFrame(columns=['Elapsed Time (s)', 'Current (A)', 'Resistance (Ohm)'])

    input_voltage = float(input("\nWhat voltage is being supplied: "))
    n_cycles = int(input("\nHow many measurements to take: "))
    sampfreq = float(input("\nHow many tests per second: "))

    instance.write("*RST")
    instance.write("SYST:ZCH ON")
    instance.write("CURR:RANG 2e-9")
    time.sleep(2)
    instance.write("INIT")
    instance.write("SYST:ZCOR:ACQ")
    instance.write("SYST:ZCOR ON")
    instance.write("CURR:RANG:AUTO ON")
    instance.write("SYST:ZCH OFF")

    print("\nShutting off display for higher performance...")
    time.sleep(2)
    instance.write("DISP:ENAB OFF")

    time_interval = 1 / float(sampfreq)

    start_time = time.time()
    rows = []  # List to store each row before concatenation

    for i in range(n_cycles):
        current_str = instance.query("READ?").split(',')[0]
        current = float(current_str[1:-1])

        resistance = input_voltage / current if current != 0 else None

        elapsed_time = time.time() - start_time

        rows.append({'Elapsed Time (s)': elapsed_time, 'Current (A)': current, 'Resistance (Ohm)': resistance})
        
        time.sleep(time_interval)

    data = pd.concat([data, pd.DataFrame(rows)], ignore_index=True)
    print(data)
    return(data)

def single_current_measurement(instance):
    instance.write("*RST")
    instance.write("SYST:ZCH ON")
    instance.write("CURR:RANG 2e-9")
    #@@ -57,13 +53,29 @@ def single_current_measurement(instance):
    instance.write("SYST:ZCOR ON")
    instance.write("CURR:RANG:AUTO ON")
    instance.write("SYST:ZCH OFF")
    instance.query("READ?")

"""
    print("Shutting off display for higher performance...")
    time.sleep(2)
    instance.write("DISP:ENAB OFF")

    time_interval = 1 / float(sampfreq)

    start_time = time.time()
    rows = []  # List to store each row before concatenation

    for i in range(n_cycles):
        current_str = instance.query("READ?").split(',')[0]
        current = float(current_str[1:-1])

        resistance = input_voltage / current if current != 0 else None

        elapsed_time = time.time() - start_time

        rows.append({'Elapsed Time (s)': elapsed_time, 'Current (A)': current, 'Resistance (Ohm)': resistance})

        time.sleep(time_interval)

    data = pd.concat([data, pd.DataFrame(rows)], ignore_index=True)
    print(data)
    return(data)
    """