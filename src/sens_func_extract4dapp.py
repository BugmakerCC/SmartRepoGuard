import json
import re
import os
EIP_funcs = [
    # ERC-20 Standard Functions
    "totalsupply",
    "balanceof",
    "transfer",
    "transferfrom",
    "approve",
    "allowance",
    
    # ERC-721 Standard Functions
    "ownerof",
    "safetransferfrom",
    "getapproved",
    "setapprovalforall",
    "isapprovedforall",
    
    # ERC-1155 Standard Functions
    "balanceofbatch",
    "safetransferfrom",
    "safebatchtransferfrom"
]
    
def extract_functions(function_names, contract_code):
    functions_dict = {}

    for function_name in function_names:
        pattern = r'function\s+' + re.escape(function_name) + r'\s*\(.*?\)\s*.*?{'
        match = re.search(pattern, contract_code, re.DOTALL)

        if match:
            start_index = match.end() - 1  
            stack = 1
            end_index = start_index + 1
            while stack > 0 and end_index < len(contract_code):
                if contract_code[end_index] == '{':
                    stack += 1
                elif contract_code[end_index] == '}':
                    stack -= 1
                end_index += 1

            functions_dict[function_name] = contract_code[match.start():end_index].strip()

        else:
            functions_dict[function_name] = None  

    return functions_dict

def normalize_string(s):
    return re.sub(r'\W+', '', s.lower())

def SensFuncExtract(proj_path):
    total_todo_files = 0
    for root, _, files in os.walk(proj_path):
        for file in files:
            total_todo_files += 1

    cnt = 0
    for root, _, files in os.walk(proj_path):
        for file in files:
            cnt += 1
            print(f"schedule: {cnt}/{total_todo_files}")
            filepath = root + '/' + file
            print(filepath)
            with open(filepath, 'r', encoding='utf-8') as file:
                data = file.read()
            
            start_marker = '```json'
            end_marker = '```'
            
            start_index = data.find(start_marker)
            if start_index == -1:
                print("No JSON start marker found in the file.")
                continue
                
            start_index += len(start_marker)
            end_index = data.find(end_marker, start_index)
            if end_index == -1:
                print("No JSON end marker found in the file.")
                continue
            
            json_str = data[start_index:end_index].strip()
            try:
                json_data = json.loads(json_str)
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON: {e}")
            
            if not json_data or ("functions" not in json_data.keys()):
                continue
            
            sens_funcs = [func["name"] for func in json_data["functions"]]
            source_path = filepath.replace('sens_sig_res', 'target')[:-4] + '.sol'
            with open(source_path, 'r', encoding='utf-8') as f:
                source_code = f.read()

            func_map = extract_functions(sens_funcs,source_code)

            safe_funcs = []
            for _ in func_map:
                if normalize_string(_) in EIP_funcs:
                    safe_funcs.append(_)
            for safe_func in safe_funcs:
                func_map.pop(safe_func, None)
            
            output_folder = filepath.replace('sens_sig_res', 'sens_code')[:-4]
            for func in func_map:
                if func_map[func] == None:
                    continue
                os.makedirs(output_folder, exist_ok=True)
                output_path = output_folder + '/' + func + '.code'
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(func_map[func])