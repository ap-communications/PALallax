# -*- encoding: utf-8 -*-

module Fluent
  class SnmpInput
    def out_exec manager, opts = {}

    # Get os version
    os_v = 0
    manager.get(["1.3.6.1.4.1.25461.2.1.2.1.1.0"]).each_varbind { | vb | os_v = vb.value.to_i}

    if os_v > 5 then
      # PAN-OS 6.1.x
      manager.get(opts[:mib]).each_varbind do | vb |
        record = {}
        time = Engine.now.to_i
        key = case vb.name.to_s
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.1" then :cplane_cpu_load
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.2" then :dplane_cpu_load
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.2" then :fan_rotation_frequency
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.4" then :system_temperature
              when "SNMPv2-SMI::enterprises.25461.2.1.2.3.3.0" then :current_session
              else; nil
              end

         record[key] = vb.value.to_i if key
         Engine.emit opts[:tag], time, record
      end

    else
      # PAN-OS 5.1.x
      manager.get(opts[:mib]).each_varbind do | vb |
        record = {}
        time = Engine.now.to_i
        key = case vb.name.to_s
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.1" then :cplane_cpu_load
              when "SNMPv2-SMI::mib-2.25.3.3.1.2.2" then :dplane_cpu_load
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.1" then :fan_rotation_frequency
              when "SNMPv2-SMI::mib-2.99.1.1.1.4.3" then :system_temperature
              when "SNMPv2-SMI::enterprises.25461.2.1.2.3.3.0" then :current_session
              else; nil
              end

         record[key] = vb.value.to_i if key
         Engine.emit opts[:tag], time, record
      end
     end

   end
  end
end
