# Keithley Model 6482 Picoammeter/Voltage Source Control Script

import matplotlib.pyplot as plt
import warnings
import os
# Additional libraries for instrument control need to be imported

# Clearing figures and warnings
plt.close('all')
warnings.filterwarnings('ignore')
print('PROGRAM STARTED\n')

# Find functions folder
# In Python, functions can be imported if they are in the same directory or in PYTHONPATH

# Physical Setup Check
quit_program = get_phys_setup()  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# User input information
file_info = init_struct4('file')  # This function needs to be defined
file_info, quit_program = get_info(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# Setup email
email_address = file_info.get('Email', None)
if email_address:
    set_ni_email()  # This function needs to be defined

# Experiment type
file_info, quit_program = get_exp_type2(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return
exp_id = file_info['Experiment']['ID']

# Voltage Parameters
# User input voltage parameters
if exp_id == 'IT':
    file_info, quit_program = get_param_it(file_info)  # This function needs to be defined
# Repeat for 'IV', 'CAP', 'STEP'

if quit_program:
    print('OK\n')
    return

# Channel Selection
file_info, quit_program = select_channels(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# Save Path
file_info, quit_program = get_save_path2(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# Processing xSettings
file_info, quit_program = get_processing_param(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# Initialize Keithley Connection
file_info = init_keithley2(file_info)  # This function needs to be defined

# Set Keithley Settings
file_info, quit_program = set_keithley(file_info)  # This function needs to be defined
if quit_program:
    print('OK\n')
    return

# Run experiment
file_info_new, quit_program = run_experiment(file_info)  # This function needs to be defined
if quit_program:
    return

# End of program
plt.close('all')
# open_save_folder(save_path)  # This function needs to be defined
print('PROGRAM ENDED\n')

# findFunctions
def find_functions():
    functions_ckn = 'path/to/CKN_Functions'
    # Add path to the system path
    os.sys.path.append(functions_ckn)

    function_folder = 'Keithley_Functions'
    functions_location_cdrive = 'C:/Keithley_Functions'
    folder_exists = 7
    print('Searching for Function Folder in directory...')
    if os.path.exists(function_folder) == folder_exists:
        print('OK\n')
        os.sys.path.append(function_folder)
    else:
        print('FUNCTIONS NOT FOUND IN DIRECTORY')
        print('Searching for Function Folder in C:...')
        if os.path.exists(functions_location_cdrive) == folder_exists:
            print('OK\n')
            os.sys.path.append(functions_location_cdrive)
        else:
            print('NOT FOUND.\n')
            # Code for prompting user to find the folder
            # In Python, this would typically be handled differently, possibly with a GUI package
