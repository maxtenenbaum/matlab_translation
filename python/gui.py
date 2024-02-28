import tkinter as tk
import ttkbootstrap as ttk
import pyvisa

class PicoammeterGUI:
    def __init__(self, master):
        self.master = master
        self.master.title("Keithley Picoammeter Controller")
        self.initialize_gui_elements()
        self.configure_layout()
        self.initialize_visa_resource_manager()

    def initialize_gui_elements(self):
        self.instrument_label = ttk.Label(self.master, text="Select Instrument:")
        self.instrument_combo = ttk.Combobox(self.master)
        self.refresh_button = ttk.Button(self.master, text="Refresh", command=self.refresh_instruments)
        self.connect_button = ttk.Button(self.master, text="Connect", command=self.connect_instrument)
        self.response_text = tk.Text(self.master, height=10, width=50)
        self.send_command_button = ttk.Button(self.master, text="Send *IDN? Command", command=self.send_command)
        self.read_response_button = ttk.Button(self.master, text="Read Response", command=self.read_response)

    def configure_layout(self):
        self.instrument_label.pack(pady=5)
        self.instrument_combo.pack(pady=5)
        self.refresh_button.pack(pady=5)
        self.connect_button.pack(pady=5)
        self.response_text.pack(pady=10)
        self.send_command_button.pack(pady=5)
        self.read_response_button.pack(pady=5)

    def initialize_visa_resource_manager(self):
        self.rm = pyvisa.ResourceManager()
        self.refresh_instruments()

    def refresh_instruments(self):
        self.instrument_combo['values'] = self.rm.list_resources()

    def connect_instrument(self):
        resource_selection = self.instrument_combo.get()
        self.instance = self.rm.open_resource(resource_selection)
        self.response_text.insert(tk.END, f"Connected to {resource_selection}\n")

    def send_command(self):
        if hasattr(self, 'instance'):
            self.instance.write('*IDN?')
            self.response_text.insert(tk.END, "Command Sent: *IDN?\n")

    def read_response(self):
        if hasattr(self, 'instance'):
            response = self.instance.read_bytes(1)
            self.response_text.insert(tk.END, f"Response: {response}\n")

if __name__ == "__main__":
    root = ttk.Window(themename='superhero')  # Replace 'litera' with your preferred theme
    gui = PicoammeterGUI(root)
    root.mainloop()
