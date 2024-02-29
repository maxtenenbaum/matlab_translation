import pyvisa
import time
from functions import print_heading

# Initialize the VISA resource manager
rm = pyvisa.ResourceManager()

# List all connected instruments
print_heading("Available Instruments")
source_options = rm.list_resources()
for index, source in enumerate(source_options, start=1):
    print(f"{index}. {source}")

# Prompt and select source
while True:
    try:
        resource_input = input("\nSelect the source number: ")
        resource_selection = source_options[int(resource_input)-1]
        break
    except (ValueError, IndexError):
        print("Invalid selection. Please enter a valid number.")

# Open selected resource
instance = rm.open_resource(resource_selection)
instance.read_termination = '\r'
instance.baud_rate = 9600
instance.write("*RST")

print_heading("Connection Success")
print("Instrument ID:", instance.query("*IDN?").strip())

# Line Frequency
print("\nLine Frequency:", instance.query("SYST:LFR?").strip(), "Hz")

# Set Autozero
autozero_set = ''
while autozero_set not in ['Y', 'n']:
    autozero_set = input("\nEnable autozero? (Y/n): ").strip()
    if autozero_set == 'Y':
        instance.write("SYST:AZER ON")
        print("Autozero Enabled")
    elif autozero_set == 'n':
        instance.write("SYST:AZER OFF")
        print("Autozero Disabled")
    else:
        print("Invalid input. Please enter 'Y' for Yes or 'n' for No.")

autozero_check = instance.query("SYST:AZER?").strip()
autozero_stat = "ON" if autozero_check == '1' else "OFF"
print("\nAutozero set to:", autozero_stat)

#print_heading("Select an experiment")
print("Test experiment")

