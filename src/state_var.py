import subprocess
import json
from contract import Contract
    
def analyze_state_var(contract: Contract):
    version = contract.get_version()
    subprocess.run(['solc-select', 'use', version], stdout=subprocess.DEVNULL)
    state_vars = []
    try:
        result = subprocess.run(['slither', contract.get_name(), '--print', 'variable-order', '--json', '-'], capture_output=True, text=True)
        state_var_json = json.loads(result.stdout)
        if state_var_json["success"]:
            for c in state_var_json["results"]["printers"][0]["elements"]:
                for i in c["name"]["content"]["rows"]:
                    var_name = i[0].split(".")[1]
                    var_type = i[1]
                    state_vars.append(f"{var_name}({var_type})")
        return state_vars
    except Exception as e:
        print("State Var Analyze Failed!")
        print(e)
        return state_vars