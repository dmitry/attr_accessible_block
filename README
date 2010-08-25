AttrAccessibleBlock
===================

This is an ActiveRecord plugin with possibility to define block inside the `attr_accessible` class method.

Because of block, it's possible to define accessibles for instances, nor just for the class level.

It's also still possible to define class level accessibles, so an old `attr_accessible :name` will work.

Main features:

* Possibility to add an accessible attributes based on current `record` state (eg. record.new_record?)
* Possibility to add additional variables and use it in the block (eg. user.role) `AttrAccessible.before_options :user, lambda { User.current || User.new }`
* Possibility to add permanently total accessibility in defined condition (eg.user.admin?) `AttrAccessible.always_accessible { user.admin? }`

See an examples to understand the conception.

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

How do I add something similar to `record`, for example I want to check current users role?

Easy, with `sentient_user` gem and add the code to the `config/initializers/plugins.rb` file:

    AttrAccessible.before_options :user, lambda { User.current || User.new }

Now `user` method available, you can check:

    attr_accessible do
      self << [:password, :password_confirmation]
      self << :email if record.new_record? || user.manager?
      self << [:some_secret_fields, :another] if user.manager?
    end

What if I want to provide an total accessibility for the admin user?

Just add this code to the `config/initializers/plugins.rb` file:

    AttrAccessible.always_accessible { user.admin? }

For more answers on your questions you can look into tests and source code.

Copyright (c) 2010 Dmitry Polushkin, released under the MIT license
