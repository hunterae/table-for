require "action_view"
require "table_for/engine"
require "building-blocks"

module TableFor
  autoload :Base, "table_for/base"
  autoload :ViewAdditions, "table_for/view_additions"
end

ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods