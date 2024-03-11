import tkinter as tk
from tkinter import ttk
import ttkbootstrap as ttkb
from gui_classes import DeviceManager

# Initialize the main window with ttkbootstrap
root = ttkb.Window(themename='superhero')
root.title("Deku Lab Crosstalk Interface")
root.geometry("1200x800")

# Status Bar
status_var = tk.StringVar()
status_var.set("Ready")

# Device Manager Initialization
devicemanager = DeviceManager(None, status_var)  # ComboBox will be set later

# Device selection
available_devices = ttkb.Combobox(values=devicemanager.device_list)
available_devices.pack(pady=15)
devicemanager.combo_widget = available_devices  # Set the ComboBox in the DeviceManager

# Connect button
def connect_device():
    devicemanager.connect_to_device()
device_connection = ttk.Button(root, text="Connect", command=connect_device)
device_connection.pack(pady=15)

#####
# Experiment selection 
available_experiments = ttkb.Combobox()
available_experiments.pack()






# Status Bar
status_bar = ttk.Label(root, textvariable=status_var, relief=ttkb.SUNKEN, anchor='w')
status_bar.pack(side='bottom', fill='x')

# Start the main loop
root.mainloop()
