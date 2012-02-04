require "spec_helper"

describe "table_for" do
  with_model :user do
    table do |t|
      t.string "email"
      t.string "first_name"
      t.string "last_name"
    end
  end

  before :each do
    User.create! :email => "andrew.hunter@livingsocial.com", :first_name => "Andrew", :last_name => "Hunter"
    User.create! :email => "todd.fisher@livingsocial.com", :first_name => "Todd", :last_name => "Fisher"
    User.create! :email => "jon.phillips@livingsocial.com", :first_name => "Jon", :last_name => "Phillips"
    @users = User.all
    @view = ActionView::Base.new("app/views")
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
      xml = XmlSimple.xml_in(%%<table style="background-color: orange"><thead><tr></tr></thead><tbody><tr></tr><tr></tr><tr></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "thead block" do
    it "should be able to replace the thead block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :thead do
          "<thead><tr><th>My new thead definition</th></tr></thead>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>My new thead definition</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :thead_html => {:style => "background-color: orange"}
      xml = XmlSimple.xml_in(%%<table><thead style="background-color: orange"><tr></tr></thead><tbody><tr></tr></tbody></table>%)
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

  describe "header_columns block" do
    it "should be able to replace the header_columns block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :header_columns do
          "<th>Column 1</th><th>Column 2</th>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>Column 1</th><th>Column 2</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
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

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Repeated Column</th><th>Repeated Column</th></tr></thead>
          <tbody><tr><td>Andrew</td><td>Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :header_html => {:class => "sortable"} do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th class="sortable">First Name</th></tr></thead><tbody><tr><td>Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
    
    it "should be able to dynamically specify column attributes" do
      buffer = @view.table_for @users[0, 1], :header_html => {:class => lambda {@view.cycle("even", "odd")},
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
  
  describe "edit_header block" do
    it "should be able to replace the edit_header block" do
      @view.expects(:edit_user_path).with(User.first).returns("/users/1/edit")
      buffer = @view.table_for @users[0,1] do |table|
        table.define :edit_header do
          "Edit"
        end
        table.column :edit
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Edit</th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1/edit">Edit</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "delete_header block" do
    it "should be able to replace the delete_header block" do
      @view.expects(:user_path).with(User.first).returns("/users/1")
      buffer = @view.table_for @users[0,1] do |table|
        table.define :delete_header do
          "Delete"
        end
        table.column :delete
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Delete</th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "show_header block" do
    it "should be able to replace the show_header block" do
      @view.expects(:user_path).with(User.first).returns("/users/1")
      buffer = @view.table_for @users[0,1] do |table|
        table.define :show_header do
          "Show"
        end
        table.column :show
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Show</th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1">Show</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "column header contents block" do
    it "should be able to override the label for a particular column" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :label => "Email Address"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email Address</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the global defined label for all columns" do
      buffer = @view.table_for @users[0,1], :label => "My Default Label" do |table|
        table.column :email, :label => "Email Address"
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>Email Address</th><th>My Default Label</th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the definition for a particular column header block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :label => "Email Address"
        table.define :email_header do |column, options|
          "My Own Header (Replaced #{options[:label]})"
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
        table.column :email, :label => "Email Address"
        table.header :email do |column, options|
          "My Own Header (Replaced #{options[:label]})"
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
        table.column :email, :sortable => true, :header_html => {:class => "email", :style => "color:red"}
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="email sorting" style="color:red"><a href="?order=email&sort_mode=asc">Email</a></th></tr></thead>
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
          <thead><tr><th class="sorting_asc"><a href="?order=email&sort_mode=desc">Email</a></th></tr></thead>
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
          <thead><tr><th class="sorting_asc"><a href="?order=email_address&sort_mode=desc">Email</a></th></tr></thead>
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
          <thead><tr><th class="sorting"><a href="?order=email_address&sort_mode=asc">Email</a></th></tr></thead>
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
          <thead><tr><th class="sorting_desc"><a href="?order=email&sort_mode=reset">Email</a></th></tr></thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should add a 'sorting' class to the 'th' element and a link around the header content if a column is sortable and the sort_mode is in reset mode" do
      @view.expects(:params).at_least_once.returns({:order => "email", :sort_mode => "reset"})
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th class="sorting"><a href="?order=email&sort_mode=asc">Email</a></th></tr></thead>
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
          <thead><tr><th class="sorting"><a href="/users?order=email&sort_mode=asc">Email</a></th></tr></thead>
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
              <th class="sorting"><a href="?order=email&sort_mode=asc">Email</a></th>
              <th>First Name</th>
              <th class="sorting"><a href="?order=last_name&sort_mode=asc">Last Name</a></th>
            </tr>
          </thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should allow a global header_html option for all columns and the ability to override on a column by column basis" do
      buffer = @view.table_for @users[0,1], :header_html => {:class => lambda {|column| "#{column.name}_header"}} do |table|
        @view.expects(:params).at_least_once.returns({})
        table.column :email, :sortable => true
        table.column :first_name, :header_html => {:class => "my_header"}
        table.column :last_name, :header_html => {:class => "my_other_header"}, :sortable => true
      end
      xml = XmlSimple.xml_in(%%
        <table>
          <thead>
            <tr>
              <th class="email_header sorting"><a href="?order=email&sort_mode=asc">Email</a></th>
              <th class="my_header">First Name</th>
              <th class="my_other_header sorting"><a href="?order=last_name&sort_mode=asc">Last Name</a></th>
            </tr>
          </thead>
          <tbody><tr><td>andrew.hunter@livingsocial.com</td><td>Andrew</td><td>Hunter</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "tbody block" do
    it "should be able to replace the tbody block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :tbody do
          "<tbody><tr><td>My new tbody definition</td></tr></tbody>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%<table><thead><tr><th>First Name</th></tr></thead><tbody><tr><td>My new tbody definition</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify html attributes" do
      buffer = @view.table_for @users[0,1], :tbody_html => {:style => "background-color: orange"}
      xml = XmlSimple.xml_in(%%<table><thead><tr></tr></thead><tbody style="background-color: orange"><tr></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "rows block" do
    it "should be able to replace the rows block" do
      buffer = @view.table_for @users do |table|
        table.define :rows do
          "<tr><td>There are #{@users.length} rows</td></tr><tr><td>This is the next row</td></tr>".html_safe
        end
        table.column :first_name
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>First Name</th></tr></thead>
          <tbody><tr><td>There are 3 rows</td></tr><tr><td>This is the next row</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "row block" do
    it "should be able to replace the row block" do
      buffer = @view.table_for @users do |table|
        table.define :row do |user|
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
      buffer = @view.table_for @users, :row_html => {:class => lambda {@view.cycle("even", "odd")},
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

  describe "columns block" do
    it "should be able to replace the columns block" do
      buffer = @view.table_for @users[0, 1] do |table|
        table.define :columns do |user|
          table.columns.map {|column| "<td>Value: #{user.send(column.name) if user.respond_to?(column.name)}</td>"}.join("").html_safe
        end
        table.column :first_name
        table.column :last_name
        table.column :some_random_column
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th>First Name</th><th>Last Name</th><th>Some Random Column</th></tr></thead>
          <tbody><tr><td>Value: Andrew</td><td>Value: Hunter</td><td>Value:</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "column block" do
    it "should be able to replace the columns block" do
      buffer = @view.table_for @users[0, 1] do |table|
        table.define :column do |user, column, options|
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
      buffer = @view.table_for @users[0,1], :column_html => {:class => "data"} do |table|
        table.column :first_name
      end
      xml = XmlSimple.xml_in(%%<table><thead><tr><th>First Name</th></tr></thead><tbody><tr><td class="data">Andrew</td></tr></tbody></table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
    
    it "should be able to dynamically specify column attributes" do
      buffer = @view.table_for @users[0, 1], :column_html => {:class => lambda {@view.cycle("even", "odd")},
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

    it "should allow a global column_html option for all columns and the ability to override on a column by column basis" do
      buffer = @view.table_for @users[0,1], :column_html => {:class => lambda {|record, column| "#{column.name}_data"}} do |table|
        table.column :first_name, :column_html => {:class => "my_data"}
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
  end

  describe "edit block" do
    it "should be able to replace the edit block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :edit do
          "Edit Link"
        end
        table.column :edit
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td>Edit Link</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to create an edit column" do
      @view.expects(:edit_user_path).with(User.first).returns("/users/1/edit")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :edit
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1/edit">Edit</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to update the label for an edit column" do
      @view.expects(:edit_user_path).with(User.first).returns("/users/1/edit")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :edit, :link_label => "Modify"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1/edit">Modify</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the action for an edit column" do
      @view.expects(:modify_user_path).with(User.first).returns("/users/1/modify")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :edit, :action => :modify
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1/modify">Edit</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the scope for an edit column" do
      @view.expects(:edit_user_test_user_path).with(User.last, User.first).returns("/users/3/test/users/1/edit")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :edit, :scope => [User.last, :test]
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/3/test/users/1/edit">Edit</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the html for an edit column" do
      @view.expects(:edit_user_path).with(User.first).returns("/users/1/edit")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :edit, :link_html => {:style => "color:red"}
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1/edit" style="color:red">Edit</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "show block" do
    it "should be able to replace the show block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :show do
          "Show Link"
        end
        table.column :show
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td>Show Link</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to create a show column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :show
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1">Show</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to update the label for an show column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :show, :link_label => "Display"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1">Display</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the action for an show column" do
      @view.expects(:display_user_path).with(User.first).returns("/users/1/display")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :show, :action => :display
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1/display">Show</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the scope for an show column" do
      @view.expects(:user_test_user_path).with(User.last, User.first).returns("/users/3/test/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :show, :scope => [User.last, :test]
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/3/test/users/1">Show</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the html for an show column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :show, :link_html => {:style => "color:red"}
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td><a href="/users/1" style="color:red">Show</a></td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "delete block" do
    it "should be able to replace the delete block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.define :delete do
          "Delete Link"
        end
        table.column :delete
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody><tr><td>Delete Link</td></tr></tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to create a delete column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to update the label for an delete column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :link_label => "Destroy"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Destroy</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the action for an delete column" do
      @view.expects(:dispose_user_path).with(User.first).returns("/users/1/dispose")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :action => :dispose
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1/dispose" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the scope for a delete column" do
      @view.expects(:user_test_user_path).with(User.last, User.first).returns("/users/3/test/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :scope => [User.last, :test]
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/3/test/users/1" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to specify the html for a delete column" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :link_html => {:style => "color:red"}
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" style="color:red" rel="nofollow" data-method="delete" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the delete confirmation message for a delete link" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :confirm => "Are you sure?"
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" rel="nofollow" data-method="delete" data-confirm="Are you sure?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end

    it "should be able to override the method for a delete link" do
      @view.expects(:user_path).with(User.first).returns("/users/1")

      buffer = @view.table_for @users[0,1] do |table|
        table.column :delete, :method => :get
      end

      xml = XmlSimple.xml_in(%%
        <table>
          <thead><tr><th></th></tr></thead>
          <tbody>
            <tr>
              <td>
                <a href="/users/1" data-method="get" data-confirm="Are you sure you want to delete this User?">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>%)
      XmlSimple.xml_in(buffer, 'NormaliseSpace' => 2).should eql xml
    end
  end

  describe "column data contents block" do
    it "should be able to replace an individual column data contents block" do
      buffer = @view.table_for @users[0,1] do |table|
        table.column :email, :label => "Email Address"
        table.column :label => "Full Name" do |user|
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