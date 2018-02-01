classdef agent_4s
   properties
      P_index = 1;
      S_index = 1;
      next_S_index = 1;
      id
      P = zeros(1,4);
      noise_level = zeros(1,4)
      state = zeros(1,4)
      C
      C_profile = []
      Q
   end
   methods
      function obj = agent_4s(id,noise_level)
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
        obj.C_profile = [obj.C_profile c];
      end
      
   end
end
