import json
import re
import os
ignored_funcs = [
    # arithmetic
    "add",
    "sub",
    "mul",
    "div",

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

def remove_comments(source_code):
    comment_pattern = r'//.*?$|/\*.*?\*/|///.*?$'

    no_comments_code = re.sub(comment_pattern, '', source_code, flags=re.MULTILINE | re.DOTALL)
    
    cleaned_code = re.sub(r'\n\s*\n', '\n', no_comments_code).strip()

    return cleaned_code

def extract_function_names_from_solidity(source_path):
    
    with open(source_path, 'r', encoding='utf-8') as f:
        contract_source_code = f.read()

    contract_source_code_cleaned = remove_comments(contract_source_code)
    function_pattern = (
        r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*'  # function name
        r'\((.*?)\)\s*'                            # parameters
        r'(public|private|internal|external)?'     # visibility
    )
    function_matches = re.findall(function_pattern, contract_source_code_cleaned, re.DOTALL)
    
    function_declaration_pattern = r"^\s*function\s+(\w+)\s*\(.*?\)\s*.*?;\s*$"

    function_declaration_matches = re.findall(function_declaration_pattern, contract_source_code_cleaned, re.MULTILINE)
    def parse_parameters(param_str):
        if not param_str.strip():
            return []  
        
        parameters = []
        param_list = [param.strip() for param in param_str.split(',')]
        for param in param_list:
            parts = param.split()  
            if len(parts) == 2:
                param_type, param_name = parts
                parameters.append({'type': param_type, 'name': param_name})
            elif len(parts) == 1:  
                param_type = parts[0]
                parameters.append({'type': param_type, 'name': 'unnamed'})
        return parameters

    functions = []
    for match in function_matches:
        function_name = match[0]
        if function_name in function_declaration_matches:
            continue
        parameters = parse_parameters(match[1])  
        visibility = match[2] if match[2] else 'internal'  
        functions.append({
            'name': function_name,
            'parameters': parameters,
            'visibility': visibility
        })

    return functions

def normalize_string(s):
    return re.sub(r'\W+', '', s.lower())

def SensFuncExtract(proj_path):
    total_todo_files = 0
    # print(proj_path)
    for root, _, files in os.walk(proj_path):
        for file in files:
            # print(file)
            if not file.endswith('.sol'):
                continue
            total_todo_files += 1
    cnt = 0
    for root, _, files in os.walk(proj_path):
        for file in files:
            if not file.endswith('.sol'):
                continue
            cnt += 1
            print(f"schedule: {cnt}/{total_todo_files}")
            filepath = root + '/' + file
            print(filepath)
            

            functions = extract_function_names_from_solidity(filepath)
            sens_funcs = [_['name'] for _ in functions]
            with open(filepath, 'r', encoding='utf-8') as f:
                source_code = f.read()

            func_map = {}
            for sens_func in sens_funcs:
                func_map[sens_func] = source_code

            safe_funcs = []
            for _ in func_map:
                if normalize_string(_) in ignored_funcs:
                    safe_funcs.append(_)
            for safe_func in safe_funcs:
                func_map.pop(safe_func, None)
            
            output_folder = filepath.replace('target/', 'sol_code/')[:-4]
            for func in func_map:
                if func_map[func] == None:
                    continue
                os.makedirs(output_folder, exist_ok=True)
                output_path = output_folder + '/' + func + '.sol'
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(func_map[func])