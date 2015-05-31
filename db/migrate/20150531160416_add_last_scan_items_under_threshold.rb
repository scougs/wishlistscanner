class AddLastScanItemsUnderThreshold < ActiveRecord::Migration
  def change
    add_column :wishlists, :last_scan_items_under_threshold, :text
  end
end
