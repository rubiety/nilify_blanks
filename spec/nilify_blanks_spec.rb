require "spec_helper"

RSpec.describe NilifyBlanks do
  context "Model with nilify_blanks" do
    before(:all) do
      class Post < ActiveRecord::Base
        nilify_blanks
      end

      @post = Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :blog_id => '')
      @post.save
    end

    it "should recognize all non-null string, text, citext columns" do
      expect(Post.nilify_blanks_columns).to eq(['first_name', 'title', 'summary', 'body', 'slug', 'blog_id'])
    end

    it "should convert all blanks to nils" do
      expect(@post.first_name).to be_nil
      expect(@post.title).to be_nil
      expect(@post.summary).to be_nil
      expect(@post.body).to be_nil
      expect(@post.slug).to be_nil
      expect(@post.blog_id).to be_nil
    end

    it "should leave not-null last name field alone" do
      expect(@post.last_name).to eq("")
    end

    it "should leave integer views field alone" do
      expect(@post.views).to eq(0)
    end
  end

  context "Model with nilify_blanks :nullables_only => false" do
    before(:all) do
      class PostWithNullables < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :nullables_only => false
      end

      @post = PostWithNullables.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :blog_id => '')
    end

    it "should recognize all (even null) string, text, citext columns" do
      expect(PostWithNullables.nilify_blanks_columns).to eq(['first_name', 'last_name', 'title', 'summary', 'body', 'slug', 'blog_id'])
    end
  end

  context "Model with nilify_blanks :types => [:text]" do
    def citext_supported
      PostOnlyText.content_columns.detect {|c| c.type == :citext}
    end

    before(:all) do
      class PostOnlyText < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :types => [:text]
      end

      @post = PostOnlyText.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
      @post.save
    end

    it "should recognize all non-null text only columns" do
      expected_types = ['summary', 'body']
      expected_types << 'slug' unless citext_supported
      expect(PostOnlyText.nilify_blanks_columns).to eq(expected_types)
    end

    it "should convert all blanks to nils" do
      expect(@post.summary).to be_nil
      expect(@post.body).to be_nil
      expect(@post.slug).to be_nil unless citext_supported
    end

    it "should leave not-null string fields alone" do
      expect(@post.first_name).to eq("")
      expect(@post.last_name).to eq("")
      expect(@post.title).to eq("")
      expect(@post.slug).to eq("") if citext_supported
    end
  end

  context "Model with nilify_blanks :only => [:first_name, :title]" do
    before(:all) do
      class PostOnlyFirstNameAndTitle < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :only => [:first_name, :title]
      end

      @post = PostOnlyFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
      @post.save
    end

    it "should recognize only first_name and title" do
      expect(PostOnlyFirstNameAndTitle.nilify_blanks_columns).to eq(['first_name', 'title'])
    end

    it "should convert first_name and title blanks to nils" do
      expect(@post.first_name).to be_nil
      expect(@post.title).to be_nil
    end

    it "should leave other fields alone" do
      expect(@post.summary).to eq("")
      expect(@post.body).to eq("")
      expect(@post.slug).to eq("")
    end
  end

  context "Model with nilify_blanks :except => [:first_name, :title]" do
    before(:all) do
      class PostExceptFirstNameAndTitle < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :except => [:first_name, :title, :blog_id]
      end

      @post = PostExceptFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
      @post.save
    end

    it "should recognize only summary, body, and views" do
      expect(PostExceptFirstNameAndTitle.nilify_blanks_columns).to eq(['summary', 'body', 'slug'])
    end

    it "should convert summary and body blanks to nils" do
      expect(@post.summary).to be_nil
      expect(@post.body).to be_nil
      expect(@post.slug).to be_nil
    end

    it "should leave other fields alone" do
      expect(@post.first_name).to eq("")
      expect(@post.title).to eq("")
    end
  end


  context "Global Usage" do
    context "Namespaced Base Class with nilify_blanks inline" do
      before(:all) do
        module Admin1
          class Base < ActiveRecord::Base
            self.abstract_class = true
            nilify_blanks
          end
        end

        class Admin1::Post < Admin1::Base
          self.table_name = "posts"
        end

        @post = Admin1::Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        expect(@post.first_name).to be_nil
      end
    end

    context "Namespaced Base Class with nilify_blanks applied after definition" do
      before(:all) do
        module Admin2
          class Base < ActiveRecord::Base
            self.abstract_class = true
          end
        end

        class Admin2::Post < Admin2::Base
          self.table_name = "posts"
        end

        Admin2::Base.nilify_blanks

        @post = Admin2::Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        expect(@post.first_name).to be_nil
      end
    end

    context "Namespaced Base Class with nilify_blanks applied after definition" do
      before(:all) do
        ActiveRecord::Base.nilify_blanks

        class InheritedPost < ActiveRecord::Base
          self.table_name = "posts"
        end

        @post = InheritedPost.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        expect(@post.first_name).to be_nil
      end
    end

  end
end
