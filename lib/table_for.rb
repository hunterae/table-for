require "action_view"
require "table_for/engine"
require "blocks"

module TableFor
  autoload :Base, "table_for/base"
  autoload :ViewAdditions, "table_for/view_additions"
  autoload :HelperMethods, "table_for/helper_methods"

  mattr_accessor :default_table_class
  @@default_table_class = nil

  mattr_accessor :render_thead_element
  @@render_thead_element = true

  mattr_accessor :render_tbody_element
  @@render_tbody_element = true

  mattr_accessor :render_tfoot_element
  @@render_tfoot_element = true

  # Default way to setup TableFor
  def self.setup
    yield self
  end
end

ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods