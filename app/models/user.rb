class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Relationships
  has_many :wishlists
  accepts_nested_attributes_for :wishlists

  # Validations
  validates :email,  uniqueness: true


  def self.created_yesterday
    where(created_at: Date.yesterday..Date.yesterday.end_of_day)
  end

end
