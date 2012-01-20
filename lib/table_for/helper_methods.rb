module TableFor
  module HelperMethods
    def table_for_options(options={}, parameters={})
      return nil if options.nil?

      evaluated_options = {}
      options.each_pair { |k, v| evaluated_options[k] = (v.is_a?(Proc) ? v.call(parameters) : v)}
      evaluated_options
    end
    
    def table_for(records, options={}, &block)
      options[:records] = records
      options[:template] = "table_for/table_for"
      options[:templates_folder] = "table_for"
      options[:variable] = "table"

      TableFor::Base.new(self, options, &block).render
    end
  end
end