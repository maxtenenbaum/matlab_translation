import pyvisa
from functions import test_connection

# Create resource manager
rm = pyvisa.ResourceManager()

# Set GPIB address to Model 6485 Default
address = "/dev/tty.usbserial-14240"

# Checkpoint to verify connection
if test_connection(address):
    print("Connection success...")

    picoammeter = rm.open_resource(address)
    
    # Send SCPI commands
    picoammeter.write("*RST")                  # Reset to GPIB defaults
    picoammeter.write("SYST:ZCH ON")           # Enable zero check
    picoammeter.write("RANG 2e-9")             # Select the 2nA range
    picoammeter.write("INIT")                  # Trigger reading for zero correction
    picoammeter.write("SYST:ZCOR:ACQ")         # Use last reading as zero correct value
    picoammeter.write("SYST:ZCOR ON")          # Perform zero correction
    picoammeter.write("RANG:AUTO ON")          # Enable auto range
    picoammeter.write("SYST:ZCH OFF")          # Disable zero check

    # Trigger a reading and retrieve it
    picoammeter.write("READ?")                 
    reading = picoammeter.read()               # Read the response

    print("Current Reading: ", reading)

    # Close the connection
    picoammeter.close()

else:
    print("Connection failure... Please check instrument and try again.")



