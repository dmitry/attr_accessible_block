require 'test_helper'

ActiveRecord::AttrAccessibleBlock.add_variable(:user) { User.current || User.new }

class AttrAccessibleBlockTest < Test::Unit::TestCase
  def setup
    setup_db

    [User, Profile].each do |k|
      k.delete_all
    end
  end

  def teardown
    teardown_db
  end

  def test_should_reject
    user = User.create(:email => 'test@test.com', :password => 'test', :role => 'admin')
    assert user.valid?
    assert !user.new_record?
    assert_equal 'test', user.password
    assert_equal 'test@test.com', user.email
    assert_equal 'default', user.role
  end

  def test_should_always_accessible
    assert_nil ActiveRecord::AttrAccessibleBlock.send(:class_variable_get, :@@always_accessible)
    ActiveRecord::AttrAccessibleBlock.always_accessible { 'admin' == user.role }
    assert_not_nil ActiveRecord::AttrAccessibleBlock.send(:class_variable_get, :@@always_accessible)

    user = User.new(:email => 'test@test.com', :password => 'test', :profile_attributes => {:first_name => 'first name', :last_name => 'last name'})
    user.role = 'admin'
    assert user.save
    assert !user.profile.new_record?
    assert_equal 'admin', user.role
    assert_equal 'first name', user.profile.first_name
    assert user.update_attributes(:profile_attributes => {:id => user.profile.id, :first_name => 'first'})
    assert_equal 'first', user.profile.first_name

    ActiveRecord::AttrAccessibleBlock.send(:class_variable_set, :@@always_accessible, nil)
    assert_nil ActiveRecord::AttrAccessibleBlock.send(:class_variable_get, :@@always_accessible)
  end

  def test_should_change_only_on_create
    user = User.create(:email => 'test@test.com', :password => 'test')
    assert user.update_attributes(:email => 'new@new.com')
    assert_equal 'test@test.com', user.email
  end

  def test_should_work_attr_accessible_question_with_block
    user = User.new(:email => 'test@test.com', :password => 'test')
    assert_equal true, user.attr_accessible?(:email)
    assert_equal true, user.attr_accessible?(:password)
    user.save
    assert_equal false, user.attr_accessible?(:email)
    assert_equal true, user.attr_accessible?(:password)
  end

  def test_should_work_attr_accessible_question_without_block
    l = Location.new(:name => 'name', :code => 'code')
    assert_equal true, l.attr_accessible?(:name)
    assert_equal false, l.attr_accessible?(:code)
  end

  def test_should_access_to_add_variable_reader
    user = User.new(:email => 'test@test.com', :password => 'test', :profile_attributes => {:first_name => 'first name', :last_name => 'last name'})
    user.role = 'manager'
    assert user.save
    user.attributes = {:email => 'new@new.com'}
    assert user.save
    assert_equal 'new@new.com', user.email
  end

  def test_simple_attr_accessible_should_work_as_expected
    l = Location.create(:name => 'name', :code => 'code')
    assert !l.valid?
    assert_equal 'name', l.name
    assert_equal nil, l.code
    l.update_attribute(:code, 'code')
    assert l.valid?
    assert_equal 'code', l.code
    l.code = 'changed'
    l.save
    assert l.valid?
    assert_equal 'changed', l.code
  end
end
