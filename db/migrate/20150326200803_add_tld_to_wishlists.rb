class AddTldToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :wishlist_tld, :string
  end
end
