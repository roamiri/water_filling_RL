classdef agent
   properties
      index
      id
      P 
      noise_level
      state = zeros(1,2)
      C
      C_profile = []
      Q
   end
   methods
      function obj = agent(id,noise_level)
        obj.id = id;
        obj.noise_level = noise_level;
      end
      
      function obj = setQTable(obj,QTable)
          obj.Q = QTable;
      end
      
      function obj = setPower(obj,power)
%           obj.P = 10^((power-30)/10);
            obj.P = power;
%             obj.powerProfile = [obj.powerProfile power];
      end
      
      function obj = setCapacity(obj,c)
        obj.C_FUE = c;
%         obj.C_profile = [obj.C_profile c];
      end
      
   end
end
