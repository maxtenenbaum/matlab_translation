import os
import pandas as pd
import numpy as np
import pyvisa

class InstrumentManager:
    def __init__(self, resource_manager):
        self.rm = resource_manager
        self.instance = None

    def list_instruments(self):
        print("Available Instruments")
        self.source_options = self.rm.list_resources()
    
    def select_instrument(self):
        while True:
            try:
                resource_input = input("\nSelect the resource number: ")
                resource_selection = self.source_options[int(resource_input)-1]
                break
            except (ValueError, IndexError):
                print("Invalid selection. Please enter a valid numnber.")
        self.instance = self.rm.open_resouce(resource_selection)
        self.instance.read_termination = '\r'
        self.instance.baud_date = 9600
        self.instance.write("*RST")
        self.instance.write("Connection Success")
        print("Instrument ID:", self.instance.query("*IDN?").strip())
    
    def get_instrument(self):
        return self.instance

class ExperimentRunner:
    def __init__(self, experiments):
        self.experiments = experiments
    
    def list_experiments(self):
        print("Pick an experiment: ")
        for index, exp in enumerate(self.experiments, start=1):
            print(f"{index}. {exp}")   

    def run_experiment(self, instrument):
        exp_choice = input("\nExperiment Selection: ")
        if exp_choice in self.experiments:
            self.experiments[exp_choice](instrument)
        else:
            print("Not an experiment")
            

