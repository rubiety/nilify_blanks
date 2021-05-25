{<img src="https://secure.travis-ci.org/rubiety/nilify_blanks.svg?branch=master" alt="Build Status" />}[http://travis-ci.org/rubiety/nilify_blanks]

== Nilify Blanks

In Rails when saving a model from a form and values are not provided by the user, an empty string is recorded to the database instead of a NULL as many would prefer (mixing blanks and NULLs can become confusing).  This plugin allows you to specify a list of attributes (or exceptions from all the attributes) that will be converted to nil if they are blank before a model is saved.

By default, columns set as NOT NULL will not be nilified, since that value cannot be persisted, and it might be better to catch that with a validation. If you want to nilify those columns anyway, you can use `only:` (see below) to explicitly mention them.

Only attributes responding to blank? with a value of true will be converted to nil.  Therefore, this does not work with integer fields with the value of 0, for example.  Usage is best shown through examples:

== Requirements

As of v1.4.0, this gem requires Rails 4 and Ruby 2.2 or higher.

== Install

Include the gem using bundler in your Gemfile:

  gem "nilify_blanks"

== Basic Usage

  # Checks and converts all content fields in the model
  class Post < ActiveRecord::Base
    nilify_blanks
  end

  # Checks and converts only text fields in the model
  class Post < ActiveRecord::Base
    nilify_blanks types: [:text]
  end

  # Checks and converts only the title and author fields
  class Post < ActiveRecord::Base
    nilify_blanks only: [:author, :title]
  end

  # Checks and converts all fields except for title and author
  class Post < ActiveRecord::Base
    nilify_blanks except: [:author, :title]
  end

  # Checks and converts any fields, regardless of their null constraint
  class Post < ActiveRecord::Base
    nilify_blanks nullables_only: false
  end

== Global Usage

You can also apply nilify_blanks to all models inheriting from ActiveRecord::Base:

  ActiveRecord::Base.nilify_blanks

Or perhaps just a model namespace base class:

  Inventory::Base.nilify_blanks

== Specifying a Callback

Checking uses an ActiveRecord before_validation callback by default, but you can specify a different callback with the :before option.  Any callback will work - just first remove the "before_" prefix from the name.

  class Post < ActiveRecord::Base
    nilify_blanks before: :create
  end

  class Post < ActiveRecord::Base
    nilify_blanks before: :validation_on_update
  end

== RSpec Matcher

First, include the matchers:

  require "nilify_blanks/matchers"

To ensure for a given column:

  describe City do
    it { should nilify_blanks_for(:name) }
  end

To ensure for all applicable content columns:

  describe City do
    it { should nilify_blanks }
  end

You can optionally match on options also:

  describe City do
    it { should nilify_blanks_for(:name, before: :create) }
  end

  describe City do
    it { should nilify_blanks(before: :create) }
  end

== Running Tests

This gem uses appraisal to test with different versions of the dependencies. See Appraisal first for which versions are tested, then run to test all appraisals:

  $ rake appraisal install
  $ rake appraisal test
