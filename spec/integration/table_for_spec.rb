require "spec_helper"

describe "table_for" do
  with_model :user do
    table do |t|
      t.integer "id"
      t.string "email"
      t.string "first_name"
      t.string "last_name"
    end
  end

  class Offer
    attr_accessor :first_name
    def initialize(first_name)
      @first_name = first_name
    end
  end

  before :each do
    User.create! id: 1, :email => "andrew.hunter@livingsocial.com", :first_name => "Andrew", :last_name => "Hunter"
    User.create! id: 2, :email => "todd.fisher@livingsocial.com", :first_name => "Todd", :last_name => "Fisher"
    User.create! id: 3, :email => "jon.phillips@livingsocial.com", :first_name => "Jon", :last_name => "Phillips"
    @users = User.all
    @view = ActionView::Base.new("app/views")
    @view.class.send(:define_method, :user_path) do |user|
      "/users/#{user.id}"
    end
  end

  it "should be able render a table with email and first and last name columns" do
    buffer = @view.table_for @users do |table|
      table.column :email
      table.column :first_name
      table.column :last_name
    end

    xml = XmlSimple.xml_in(%%
      <table>
        <thead><tr><th>Email</th><th>First Name</th><th>Last Name</th></tr></thead>
        <tbody>
          <tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr>
          <tr><td>todd.fisher@livingsocial.com</td><td>Todd</td><td>Fisher</td></tr>
          <tr><td>jon.phillips@livingsocial.com</td><td>Jon</td><td>Phillips</td></tr>
        </tbody>
      </table>%)
    XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
  end

  describe "table block" do
    it "should be able to replace the table block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :table do
          "My new table definition"
        end
        table.column :email
        table.column :first_name
        table.column :last_name
      end

      buffer.strip.should eql "My new table definition"
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users, :table_html => {:style => "background-color: orange"}
      xml = XmlSimple.xml_in(%%<table style="background-color: orange"><thead><tr></tr></thead><tbody><tr></tr><tr></tr><tr></tr></tbody></table>%, keeproot: true)
      XmlSimple.xml_in(buffer, normalisespace: 2, keeproot: true).should eql xml
    end
  end

  describe "header block" do
    it "should be able to replace the thead block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :header do
          "<thead><tr><th>My new header definition</th></tr></thead>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>My new header definition</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :thead_html => {:style => "background-color: orange"}
      xml = XmlSimple.xml_in(%%<table><thead style="background-color: orange"><tr></tr></thead><tbody><tr></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should translate column names" do
      rails_4_active_record_array = @users[0, 1].clone
      Array.any_instance.expects(:model => User)
      I18n.expects(:t).with("activerecord.attributes.user.first_name", :default => "First Name").returns("Vorname")
      buffer = @view.table_for rails_4_active_record_array do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>Vorname</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml

      Array.any_instance.stubs(:respond_to? => false)
      I18n.expects(:t).with("activerecord.attributes.user.first_name", :default => "First Name").returns("Vorname2")
      buffer = @view.table_for @users[0,1] do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>Vorname2</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml

      non_activerecord_array = [Offer.new("Timmy")]

      I18n.expects(:t).with("tables.columns.offer.first_name", :default => "First Name").returns("Vorname3")
      buffer = @view.table_for non_activerecord_array do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>Vorname3</th></tr></thead><tbody><tr><td>Timmy</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml

      # the rare case where the array has objects of different types
      mixed_array = [@users.first, Offer.new("Timmy")]
      I18n.expects(:t).with("tables.columns.first_name", :default => "First Name").returns("Vorname3")
      buffer = @view.table_for mixed_array do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>Vorname3</th></tr></thead><tbody><tr><td>Andrew</td></tr><tr><td>Timmy</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should not translate column name if header passed" do
      I18n.expects(:t).never
      buffer = @view.table_for @users[0,1] do |table|
        table.column :first_name, :header => "My First Name"
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>My First Name</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "header_row block" do
    it "should be able to replace the header_row block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :header_row do
          "<tr><th>My new header_row definition</th></tr>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>My new header_row definition</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :header_row_html => {:style => "background-color: orange"} do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr style="background-color: orange"><th>First Name</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "header_column block" do
    it "should be able to replace the header_columns block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :header_column do
          "<th>Repeated Column</th>".html_safe
        end
        table.column :first_name
        table.column :last_name
      end

      html_includes?(buffer, "<thead><tr><th>Repeated Column</th><th>Repeated Column</th></tr></thead>")
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :header_column_html => {:class => "sortable"} do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th class="sortable">First Name</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to dynamically specify column attributes" do
      buffer = @view.table_for @users[0, 1], :header_column_html => {:class => lambda {@view.cycle("even", "odd")},
                                                              :id => lambda {|column| "#{column.name.to_s}_header"}} do |table|
        table.column :email
        table.column :first_name
        table.column :last_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead>
            <tr>
              <th class="even" id="email_header">Email</th>
              <th class="odd" id="first_name_header">First Name</th>
              <th class="even" id="last_name_header">Last Name</th>
            </tr></thead>
          <tbody>
            <tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "column header contents block" do
    it "should be able to override the header for a particular column" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :header => "Email Address"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email Address</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the global defined header for all columns" do
      buffer = @view.table_for @users[0,1], :header => "My Default Header" do |table|
        table.column :email, :header => "Email Address"
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email Address</th><th>My Default Header</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the definition for a particular column header block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :header => "Email Address"
        table.define :email_header do |column, options|
          "My Own Header (Replaced #{options[:header]})"
        end
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>My Own Header (Replaced Email Address)</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the definition for a particular column header block using the table_for 'header' method" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :header => "Email Address"
        table.header :email do |column, options|
          "My Own Header (Replaced #{options[:header]})"
        end
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>My Own Header (Replaced Email Address)</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting' class to the 'th' element and a link around the header content if a column is sortable" do
      @view.expects(:params).at_least_once.returns({})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true, :header_column_html => {:class => "email", :style => "color:red"}
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="email sorting" style="color:red"><a href="?order=email&amp;sort_mode=asc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting_asc' class to the 'th' element and a link around the header content if a column is sortable and the column is sorted in asc order" do
      @view.expects(:params).at_least_once.returns({:order => "email", :sort_mode => "asc"})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting_asc"><a href="?order=email&amp;sort_mode=desc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting_asc' class to the 'th' element and a link around the header content if a column is sortable and the column is sorted in asc order and the order param matches the column order field" do
      @view.expects(:params).at_least_once.returns({:order => "email_address", :sort_mode => "asc"})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true, :order => "email_address"
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting_asc"><a href="?order=email_address&amp;sort_mode=desc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should not add a 'sorting_asc' class to the 'th' element and a link around the header content if a column is sortable and the column is sorted in asc order and the order param does not match the column order field" do
      @view.expects(:params).at_least_once.returns({:order => "email", :sort_mode => "asc"})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true, :order => "email_address"
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting"><a href="?order=email_address&amp;sort_mode=asc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting_desc' class to the 'th' element and a link around the header content if a column is sortable and the column is sorted in desc order" do
      @view.expects(:params).at_least_once.returns({:order => "email", :sort_mode => "desc"})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting_desc"><a href="?order=email&amp;sort_mode=">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting' class to the 'th' element and a link around the header content if a column is sortable and the sort_mode is in reset mode" do
      @view.expects(:params).at_least_once.returns({:order => "email", :sort_mode => ""})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting"><a href="?order=email&amp;sort_mode=asc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should allow a sort_url to be specified for sortable columns" do
      @view.expects(:params).at_least_once.returns({})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true, :sort_url => "/users"
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting"><a href="/users?order=email&amp;sort_mode=asc">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should allow a global sortable option for all columns and the ability to override on a column by column basis" do
      @view.expects(:params).at_least_once.returns({})
      buffer = @view.table_for @users[0,1], :sortable => true do |table|
        table.column :email
        table.column :first_name, :sortable => false
        table.column :last_name
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead>
            <tr>
              <th class="sorting"><a href="?order=email&amp;sort_mode=asc">Email</a></th>
              <th>First Name</th>
              <th class="sorting"><a href="?order=last_name&amp;sort_mode=asc">Last Name</a></th>
            </tr>
          </thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should allow a global header_column_html option for all columns and the ability to override on a column by column basis" do
      buffer = @view.table_for @users[0,1], :header_column_html => {:class => lambda {|column| "#{column.name}_header"}} do |table|
        @view.expects(:params).at_least_once.returns({})
        table.column :email, :sortable => true
        table.column :first_name, :header_column_html => {:class => "my_header"}
        table.column :last_name, :header_column_html => {:class => "my_other_header"}, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead>
            <tr>
              <th class="email_header sorting"><a href="?order=email&amp;sort_mode=asc">Email</a></th>
              <th class="my_header">First Name</th>
              <th class="my_other_header sorting"><a href="?order=last_name&amp;sort_mode=asc">Last Name</a></th>
            </tr>
          </thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "body block" do
    it "should be able to replace the body block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :body do
          "<tbody><tr><td>My new body definition</td></tr></tbody>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>First Name</th></tr></thead><tbody><tr><td>My new body definition</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :tbody_html => {:style => "background-color: orange"}
      xml = XmlSimple.xml_in(%%<table><thead><tr></tr></thead><tbody style="background-color: orange"><tr></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "data_row block" do
    it "should be able to replace the data_row block" do
      buffer = @view.table_for @users do |table|
        table.define :data_row do |user|
          "<tr><td>User #{user.first_name}</td></tr>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>First Name</th></tr></thead>
          <tbody>
            <tr><td>User Andrew</td></tr>
            <tr><td>User Todd</td></tr>
            <tr><td>User Jon</td></tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to dynamically specify row attributes" do
      buffer = @view.table_for @users, :data_row_html => {:class => lambda {@view.cycle("even", "odd")},
                                                     :id => lambda {|user| "user-#{user.id}"}} do |table|
        table.column :email
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email</th></tr></thead>
          <tbody>
            <tr class="even" id="user-1"><td>andrew.hunter@livingsocial.com</td></tr>
            <tr class="odd" id="user-2"><td>todd.fisher@livingsocial.com</td></tr>
            <tr class="even" id="user-3"><td>jon.phillips@livingsocial.com</td></tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "data_column block" do
    it "should be able to replace the data_column block" do
      buffer = @view.table_for @users[0, 1] do |table|
        table.define :data_column do |column, user, options|
          "<td>#{column.name.to_s.titleize} value is #{user.send(column.name)}</td>".html_safe
        end
        table.column :email
        table.column :first_name
        table.column :last_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email</th><th>First Name</th><th>Last Name</th></tr></thead>
          <tbody>
            <tr>
              <td>Email value is andrew.hunter@livingsocial.com</td>
              <td>First Name value is Andrew</td>
              <td>Last Name value is Hunter</td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :data_column_html => {:class => "data"} do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>First Name</th></tr></thead><tbody><tr><td class="data">Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to dynamically specify column attributes" do
      buffer = @view.table_for @users[0, 1], :data_column_html => {:class => lambda {@view.cycle("even", "odd")},
                                                              :id => lambda {|user, column| "#{column.name.to_s}_data"}} do |table|
        table.column :email
        table.column :first_name
        table.column :last_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead>
            <tr><th>Email</th><th>First Name</th><th>Last Name</th></tr>
          </thead>
          <tbody>
            <tr>
              <td class="even" id="email_data">andrew.hunter@livingsocial.com</td>
              <td class="odd" id="first_name_data">Andrew</td>
              <td class="even" id="last_name_data">Hunter</td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should allow a global data_column_html option for all columns and the ability to override on a column by column basis" do
      buffer = @view.table_for @users[0,1], :data_column_html => {:class => lambda {|record, column| "#{column.name}_data"}} do |table|
        table.column :first_name, :data_column_html => {:class => "my_data"}
        table.column :last_name
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>First Name</th><th>Last Name</th></tr></thead>
          <tbody>
            <tr>
              <td class="my_data">Andrew</td>
              <td class="last_name_data">Hunter</td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to use the table's current_index in a cell's data_column_html" do
      buffer = @view.table_for @users do |table|
        table.column :id, data_column_html: {
            class: lambda { |record| "column-for-row-#{table.current_index}"
          }
        }
      end
      html_includes?(buffer, "<td class='column-for-row-0'>1</td>")
      html_includes?(buffer, "<td class='column-for-row-1'>2</td>")
    end
  end

  describe "column data contents block" do
    context "when passing a link param" do
      it "render a link surrounding a table cell's content when it is true" do
        buffer = @view.table_for @users do |table|
          table.column :email, link: true
        end
        html_includes?(buffer, "<a href='/users/1'>andrew.hunter@livingsocial.com</a>")
      end
    end

    it "should be able to use the table's current_index in the content of a cell" do
      buffer = @view.table_for @users do |table|
        table.column :id do |user|
          "User id #{user.id} rendering with row index #{table.current_index}"
        end
      end
      html_includes?(buffer, "User id 1 rendering with row index 0")
      html_includes?(buffer, "User id 2 rendering with row index 1")
    end

    it "should allow a link_url proc to render a link surrounding a table cell's content" do
      buffer = @view.table_for @users do |table|
        table.column :email, link_url: lambda {|user| "/admin/users/#{user.id}"}
      end
      html_includes?(buffer, "<a href='/admin/users/1'>andrew.hunter@livingsocial.com</a>")
    end

    it "should use the globally defined link_namespace unless defined directly on the column" do
      @view.class.send(:define_method, :admin_user_path) do |user|
        "/admin/users/#{user.id}"
      end
      @view.class.send(:define_method, :profile_user_path) do |user|
        "/profile/users/#{user.id}"
      end
      buffer = @view.table_for @users, link_namespace: :admin do |table|
        table.column :email, link: true
        table.column :id, link_namespace: :profile, link: true
      end
      html_includes?(buffer, "<a href='/admin/users/1'>andrew.hunter@livingsocial.com</a>")
      html_includes?(buffer, "<a href='/profile/users/1'>1</a>")
    end

    it "should be able to replace an individual column data contents block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :header => "Email Address"
        table.column :header => "Full Name" do |user|
          "#{user.first_name} #{user.last_name}"
        end
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email Address</th><th>Full Name</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end
end
