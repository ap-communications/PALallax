# coding: utf-8

module Fluent
 class TextParser
  class PaloSyslogPaser < Parser
   Plugin.register_parser('paloalto_syslog', self)


    def initialize
      super
      tag = ""
    end

    def configure(conf)
      super
    end

    def parse(text)
      syslog_value = text.split(/(@.?000\s*.+)/,2)

      raise "ERR001:syslog format error(no syslog value)" if syslog_value[1].nil?

      if %r{@#000:\s?\"os[67].[1]\"} === syslog_value[1]\
      || %r{@000:\s?\"os[67].[1]\"} === syslog_value[1] then

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
        "device_name" => "@056"

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
        "action_source" => "@#050"

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

        else
         raise "ERR003:syslog format error(type definition error)"
        end

     #Log emit
     time = Engine.now
     Engine.emit(tag, time, record_value)

    end



    def time_transformation(syslog_time)
      require 'time'
      Time.parse(syslog_time).to_i
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

  end
 end
end
