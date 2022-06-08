# coding: utf-8

require 'fluent/parser'
require 'fluent/output'
require 'fluent/plugin_helper'

module Fluent
  class NozomiSyslogPaser < Output
    Plugin.register_parser('nozomi_syslog', self)
    helpers :event_emitter
  
    def initialize
        super
        tag = ""
    end

    desc "Settign of ES host"
    config_param :es_host, :string
    config_param :es_port, :string
    config_param :es_user, :string
    config_param :es_password, :string, secret: true
    config_param :es_ca_file, :string
    desc "Setting of Nozomi host"
    config_param :nozomi_host, :string
    config_param :nozomi_user, :string
    config_param :nozomi_pass, :string, secret: true
    desc "Setting Timezone"
    config_param :nozomi_time_zone, :integer, default: 0

    ENV['TZ'] = "UTC"
    
    def configure(conf)
        super
    end

    def parse(text)
        record_value = {}
        sp_value = text.split(/\A(\w{3}\s+\d{1,2}\s\d{2}:\d{2}:\d{2})\s(.*)\s(.*):\sCEF:/)
        record_value["receive_time"] = time_transformation(sp_value[1]) #Feb 20 18:29:26
        record_value["hostname"] = sp_value[2] #nozomi-n2os.local
        record_value["event"] = sp_value[3] #n2osevents[0]

        #cef_value = sp_value[4].split(/\A(\d)\|(.*\s?)\|(N2OS)\|(.*)\|(.*):(.*[:-].*)\|(.*\s?)\|(\d{1,2})\|(.*)/)
        cef_value = sp_value[4].split(/(.*)\|(.*)\|(.*)\|(.*)\|(.*):(.*[:-].*)\|(.*)\|(.*)\|(.*)|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)\|(.*)/)
        record_value["cef_version"] = cef_value[1] #0
        record_value["vender"] = cef_value[2] #Nozomi Networks
        record_value["product"] = cef_value[3] #N2OS
        record_value["osverson"] = cef_value[4] #21.8.0-12061235_00473
        record_value["type"] = cef_value[5] #SIGN

        if record_value["type"] == "HEALTH" #HEALTHにはサブタイプがない
          record_value["title"] = cef_value[6] #High rate of outbound connections
          record_value["severity"] = cef_value[7] #9
          syslog_value = cef_value[8].scan(/flex[\w\d]+=[[\w\d]\s]+(?=\sflex)|msg=[[\w\d!#$%&'()-=^~|@`\[{;+:*\]},]\s]+(?=\ssrc)|msg=[[\w\d!#$%&'()-=^~|@`\[{;+:*\]},]\s]+\z|\w+=\[\"?[\w+!#$%&'()-=^~|@`\[{;+:*\]},]*\"?\]|\w+=\[\"[[\w+-][\",\s]]*\]|\w+=[\w+!#$%&'()-=^~|@`\[{;+:*\]},<\.>\/?\\_]+|\w+=\"[\w+\s+!#$%&'()-=^~|@`\[{;+:*\]},]*/)
        else
          record_value["subtype"] = cef_value[6] #OUTBOUND-CONNECTIONS
          record_value["title"] = cef_value[7] #High rate of outbound connections
          record_value["severity"] = cef_value[8] #9
          syslog_value = cef_value[9].scan(/flex[\w\d]+=[[\w\d]\s]+(?=\sflex)|msg=[[\w\d!#$%&'()-=^~|@`\[{;+:*\]},]\s]+(?=\ssrc)|msg=[[\w\d!#$%&'()-=^~|@`\[{;+:*\]},]\s]+\z|\w+=\[\"?[\w+!#$%&'()-=^~|@`\[{;+:*\]},]*\"?\]|\w+=\[\"[[\w+-][\",\s]]*\]|\w+=[\w+!#$%&'()-=^~|@`\[{;+:*\]},<\.>\/?\\_]+|\w+=\"[\w+\s+!#$%&'()-=^~|@`\[{;+:*\]},]*/)
        end

        syslog_value.each{|log|
          key, value = log.split("=")
        case
        when key =~ /.*Label/
          #keyがflexstringLabelだった場合、valueをkeyとして、flexstringの要素を新たに追加する。
          #その際に元々のflexstringの要素を削除する
          new_key = is_convert_key?("#{value}".downcase)
          key = key.gsub!(/Label/, "")
          new_value = is_value_exception?(new_key, record_value["#{key}"])
          record_value["#{new_key}"] = is_nil?(new_value)
          record_value.delete("#{key}")
        else
          new_key = is_convert_key?(key)
          new_value = is_value_exception?(new_key, value)
          record_value["#{new_key}"] = is_nil?(new_value)
        end
    }
    
    case
    when record_value["type"] == "SIGN"
        tag = "syslog_sign.nozomi"
    
    when record_value["type"] == "INCIDENT"
        tag = "syslog_incident.nozomi"
        record_value["parents"] = record_value["event_id"]
        #ES上でparentsフィールドが反映されていないレコードを探して更新する
        sync_alert(record_value["event_id"])
    
    when record_value["type"] == "VI"
        tag = "syslog_vi.nozomi"
    
    when record_value["type"] == "AUDIT"
        tag = "syslog_audit.nozomi"

    when record_value["type"] == "HEALTH"
    tag = "syslog_health.nozomi"
    
    end

    time = Engine.now
    router.emit(tag, time, record_value)
    end
  
    def is_nil?(value)
      return value = (value == nil || value == "") ? nil : value
    end
    
    def is_value_exception?(key, value)
      case key
      when "parents"
        if value =~ /\[.*\]/
          new_value = value.delete!("[]")
        end
        return new_value
      when "time_generated"
        return new_value = value.to_i
      else
        return new_value = value
      end
    end
  
    def is_convert_key?(key)
      convert_hash ={
        "dpt" => "dport",
        "spt" => "sport",
        "dmac" => "dst_mac",
        "smac" => "src_mac",
        "msg" => "msgs",
        "id" => "event_id",
        "start" => "time_generated"
      }

      if convert_hash.include?(key)
        new_key = convert_hash[key]
        return new_key
      else
        return key
      end
    end
  
  
    def time_transformation(syslog_time)
      require 'time'
      t = Time.parse(syslog_time) + (nozomi_time_zone * -3600)
      t.to_i
    end
      
    def sync_alert(incident_id) 
      require "net/https"
      require "json"
  
      uri = URI.parse("https://#{@nozomi_host}/api/open/query/do")
      params = { :query => "alerts|where parents include? #{incident_id}"}
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      req.basic_auth(@nozomi_user, @nozomi_pass)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      #parentsフィールドにincident_idを持つアラート一覧を取得
      res = http.request(req)
      data = JSON.parse(res.body)
        
      #例外処理
      case data["total"]
      when 0
        raise "INFO:No alerts related to the incident were found. 
        Pleaze confirm the alert summary in the Nozomi web console. 
        You can filter by ID :#{incident_id}."
      when 1
        event_id = data["result"][0]["id"]
        es_query(event_id, incident_id)
      else
        #インシデントに紐付くアラートidを一件ずつ取り出す
        alert_list = []
        data["result"].each { |alert| alert_list = alert["id"] }
        
        es_query(incident_id, alert_list)

      end
    end
  
    def es_query(incident_id, list)
      require "date"
      require "elasticsearch"
      client = Elasticsearch::Client.new(
          {log: true, 
            hosts: { 
              host: "#{@es_host}", 
              port: "#{@es_port}",
              user: "#{@es_user}",
              password: "#{@es_password}",
              scheme: "https"
              },
            transport_options: {
                ssl: { ca_file: "#{@es_ca_file}" }
              }
              
          })
      today = Date.today
      index = "nozomi_syslog_log_001_sign-#{today.strftime('%Y%m%d')}"
      prev_index = "nozomi_syslog_log_001_sign-#{(today-1).strftime('%Y%m%d')}"

      res_doc = client.search(index: index, body: {query: {match: {event_id: incident_id}}})
      if res_doc["hits"]["total"]["value" ] != 0
        parents = res_doc["hits"]["hits"][0]["_source"]["parents"]
        if parents == "[]"
            id = res_doc["hits"]["hits"][0]["_id"]
            client.update(index: index, id: id, body: { doc: { parents: incident_id } })
            puts("updated es documents #{id}")
        end
      end
    end
  end
end