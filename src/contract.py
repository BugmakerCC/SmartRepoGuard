class Contract:
    def __init__(self, name:str=None, version:str=None, state_vars:list=[], dependency:dict=None, callgraph:dict=None, compiled:bool=False, safety:str="unknown"):
        """
        :param name: contract name
        :param version: solidity version
        :param state_vars: state variables
        :param callgraph: function call graph
        :param dependency: data dependency graph
        :param compiled: boolean 
        :param safety: boolean
        """
        self.name = name
        self.version = version
        self.state_vars = state_vars
        self.dependency = dependency
        self.callgraph = callgraph
        self.compiled = compiled
        self.safety=safety

    def __str__(self):
        return (f"Contract(name={self.name}, "
                f"dependency={self.dependency}, "
                f"CallGraph={self.callgraph})")
        
    def get_version(self):
        return self.version
    
    def get_name(self):
        return self.name
    
    def get_safety(self):
        return self.safety

    def get_compiled(self):
        return self.compiled

    def get_callgraph(self):
        return self.callgraph
    
    def get_dependency(self):
        return self.dependency

    def set_compiled(self, cp:bool):
        self.compiled = cp

    def set_callgraph(self, cg:dict):
        self.callgraph = cg

    def set_dependency(self, d:dict):
        self.dependency = d

    def set_safety(self, sf:str):
        self.safety = sf

    def set_state_vars(self, sv:list):
        self.state_vars = sv
    
    def get_state_vars(self):
        return self.state_vars

    def cg_to_str(self):
        res = {}
        if not self.callgraph:
            return None
        for key in self.callgraph:
            res[key.get_name()] = [value.get_name() for value in self.callgraph[key]]
        return res

    def to_dict(self):
        return {
            "Name": self.name,
            "Compiled": self.compiled,
            "Safety": self.safety
        }