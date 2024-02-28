import pyvisa
import time

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
instance = rm.open_resource(resource_selection)

# Initialize device
print(instance)
instance.read_termination = '\r' # MAY NEED TO CHANGE - ENSURE THAT DEVICE TERMINATOR IS SAME
instance.write_termination = '\r' 
instance.baud_rate = 9600
#instance.query_delay = 5
instance.query("*IDN?")




