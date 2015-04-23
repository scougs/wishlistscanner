namespace :scheduled_task do

  desc "This task checks for and sends the update emails"
  task :send_daily_update_emails => :environment do
    #create a new @daily_scan_entry
    @daily_scan_entry = Scan.new
    #set the last_scan_start_time to now
    last_scan_start_time = Time.now
    #set daily_scan_entry variables as 0
    items_scanned_on_last_daily_scan = 0
    emails_sent_during_last_daily_scan = 0

    Wishlist.all.each do |wishlist|
      # if wishlist.next_email.today? || wishlist.next_email == nil
      if nil == nil
        wishlist.run_scan_tasks

        items_scanned_on_last_daily_scan +=  wishlist.last_scan_array.count
        emails_sent_during_last_daily_scan += 1
      end
    end

    #set the last_scan_end_time to now
    last_scan_end_time = Time.now
    #add items_scanned_on_last_daily_scan to the total_items_scanned
    if Scan.last == nil
      total_items_scanned = items_scanned_on_last_daily_scan
    else
      total_items_scanned = Scan.last.total_items_scanned += items_scanned_on_last_daily_scan
    end
    #update the daily scan
    @daily_scan_entry.update_attributes(
                      :total_items_scanned => total_items_scanned,
                      :items_scanned_on_last_daily_scan => items_scanned_on_last_daily_scan,
                      :last_scan_start_time => last_scan_start_time,
                      :last_scan_end_time => last_scan_end_time,
                      :emails_sent_during_last_daily_scan =>emails_sent_during_last_daily_scan)
    #send admin email
    @daily_scan_entry.send_daily_admin_email
  end

end