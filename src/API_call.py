import os
import requests
import time
import re
proxy = {
    'http': 'http://127.0.0.1:7890',
    'https': 'http://127.0.0.1:7890'
}
api_url = 'https://www.gptapi.us/v1/chat/completions'


def extract_solidity_code(content):
    pattern = r"```solidity(.*?)```" 
    match = re.search(pattern, content, re.DOTALL)  

    if match:
        solidity_code = match.group(1).strip()  
        return solidity_code
    else:
        print("No solidity code found!")
        return None
    

def save_analysis_results(file_path, content):
    folder_path = os.path.dirname(file_path)
    
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def get_response(prompt):
    attempts = 10  
    request_input = [{"role": "user", "content": prompt}]
    for attempt in range(attempts):
        try:
            response = requests.post(api_url, json={
                'model': 'gpt-4o',
                'messages': request_input,
            }, headers={'Authorization': 'your-key'}, proxies=proxy)
            response_str = response.json()["choices"][0]["message"]["content"]
            return response_str

        except Exception as e:
            print(f"Fail: {e}. try {attempt + 1}/{attempts}...")
            time.sleep(10) 

    return None  