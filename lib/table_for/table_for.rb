require 'rails'
require 'table-for'

module TableFor
  class Base < BuildingBlocks::Base
    alias columns block_positions
    alias column use
    
    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end
  end
end
