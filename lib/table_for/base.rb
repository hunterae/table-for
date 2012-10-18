require 'building-blocks'

module TableFor
  class Base < BuildingBlocks::Base
    alias columns queued_blocks
    alias column queue

    attr_accessor :current_record

    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end

    def set_current_record(record)
      self.current_record = record
    end
  end
end
