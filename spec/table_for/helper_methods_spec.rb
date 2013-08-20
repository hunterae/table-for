require "spec_helper"

describe TableFor::HelperMethods do
  before(:each) do
    @view_class = Class.new
    @view = @view_class.new
    @view_class.send(:include, Blocks::ViewAdditions::ClassMethods)
    @helper = TableFor::Base.new(@view)
    @records = [OpenStruct.new(:id => 1)]
    @column = stub(:name => :my_column, :anonymous => false)
  end

  describe "header_column_html method" do
    it "should return an empty hash if header_column_html is not passed in" do
      header_column_html = @helper.header_column_html(@column)
      header_column_html.should eql({})
    end

    it "should evaluate any procs for header_column_html" do
      header_column_html = @helper.header_column_html(@column, :header_column_html => {:class => lambda {|column| "#{column.name}_header"}})
      header_column_html[:class].should eql "#{@column.name}_header"
    end

    it "should join the 'sorting' class with any other header_column_html class provided" do
      @view.expects(:params).returns({})
      header_column_html = @helper.header_column_html(@column, :header_column_html => {:class => "c1 c2"}, :sortable => true)
      header_column_html[:class].should eql "c1 c2 sorting"
    end

    it "should add a 'sorting' class to the header_column_html class if a column is sortable" do
      @view.expects(:params).returns({})
      header_column_html = @helper.header_column_html(@column, :sortable => true)
      header_column_html[:class].should eql "sorting"
    end

    it "should add a 'sorting_asc' class to the header_column_html class if a column is sortable and it is already sorted in asc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "asc")
      header_column_html = @helper.header_column_html(@column, :sortable => true)
      header_column_html[:class].should eql "sorting_asc"
    end

    it "should add a 'sorting_desc' class to the header_column_html class if a column is sortable and it is already sorted in desc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "desc")
      header_column_html = @helper.header_column_html(@column, :sortable => true)
      header_column_html[:class].should eql "sorting_desc"
    end

    it "should add a 'sorting' class to the header_column_html class if a column is sortable and it is reset mode" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "reset")
      header_column_html = @helper.header_column_html(@column, :sortable => true)
      header_column_html[:class].should eql "sorting"
    end
  end

  describe "header_sort_link method" do
    before(:each) do
      @view.stubs(:capture).returns(@column.name.to_s.titleize)
    end

    it "should be able to generate a sort link for a column if that column is sortable" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=asc").returns "my link"
      @helper.header_sort_link(@column, :sortable => true).should eql "my link"
    end

    it "should be able to generate a sort link for a column if that column is sortable and it is already sorted in asc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "asc")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=desc").returns "my link"
      @helper.header_sort_link(@column, :sortable => true).should eql "my link"
    end

    it "should be able to generate a sort link for a column if that column is sortable and it is already sorted in desc order" do
      @view.expects(:params).at_least_once.returns(:order => @column.name.to_s, :sort_mode => "desc")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=reset").returns "my link"
      @helper.header_sort_link(@column, :sortable => true).should eql "my link"
    end

    it "should be able specify the sort_url for a sort link" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "/users?order=#{@column.name}&sort_mode=asc").returns "my link"
      @helper.header_sort_link(@column, :sort_url => "/users", :sortable => true).should eql "my link"
    end

    it "should be able specify the order field for a sort link" do
      @view.expects(:params).at_least_once.returns({})
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=first_name%2Clast_name&sort_mode=asc").returns "my link"
      @helper.header_sort_link(@column, :order => "first_name,last_name", :sortable => true).should eql "my link"
    end

    it "should remove the action and controller params when generating the url" do
      @view.expects(:params).at_least_once.returns(:controller => "users", :action => "show")
      @view.expects(:link_to).with(@column.name.to_s.titleize, "?order=#{@column.name}&sort_mode=asc").returns "my link"
      @helper.header_sort_link(@column, :sortable => true) { @column.name.to_s.titleize }.should eql "my link"
    end
  end
end