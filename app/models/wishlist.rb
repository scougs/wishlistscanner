require 'action_view'
include ActionView::Helpers::NumberHelper

class Wishlist < ActiveRecord::Base

# Relationships
belongs_to :user

# Before Filters
before_save :extract_wishlist_details
# before_save :set_wishlist_threshold

serialize :last_scan_array

# Validations
  validates :wishlist_id, :wishlist_url, :kindle_only, :frequency, :name, presence: true, :on => :save


  def extract_wishlist_details
    if wishlist_tld.blank?
      url = wishlist_id
      extract_wishlist_id(url)
      extract_wishlist_tld(url)
      fetch_wishlist_name_from_amazon
    end
  end


  def extract_wishlist_id(url)
    extracted_wishlist_id = url.match("([A-Z0-9]{10,15})")[1]
    write_attribute(:wishlist_id, extracted_wishlist_id)
  end


  def extract_wishlist_tld(url)
    extracted_wishlist_domain = url.match(".*\:\/\/?([^\/]+)")[1]
    extracted_wishlist_tld = PublicSuffix.parse(extracted_wishlist_domain).tld
    write_attribute(:wishlist_tld, extracted_wishlist_tld)
  end


  def fetch_wishlist_name_from_amazon
    wishlist_name = Nokogiri::HTML(open(wishlist_full_url)).css('span.a-size-extra-large').children[1].children.text.strip
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


  def wishlist_show_items
    if last_scan_date.present?
      wishlist_scrape_array = last_scan_array
      items_under_threshold_array = []
      wishlist_scrape_array.each do |item|
        if item[:price] != "Unavailable" && item[:price].cents <= threshold
          items_under_threshold_array << item
        end
      end
    end
    return items_under_threshold_array
  end


  def wishlist_run
    wishlist_scrape_array = scan_all_items

    items_under_threshold_array = []

    wishlist_scrape_array.each do |item|
      if item[:price] != "Unavailable" && item[:price].cents <= threshold
        items_under_threshold_array << item
      end
    end

    self.last_scan_array = wishlist_scrape_array
    self.last_scan_date = DateTime.now
    self.save
    return items_under_threshold_array

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
      part_link = e.search('h5 > a').first.attributes["href"].value

      #extract the asin from the url
      wishlist_item[:asin] = part_link.match("/([A-Z0-9]{10})")[1]

      #create the link to the book with the affiliate link
      wishlist_item[:link] = "http://www.amazon.co.uk/dp" + part_link + "&tag=kindlescanner-21"

      #extract the title
      wishlist_item[:title] = e.search('h5 > a').first.attributes["title"].value

      #extract the price
      price = e.search('span.a-color-price').first.children.first.text.chars.select(&:valid_encoding?).join.strip
      if price == "Unavailable"
        wishlist_item[:price] = price
      else
        Monetize.assume_from_symbol = true
        wishlist_item[:price] = price.to_money
      end

      wishlist_scrape_array << wishlist_item

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
    #run wishlist scan
    wishlist_run
    #send update email
    send_update_email
  end


  def send_update_email
    #send the update email
    WishlistMailer.wishlist_results_email(self.id).deliver

    #update the dates for last and next emails
    update(last_email: DateTime.now)
    update_next_update_email_date

  end


  def update_next_update_email_date
    if frequency == "Weekly"
      update(next_email: last_email + 7.days)
    elsif frequency == "Daily"
      update(next_email: last_email + 1.days)
    end
  end

end
