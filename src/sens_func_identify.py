import os
from API_call import get_response, save_analysis_results

def SensFuncIdentify(dapp_path):
    total_todo_files = 0
    for root, _, files in os.walk(dapp_path):
        for file in files:
            if file.endswith('.sol'):
                total_todo_files += 1

    cnt = 0
    for root, _, files in os.walk(dapp_path):
        for file in files:
            if file.endswith('.sol'):
                cnt += 1
                print(f"schedule: {cnt}/{total_todo_files}")
                file_path = os.path.join(root, file)
                print(file_path)
                res_path = file_path.replace('target/', 'sens_sig_res/')[:-4] + '.txt'
                while not os.path.exists(res_path):
                    output = None
                    if "interface" in file_path.lower() or "librar" in file_path.lower() or "util" in file_path.lower() or "mock" in file_path.lower() or "test" in file_path.lower():
                        print("Safe file, skip.")
                        break

                    with open(file_path, 'r', encoding='utf-8') as f:
                        code_content = f.read()

                    prompt = f"""Please analyze the following smart contract and identify any functions involving sensitive operations, specifically:
                                •	Transfers
                                •	SelfDestruction
                                •	State variable modification
                                •	External contract calls
                                Return the results in JSON format with function signatures, following this structure: 'functions': [{{'name': 'setProofType', 'parameters': ['byte _proofType']}}]. 
                                The code is as follows:\n{code_content}"""

                    output = get_response(prompt)

                    if output:
                        save_analysis_results(res_path, output)
                    else:
                        print("Analysis Failed!")