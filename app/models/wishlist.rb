require 'action_view'
include ActionView::Helpers::NumberHelper

class Wishlist < ActiveRecord::Base

  # Relationships
  belongs_to :user

  # Serialize
  serialize :last_scan_array
  serialize :new_items
  serialize :last_scan_items_under_threshold

  # Validations
  validate :url_contains_wishlist_id
  validates :wishlist_id, :wishlist_url, :kindle_only, :frequency, :name, presence: true, :on => :save

  # Before Filters
  before_save :extract_wishlist_details
  before_save :default_consecutive_empty_scan_count


  def default_consecutive_empty_scan_count
    consecutive_empty_scan_count ||= 0
  end


  def url_contains_wishlist_id
    if wishlist_id_from_amazon_url_regex(wishlist_id) == nil
      errors.add(:wishlist_id, "The Wishlist URL is not valid as it doesn't have the ID needed.")
    end
  end


  def extract_wishlist_details
    if wishlist_tld.blank?
      extract_wishlist_tld(wishlist_id)
      extract_wishlist_id(wishlist_id)
      fetch_wishlist_name_from_amazon
    end
  end


  def extract_wishlist_id(url)
    write_attribute(:wishlist_id, wishlist_id_from_amazon_url_regex(url)[1])
  end


  def wishlist_id_from_amazon_url_regex(url)
    url.match("([A-Z0-9]{10,15})")
  end


  def extract_wishlist_tld(url)
    extracted_wishlist_domain = url.match(".*\:\/\/?([^\/]+)")[1]
    extracted_wishlist_tld = PublicSuffix.parse(extracted_wishlist_domain).tld
    write_attribute(:wishlist_tld, extracted_wishlist_tld)
  end


  def fetch_wishlist_name_from_amazon
    wishlist_name = Nokogiri::HTML(open(wishlist_full_url)).css("#wl-list-info").children[3].children[1].text.strip
    write_attribute(:name, wishlist_name)
  end


  def threshold_float
    e = threshold.to_f/100
    e = number_with_precision(e, precision: 2)
    return e
  end


  def set_wishlist_threshold
  end


  def threshold_to_float
    e = threshold.to_f/100
    e = number_with_precision(e, precision: 2)
    return e
  end


  def wishlist_run
    wishlist_scrape_array = scan_all_items

    items_under_threshold_array = []

    wishlist_scrape_array.each do |item|
      if item[:price] != "Unavailable" && item[:price].cents <= threshold
        items_under_threshold_array << item
      end
    end

    if last_scan_array?
      self.new_items = identify_new_items(items_under_threshold_array)
    end

    self.last_scan_array = wishlist_scrape_array
    self.last_scan_date = DateTime.now
    self.last_scan_items_under_threshold = items_under_threshold_array
    self.save
    return self.last_scan_items_under_threshold

  end


  def identify_new_items(items_under_threshold_array)
    items_under_threshold_array - last_scan_items_under_threshold
  end


  def scan_all_items
    wishlist_scrape_array = []
    url = wishlist_scan_url
    page = create_mechanize_page(url)

    wishlist_scrape(page, wishlist_scrape_array)

    return wishlist_scrape_array
  end


  def wishlist_scan_url
    if kindle_only == true
      url = wishlist_kindle_only_url
    else
      url = wishlist_full_url
    end
    return url
  end


  def wishlist_full_url
    "http://www.amazon." + wishlist_tld + "/gp/registry/wishlist/" + wishlist_id
  end


  def wishlist_kindle_only_url
    "http://www.amazon." + wishlist_tld + "/gp/registry/wishlist/" + wishlist_id + "?filter=337"
  end


  def create_mechanize_page(url)
    agent = Mechanize.new
    page = agent.get(url)
    return page
  end


  def wishlist_scrape(page, wishlist_scrape_array)

    page.search('div[id^="itemInfo"]').each do |e|
      wishlist_item = {}

      #extract the url from the page
      part_link = e.search('h5 > a')

      if !part_link.empty?

        #extract the asin from the url
        wishlist_item[:asin] = part_link.first.attributes["href"].value.match("/([A-Z0-9]{10})")[1]

        #create the link to the book with the affiliate link
        wishlist_item[:link] = "http://www.amazon.co.uk/dp/" + wishlist_item[:asin] + "?&tag=wishlistscanner-21"

        #extract the title
        wishlist_item[:title] = e.search('h5 > a').first.attributes["title"].value

        #extract the price
        price = e.search('span.a-color-price').first.children.first.text.chars.select(&:valid_encoding?).join.strip
        binding.pry
        if price == "Unavailable"
          wishlist_item[:price] = price
        elsif price < 2
          wishlist_item[:price] = price
        else
          Monetize.assume_from_symbol = true
          wishlist_item[:price] = price.to_money
        end

        wishlist_scrape_array << wishlist_item
      end

    end

    if is_there_a_next_page?(page)
      wishlist_next_page(page, wishlist_scrape_array)
    else
      return wishlist_scrape_array
    end

  end


  def is_there_a_next_page?(page)
    page.link_with(:text => "Next→") != nil
  end


  def wishlist_next_page(page, wishlist_scrape_array)
    next_page = page.link_with(:text => "Next→").click
    wishlist_scrape(next_page, wishlist_scrape_array)
  end


  def run_scan_tasks
    wishlist_run
    #check to see if there are items under the threshold
    if !last_scan_items_under_threshold.empty?
      send_update_email
      update_last_email_date
    else
      increment_empty_scan_count

      if consecutive_empty_scan_count == 1
        WishlistMailer.wishlist_first_notify_email(self.id).deliver
      elsif consecutive_empty_scan_count % 5 == 0
        WishlistMailer.wishlist_we_are_still_here(self.id).deliver
      end

    end
    update_next_update_email_date
  end

  def increment_empty_scan_count
    self.consecutive_empty_scan_count += 1
    save
  end


  def send_update_email
    WishlistMailer.wishlist_results_email(self.id).deliver
  end


  def update_last_email_date
    #set the last email sent time to current time
    update(last_email: DateTime.now)
  end

  def update_next_update_email_date
    if last_email == nil
      update(last_email: DateTime.now)
    else
      if frequency == "Weekly"
        update(next_email: last_email + 7.days)
      elsif frequency == "Daily"
        update(next_email: last_email + 1.days)
      end
    end
  end


  def self.created_yesterday
    where(created_at: Date.yesterday..Date.yesterday.end_of_day)
  end


  def is_vaild_price?(price)
    if price.empty?
      return false
    elsif condition

  end


  def populate_last_scan_items_under_threshold
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
