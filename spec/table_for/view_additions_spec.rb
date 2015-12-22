require "spec_helper"

describe TableFor::ViewAdditions do
  before(:each) do
    @view_class = Class.new
    @view = @view_class.new
    @view_class.send(:include, ActionView::Helpers::TextHelper)
    @view_class.send(:include, TableFor::ViewAdditions::ClassMethods)
    @view_class.send(:include, Blocks::ViewAdditions)
    @records = [OpenStruct.new(:id => 1)]
    @column = stub(:name => :my_column)
  end

  describe "#table_for" do
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
end
