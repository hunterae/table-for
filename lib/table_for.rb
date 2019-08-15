require "blocks"
require "table_for/engine"

module TableFor
  autoload :Base, "table_for/base"
  autoload :ViewAdditions, "table_for/view_additions"

  mattr_accessor :config
  @@config = Blocks::OptionsSet.new("TableFor Global Options")
  
  # set these to nil in setup block if you do not want thead, tbody, or tfoot tags rendered
  @@config.add_options(
    defaults: {
      thead_tag: :thead,
      tbody_tag: :tbody,
      tfoot_tag: :tfoot,
      sort_modes: [:asc, :desc]
    })

  # Default way to setup TableFor
  def self.setup
    yield config
  end
end

ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods