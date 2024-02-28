import pyvisa
import time

# Define instrument connection parameters
instrument_address = "/dev/tty.usbserial-14240"  # Replace with your specific address
baud_rate = 9600

# Define available experiments
experiments = {
    "1": "Current measurement at different voltages",
    "2": "Other experiment (add your specific details here)",
    # Add more experiments and their descriptions as needed
}


def connect_instrument():
    """Connects to the instrument and returns the handle."""
    rm = pyvisa.ResourceManager()
    try:
        instrument = rm.open_resource(instrument_address, baud_rate=baud_rate)
        instrument.timeout = 5000  # Set timeout in milliseconds
        instrument.clear()
        idn = instrument.query("*IDN?")
        print(f"Instrument ID: {idn}")
        return instrument
    except Exception as e:
        print(f"Failed to connect: {e}")
        return None


def take_current_measurement(instrument, voltage):
    """Performs a current measurement at a given voltage and returns the value."""
    # ... (same as previous implementation)
    # Include instrument-specific commands for setting voltage, measurement range, etc.
    # Replace placeholder comments with actual commands based on the SCPI manual.


def main():
    """Main function to establish connection, choose experiment, and run."""
    instrument = connect_instrument()

    if instrument:
        print("Connection successful...")

        # Display available experiments
        print("\nAvailable experiments:")
        for code, description in experiments.items():
            print(f"{code}: {description}")

        # Ask for experiment selection
        while True:
            choice = input("\nEnter experiment code or 'q' to quit: ")
            if choice == "q":
                break
            elif choice in experiments:
                if choice == "1":
                    # Run current measurement experiment
                    for voltage in [1, 2, 3]:  # Modify voltages as needed
                        instrument.write("*CLS")  # Clear status before sending new commands
                        current = take_current_measurement(instrument, voltage)
                        print(f"Voltage: {voltage}V, Current: {current}A")
                else:
                    print(f"Experiment '{experiments[choice]}' not yet implemented.")
                break
            else:
                print(f"Invalid choice. Please enter a valid experiment code or 'q'.")

        # Close connection and perform instrument reset (optional)
        instrument.write("*RST")  # Reset instrument to default state (optional)
        instrument.close()
        print("Connection closed.")

    else:
        print("Connection failed.")


if __name__ == "__main__":
    main()






"""import pyvisa

def rs232_connect(address, baud_rate=9600, data_bits=8, parity=pyvisa.constants.Parity.none, stop_bits=pyvisa.constants.StopBits.one):

    rm = pyvisa.ResourceManager()

    try:
        instrument = rm.open_resource(address, baud_rate=baud_rate, data_bits=data_bits, parity=parity, stop_bits=stop_bits)
        instrument.timeout = 5000
        instrument.clear()
        idn=instrument.query("*IDN?")
        print(f"Instrument ID: {idn}")
        return instrument
    except Exception as e:
        print(f"Failed to connect: {e}")
        return None

def main():
    instrument_address = "ASRLCOM1::INSTR" # Example: "ASRL3::INSTR" for COM3
    instrument = rs232_connect(instrument_address)

    if instrument:
        print("Connection success...")


    
    else:
        print("Connection Failure.")

if __name__ == "__main__":
    main()"""