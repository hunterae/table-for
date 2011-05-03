require "action_view"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "table_for/table_for"
require "table_for/helper_methods"
# require "table_for/engine"

$LOAD_PATH.shift

if defined?(ActionView::Base)
  ActionView::Base.send :include, TableFor::HelperMethods
end
