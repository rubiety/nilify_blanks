require File.join(File.dirname(__FILE__), 'test_helper')

class NilifyBlanksTest < Test::Unit::TestCase
  context "Model with nilify_blanks" do
    setup do
      class Post < ActiveRecord::Base
        nilify_blanks
      end
      
      @post = Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    should "recognize all non-null columns" do
      assert_equal ['first_name', 'title', 'summary', 'body', 'views'], Post.nilify_blanks_columns
    end
    
    should "convert all blanks to nils" do
      assert_equal nil, @post.first_name
      assert_equal nil, @post.title
      assert_equal nil, @post.summary
      assert_equal nil, @post.body
    end
    
    should "leave not-null last name field alone" do
      assert_equal '', @post.last_name
    end
    
    should "leave integer views field alone" do
      assert_equal 0, @post.views
    end
  end
  
  context "Model with nilify_blanks :only => [:first_name, :title]" do
    setup do
      class PostOnlyFirstNameAndTitle < ActiveRecord::Base
        set_table_name :posts
        nilify_blanks :only => [:first_name, :title]
      end
      
      @post = PostOnlyFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    should "recognize only first_name and title" do
      assert_equal ['first_name', 'title'], PostOnlyFirstNameAndTitle.nilify_blanks_columns
    end
    
    should "convert first_name and title blanks to nils" do
      assert_equal nil, @post.first_name
      assert_equal nil, @post.title
    end
    
    should "leave other fields alone" do
      assert_equal '', @post.summary
      assert_equal '', @post.body
    end
  end
  
  context "Model with nilify_blanks :except => [:first_name, :title]" do
    setup do
      class PostExceptFirstNameAndTitle < ActiveRecord::Base
        set_table_name :posts
        nilify_blanks :except => [:first_name, :title]
      end
      
      @post = PostExceptFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :views => 0)
      @post.save
    end
    
    should "recognize only summary, body, and views" do
      assert_equal ['summary', 'body', 'views'], PostExceptFirstNameAndTitle.nilify_blanks_columns
    end
    
    should "convert summary and body blanks to nils" do
      assert_equal nil, @post.summary
      assert_equal nil, @post.body
    end
    
    should "leave other fields alone" do
      assert_equal '', @post.first_name
      assert_equal '', @post.title
    end
  end
end
