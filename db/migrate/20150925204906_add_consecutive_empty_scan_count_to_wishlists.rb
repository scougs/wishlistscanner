class AddConsecutiveEmptyScanCountToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :consecutive_empty_scan_count, :integer, :default => 0
  end
end
