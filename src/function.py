class Function:
    def __init__(self, name:str=None, type:str=None, params:list=[], visibility:str=None, cfg:dict=None, dependency:str=None, sensitive:bool=False):
        """
        :param name: function name
        :param type: function type
        :param cfg: Control Flow Graph (optional)
        :param dependency: dependency graph (optional)
        :param sensitive: boolean
        """
        self.name = name
        self.type = type
        self.params = params
        self.visibility = visibility
        self.cfg = cfg  
        self.dependency = dependency  
        self.sensitive = sensitive

    def __str__(self):
        return (f"Function(name={self.name}, "
                f"type={self.type}, "
                f"cfg={self.cfg}, "
                f"dependency={self.dependency}, "
                f"sensitive={self.sensitive})")

    def get_visibility(self):
        return self.visibility
    
    def set_visibility(self, v:str):
        self.visibility = v
        
    def get_params(self):
        return self.params

    def get_type(self):
        return self.type

    def set_sensitive(self, is_sensitive:bool):
        """
        :param is_sensitive: boolean
        """
        self.sensitive = is_sensitive

    def get_sensitive(self):
        return self.sensitive
        
    def get_name(self):
        return self.name
    
    def set_cfg(self, cfg_content:dict):
        if not isinstance(cfg_content, dict):
            raise ValueError("CFG should be a dict.")
        
        self.cfg = cfg_content

    def get_cfg(self):
        return self.cfg
    