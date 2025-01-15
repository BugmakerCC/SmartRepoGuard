from sens_func_extract4sc import SensFuncExtract
from static_analysis import StaticAnalysis
from datetime import datetime

def print_with_time(message):
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{current_time}] {message}")

def print_separator():
    print("=" * 40)

def SmartContractAnalyze(filepath):
    # sensitive function signature -> function body
    print_separator()  
    start_time = datetime.now()
    print_with_time("✨ Extracting Function Bodies from Sensitive Function Signatures ✨")
    SensFuncExtract(filepath)
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Function Body Extraction Completed (Time used: {elapsed_time})")
    print_separator() 

    # completed contract -> result
    sol_code_path = filepath.replace('target/', 'sol_code/')
    print_separator() 
    start_time = datetime.now()
    print_with_time("✨ Performing Static Analysis on Completed Contract ✨")
    StaticAnalysis(sol_code_path, 'sc')
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Static Analysis Completed (Time used: {elapsed_time})")
    print_separator() 