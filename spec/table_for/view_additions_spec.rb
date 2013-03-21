require "spec_helper"

describe TableFor::ViewAdditions do
  before(:each) do
    @view_class = Class.new
    @view = @view_class.new
    @view_class.send(:include, ActionView::Helpers::TextHelper)
    @view_class.send(:include, TableFor::ViewAdditions::ClassMethods)
    @records = [OpenStruct.new(:id => 1)]
    @column = stub(:name => :my_column)
  end

  describe "table_for method" do
    it "should call render_template on the TableFor::Base instance" do
      TableFor::Base.expects(:new).returns(mock(:render_template => ""))
      @view.table_for(@records)
    end

    it "should pass the view as the first parameter to TableFor::Base initialization" do
      TableFor::Base.expects(:new).with {|view, options| view == @view}.returns(mock(:render_template => ""))
      @view.table_for(@records)
    end

    it "should default the template to render" do
      TableFor::Base.any_instance.expects(:render_template).with {|template| template == "table_for/table_for"}.returns("")
      @view.table_for(@records)
    end

    it "should default the variable to 'table' to render" do
      TableFor::Base.expects(:new).with {|view, options| options[:variable] == "table"}.returns(mock(:render_template => ""))
      @view.table_for(@records)
    end

    it "should default the records to the collection passed in" do
      TableFor::Base.expects(:new).with {|view, options| options[:records] == @records}.returns(mock(:render_template => ""))
      @view.table_for(@records)
    end

    it "should add any runtime options to the options initialized for TableFor::Base" do
      TableFor::Base.expects(:new).with {|view, options| options[:option1] == 1 && options[:option2] == "2"}.returns(mock(:render_template => ""))
      @view.table_for(@records, :option1 => 1, :option2 => "2")
    end
  end

  describe "table_for_header_html method" do
    it "should return nil if header_html is not passed in" do
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {}), @column)
      header_html.should eql({})
    end

    it "should evaluate any procs for header_html" do
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {:class => "#{@column.name}_header"}), @column, :header_html => {:class => lambda {|column| "#{column.name}_header"}})
      header_html[:class].should eql "#{@column.name}_header"
    end

    it "should join the 'sorting' class with any other header_html class provided" do
      @view.expects(:params).returns({})
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {:class => "c1 c2"}), @column, :header_html => {:class => "c1 c2"}, :sortable => true)
      header_html[:class].should eql "c1 c2 sorting"
    end

    it "should add a 'sorting' class to the header_html class if a column is sortable" do
      @view.expects(:params).returns({})
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {}), @column, :sortable => true)
      header_html[:class].should eql "sorting"
    end

    it "should add a 'sorting_asc' class to the header_html class if a column is sortable and it is already sorted in asc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "asc")
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {}), @column, :sortable => true)
      header_html[:class].should eql "sorting_asc"
    end

    it "should add a 'sorting_desc' class to the header_html class if a column is sortable and it is already sorted in desc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "desc")
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {}), @column, :sortable => true)
      header_html[:class].should eql "sorting_desc"
    end

    it "should add a 'sorting' class to the header_html class if a column is sortable and it is reset mode" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "reset")
      header_html = @view.table_for_header_html(mock(:evaluated_procs => {}), @column, :sortable => true)
      header_html[:class].should eql "sorting"
    end
  end

  describe "table_for_sort_link method" do
    it "should be able to generate a sort link for a column if that column is sortable" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=asc").returns "my link"
      @view.table_for_sort_link(@column).should eql "my link"
    end

    it "should be able to generate a sort link for a column if that column is sortable and it is already sorted in asc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "asc")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=desc").returns "my link"
      @view.table_for_sort_link(@column).should eql "my link"
    end

    it "should be able to generate a sort link for a column if that column is sortable and it is already sorted in desc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "desc")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=reset").returns "my link"
      @view.table_for_sort_link(@column).should eql "my link"
    end

    it "should be able specify the label for a sort link" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with("My Label", "?order=#{@column.name}&sort_mode=asc").returns "my link"
      @view.table_for_sort_link(@column, :label => "My Label").should eql "my link"
    end

    it "should be able specify the sort_url for a sort link" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "/users?order=#{@column.name}&sort_mode=asc").returns "my link"
      @view.table_for_sort_link(@column, :sort_url => "/users").should eql "my link"
    end

    it "should be able specify the order field for a sort link" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=first_name%2Clast_name&sort_mode=asc").returns "my link"
      @view.table_for_sort_link(@column, :order => "first_name,last_name").should eql "my link"
    end

    it "should remove the action and controller params when generating the url" do
      @view.expects(:params).at_least_once.returns(:controller => "users", :action => "show")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=asc").returns "my link"
      @view.table_for_sort_link(@column).should eql "my link"
    end
  end

  describe "table_for_column_header method" do
    it "should translate column name" do
      I18n.expects(:t).with("activerecord.attributes.user.my_column").returns("my translated link")
      @view.table_for_column_header(@column, :user).should eql "my translated link"
    end

    it "should not translate column name if label passed" do
      I18n.expects(:t).never
      @view.expects(:table_for_sort_link).never
      @view.table_for_column_header(@column, :user, { label: 'custom label' }).should eql "custom label"
    end

    it "should pass label to table_for_sort_link if sortable" do
      options = { label: 'custom', sortable: true }
      @view.expects(:table_for_sort_link).with(@column, options).returns('link')
      @view.table_for_column_header(@column, :user, options).should eql 'link'
    end
  end
end