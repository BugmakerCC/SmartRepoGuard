import re

def extract_solidity_code(content):
    pattern = r"```solidity(.*?)```"  
    match = re.search(pattern, content, re.DOTALL)  

    if match:
        solidity_code = match.group(1).strip()  
        return solidity_code
    else:
        print("未检测到solidity代码!")
        return None