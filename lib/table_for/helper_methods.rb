module TableFor
  module HelperMethods
    def table_for_options(options={}, parameters={})
      evaluated_options = {}
      options.each_pair { |k, v| evaluated_options[k] = (v.is_a?(Proc) ? v.call(parameters) : v)}
      evaluated_options
    end
    
    def table_for(records, options={}, &block)
      options[:view] = self
      options[:records] = records
      options[:block] = block
      options[:row_html] = {:class => lambda { |parameters| cycle('odd', 'even')}} if options[:row_html].nil?
      options[:template] = "table_for/table_for"
      options[:templates_folder] = "table_for"
      options[:record_variable] = "records"
      options[:variable] = "table"
      
      TableFor::Base.new(options).render
    end
  end
end