class AddNewItemsToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :new_items, :text
  end
end
