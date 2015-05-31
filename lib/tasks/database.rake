namespace :database_task do

  desc "This task populates the last_scan_items_under_threshold table from the last scan for all Wishlists in the database"
  task :populate_last_scan_items_under_threshold => :environment do
    Wishlist.all.each do |wishlist|
      items_under_threshold_array = []
      wishlist.last_scan_array.each do |item|
        if item[:price] != "Unavailable" && item[:price].cents <= wishlist.threshold
          items_under_threshold_array << item
        end
      end
      wishlist.last_scan_items_under_threshold = items_under_threshold_array
      wishlist.save!
    end
  end

end