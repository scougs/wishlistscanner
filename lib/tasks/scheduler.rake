namespace :scheduled_task do

  desc "This task checks for and sends the update emails"
  task :send_daily_update_emails => :environment do
    Wishlist.all.each do |wishlist|
      if wishlist.next_email.today?
        wishlist.run_scheduled_update
      end
    end
  end

end