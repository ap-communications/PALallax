# coding: utf-8

require 'fluent/parser'
require 'fluent/output'
require 'fluent/plugin_helper'

module Fluent
  class PaloSyslogPaser < Output
    Plugin.register_parser('paloalto_syslog', self)
    helpers :event_emitter


    def initialize
        super
        tag = ""
    end

    desc "Setting Timezone"
    config_param :palo_time_zone, :integer, default: 0

    ENV['TZ'] = "UTC"

    def configure(conf)
        super
    end

    def parse(text)
        syslog_value = text.split(/(@.?000\s*.+)/,2)

        raise "ERR001:syslog format error(no syslog value)" if syslog_value[1].nil?

        if %r{@#000:\s?\"os([89]|1[0]).[012]\"} === syslog_value[1]\
        || %r{@000:\s?\"os([89]|1[0]).[012]\"} === syslog_value[1] then

        logemit(syslog_value)

        elsif raise "ERR002:syslog format error(version definition error)"


        end

    end


    def logemit(syslog_value)
        record_value = {}

        field_hash_threat ={
        "receive_time" => "@002",
        "serial" => "@003",
        "type" => "@004",
        "subtype_threat" => "@005",
        "time_generated" => "@007",
        "src" => "@008",
        "dst" => "@009",
        "natsrc" => "@010",
        "natdst" => "@011",
        "rule" => "@012",
        "srcuser" => "@013",
        "dstuser" => "@014",
        "app" => "@015",
        "vsys" => "@016",
        "from" => "@017",
        "to" => "@018",
        "inbound_if" => "@019",
        "outbound_if" => "@020",
        "logset" => "@021",
        "sessionid" => "@023",
        "repeatcnt" => "@024",
        "sport" => "@025",
        "dport" => "@026",
        "natsport" => "@027",
        "natdport" => "@028",
        "flags" => "@029",
        "proto" => "@030",
        "action" => "@031",
        "misc_url" => "@032",
        "threatid" => "@033",
        "category" => "@034",
        "severity" => "@035",
        "direction" => "@036",
        "seqno" => "@037",
        "actionflags" => "@038",
        "srcloc" => "@039",
        "dstloc" => "@040",
        "contenttype" => "@042",
        "pcap_id" => "@043",
        "filedigest" => "@044",
        "cloud" => "@045",
        "user_agent" => "@047",
        "filetype" => "@048",
        "xff" => "@049",
        "referer" => "@050",
        "sender" => "@051",
        "subject" => "@052",
        "recipient" => "@053",
        "reportid" => "@054",
        "vsys_name" => "@055",
        "device_name" => "@056",
        "source_vm_uuid" => "@057",
        "destination_vm_uuid" => "@058",
        "http_method" => "@059",
        "tunnel_id_imsi" => "@060",
        "monitor_tag_imei" => "@061",
        "parent_session_id" => "@062",
        "parent_start_time" => "@063",
        "tunnel_type" => "@064",
        "threat_category" => "@065",
        "content_version" => "@066",
        "sctp_association_id" => "@067",
        "payload_protocol_id" => "@068",
        "http_headers" => "@069",
        "url_category" => "@070",
        "rule_uuid" => "@071",
        "http2_connection" => "@072",
        "dynamic_usergroup_name" => "@073",
        "xff_ip" => "@074",
        "src_category" => "@075",
        "src_profile" => "@076",
        "src_model" => "@077",
        "src_vendor" => "@078",
        "src_osfamily" => "@079",
        "src_osversion" => "@080",
        "src_host" => "@081",
        "src_mac" => "@082",
        "dst_category" => "@083",
        "dst_profile" => "@084",
        "dst_model" => "@085",
        "dst_vendor" => "@086",
        "dst_osfamily" => "@087",
        "dst_osversion" => "@088",
        "dst_host" => "@089",
        "dst_mac" => "@090",
        "container_id" => "@091",
        "pod_namespace" => "@092",
        "pod_name" => "@093",
        "src_edl" => "@094",
        "dst_edl" => "@095",
        "hostid" => "@096",
        "serialnumber" => "@097",
        "domain_edl" => "@098",
        "src_dag" => "@099",
        "dst_dag" => "@100",
        "partial_hash" => "@101",
        "high_res_timestamp" => "@102",
        "reason" => "@103",
        "justification" => "104",
        "nssai_sst" => "@105",
        "subcategory_of_app" => "@106",
        "category_of_app" => "@107",
        "technology_of_app" => "@108",
        "risk_of_app" => "@109",
        "characteristic_of_app" => "@110",
        "container_of_app" => "@111",
        "is_saas_of_app" => "@112",
        "sanctioned_state_of_app" => "@113",
        "cloud_reportid" => "@114"
        }

        field_hash_traffic = {
        "receive_time" => "@#002",
        "serial" => "@#003",
        "type" => "@#004",
        "subtype_traffic" => "@#005",
        "time_generated" => "@#007",
        "src" => "@#008",
        "dst" => "@#009",
        "natsrc" => "@#010",
        "natdst" => "@#011",
        "rule" => "@#012",
        "srcuser" => "@#013",
        "dstuser" => "@#014",
        "app" => "@#015",
        "vsys" => "@#016",
        "from" => "@#017",
        "to" => "@#018",
        "inbound_if" => "@#019",
        "outbound_if" => "@#020",
        "logset" => "@#021",
        "sessionid" => "@#023",
        "repeatcnt" => "@#024",
        "sport" => "@#025",
        "dport" => "@#026",
        "natsport" => "@#027",
        "natdport" => "@#028",
        "flags" => "@#029",
        "proto" => "@#030",
        "action" => "@#031",
        "bytes" => "@#032",
        "bytes_sent" => "@#033",
        "bytes_received" => "@#034",
        "packets" => "@#035",
        "start" => "@#036",
        "elapsed" => "@#037",
        "category" => "@#038",
        "seqno" => "@#040",
        "actionflags" => "@#041",
        "srcloc" => "@#042",
        "dstloc" => "@#043",
        "pkts_sent" => "@#045",
        "pkts_received" => "@#046",
        "session_end_reason" => "@#047",
        "vsys_name" => "@#048",
        "device_name" => "@#049",
        "action_source" => "@#050",
        "source_vm_uuid" => "@#051",
        "destination_vm_uuid" => "@#052",
        "tunnel_id_imsi" => "@#053",
        "monitor_tag_imei" => "@#054",
        "parent_session_id" => "@#055",
        "parent_start_time" => "@#056",
        "tunnel_type" => "@#057",
        "sctp_association_id" => "@#058",
        "sctp_chunks" => "@#059",
        "sctp_chunks_sent" => "@#060",
        "sctp_chunks_received" => "@#061",
        "rule_uuid" => "@#062",
        "http2_connection" => "@#063",
        "link_change_count" => "@#064",
        "policy_id" => "@#065",
        "link_switches" => "@#066",
        "dynamic_usergroup_name" => "@#071",
        "xff_ip" => "@#072",
        "src_category" => "@#073",
        "src_profile" => "@#074",
        "src_model" => "@#075",
        "src_vendor" => "@#076",
        "src_osfamily" => "@#077",
        "src_osversion" => "@#078",
        "src_host" => "@#079",
        "src_mac" => "@#080",
        "dst_category" => "@#081",
        "dst_profile" => "@#082",
        "dst_model" => "@#083",
        "dst_vendor" => "@#084",
        "dst_osfamily" => "@#085",
        "dst_osversion" => "@#086",
        "dst_host" => "@#087",
        "dst_mac" => "@#088",
        "container_id" => "@#089",
        "pod_namespace" => "@#090",
        "pod_name" => "@#091",
        "src_edl" => "@#092",
        "dst_edl" => "@#093",
        "hostid" => "@#094",
        "serialnumber" => "@#095",
        "src_dag" => "@#096",
        "dst_dag" => "@#097",
        "session_owner" => "@#098",
        "high_res_timestamp" => "@#099",
        "nssai_sst" => "@#100",
        "nssai_sd" => "@#101",
        "subcategory_of_app" => "@#102",
        "category_of_app" => "@#103",
        "technology_of_app" => "@#104",
        "risk_of_app" => "@#105",
        "characteristic_of_app" => "@#106",
        "container_of_app" => "@#107",
        "is_saas_of_app" => "@#108",
        "sanctioned_state_of_app" => "@#109",
        "offloaded" => "@#110"
        }

        field_hash_globalprotect ={
        "receive_time" => "@002",
        "serial" => "@003",
        "seqno" => "@004",
        "actionflags" => "@005",
        "type" => "@006",
        "time_generated" => "@007",
        "vsys" => "@008",
        "eventid" => "@009",
        "stage" => "@010",
        "auth_method" => "@011",
        "tunnel_type" => "@012",
        "srcuser" => "@013",
        "srcregion" => "@014",
        "machinename" => "@015",
        "public_ip" => "@016",
        "public_ipv6" => "@017",
        "private_ip" => "@018",
        "private_ipv6" => "@019",
        "hostid" => "@020",
        "serialnumber" => "@021",
        "client_ver" => "@022",
        "client_os" => "@023",
        "client_os_ver" => "@024",
        "repeatcnt" => "@025",
        "reason" => "@026",
        "error" => "@027",
        "opaque" => "@028",
        "status" => "@029",
        "location" => "@030",
        "login_duration" => "@031",
        "connect_method" => "@032",
        "error_code" => "@033",
        "portal" => "@034",
        "selection_type" => "@035",
        "response_time" => "@036",
        "priority" => "@037",
        "attempted_gateways" => "@038",
        "gateway" => "@039",
        "vsys_name" => "@040",
        "device_name" => "@041",
        "vsys_id" => "@042",

        }

        #Threat log parse
        if syslog_value[1].include?("@004:\"THREAT\"") then

            #Hostname extraction
            record_value["hostname"] = syslog_value[0].split(" ")[3]

            field_hash_threat.each{|key, value|
                record = case value
                    #receive_time
                    when "@002" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                    #time_generated
                    when "@007" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                    #misc
                    when "@032" then  exception_handling(syslog_value[1],value,"@033")
                    #user_agent
                    when "@047" then  exception_handling(syslog_value[1],value,"@048")
                    #xff
                    when "@049" then  exception_handling(syslog_value[1],value,"@050")
                    #referer
                    when "@050" then  exception_handling(syslog_value[1],value,"@051")
                    #url_category_list
                    #when "@070" then  perse_category_list(syslog_value[1],value,"@070","@072") if syslog_value[1].include?("@070")
                    #when "@071" then  perse_category_list(syslog_value[1],value,"@070","@072") if syslog_value[1].include?("@071")
                    when value then  syslog_value[1].match(%r{#{value}:\s*"(.*?)"})
                end

                # recordの中身がnullの場合、空白を代入する。
                # recordのclassがMatchDataの場合、record配列の[1]をrecord_valueに代入する。（record[1]でMatchメソッドで取得した値が取得可能）
                # classがMatchDataではない場合、record変数には時間情報が代入されているため、record_valueにそのままrecordの値を代入する。
                if record == nil || record ==""
                record_value["#{key}"] == nil
                elsif record.class == MatchData then

                if record[1] == nil || record[1] == "" then
                record_value["#{key}"] = nil
                else
                record_value["#{key}"] = record[1]
                end

                else
                record_value["#{key}"] = record
                end

            }


            #subtypeの内容に応じてmiscのフィールド名を変更
            unless record_value["subtype_threat"] == /url/i then
            case record_value["subtype_threat"]
                when /file/i then
                    record_value["misc_file"] = record_value["misc_url"]
                    record_value["misc_url"] = nil
                when /virus/i then
                    record_value["misc_virus"] = record_value["misc_url"]
                    record_value["misc_url"] = nil
                when /wildfire/i then
                    record_value["misc_wildfire"] = record_value["misc_url"]
                    record_value["wildfire_result"] = record_value["category"]
                    record_value["misc_url"] = nil
                    record_value["category"] = nil
                when /vulnerability/i then
                    record_value["misc_file"] = record_value["misc_url"]
                    record_value["misc_url"] = nil
            end
            end

            tag = "syslog_threat.palo"

        #Traffic log parse
        elsif syslog_value[1].include?("@#004:\"TRAFFIC\"") then

            #Hostname extraction
            record_value["hostname"] = syslog_value[0].split(" ")[3]

            field_hash_traffic.each{|key, value|

                record =  case value
                when "@#002" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                when "@#007" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                when "@#036" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                when value then  syslog_value[1].match(%r{#{value}:\s*"(.*?)"})
                end

                # recordの中身がnullの場合、空白を代入する。
                # recordのclassがMatchDataの場合、record配列の[1]をrecord_valueに代入する。（record[1]でMatchメソッドで取得した値が取得可能）
                # classがMatchDataではない場合、record変数には時間情報が代入されているため、record_valueにそのままrecordの値を代入する。
                if record == nil || record == " " then
                    record_value["#{key}"] == nil
                elsif record.class == MatchData then
                    if record[1] == nil || record[1] == "" then
                        record_value["#{key}"] = nil
                    else
                        record_value["#{key}"] = record[1]
                    end
                else
                    record_value["#{key}"] = record
                end

            }


        tag = "syslog_traffic.palo"

        #GlobalProtect log parse
        elsif syslog_value[1].include?("@#006:\"GLOBALPROTECT\"") then

            #Hostname extraction
            record_value["hostname"] = syslog_value[0].split(" ")[3]

            field_hash_globalprotect.each{|key, value|

            record =  case value
                when "@#002" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                when "@#007" then  time_transformation(syslog_value[1].match(%r{#{value}:\s*"(.*?)"})[1])
                when value then  syslog_value[1].match(%r{#{value}:\s*"(.*?)"})
            end

            # recordの中身がnullの場合、空白を代入する。
            # recordのclassがMatchDataの場合、record配列の[1]をrecord_valueに代入する。（record[1]でMatchメソッドで取得した値が取得可能）
            # classがMatchDataではない場合、record変数には時間情報が代入されているため、record_valueにそのままrecordの値を代入する。
            if record == nil || record == " " then
                record_value["#{key}"] == nil
            elsif record.class == MatchData then
                if record[1] == nil || record[1] == "" then
                    record_value["#{key}"] = nil
                else
                    record_value["#{key}"] = record[1]
                end
            else
                record_value["#{key}"] = record
            end

            }

        tag = "syslog_globalprotect.palo"

        else
        raise "ERR003:syslog format error(type definition error)"
        end

        #Log emit
        time = Fluent::Engine.now
        router.emit(tag, time, record_value)

    end

    def time_transformation(syslog_time)
        require 'time'
        t = Time.parse(syslog_time) + (palo_time_zone * -3600)
        t.to_i
    end

    #正規表現での抽出で例外が発生する可能性があるフィールドは例外処理をする
    def exception_handling(syslog_value,value,word)

        #処理対象フィールドの開始位置取得
        word_start = syslog_value.index("#{value}")
        #処理対象フィールドの終了位置取得（次のフィールドの開始位置取得）
        word_end  = syslog_value.index("#{word}")
        #処理対象フィールドの文字数計算
        position  = word_end - word_start


        #先頭のダブルクォートの数に応じて取得する位置を変更する
        #ダブルクオートが先頭2つの場合
        if syslog_value.include?("#{value}:\"\"\"") then
            splitdata = syslog_value[word_start + 8,position - 12]
        #ダブルクオートが先頭3つの場合
        elsif syslog_value.include?("#{value}:\"\"") then
            splitdata = syslog_value[word_start + 7,position - 10]
        #ダブルクオートが先頭1つの場合
        elsif syslog_value.include?("#{value}:\"") then
            splitdata = syslog_value[word_start + 6,position - 8]
        else
            return nil
        end

        if splitdata != nil
            splitdata.lstrip!
        end

        return splitdata
    end
    
    def perse_category_list(syslog_value,value,list_value,word)
        word_start = syslog_value.index("#{list_value}")
        word_end  = syslog_value.index("#{word}")
        position  = word_end - word_start

        if syslog_value.include?("#{list_value}:\"\"")
        category_list = syslog_value[word_start + 7,position - 10]
        elsif syslog_value.include?("#{list_value}:\"") then
        category_list = syslog_value[word_start + 6,position - 8]
        else
            return nil
        end

        splitdata = case value
            when "@070" then category_list.split(",")[0]
            when "@071" then category_list.split(",")[1]
        end
        
        if splitdata != nil
        splitdata.lstrip!
        end

        return splitdata
    end

  end
end
