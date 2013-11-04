require 'with_template'
require 'blocks'

module TableFor
  class Base < WithTemplate::Base
    alias columns queued_blocks
    alias column queue

    attr_accessor :current_record
    alias_method :current_row, :current_record

    def initialize(view, options={})
      super(view, TableFor.config.merge(options))
    end

    def header(name, options={}, &block)
      define("#{name.to_s}_header", options.reverse_merge(:header => true), &block)
    end

    def footer(options={}, &block)
      define(:footer_content, options, &block)
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
            I18n.t("#{translation_lookup_prefix}.#{column.name.to_s.underscore}", :default => column.name.to_s.titleize)
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

    private
    def translation_lookup_prefix
      if global_options[:records].respond_to?(:model)
        "activerecord.attributes.#{global_options[:records].model.to_s.underscore}"
      elsif global_options[:records].all? {|record| record.is_a?(ActiveRecord::Base) && record.class == global_options[:records].first.class }
        "activerecord.attributes.#{global_options[:records].first.class.to_s.underscore}"
      elsif global_options[:records].all? {|record| record.class == global_options[:records].first.class }
        "tables.columns.#{global_options[:records].first.class.to_s.underscore}"
      else
        "tables.columns"
      end
    end
  end
end