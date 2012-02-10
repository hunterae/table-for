module TableFor
  module ViewAdditions
    module ClassMethods
      def table_for(records, options={}, &block)
        options[:use_partials_for_before_and_after_hooks] = false
        TableFor::Base.new(self, options.merge(:variable => "table", :records => records)).render_template("table_for/table_for", &block)
      end

      def table_for_header_html(table, column, options={})
        header_html = table.evaluated_procs(column, options[:header_html])
        if options[:sortable]
          order = options[:order] ? options[:order].to_s : column.name.to_s
          sort_class = (params[:order] != order || params[:sort_mode] == "reset") ? "sorting" : (params[:sort_mode] == "desc" ? "sorting_desc" : "sorting_asc")
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
