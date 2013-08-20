require 'blocks'

module TableFor
  class Base < Blocks::Base
    include TableFor::HelperMethods::InstanceMethods

    alias columns queued_blocks
    alias column queue

    attr_accessor :current_record
    alias_method :current_row, :current_record
  end
end