require 'onboard/extensions/string'
require 'onboard/extensions/hash'

class OnBoard
  module Service
    module RADIUS
      module Terms
        class Document

          class << self

            def setup
              @@conf          ||= RADIUS.read_conf
              @@terms_table   ||= @@conf['terms']['table'].to_sym
              @@terms_cols    ||= @@conf['terms']['columns'].symbolize_values
            end

            def setup!
              @@conf = @@terms_table = @@terms_cols = nil
              setup
            end

            def get_all
              setup
              RADIUS.db[@@terms_table].select.map do |row|
                Hash[ 
                  row.map do |k, v| 
                    [
                      k, 
                      v.respond_to?(:smart_encode)  ? 
                          v.smart_encode('utf-8')   : 
                          v
                    ]
                  end
                ]
              end              
            end

          end

        end
      end
    end
  end
end
