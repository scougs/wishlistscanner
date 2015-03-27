class CreateWishlists < ActiveRecord::Migration
  def change
    create_table :wishlists do |t|
      t.string :wishlist_id
      t.integer :threshold

      t.timestamps null: false
    end
  end
end
