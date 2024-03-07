import pyvisa
from experiments import single_current_measurement, current_measurements

experiments = {
    "Single Current Snapshot":single_current_measurement,
    "Repeated Current Measurements":current_measurements
}

# Connection to instrument
rm = pyvisa.ResourceManager()
instrument_manager = InstrumentManager(rm)
instrument_manager.list_instruments()
instrument_manager.select_instruments()
instrument = instrument_manager.get_instrument()

# Experiment
experiment_runner = ExperimentRunner(experiments)
experiment_runner.list_experiments()
experiment_runner.run_experiment(instrument)

# Cleanup
instrument.write("DISP:ENAB ON")
instrument.write("*RST")