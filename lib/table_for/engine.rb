require "table-for"
require "rails"

module TableFor
  class Engine < Rails::Engine
    initializer "table_for.initialize_helpers" do
      ActiveSupport.on_load(:action_view) do
        include TableFor::HelperMethods
      end
    end
  end
end
