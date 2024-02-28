import pyvisa
import time
"""
This code currently works to connect to Keithley through RS-232 communication

Working:
Initialize resource manager
List available resources
Select and open resource

Issues:
I/O communication most likely due to problems with terminator
6485 says line feed - "\n" is the terminator

Currently implemented read_bytes() function in order to read out the actual bytes being read by computer
- Last read byte should be the terminator
"""




# Initialize the VISA resource manager
rm = pyvisa.ResourceManager()

# List all connected instruments and append options
print("Available Instruments:")
source_options = []
for sources in rm.list_resources():
    source_options.append(sources)
    print(f"{rm.list_resources().index(sources)+1}. {sources}")

# Prompt and select source
resource_input = input("Which source would you like to use: ")
resource_selection = source_options[int(resource_input)-1]

# Open selected resource
instance = rm.open_resource(resource_selection, send_end=False, delay=1.2)

# Initialize device
print(instance)
"""instance.read_termination = '\n' # LINE FEED TERMINATOR
instance.write_termination = '\n' 
instance.baud_rate = 9600
instance.query_delay = 5
instance.write("*RST")
instance.query("*IDN?")"""

# Testing read_bytes() 
instance.write('*IDN?')
while True:
    print(instance.read_bytes(1))




