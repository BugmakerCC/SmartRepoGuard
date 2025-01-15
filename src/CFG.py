import subprocess
from function import Function
import os
import json
import re
def parse_dot(dot_content):
    nodes = {}
    edges = []
    
    # node
    node_pattern = r'(\d+)\[label="([^"]+)"\]'
    for match in re.finditer(node_pattern, dot_content):
        node_id = match.group(1)
        label = match.group(2).strip()
        
        node_type_match = re.search(r'Node Type:\s*(.*)', label)
        expression_match = re.search(r'EXPRESSION:\s*(.*?)(?:\n\s*IRs:|$)', label, re.DOTALL)
        irs_match = re.search(r'IRs:\s*(.*)', label, re.DOTALL)
    
        nodes[node_id] = {
            "Node Type": node_type_match.group(1).strip() if node_type_match else None,
            "EXPRESSION": expression_match.group(1).strip() if expression_match else None,
            "IRs": irs_match.group(1).strip().splitlines() if irs_match else None
        }

    # edge
    edge_pattern = r'(\d+)->(\d+);'
    for match in re.finditer(edge_pattern, dot_content):
        start_node = match.group(1)
        end_node = match.group(2)
        edges.append((start_node, end_node))
    
    return {"nodes": nodes, "edges": edges}


def get_func_name(s):
    left_paren_index = s.find('(')
    last_dash_index = s.rfind('-', 0, left_paren_index)
    if left_paren_index != -1 and last_dash_index != -1:
        return s[last_dash_index+1:left_paren_index].strip()
    else:
        print("No function name found in the file.")
        return None 
    
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

def get_CFG(file_path, CallGraph):
    compiled_flag = False
    try:
        version = get_version(file_path)
        subprocess.run(['solc-select', 'use', version], stdout=subprocess.DEVNULL)
        res = {}
        result = subprocess.run(['slither', file_path, '--print', 'cfg', '--json', '-'], capture_output=True, text=True)
        cfg_json = json.loads(result.stdout)
        if cfg_json["success"] == True:
            compiled_flag = True
            # key
            for key in CallGraph:
                for elem in cfg_json["results"]["printers"][0]["elements"]:
                    if get_func_name(elem["name"]["filename"]) == key.get_name():
                        temp_node = key
                        temp_node.set_cfg(parse_dot(elem["name"]["content"]))
                        values = CallGraph[key]
                        # value
                        for value in values:
                            for elem_ in cfg_json["results"]["printers"][0]["elements"]:
                                if get_func_name(elem_["name"]["filename"]) == value.get_name():
                                    value.set_cfg(parse_dot(elem_["name"]["content"]))
                        res[temp_node] = values
            return {'CG':res, 'flag':compiled_flag}

        else:

            return {'CG':CallGraph, 'flag':compiled_flag}
    
    except Exception as e:
        print(e)
        return {'CG':CallGraph, 'flag':compiled_flag}