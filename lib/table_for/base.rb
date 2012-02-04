require 'building-blocks'

module TableFor
  class Base < BuildingBlocks::Base
    alias columns queued_blocks
    alias column queue

    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end
  end
end
