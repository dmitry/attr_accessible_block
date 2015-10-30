AttrAccessibleBlock 0.3.2
=========================

DEPRECATED SINCE >= Rails 4.x

[![travis-ci status](https://secure.travis-ci.org/dmitry/attr_accessible_block.png)](http://travis-ci.org/dmitry/attr_accessible_block) [![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/dmitry/attr_accessible_block/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Tested on Rubies: 1.9.3, 2.0.0, 2.1.1 thanks to Travis!

> If you need same functionallity for the Rails 2.3 or Rails 3.0, then use v0.2.2, it's fully tested and ready for this oldies. New version is total rewrite of the previous plugin, but API is the same, so it's easy to migrate if needed.

Latest version of the gem is only available for the Rails 3.2.x

This is an ActiveModel plugin with possibility to define block inside the `attr_accessible` class method. `attr_protected` not supported.

Because of block, it's possible to define accessibles for instances, not just for the class level.

It's also still possible to define class level accessibles, so an old `attr_accessible :name` will work.

Main features:

* Add an accessible attributes based on current `record` state (eg. record.new_record?)
* Add additional variables and use it in the block (eg. current user) `ActiveModel::MassAssignmentSecurity::WhiteListBlock.add_variable(:user) { User.current || User.new }`
* Add permanently full accessibility on defined condition (eg.user.admin?) `ActiveModel::MassAssignmentSecurity::WhiteListBlock.always_accessible { user.admin? }`
* Check is attribute mass-assignable or no using `attr_accessible?` instance method, that returns boolean value.

See an examples to understand the conception or specs.

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
        add [:password, :password_confirmation]
        add :email if record.new_record?
      end
    end

And creation of the user now can be written more DRYer

    user = User.create(params[:user])

And on user update changing of email will be rejected because of `new_record?` method.

Sometimes you may need to check is attribute of model assignable or no (this method mostly interesting when doing form inputs). You can do it with using `attr_accessible?` method:

    user.attr_accessible?(:email) # returns false
    user.attr_accessible?(:password) # returns true

How do I add something similar to `record`, for example I want to check current users role?

Easy, with `sentient_user` gem and add the code to the `config/initializers/plugins.rb` file:

    ActiveModel::MassAssignmentSecurity::WhiteListBlock.add_variable(:user) { User.current || User.new }

Now `user` method available, you can check:

    attr_accessible do
      add [:password, :password_confirmation]
      add :email if record.new_record? || user.manager?
      add [:some_secret_fields, :another] if user.manager?
    end

What if I want to provide an total accessibility for the admin user?

Just add this code to the `config/initializers/plugins.rb` file:

    ActiveModel::MassAssignmentSecurity::WhiteListBlock.always_accessible { user.admin? }

It works even with standard `attr_accessible`, look into specs to see behaviour.

> NOTE: if you are getting `stack level too deep` then you have recursive call of the model object in `always_accessible` or `add_variable` blocks. Try to avoid it.

Should be STI compatible, but haven't tested yet. Need's feedback on this feature. Feel free to contact with me if something goes wrong.

And there is more, you always still can use old implementation of the `attr_accessible`, just use `old_attr_accessible` method in your models.

For more answers on your questions you can look into tests and source code.

Used on http://tenerife.by

Copyright (c) 2010-2012 Dmitry Polushkin, released under the MIT license
