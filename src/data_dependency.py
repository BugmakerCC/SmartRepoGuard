import json
import subprocess
import os

def extract_dependencies(node, var_dependencies, current_var=None):
    
    operators = {"=", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", "&=", "^=", "|="}
    
    if isinstance(node, dict):
        
        if node.get("type") == "VariableDeclaration":
            current_var = node["name"]
            if not (current_var in var_dependencies):
                var_dependencies[current_var] = set()
        
        if node.get("type") == "VariableDeclarationStatement":
            for variable in node["variables"]:
                if variable == None:
                    continue
                current_var = variable["name"]
                if not (current_var in var_dependencies):
                    var_dependencies[current_var] = set()
                if node.get("initialValue"):
                    
                    right_vars = extract_all_vars(node["initialValue"])
                    
                    if check_msg_sender(node["initialValue"]):
                        right_vars.append("msg.sender")
                    for right_var in right_vars:
                        var_dependencies[current_var].add(right_var)

        
        if node.get("type") == "BinaryOperation" and node["operator"] in operators:
            left_var = extract_base_var(node["left"])
            right_vars = extract_all_vars(node["right"])
            
            if check_msg_sender(node["right"]):
                right_vars.append("msg.sender")
            for right_var in right_vars:
                if left_var in var_dependencies:
                    var_dependencies[left_var].add(right_var)

        
        for key, value in node.items():
            extract_dependencies(value, var_dependencies, current_var)

    elif isinstance(node, list):
        
        for item in node:
            extract_dependencies(item, var_dependencies, current_var)

def extract_base_var(node):
    
    if node.get("type") == "MemberAccess":
        
        if isinstance(node["expression"], dict):
            return extract_base_var(node["expression"])
        else:
            return node["expression"]["name"]
    elif node.get("type") == "IndexAccess":
        return extract_base_var(node["base"])
    elif node.get("type") == "Identifier":
        return node["name"]
    return None

def extract_all_vars(node):
   
    vars = []
    if node.get("type") == "Identifier":
        vars.append(node["name"])
    
    elif node.get("type") == "IndexAccess":
        return extract_all_vars(node["base"])
    
    elif node.get("type") == "MemberAccess":
        if "name" in node["expression"]:
            if node["expression"]["name"] == "msg" and node["memberName"] == "sender":
                vars.append("msg.sender")
        vars.extend(extract_all_vars(node["expression"]))
   
    elif node.get("type") == "TupleExpression":
        for component in node.get("components", []):
            vars.extend(extract_all_vars(component))
    
    elif node.get("type") == "FunctionCall" and node["expression"]["type"] == "MemberAccess":
        vars.extend(extract_all_vars(node["expression"]))
        for arg in node.get("arguments", []):
            vars.extend(extract_all_vars(arg))
    
    elif node.get("type") == "FunctionCall":
        for arg in node.get("arguments", []):
            vars.extend(extract_all_vars(arg))
    return vars

def check_msg_sender(node):
    
    if isinstance(node, dict):
        
        if node.get("type") == "MemberAccess" and "name" in node["expression"]:
            if node["expression"]["name"] == "msg" and node["memberName"] == "sender":
                return True
        for key, value in node.items():
            if check_msg_sender(value):
                return True
    elif isinstance(node, list):
        for item in node:
            if check_msg_sender(item):
                return True
    return False

def filter_exception_values(var_dependencies):
    
    if None in var_dependencies:
        var_dependencies.pop(None)
    for var in var_dependencies:
        if var in var_dependencies[var]:
            var_dependencies[var].remove(var)
        if 'this' in var_dependencies[var]:
            var_dependencies[var].remove('this')
        if 'msg' in var_dependencies[var]:
            var_dependencies[var].remove('msg')
    return var_dependencies

def graph_extract(ast_path):
    
    with open(ast_path, 'r', encoding='utf-8') as file:
        ast = json.load(file)
    var_dependencies = {}
    extract_dependencies(ast, var_dependencies)
    var_dependencies = filter_exception_values(var_dependencies)
    
    var_dependencies = {var: list(deps) for var, deps in var_dependencies.items()}
    return var_dependencies