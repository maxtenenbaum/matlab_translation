import pyvisa
from functions import print_heading, list_experiments
from experiments import current_measurements, test_func, single_current_measurement
import pandas as pd
# Initiate resource manager
rm = pyvisa.ResourceManager()

# List available instrumentrs to connect to
print_heading("Available Instruments")
source_options = rm.list_resources()
for index, source in enumerate(source_options, start=1):
    print(f"{index}. {source}")

# Select resource
while True:
    try:
        resource_input = input("\nSelect the source number: ")
        resource_selection = source_options[int(resource_input)-1]
        break
    except (ValueError, IndexError):
        print("Invalid selection. Please enter a valid number.")

# Open selected resource and reset
instance = rm.open_resource(resource_selection)
instance.read_termination = '\r'
instance.baud_rate = 9600
instance.write("*RST")
print_heading("Connection Success")
print("Instrument ID:", instance.query("*IDN?").strip())


# Select experiment
experiments = {
    "Single Shot Current":single_current_measurement,
    "Current Measurements":current_measurements
}
print_heading("Pick an experiment: ")
list_experiments(experiments)

exp_choice = input("\nExperiment Selection: ")

if exp_choice == str(1):
    #experiments["Single Shot Current"](instance)
    current_data = current_measurements(instance)
elif exp_choice == str(2):
    experiments["Current Measurements"](instance)
else:
    print("Not an experiment")

instance.write("DISP:ENAB ON")
instance.write("*RST")



