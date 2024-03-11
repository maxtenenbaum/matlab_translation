import pyvisa
import tkinter as tk

class DeviceManager:
    def __init__(self, combo_widget, status_var):
        self.rm = pyvisa.ResourceManager()
        self.device_list = self.rm.list_resources()
        self.instance = None
        self.combo_widget = combo_widget
        self.status_var = status_var

    def connect_to_device(self):
        selected_device = self.combo_widget.get()
        if selected_device:
            try:
                self.instance = self.rm.open_resource(selected_device)
                self.instance.read_termination = '\r'
                self.instance.baud_rate = 9600
                self.instance.write("*RST")
                self.status_var.set(f"Connected to {selected_device}")
            except Exception as e:
                self.status_var.set(f"Error connecting: {str(e)}")
        else:
            self.status_var.set("No device selected")

