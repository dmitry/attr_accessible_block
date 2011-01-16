AttrAccessibleBlock 0.2
=======================

This is an ActiveRecord plugin with possibility to define block inside the `attr_accessible` class method.

Tested with Rails 2.3 and 3.0

Because of block, it's possible to define accessibles for instances, nor just for the class level.

It's also still possible to define class level accessibles, so an old `attr_accessible :name` will work.

Main features:

* Possibility to add an accessible attributes based on current `record` state (eg. record.new_record?)
* Possibility to add additional variables and use it in the block (eg. user.role) `ActiveRecord::AttrAccessibleBlock.before_options :user, lambda { User.current || User.new }`
* Possibility to add permanently total accessibility in defined condition (eg.user.admin?) `ActiveRecord::AttrAccessibleBlock.always_accessible { user.admin? }`

Also it's possible to check directly is attribute mass-assignable or no using `attr_accessible?` instance method.

See an examples to understand the conception.

Installation
============

    gem install attr_accessible_block

Examples
========

How many times you had code like that:

    class User < ActiveRecord::Base
      attr_accessible :password, :password_confirmation

      # ...
    end

And in controller:

    def create
      user = User.new(params[:user])
      user.email = params[:user][:email]
      user.save

      # ...
    end

Now it's possible to do it easier:

    class User < ActiveRecord::Base
      attr_accessible do
        self << [:password, :password_confirmation]
        self << :email if record.new_record?
      end
    end

And creation of the user now can be written more DRYer

    user = User.create(params[:user])

And on user update changing of email will be rejected because of `new_record?` method.

Sometimes you may need to check is attribute of model assignable or no (this method mostly interesting when doing form inputs). You can do it with using `attr_accessible?` method:

    user.assignable?(:email) # returns false
    user.assignable?(:password) # returns true

How do I add something similar to `record`, for example I want to check current users role?

Easy, with `sentient_user` gem and add the code to the `config/initializers/plugins.rb` file:

    ActiveRecord::AttrAccessibleBlock.before_options :user, lambda { User.current || User.new }

Now `user` method available, you can check:

    attr_accessible do
      self << [:password, :password_confirmation]
      self << :email if record.new_record? || user.manager?
      self << [:some_secret_fields, :another] if user.manager?
    end

What if I want to provide an total accessibility for the admin user?

Just add this code to the `config/initializers/plugins.rb` file:

    ActiveRecord::AttrAccessibleBlock.always_accessible { user.admin? }

NOTICE: when using attr_accessible as a block, then no second parameter is available for the `attributes=` method (guard_protected_attributes = true). Instead use power of blocks! Also do not use attr_protected, because it's bad :)

Should be STI compatible, but haven't tested yet. Need's feedback on this feature. Feel free to contact with me if something goes wrong.

For more answers on your questions you can look into tests and source code.

Copyright (c) 2010 Dmitry Polushkin, released under the MIT license
