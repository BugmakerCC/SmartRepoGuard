from sens_func_identify import SensFuncIdentify
from sens_func_extract4dapp import SensFuncExtract
from code_completion import CodeCompletion
from self_reflection import SelfReflection
from static_analysis import StaticAnalysis
from datetime import datetime

def print_with_time(message):
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{current_time}] {message}")

def print_separator():
    print("=" * 40)

def DAppAnalyze(dapp_path):
    # contract -> sensitive function signature
    print_separator()  
    start_time = datetime.now()
    print_with_time("✨ Starting Sensitive Function Identification ✨")
    SensFuncIdentify(dapp_path)
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Sensitive Function Identification Completed (Time used: {elapsed_time})")
    print_separator() 

    # sensitive function signature -> function body
    sens_sig_path = dapp_path.replace('target/', 'sens_sig_res/')
    print_separator()  
    start_time = datetime.now()
    print_with_time("✨ Extracting Function Bodies from Sensitive Function Signatures ✨")
    SensFuncExtract(sens_sig_path)
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Function Body Extraction Completed (Time used: {elapsed_time})")
    print_separator()  

    # function body -> completed contract
    sens_code_path = sens_sig_path.replace('sens_sig_res/', 'sens_code/')
    print_separator()  
    start_time = datetime.now()
    print_with_time("✨ Completing Contract Code from Function Bodies ✨")
    CodeCompletion(sens_code_path)
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Contract Code Completion Completed (Time used: {elapsed_time})")
    print_separator()  

    # completed contract -> self reflection
    sol_code_path = sens_code_path.replace('sens_code/', 'sol_code/')
    print_separator() 
    start_time = datetime.now()
    print_with_time("✨ Performing Self-Reflection on Completed Contract ✨")
    SelfReflection(sol_code_path)
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Self-Reflection Completed (Time used: {elapsed_time})")
    print_separator() 

    # completed contract -> result
    print_separator()  
    start_time = datetime.now()
    print_with_time("✨ Performing Static Analysis on Completed Contract ✨")
    StaticAnalysis(sol_code_path, 'dapp')
    end_time = datetime.now()
    elapsed_time = end_time - start_time
    print_with_time(f"✅ Static Analysis Completed (Time used: {elapsed_time})")
    print_separator()  