module TableFor
  module ViewAdditions
    module ClassMethods
      def table_for(records, options={}, &block)
        options[:records] = records
        options[:template] = "table_for/table_for"
        options[:variable] = "table"

        TableFor::Base.new(self, options, &block).render
      end

      def table_for_evaluated_options(*args)
        options = args.extract_options!
        options.inject({}) { |hash, (k, v)| hash[k] = (v.is_a?(Proc) ? v.call(*args) : v); hash} unless options.nil?
      end

      def table_for_header_html(column, options={})
        header_html = table_for_evaluated_options(column, options[:header_html])
        if options[:sortable]
          order = options[:order] ? options[:order].to_s : column.name.to_s
          sort_class = (params[:order] != order || params[:sort_mode] == "reset") ? "sorting" : (params[:sort_mode] == "desc" ? "sorting_desc" : "sorting_asc")
          header_html = {} if header_html.nil?
          header_html[:class] = (header_html[:class] ? "#{header_html[:class]} #{sort_class}" : sort_class)
        end
        header_html
      end

      def table_for_sort_link(column, options={})
        order = options[:order] ? options[:order].to_s : column.name.to_s
        label = (options[:label] ? options[:label] : column.name.to_s.titleize)
        sort_mode = (params[:order] != order || params[:sort_mode] == "reset") ? "asc" : (params[:sort_mode] == "desc" ? "reset" : "desc")
        parameters = params.merge(:order => order, :sort_mode => sort_mode)
        parameters.delete(:action)
        parameters.delete(:controller)
        url = options[:sort_url] ? options[:sort_url] : ""
        link_to label, "#{url}?#{parameters.to_query}"
      end
    end
  end
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, TableFor::ViewAdditions::ClassMethods
end
