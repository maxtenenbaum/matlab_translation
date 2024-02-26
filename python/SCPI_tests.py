import pyvisa

# Create resource manager
rm = pyvisa.ResourceManager()

# Connect to Keithley (14 is standard GPIB address for Model 6485)
instrument_address = "GPIB::14"
picoammeter = rm.open_resource(instrument_address)

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
