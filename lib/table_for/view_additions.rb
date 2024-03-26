module TableFor
  module ViewAdditions
    module ClassMethods
      def table_for(records, options={}, &block)
        TableFor::Base.new(self, TableFor.config.merge(options.merge(builder_variable: :table, records: records))).render(partial: "table_for/table_for", &block)
      end
    end
  end
end
