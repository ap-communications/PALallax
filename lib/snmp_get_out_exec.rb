module Fluent
  class SnmpInput
    def out_exec manager, opts = {}
      manager.get(opts[:mib]).each_varbind do | vb |
        record = {}
  
        time = Engine.now.to_i 

        key = case vb.name.to_s
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.1" then :cplane_cpu_load
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.2" then :dplane_cpu_load
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.1" then :fan_rotation_frequency
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.3" then :system_temperature
              else; nil
              end
        record[key] = vb.value.to_i if key
        Engine.emit opts[:tag], time, record
      end
    end
  end
end
