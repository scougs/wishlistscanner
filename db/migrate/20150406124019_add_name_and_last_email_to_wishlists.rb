class AddNameAndLastEmailToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :name, :string
    add_column :wishlists, :last_email, :datetime
    add_column :wishlists, :next_email, :datetime
  end
end
