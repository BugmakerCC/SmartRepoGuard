# function snippet completion
from API_call import get_response, save_analysis_results, extract_solidity_code
import os
def CodeCompletion(sens_code_path):
    total_todo_files = 0
    for root, _, files in os.walk(sens_code_path):
        for file in files:
            if file.endswith('.code'):
                total_todo_files += 1

    cnt = 0
    for root, _, files in os.walk(sens_code_path):
        for file in files:
            if file.endswith('.code'):
                cnt += 1
                code_change = 0
                print(f"schedule: {cnt}/{total_todo_files}")
                file_path = os.path.join(root, file)
                print(file_path)
                res_path = file_path.replace('sens_code/', 'sol_code/')[:-5] + '.sol'
                with open(file_path, 'r', encoding='utf-8') as f:
                    code_content = f.read()
                no_code_output = 0
                if os.path.exists(res_path):
                    with open(res_path, 'r', encoding='utf-8') as f:
                        exist_code = f.read()
                    if code_content in exist_code:
                        print("Current code is okay.")
                        continue

                while not os.path.exists(res_path):
                    if no_code_output > 3:
                        print("No code output for 3 times, skip.")
                        break
                    if code_change > 3:
                        print("code changed for 3 times, skip.")
                        break
                    prompt = f"""You are now a smart contract expert. Please expand a smart contract function into a complete and compilable smart contract. Ensure that:

                                1.	Preserve the original function exactly as it is, without adding any modifiers or making alterations to it.
                                2.  Ensure no modifications are made to the original code, including any additions of comments.
                                3.	No external dependencies or imports are introduced.

                                Here is the code snippet: \n{code_content}"""

                    output = get_response(prompt)
                    if not output:
                        continue
                    code = extract_solidity_code(output)
                    if code:
                        save_analysis_results(res_path, code)
                    else:
                        no_code_output += 1
                        print("Analysis Failed!")