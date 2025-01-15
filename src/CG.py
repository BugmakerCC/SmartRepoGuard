import json
import subprocess
import os

def getAST(filepath):
    """
    Generate the AST for the Solidity contract by calling an external Node.js script.
    
    Args:
        filepath (str): Path to the Solidity contract file.
    """
    output_path = ('./temp_ast/' + filepath)
    command = ['solc', filepath, '--ast-compact-json', '-o', output_path, '--overwrite']
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode == 0:
        # print(f"AST successfully generated at {output_path}")
        return output_path + '/' + output_path[output_path.rfind('/') + 1:] + '_json.ast'
    else:
        print(f"Error generating AST: {result.stderr}")
        return None


def find_function_calls(node, current_function, call_relations):
    """Recursively find function calls in the AST node."""
    if isinstance(node, dict):
        if node.get("nodeType") == "FunctionDefinition" and "name" in node:
            current_function = node["name"] if node["name"] else "Anonymous Function"
            call_relations[current_function] = []
        
            # modifier call
            if "modifiers" in node:
                modifiers = [mod.get("modifierName") for mod in node["modifiers"] if "modifierName" in mod]
                modifier_names = [mod.get("name") for mod in modifiers if "name" in mod]
                call_relations[current_function].extend(modifier_names)
        
        if node.get("nodeType") == "FunctionCall":
            if current_function:
                called_function = node["expression"].get("memberName", None)
                if called_function:
                    call_relations[current_function].append(called_function)

        for key, value in node.items():
            find_function_calls(value, current_function, call_relations)

    elif isinstance(node, list):
        for item in node:
            find_function_calls(item, current_function, call_relations)


def extract_function_calls(ast_json):
    """Extracts and prints function call relationships from the AST JSON."""
    call_relations = {}
    find_function_calls(ast_json, None, call_relations)
    keys_to_remove = ['sub', 'div', 'add', 'mul']  # safe key
    for key in keys_to_remove:
        call_relations.pop(key, None)
    for func in call_relations:
        call_relations[func] = set(call_relations[func]) - {'sub', 'div', 'add', 'mul'}
    return call_relations

def get_CG(contract_file):
    # Generate the AST
    ast_path = getAST(contract_file)

    # Load the AST from the JSON file
    try:
        with open(ast_path, 'r') as f:
            ast_json = json.load(f)

        # Extract and print function call relationships
        cg = extract_function_calls(ast_json)
        return cg
    except Exception as e:
        print(e)
        return None
