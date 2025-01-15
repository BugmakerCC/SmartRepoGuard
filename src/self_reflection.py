
import subprocess
import os
from API_call import get_response
from static_analysis import get_version
from sol_code_extract import extract_solidity_code

def SelfReflection(directory):
    total_todo_files = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                total_todo_files += 1
                
    cnt = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                cnt += 1
                print(f"schedule: {cnt}/{total_todo_files}")
                file_path = os.path.join(root, file)
                print(file_path)
                times = 0
                compile_flag = False
                version = get_version(file_path)
                if not version:
                    version = '0.8.0'
                while not compile_flag:
                    times += 1
                    if times > 1:
                        print(f"Self-reflection for {times-1} times..")

                    if times > 6:
                        print("Too many times for self-reflection, skip this contract")
                        break

                    with open(file_path, 'r', encoding='utf-8') as f:
                        code = f.read()
                    print(f"Compilation for {times} times..")
                    subprocess.run(['solc-select', 'use', version], stdout=subprocess.DEVNULL)
                    compile_output = subprocess.run(['solc', file_path], stderr=subprocess.PIPE, text=True)
                    message = compile_output.stderr

                    if "Error: " not in message:
                        print("Pass compilation.")
                        compile_flag = True
                        break
                    
                    print("Compilation Failed.")
                    prompt = f'''You are an AI code assistant specializing in smart contract development. 
                    Your task is to analyze a given smart contract source code that has failed to compile, 
                    along with the compilation error messages provided. 
                    Based on above information, you will modify the source code to ensure that it compiles successfully.
                    The source code is as follows:\n {code}\n
                    The error message is as follows:\n {message}
                    Please ensure that no content in the function {file[:-4]} is modified in any way, including the addition of comments.
                    '''
                    result = get_response(prompt)
                    if result:
                        modified_code = extract_solidity_code(result)
                        if modified_code:
                            with open(file_path, 'w', encoding='utf-8') as f_:
                                f_.write(modified_code)
                            print("Modified code written in the original file.")
                        else:
                            print("No code found in the response.")
                    else:
                        print("LLM failed to analyze it.")