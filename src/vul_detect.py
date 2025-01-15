from contract import Contract
from function import Function
from CFG import parse_dot
import re


def build_chain_from_edges(edges, start_node):
    edge_dict = {start: end for start, end in edges}
    
    chain = [start_node]
    
    current_node = start_node
    while current_node in edge_dict:
        next_node = edge_dict[current_node]
        chain.append(next_node)
        current_node = next_node
    
    return chain

def msg_sender_exist(slithIRs: list, file_path) -> bool:
    flag = False
    for ir in slithIRs:
        if 'msg.sender' in ir:
            return True
        if 'INTERNAL_CALL' in ir or 'LIBRARY_CALL' in ir:
            flag = call_return_msg_sender(ir, file_path)
    return flag

def return_value_is_msg_sender(cfg):
    for node_id in cfg['nodes']:
        if cfg['nodes'][node_id]['IRs'] == None:
            continue
        for ir in cfg['nodes'][node_id]['IRs']:
            if ir == 'RETURN msg.sender':
                return True
    return False

def comparison_exists(cfg):
    symbols = ['==', '!=', '>', '<', '>=', '<=']
    for node_id in cfg['nodes']:
        if cfg['nodes'][node_id]['IRs'] == None:
            continue
        for ir in cfg['nodes'][node_id]['IRs']:
            if any(symbol in ir.split() for symbol in symbols) or '(bool)' in ir:
                return True
    return False

def check_msg_value(cfg):
    for node_id in cfg['nodes']:
        if cfg['nodes'][node_id]['IRs'] == None:
            continue
        for ir in cfg['nodes'][node_id]['IRs']:
            if 'msg.value' in ir:
                return True
    return False

def call_return_msg_sender(ir: str, file_path: str) -> bool:
    match = re.search(r"(\w+)\.(\w+\(.*?\))", ir)
    if match:
        contr_name = match.group(1)  
        func_sig = match.group(2)   
    else:
        return False
    call_path = file_path + '-' + contr_name + '-' + func_sig + '.dot'
    try:
        with open(call_path, 'r', encoding='utf-8') as f:
            dot_content = f.read()
        call_cfg = parse_dot(dot_content)
        if return_value_is_msg_sender(call_cfg):
            return True
    except Exception as e:
        print(e)
    return False

def msg_sender_as_parameter(slithIRs: list, file_path: str):
    msg_sender_para = False
    for ir in slithIRs:
        if 'INTERNAL_CALL' in ir or 'LIBRARY_CALL' in ir:
            match = re.search(r"arguments:\s*(\[[^\]]*\])", ir)
            if match:
                arguments_list = match.group(1)  
            elif "(address)(msg.sender)" in ir:
                arguments_list = ['msg.sender']
            else:
                continue
            if 'msg.sender' in arguments_list:
                msg_sender_para = True
            else:
                continue
            if msg_sender_para and '(bool)' in ir:
                return True
            match2 = re.search(r"(\w+)\.(\w+\(.*?\))", ir)
            if match2:
                contr_name = match2.group(1)  
                func_sig = match2.group(2)   
            else:
                continue
            call_path = file_path + '-' + contr_name + '-' + func_sig + '.dot'
            try:
                with open(call_path, 'r', encoding='utf-8') as f:
                    dot_content = f.read()
                call_cfg = parse_dot(dot_content)
                if comparison_exists(call_cfg):
                    comparison_exist = True
                if msg_sender_para and comparison_exist:
                    return True
            except Exception as e:
                print(e)
    return False
            
def is_state_var_modified(ir:str, state_vars:list) -> bool:
    state_var_names = [item[:item.find('(')] for item in state_vars]
    if '(->' in ir and ':=' in ir:
        start_index = ir.find('(->')
        end_index = ir.find(')', start_index)
        var_name = ir[start_index + 3 : end_index]
        if var_name.strip() in state_var_names:
            return True
    elif ':=' in ir:
        if ir.split(':=')[0].strip() in state_vars:
            return True
    elif '(-> ' in ir and ')' in ir:
        start_index = ir.find('(-> ')
        end_index = ir.find(')', start_index)
        var_name = ir[start_index + 4 : end_index]
        if var_name.strip() in state_var_names:
            return True
    else:
        return False

def extract_contract_names(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        solidity_code = file.read()

    contract_name_pattern = r"\bcontract\s+(\w+)\s+(?:is\s+[\w\s,]+)?\s*{"
    contract_names = re.findall(contract_name_pattern, solidity_code)

    return contract_names


def is_transfer(ir:str) -> bool:
    if 'Transfer dest' in ir:
        return True
    
    if 'HIGH_LEVEL_CALL' in ir and any(token in ir for token in ['ERC20', 'ERC721', 'ERC-1155']):
        start_index = ir.find('function:')
        end_index = ir.find(',', start_index)
        function_name = ir[start_index + len('function:'):end_index].strip()
        if 'transfer' in function_name.lower():
            return True
    return False

def detect(contract: Contract, type_):
    contract_names = extract_contract_names(contract.get_name())
    file_path = contract.get_name()
    access_checked = False
    CallGraph = contract.get_callgraph()
    state_vars = contract.get_state_vars()
    sensitive_function = None
    for function in CallGraph:
        if function.get_sensitive():
            sensitive_function = function
            break
    if sensitive_function:
        modifiers = [modifier for modifier in CallGraph[sensitive_function] if modifier.get_type() == 'modifier']
        if type_ == 'dapp' and modifiers != []:
            access_checked = True
            return access_checked
    else:
        print("Sensitive Function not Found!")
        access_checked = True
        return access_checked

    if sensitive_function.get_name() in contract_names:
        return True

    if sensitive_function.get_visibility() == 'internal' or sensitive_function.get_visibility() == 'private':
        access_checked = True
        return access_checked
    
    if sensitive_function.get_cfg():
        cfg = sensitive_function.get_cfg()
        state_var_modified_in_calls = False
        function_calls = CallGraph[sensitive_function]
        for function_call in function_calls:
            if state_var_modified_in_calls:
                break
            function_call_cfg = function_call.get_cfg()
            function_call_link = build_chain_from_edges(function_call_cfg['edges'], '0')
            for block in function_call_link:
                if state_var_modified_in_calls:
                    break
                if not function_call_cfg['nodes']:
                    continue
                if function_call_cfg['nodes'][block]['IRs']:
                    for ir in function_call_cfg['nodes'][block]['IRs']:
                        if is_state_var_modified(ir, state_vars):
                            state_var_modified_in_calls = True
                            break


        for mod in modifiers:
            if access_checked:
                break
            mod_cfg = mod.get_cfg()
            if check_msg_value(mod_cfg):
                access_checked = True
                print("custom modifier check.")
                return access_checked
            link = build_chain_from_edges(mod_cfg['edges'], '0')
            mod_IRs = []
            for block in link:
                if access_checked:
                    break
                try:
                    if mod_cfg['nodes'][block]['IRs']:
                        mod_IRs.extend(mod_cfg['nodes'][block]['IRs'])
                except Exception as e:
                    print(e)
            if (msg_sender_exist(mod_IRs, file_path) and comparison_exists(mod_cfg)) or msg_sender_as_parameter(mod_IRs, file_path):
                access_checked = True
                print("custom modifier check.")
                return access_checked
                
                
        link = build_chain_from_edges(cfg['edges'], '0')
        state_var_modified = False
        transfer_flag = False
        selfdestruct_flag = False
        low_level_call_flag = False
        IRs = []
        if check_msg_value(cfg):
            print("msg.value exists.")
            access_checked = True
            return access_checked
        
        for block in link:
            if block not in cfg['nodes'].keys():
                continue
            
            if access_checked == True:
                break

            if not cfg['nodes']:
                print("CFG construction failed, please ensure sensitive function is not null.")
                break

            try:   
                if cfg['nodes'][block]['IRs']:
                    IRs.extend(cfg['nodes'][block]['IRs'])
                    for ir in cfg['nodes'][block]['IRs']:
                        if is_transfer(ir):
                            transfer_flag = True

                        if 'SOLIDITY_CALL selfdestruct' in ir:
                            selfdestruct_flag = True
                            break
                            
                        if "tx.origin" in ir:
                            return "tx.origin vulnerability"

                        if 'LOW_LEVEL_CALL' in ir:
                            low_level_call_flag = True
                            break

                        if is_state_var_modified(ir, state_vars):
                            state_var_modified = True

                        if ".onlyOwner" in ir:
                            print("library check.")
                            access_checked = True
                            return access_checked

            except Exception as e:
                print(e)

        if (msg_sender_exist(IRs, file_path) and comparison_exists(cfg)) or msg_sender_as_parameter(IRs, file_path):
            access_checked = True
            print("internal check.")
            return access_checked

        # 1. selfdestruct
        if selfdestruct_flag and access_checked == False:
            return "Selfdestruct without permission control."
        
        # 2. low-level call
        if low_level_call_flag and access_checked == False:
            return "External contract call without permission control."
        
        # 3. risky state variable modification
        if state_var_modified and transfer_flag == False and access_checked == False:
            return "State variable modification without permission control."
        
        # 4. risky transfer
        if transfer_flag and state_var_modified == False and state_var_modified_in_calls == False and access_checked == False:
            return "Risky transfer without permission control."
        
    return True