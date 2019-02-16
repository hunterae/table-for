require 'with_template'
require 'blocks'

module TableFor
  class Base < WithTemplate::Base
    alias columns queued_blocks

    attr_accessor :current_record
    alias_method :current_row, :current_record

    attr_accessor :current_index
    alias_method :current_row_index, :current_index


    def initialize(view, options={})
      super(view, TableFor.config.merge(options))
    end

    def header(name, options={}, &block)
      define("#{name.to_s}_header", options.reverse_merge(:header => true), &block)
    end

    def footer(options={}, &block)
      define(:footer_content, options, &block)
    end

    def column(*args, &block)
      options = args.extract_options!
      queue(*args, options, &block)
      if options[:link_url] ||
         options[:link_action] ||
         options[:link_method] ||
         options[:link_confirm] ||
         options[:link]
        around(columns.last.name) do |content_block, record, column, options|
          options = options.merge(column.options)
          url = if options[:link_url]
            call_with_params(options[:link_url], record)
          else
            [
              options[:link_action],
              options[:link_namespace] || global_options[:link_namespace],
              record
            ].flatten.compact
          end
          html_options = {data: {}}
          html_options[:data][:method] = options[:link_method] if options[:link_method].present?
          html_options[:data][:confirm] = options[:link_confirm] if options[:link_confirm].present?
          html_options = html_options.deep_merge(options[:link_html] || {})
          view.link_to content_block.call, url, html_options
        end
      end
      nil
    end

    def header_column_html(column, options={})
      header_column_html = call_each_hash_value_with_params(options[:header_column_html], column)
      if options[:sortable]
        order = options[:order] ? options[:order].to_s : column.name.to_s

        sort_modes = options[:sort_modes].presence || TableFor.config.sort_modes
        current_sort_mode = (view.params[:order] != order || view.params[:sort_mode].blank?) ? nil : view.params[:sort_mode]
        current_sort_mode = sort_modes[sort_modes.index(current_sort_mode.to_sym)] rescue nil if current_sort_mode
        sort_class = "sorting#{"_#{current_sort_mode}" if current_sort_mode}"

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
      if options[:formatter]
        if options[:formatter].is_a?(Proc)
          call_with_params(options[:formatter], record.send(column.name), options)
        else
          record.send(column.name).try(*options[:formatter])
        end
      elsif options[:data] || [:edit, :show, :delete].include?(column.name)
        call_with_params(options[:data], record)
      else
        record.send(column.name)
      end
    end

    def set_current_record_and_index(record, index)
      self.current_record = record
      self.current_index = index
    end

    def header_sort_link(column, options={}, &block)
      if options[:sortable] && (options[:header] || !column.anonymous)
        order = options[:order] ? options[:order].to_s : column.name.to_s

        sort_modes = options[:sort_modes].presence || TableFor.config.sort_modes
        current_sort_mode = (view.params[:order] != order || view.params[:sort_mode].blank?) ? nil : view.params[:sort_mode]
        next_sort_mode_index = sort_modes.index(current_sort_mode.to_sym) + 1 rescue 0
        if next_sort_mode_index == sort_modes.length
          next_sort_mode = nil
        else
          next_sort_mode = sort_modes[next_sort_mode_index]
        end

        parameters = view.params.merge(:order => order, :sort_mode => next_sort_mode)
        parameters.delete(:action)
        parameters.delete(:controller)
        if parameters.respond_to?(:to_unsafe_h)
          parameters = parameters.to_unsafe_h
        end
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
