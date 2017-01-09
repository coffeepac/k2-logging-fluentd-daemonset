require 'fluent/filter'

module Fluent
  class  DeirdreTestFilter < Filter
    Fluent::Plugin.register_filter('deirdre_test_filter', self)

    def configure(conf)
      super
    end

    def start
      super
    end

    def get_log_directory(arr)
      arr.each do |f|
       if (!f.match /.log\z/) && (!f.match /\A\./)
        return f
       end
      end
    end

    def get_filename(arr)
      arr.each do |f|
        if !f.match /\A\./
          return f
        end
      end
    end


    def filter_stream(tag, es)
      new_es =  MultiEventStream.new
      entries = Dir.entries("/var/log/containers/")
      filepath = get_log_directory(entries)
      log_file = Dir.entries("/var/log/containers/#{filepath}")
      filename = get_filename(log_file)
      regexed_tag = tag.scan (/[^named.var.containers.]\S+/)


      es.each {|time, record|
        record['uniquestring'] = {
          'name' => 'hatch',
          'filepath' => "/#{filepath}/#{filename}",
          'tag' => regexed_tag[0]
        }
        new_es.add(time, record)
      }

      return new_es
    end


  end
end
