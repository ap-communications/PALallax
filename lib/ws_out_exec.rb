module Fluent
  class WSRPCOutput
    def out_exec(ws, options = {})
      tag = options[:tag]
      uri = options[:uri]
      record = options[:record]
      time = options[:time]
      if record.has_key?('type') && record['type'] == 'THREAT'
        new_record = { source_country: record['source_country'],
                       source_ip: record['source_ip'] }
        ws.notify(uri, 'log', tag: tag, time: time, record: new_record)
      end
    end
  end
end
