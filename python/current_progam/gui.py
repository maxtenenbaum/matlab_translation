import tkinter as tk
from tkinter import ttk
import ttkbootstrap as ttkb
from ttkbootstrap.constants import *
import os
import pandas as pd
import numpy as np
import pyvisa
import matplotlib.pyplot as plt
import time
from experiments import single_current_measurement, current_measurements

#%% GUI optimized classes
class InstrumentManager:
    def __init__(self):
        self.rm = pyvisa.ResourceManager()
        self.instance = None
        self.instruments_list = self.rm.list_resources()
    
    def connect_to_instrument(self, instrument):
        rm = self.rm
        self.instance = rm.open_resource(instrument)
        self.instance.read_termination = '\r'
        self.instance.baud_rate = 9600
        self.instance.write("*RST")
        status_var.set("Connection Success")
        
def get_instrument_selection():
    return available_instruments.get()

def connect_instrument():
    selected_instrument = get_instrument_selection()
    instrument_manager.connect_to_instrument(selected_instrument)
    status_var.set(f"Connected to {selected_instrument}")

###########
###########

class ExperimentRunner:
    def __init__(self, experiments):
        self.experiments = experiments
        self.experiments_list = list(self.experiments.keys())
    
    def run_experiment(self):
        status_var.set(f"Running experiment: {get_experiment_selection()}")
        dataframe = self.experiments[get_experiment_selection()](instrument_manager.instance)
        instrument_manager.instance.write("DISP:ENAB ON")
        instrument_manager.instance.write("*RST")
        return dataframe

def get_experiment_selection():
    return available_experiments.get()



#%% GUI

# Set variables
expts = {
    "Single Current Snapshot":single_current_measurement,
    "Repeated Current Measurements":current_measurements
}

# Initialize variables
instrument_manager = InstrumentManager()
experiment_runner = ExperimentRunner(expts)

# Initialize the main window with ttkbootstrap
root = ttkb.Window(themename='superhero')
root.title("Deku Lab Crosstalk Interface")
root.geometry("1200x800")

# Instruments
available_instruments = ttk.Combobox(values=instrument_manager.instruments_list)
available_instruments.pack(pady=15)
# Connect button
connect_to_instrument = ttk.Button(root, text="Connect", command=connect_instrument)
connect_to_instrument.pack()

# Experiments
available_experiments = ttk.Combobox(values=experiment_runner.experiments_list)
available_experiments.pack(pady=15)

# Choose button
run_experiment = ttk.Button(root, text='Run experiment', command=experiment_runner.run_experiment)
run_experiment.pack()

# Status Bar
status_var = tk.StringVar()
status_var.set("Ready")
status_bar = ttk.Label(root, textvariable=status_var, relief=ttkb.SUNKEN, anchor='w')
status_bar.pack(side='bottom', fill='x')

# Start the main loop
root.mainloop()
