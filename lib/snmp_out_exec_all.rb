# -*- encoding: utf-8 -*-

require 'pr_geohash'
require 'geoip'

module Fluent
  class SnmpTrapInput
    def out_exec(options)
      Thread.new do
        manager = options[:manager]
        manager.on_trap_default do |trap|
          tag = options[:tag]
          time = Engine.now
          time = time - time % 5
          record0 = {}
          trap.varbind_list.each do | entry |
            record0[entry.name.inspect.to_json] = entry.value
          end
          record = key_translate(record0)
          Engine.emit(tag, time,record)
        end
        trap("INT") { manager.exit }
        manager.join
      end
    end

    def key_translate(record)
      record2 = {}
      severities = ['informational', 'low', 'medium', 'high', 'critical']
      record.each_pair do |key, value|
         key2 = case key
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.2]\""   then :receive_time
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.3]\""   then :serial
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.4]\""   then :type
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.5]\""   then :subtype
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.7]\""   then :vsys
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.8]\""   then :sequence_number
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.9]\""   then :action_flags
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.50]\""  then :source_ip
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.51]\""  then :destination_ip
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.52]\""  then :nat_source_ip
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.53]\""  then :nat_destination_ip
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.54]\""  then :rule_name
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.55]\""  then :source_user
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.56]\""  then :destination_user
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.57]\""  then :application
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.58]\""  then :source_zone
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.59]\""  then :destination_zone
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.60]\""  then :ingress_interface
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.61]\""  then :egress_interface
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.62]\""  then :log_action
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.63]\""  then :session_id
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.64]\""  then { key: :repeat_count, func: :to_i }
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.65]\""  then :source_port
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.66]\""  then :destination_port
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.67]\""  then :nat_source_port
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.68]\""  then :nat_destination_port
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.69]\""  then :flags
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.70]\""  then :protocol
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.71]\""  then :action
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.72]\""  then :time_generated
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.73]\""  then :source_country
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.74]\""  then :destination_country
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.100]\"" then { key: :traffic_bytes, func: :to_i }
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.101]\"" then { key: :traffic_packets, func: :to_i }
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.102]\"" then :traffic_start_time
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.103]\"" then :traffic_elapsed
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.104]\"" then :traffic_category
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.200]\"" then :threat_id
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.201]\"" then :threat_category
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.202]\"" then :threat_content_type
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.203]\"" then :threat_severity
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.204]\"" then :threat_direction
                when "\"[1.3.6.1.4.1.25461.2.1.3.1.205]\"" then :url
                else; nil
                end
         if key2.respond_to?(:to_hash)
           value2 = value.send(key2[:func])
           record2[key2[:key]] = value2
         elsif key2.respond_to?(:to_sym)
           record2[key2] = value
         end
      end
      dest_city = GeoIP.new('vendor/geoip/GeoLiteCity.dat').city(record2[:destination_ip])
      dest_meta = if dest_city
        { destination_geohash: GeoHash.encode(dest_city.longitude, dest_city.latitude) }
      else
        {}
      end
      src_city = GeoIP.new('vendor/geoip/GeoLiteCity.dat').city(record2[:source_ip])
      src_meta = if src_city
        { source_geohash: GeoHash.encode(src_city.longitude, src_city.latitude) }
      else
        {}
      end
      record2.merge(dest_meta)
             .merge(src_meta)
    end
  end
end
