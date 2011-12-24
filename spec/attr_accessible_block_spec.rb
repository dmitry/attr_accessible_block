# encoding: utf-8
require 'spec_helper'

class BaseModel
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::AttributeMethods

  def self.attributes(attributes)
    attr_accessor *attributes
    define_attribute_methods attributes
  end

  def initialize(attributes={})
    sanitize_for_mass_assignment(attributes).each do |name, value|
      update_attribute(name, value)
    end
  end

  def update_attribute(name, value)
    multi = (name.to_s.match(/^(.+)\(/))
    name = multi[1] if multi

    send(:"#{name}=", value)
  end
end

class User < BaseModel
  attributes %w(email password date role)

  attr_accessible :email, :password, :date

  def self.current
    User.new
  end
end

class Location < BaseModel
  attributes %w(name size user point)

  attr_accessible do
    add [:name, :size]
    add :user if user.role == :moderator
  end
end

ActiveModel::MassAssignmentSecurity::WhiteListBlock.add_variable(:user) { User.current }
ActiveModel::MassAssignmentSecurity::WhiteListBlock.always_accessible { User.current.role == :admin }

describe AttrAccessibleBlock do
  it "should have standard static attr_accessible" do
    user = User.new(:email => 'test@test.com', :password => 'test', 'date(i0)' => '10', :role => 'admin')
    user.password.should eq 'test'
    user.email.should eq 'test@test.com'
    user.date.should eq '10'
    user.role.should be_nil
  end

  it "should have block attr_accessible" do
    location = Location.new(:name => 'test', :size => 10, :user => 'user', 'point(i2)' => '10')
    location.name.should eq 'test'
    location.size.should eq 10
    location.user.should be_nil
    location.point.should be_nil
  end

  it "should have block attr_accessible" do
    location = Location.new(:name => 'test', :size => 10, :user => 'user', 'point(i2)' => '10')
    location.attr_accessible?(:name).should be_true
    location.attr_accessible?(:size).should be_true
    location.attr_accessible?(:user).should be_false
    location.attr_accessible?(:point).should be_false
  end

  it "should have block attr_accessible that always accessible" do
    u = User.new.tap { |u| u.role = :admin }
    User.should_receive(:current).twice.and_return(u)
    location = Location.new(:name => 'test', :size => 10, :user => 'user', 'point(i2)' => '10')
    location.name.should eq 'test'
    location.size.should eq 10
    location.user.should eq 'user'
    location.point.should eq '10'
  end

  it "should have block attr_accessible uses variable" do
    u = User.new.tap { |u| u.role = :moderator }
    User.should_receive(:current).twice.and_return(u)
    location = Location.new(:name => 'test', :size => 10, :user => 'user', 'point(i2)' => '10')
    location.name.should eq 'test'
    location.size.should eq 10
    location.user.should eq 'user'
    location.point.should be_nil
  end
end