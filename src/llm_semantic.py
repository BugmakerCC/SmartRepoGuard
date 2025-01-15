prompt = f"""You are an expert in semantic analysis of vulnerability reports. Analyze the following smart contract vulnerability report to determine whether it indicates the presence of vulnerabilities in the smart contract.
•	If the report indicates the smart contract has vulnerabilities, output: Result: 1.
•	If the report indicates the smart contract has no vulnerabilities, output: Result: 0.
Note:
•	Focus only on the semantic content of the report.
•	Ensure the output is strictly formatted as Result: 1 or Result: 0.
Here is the vulnerability report:\n"""