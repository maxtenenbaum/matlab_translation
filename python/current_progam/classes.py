import os
import pandas as pd
import numpy as np
import pyvisa
import matplotlib.pyplot as plt

class InstrumentManager:
    def __init__(self, resource_manager):
        self.rm = resource_manager
        self.instance = None

    def list_instruments(self):
        print("Available Instruments")
        self.source_options = self.rm.list_resources()
        for index, source in enumerate(self.source_options, start = 1):
            print(f"{index}. {source}")

    def select_instrument(self):
        while True:
            try:
                resource_input = input("\nSelect the resource number: ")
                resource_selection = self.source_options[int(resource_input)-1]
                break
            except (ValueError, IndexError):
                print("Invalid selection. Please enter a valid numnber.")
        self.instance = self.rm.open_resource(resource_selection)
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
        exp_pick = ''
        if exp_choice == '1':
            exp_pick = 'Single Current Snapshot'
        elif exp_choice == '2':
            exp_pick = 'Repeated Current Measurements'
        if exp_pick in self.experiments:
            dataframe = self.experiments[exp_pick](instrument)
            return dataframe
        else:
            print("Not an experiment")
            return None
            

class DataAnalyzer:
    def __init__(self, dataframe):
        self.dataframe = dataframe
    
    def perform_analysis(self):
        pass


class DataViz:
    def __init__(self, dataframe):
        self.dataframe = dataframe

    def plot_data(self, dataframe):
        plt.figure(figsize=(10, 6))
        plt.plot(self.dataframe['Elapsed Time (s)'], self.dataframe['Current (A)'], marker='o')
        plt.title('Current vs Elapsed Time')
        plt.xlabel('Elapsed Time (s)')
        plt.ylabel('Current (A)')
        plt.grid(True)
        plt.savefig(f'output/plot.png', dpi=300)
