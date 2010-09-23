ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :email, :null => false
    t.string :password, :null => false
    t.string :role, :null => false
  end

  create_table :profiles, :force => true do |t|
    t.references :user, :null => false
    t.string :first_name, :null => false
    t.string :last_name, :null => false
  end

  create_table :locations, :force => true do |t|
    t.string :name, :null => false
    t.string :code, :null => false
  end
end

class User < ActiveRecord::Base
  attr_accessible do
    self << [:password, :profile_attributes]
    self << :email if record.new_record? || 'manager' == user.role
  end

  has_one :profile
  accepts_nested_attributes_for :profile

  before_create :set_default_role

  validates_presence_of :email, :password

  def self.current
    User.last
  end

  private

  def set_default_role
    self.role ||= 'default'
  end
end

class Profile < ActiveRecord::Base
  attr_accessible do
    self << [:first_name, :last_name] if record.new_record?
  end

  belongs_to :user

  validates_presence_of :first_name, :last_name
end

class Location < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name, :code  
end
