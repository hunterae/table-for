require "action_view"
require "with_template"
require "table_for/engine"

module TableFor
  autoload :Base, "table_for/base"
  autoload :ViewAdditions, "table_for/view_additions"

  mattr_accessor :config
  @@config = Hashie::Mash.new
  # set these to nil in setup block if you do not want thead, tbody, or tfoot tags rendered
  @@config.thead_tag = :thead
  @@config.tbody_tag = :tbody
  @@config.tfoot_tag = :tfoot
  @@config.sort_modes = [:asc, :desc]

  # Default way to setup TableFor
  def self.setup
    yield config
  end
end

ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods