class AddLastScanDetailsToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :last_scan_date, :datetime
    add_column :wishlists, :last_scan_array, :text
  end
end
