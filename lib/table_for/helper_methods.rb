module TableFor
  module HelperMethods
    module InstanceMethods
      def header(name, options={}, &block)
        define("#{name.to_s}_header", options.reverse_merge(:header => true), &block)
      end

      def footer(options={}, &block)
        define(:footer_content, options, &block)
      end

      def table_html(options)
        if options[:table_html]
          options[:table_html].reverse_merge!(:class => TableFor.default_table_class) if TableFor.default_table_class
          options[:table_html]
        elsif TableFor.default_table_class
          {:class => TableFor.default_table_class}
        end
      end

      def header_column_html(column, options={})
        header_column_html = call_each_hash_value_with_params(options[:header_column_html], column)
        if options[:sortable]
          order = options[:order] ? options[:order].to_s : column.name.to_s
          sort_class = (view.params[:order] != order || view.params[:sort_mode] == "reset") ? "sorting" : (view.params[:sort_mode] == "desc" ? "sorting_desc" : "sorting_asc")
          header_column_html[:class] = (header_column_html[:class] ? "#{header_column_html[:class]} #{sort_class}" : sort_class)
        end
        header_column_html
      end

      def header_cell_content(column, options={})
        unless options[:header] == false
          header_sort_link(column, options) do
            if options[:header]
              call_with_params options[:header], column
            elsif column.anonymous
              nil
            else
              column.name.to_s.titleize
            end
          end
        end
      end

      def cell_content(record, column, options={})
        if options[:link_url] || options[:link_action] || options[:link_method] || options[:link_confirm] || options[:link]
          url = options[:link_url] ? call_with_params(options[:link_url], record) : [options[:link_action], options[:link_namespace], record].flatten
        end

        if options[:formatter]
          if options[:formatter].is_a?(Proc)
            content = call_with_params(options[:formatter], record.send(column.name), options)
          else
            content = record.send(column.name).try(*options[:formatter])
          end
        elsif options[:data] || [:edit, :show, :delete].include?(column.name)
          content = call_with_params(options[:data], record)
        else
          content = record.send(column.name)
        end

        if content.blank? || url.blank? || options[:link] == false
          content
        elsif url
          view.link_to content, url, {:method => options[:link_method], :confirm => options[:link_confirm]}.merge(options[:link_html])
        end
      end

      def set_current_record(record)
        self.current_record = record
      end

      def header_sort_link(column, options={}, &block)
        if options[:sortable] && (options[:header] || !column.anonymous)
          order = options[:order] ? options[:order].to_s : column.name.to_s
          sort_mode = (view.params[:order] != order || view.params[:sort_mode] == "reset") ? "asc" : (view.params[:sort_mode] == "desc" ? "reset" : "desc")
          parameters = view.params.merge(:order => order, :sort_mode => sort_mode)
          parameters.delete(:action)
          parameters.delete(:controller)
          url = options[:sort_url] ? options[:sort_url] : ""
          view.link_to view.capture(self, &block), "#{url}?#{parameters.to_query}"
        else
          view.capture(self, &block)
        end
      end
    end
  end
end