module TableFor
  module ViewAdditions
    module ClassMethods
      def table_for(records, options={}, &block)
        TableFor::Base.new(self, options.merge(:variable => "table", :records => records)).render_template("table_for/table_for", &block)
      end
    end
  end
end
