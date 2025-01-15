import os
import re
import json
from function import Function
from contract import Contract
from CG import get_CG
from CFG import get_CFG
from data_dependency import graph_extract
from sens_func_extract4sc import remove_comments
from vul_detect import detect
from state_var import analyze_state_var
import subprocess

def get_version(source_path):
    with open(source_path, 'r', encoding='utf-8') as f:
        source = f.read()
    version_pattern = re.compile(r'pragma\s+solidity\s+\^?(\d+\.\d+\.\d+);')
    match = version_pattern.search(source)

    if match:
        version = match.group(1)
        return version
    else:
        print("Version match failed.")
        return None

def extract_function_and_modifier_names_from_solidity(source_path):
    
    with open(source_path, 'r', encoding='utf-8') as f:
        contract_source_code = f.read()
    contract_source_code_cleaned = remove_comments(contract_source_code)
    
    function_pattern = (
        r'function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*'  
        r'\((.*?)\)\s*'                            
        r'((?:[a-zA-Z_][a-zA-Z0-9_]*\s*)*)'       
    )

    modifier_pattern = (
        r'modifier\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*'  
        r"(?:\((.*?)\))?\s*"                       
        r'.*?{'                                    
    )

    function_matches = re.findall(function_pattern, contract_source_code_cleaned, re.DOTALL)
    modifier_matches = re.findall(modifier_pattern, contract_source_code_cleaned, re.DOTALL)

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
    
    def parse_vis(vis_str):
        if 'private' in vis_str or 'internal' in vis_str:
            return 'internal'
        else:
            return 'public'

    functions = []
    for match in function_matches:
        function_name = match[0]
        parameters = parse_parameters(match[1])  
        visibility = parse_vis(match[2])
        functions.append({
            'name': function_name,
            'parameters': parameters,
            'visibility': visibility
        })

    modifiers = []
    for match in modifier_matches:
        modifier_name = match[0]
        parameters = parse_parameters(match[1])  
        modifiers.append({
            'name': modifier_name,
            'parameters': parameters
        })

    result = {
        'functions': functions,
        'modifiers': modifiers
    }

    return result

def serialize_contracts(data):
    if isinstance(data, dict):
        return {key: serialize_contracts(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [serialize_contracts(item) for item in data]
    elif isinstance(data, Contract):  
        return str(data.get_safety())  
    else:
        return data

def code_changed(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        current_code = f.read()
    sens_code_path = filepath.replace('sol_code/', 'sens_code/')[:-4] + '.code'
    with open(sens_code_path, 'r', encoding='utf-8') as f_:
        sens_code = f_.read()
    if sens_code not in remove_comments(current_code):
        return True
    return False

vulnerabilities = [
    "Selfdestruct without permission control.",
    "External contract call without permission control.",
    "State variable modification without permission control.",
    "Risky transfer without permission control.",
    "tx.origin vulnerability."
]

def StaticAnalysis(directory, type_):
    # contracts = {}
    total_todo_files = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                total_todo_files += 1

    cnt = 0
    failure = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sol'):
                cnt += 1
                file_path = os.path.join(root, file)
                print(file_path)
                print(f"schedule: {cnt}/{total_todo_files}")
                if "interface" in file_path.lower() or "librar" in file_path.lower() or "util" in file_path.lower() or "mock" in file_path.lower() or "test" in file_path.lower():
                    print("Safe file, skip.")
                    continue
                result_path = file_path.replace('sol_code', 'result')[:-4] + '.res'
                if os.path.exists(result_path):
                    print("Result already exists.")
                    continue
                dirs = os.path.dirname(result_path)
                os.makedirs(dirs, exist_ok=True)
                version = get_version(file_path)
                if not version:
                    version = '0.8.0'
                try:
                    subprocess.run(['solc-select', 'use', version])
                except Exception as e:
                    print(e)
                    subprocess.run(['solc-select', 'install', version])
                    subprocess.run(['solc-select', 'use', version], stdout=subprocess.DEVNULL)
                contract = Contract(file_path,version=version)
                TempGraph = get_CG(file_path)
                
                if not TempGraph:
                    failure += 1
                    print("Compilation failed.")
                    with open(result_path, 'w') as f:
                        f.write(contract.get_safety())
                    continue

                functions_and_modifiers = extract_function_and_modifier_names_from_solidity(file_path)
                func_node_list = []
                for func in functions_and_modifiers['functions']:
                    if func['name'] == file[:-4]:
                        f = Function(name=func['name'], type='function', params=func['parameters'], visibility=func['visibility'], sensitive=True)
                        func_node_list.append(f)
                    else:
                        f = Function(name=func['name'], type='function', params=func['parameters'], visibility=func['visibility'], sensitive=False)
                        func_node_list.append(f)

                mod_node_list = []
                for mod in functions_and_modifiers['modifiers']:
                    f = Function(name=mod['name'], type='modifier', params=func['parameters'], visibility='public', sensitive=False)
                    mod_node_list.append(f)

                node_list = func_node_list + mod_node_list
                
                FuncMap = {}
                for i in node_list:
                    FuncMap[i.get_name()] = i

                CallGraph = {}
                for func_key in TempGraph:
                    if func_key in FuncMap.keys():
                        key = FuncMap[func_key]
                        values = set()
                        for func_value in TempGraph[func_key]:
                            if func_value in FuncMap.keys():
                                values.add(FuncMap[func_value])
                            else:
                                continue
                        CallGraph[key] = values
                    else:
                        continue
                
                
                Compiled_CallGraph = get_CFG(file_path, CallGraph)["CG"]
                compiled_flag = get_CFG(file_path, CallGraph)["flag"]
                contract.set_compiled(compiled_flag)
                contract.set_callgraph(Compiled_CallGraph)
                
                

                if not contract.get_compiled():
                    with open(result_path, 'w') as f:
                        f.write(contract.get_safety())
                    continue

                state_vars = analyze_state_var(contract)
                contract.set_state_vars(state_vars)

                conclusion = detect(contract, type_)
                if conclusion in vulnerabilities:
                    contract.set_safety(conclusion)
                else:
                    contract.set_safety('Secure')
                
                with open(result_path, 'w') as f:
                    f.write(contract.get_safety())
    print(f"Num of Compilation Failure: {failure}")