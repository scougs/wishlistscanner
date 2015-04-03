class AddTypeAndFrequancyToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :frequency, :string
    add_column :wishlists, :kindle_only, :boolean, default: false
  end
end
