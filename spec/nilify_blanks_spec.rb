require "spec_helper"

describe NilifyBlanks do
  
  context "Model with nilify_blanks" do
    before(:all) do
      class Post < ActiveRecord::Base
        nilify_blanks
      end
      
      @post = Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    it "should recognize all non-null string, text columns" do
      Post.nilify_blanks_columns.should == ['first_name', 'title', 'summary', 'body']
    end
    
    it "should convert all blanks to nils" do
      @post.first_name.should be_nil
      @post.title.should be_nil
      @post.summary.should be_nil
      @post.body.should be_nil
    end
    
    it "should leave not-null last name field alone" do
      @post.last_name.should == ""
    end
    
    it "should leave integer views field alone" do
      @post.views.should == 0
    end
  end

  context "Model with nilify_blanks :types => [:text]" do
    before(:all) do
      class PostOnlyText < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :types => [:text]
      end
      
      @post = PostOnlyText.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    it "should recognize all non-null text only columns" do
      PostOnlyText.nilify_blanks_columns.should == ['summary', 'body']
    end
    
    it "should convert all blanks to nils" do
      @post.summary.should be_nil
      @post.body.should be_nil
    end
    
    it "should leave not-null string fields alone" do
      @post.first_name.should == ""
      @post.last_name.should == ""
      @post.title.should == ""
    end
  end
  
  context "Model with nilify_blanks :only => [:first_name, :title]" do
    before(:all) do
      class PostOnlyFirstNameAndTitle < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :only => [:first_name, :title]
      end
      
      @post = PostOnlyFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    it "should recognize only first_name and title" do
      PostOnlyFirstNameAndTitle.nilify_blanks_columns.should == ['first_name', 'title']
    end
    
    it "should convert first_name and title blanks to nils" do
      @post.first_name.should be_nil
      @post.title.should be_nil
    end
    
    it "should leave other fields alone" do
      @post.summary.should == ""
      @post.body.should == ""
    end
  end
  
  context "Model with nilify_blanks :except => [:first_name, :title]" do
    before(:all) do
      class PostExceptFirstNameAndTitle < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :except => [:first_name, :title]
      end
      
      @post = PostExceptFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    it "should recognize only summary, body, and views" do
      PostExceptFirstNameAndTitle.nilify_blanks_columns.should == ['summary', 'body']
    end
    
    it "should convert summary and body blanks to nils" do
      @post.summary.should be_nil
      @post.body.should be_nil
    end
    
    it "should leave other fields alone" do
      @post.first_name.should == ""
      @post.title.should == ""
    end
  end
  
end
