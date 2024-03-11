import pyvisa
from classes import InstrumentManager, ExperimentRunner, DataAnalyzer, DataViz
from experiments import single_current_measurement, current_measurements
import matplotlib.pyplot as plt

experiments = {
    "Single Current Snapshot":single_current_measurement,
    "Repeated Current Measurements":current_measurements
}

# Connection to instrument
rm = pyvisa.ResourceManager()
instrument_manager = InstrumentManager(rm)
instrument_manager.list_instruments()
instrument_manager.select_instrument()
instrument = instrument_manager.get_instrument()

# Experiment
experiment_runner = ExperimentRunner(experiments)
experiment_runner.list_experiments()
dataframe = experiment_runner.run_experiment(instrument)

# Next Steps


plot_prompt = input("Would you like to plot the data (y/n)")
if plot_prompt == 'y':
    plotter = DataViz(dataframe)
    plotter.plot_data(dataframe)

# Data analysis
"""if dataframe is not None:
    analyzer = DataAnalyzer(dataframe)
    analyzer.perform_analysis()

# Data visualization
if dataframe is not None:
    plotter = DataViz(dataframe)
    plotter.plot_data(dataframe)
"""
# Cleanup
instrument.write("DISP:ENAB ON")
instrument.write("*RST")