class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.integer   :total_items_scanned
      t.integer   :items_scanned_on_last_daily_scan
      t.datetime  :last_scan_start_time
      t.datetime  :last_scan_end_time
      t.integer   :emails_sent_during_last_daily_scan
    end
  end
end