require "action_view"
require "table_for/engine"
require "blocks"

module TableFor
  autoload :Base, "table_for/base"
  autoload :ViewAdditions, "table_for/view_additions"

  mattr_accessor :default_table_class
  @@default_table_class = nil

  # Default way to setup TableFor
  def self.setup
    yield self
  end
end

ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods