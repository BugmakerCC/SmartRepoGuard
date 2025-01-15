from dapp_analyze import DAppAnalyze
from smartcontract_analyze import SmartContractAnalyze
import sys

def main():
    '''
    python main.py -[analyze_type] [target_path]

    analyze_type: 'sc'(smart contract) or 'dapp'(DApp)
    target_path: ./path/to/your/file(directory)
    '''
    if len(sys.argv) == 3:
        analyze_type = sys.argv[1][1:]
        target_path = sys.argv[2]
        if analyze_type == 'sc':
            SmartContractAnalyze(target_path)
        elif analyze_type == 'dapp':
            DAppAnalyze(target_path)
        else:
            print("Analyze type error. Type should be like '-sc'(smart contract) or '-dapp'(DApp)")
    else:
        print("Parameters error. Command should be like 'python main.py [analyze_type] [target_path]'")
        pass

main()