# coding: utf-8

require 'fluent/parser'
require 'fluent/output'
require 'fluent/plugin_helper'

module Fluent
  class FortiSyslogPaser < Output
    Plugin.register_parser('fortigate_syslog', self)
    helpers :event_emitter


    def initialize
      super
      tag = ""
    end

    desc "Setting Timezone"
    config_param :forti_time_zone, :integer, default: 0

    ENV['TZ'] = "UTC"

    def configure(conf)
      super
    end

    def parse(text)
      # parse syslog
      syslog_value = text.scan(/\w+=[\w+!#$%&'()-=^~|@`\[{;+:*\]},<\.>\/?\\_]+|\w+=\"[\w+\s+!#$%&'()-=^~|@`\[{;+:*\]},<\.>\/?\\_]*\"?+/)
      if syslog_value.length == 0 then raise "ERR001:syslog format error(wrong syslog format)" end
      logemit(syslog_value)
    end

    def logemit(syslog_value)
      # emit to elasticsearch
      record_value = {}
      date = ""
      datetime = ""
      syslog_value.each{|value|

        record = value.split("=")
        k = record[0]
        v = record[1]
        # date and time combining
        case k
          when "date" then
            date = v
            next
          when "time" then
            datetime = date.concat(" " + v)
            next
          when "eventtime" then
            eventtime = v.to_s
            epoch_sec = 10
            if eventtime.to_s.length > epoch_sec
              num_gap = eventtime.length - epoch_sec
              eventtime.slice!(10, num_gap)
              v = eventtime
            end
        end
        record_value["#{k}"] = (v == nil || v == "") ? nil : v.tr("\"","")
      }

      if date_formatcheck(datetime) != false then
        record_value["receive_time"] = time_transformation(datetime)
      else
        raise "ERR002:syslog format error(receive_time is not defined)"
      end

      if record_value["type"] == "traffic" then
        tag = "syslog_traffic.forti"
      elsif record_value["type"] == "utm" then
        tag = "syslog_security.forti"
      else
        raise "ERR003:syslog format error(type definition error)"
      end

      #Log emit
      time = Fluent::Engine.now
      router.emit(tag, time, record_value)
    end

    def date_formatcheck(datetimestr)
      require 'date'
      ! Date.parse(datetimestr).nil? rescue false
    end

    def time_transformation(syslog_time)
      require 'time'
      t = Time.parse(syslog_time) + (forti_time_zone * -3600)
      t.to_i
    end

 end
end