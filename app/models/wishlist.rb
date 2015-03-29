class Wishlist < ActiveRecord::Base

# Relationships
  belongs_to :user

  # Before Filters
  before_save :extract_wishlist_details

  serialize :last_scan_array


  def extract_wishlist_details
    if wishlist_tld.blank?
      url = wishlist_id
      extract_wishlist_id(url)
      extract_wishlist_tld(url)
    end
  end


  def extract_wishlist_id(url)
    extracted_wishlist_id = url.match("/([A-Z0-9]{10,15})")[1]
    write_attribute(:wishlist_id, extracted_wishlist_id)
  end


  def extract_wishlist_tld(url)
    extracted_wishlist_domain = url.match(".*\:\/\/?([^\/]+)")[1]
    extracted_wishlist_tld = PublicSuffix.parse(extracted_wishlist_domain).tld
    write_attribute(:wishlist_tld, extracted_wishlist_tld)
  end


  def wishlist_show_items
    wishlist_scrape_array = last_scan_array
    items_under_threshold_array = []
    wishlist_scrape_array.each do |item|
      if item[:price] != "Unavailable" && item[:price].cents <= threshold
        items_under_threshold_array << item
      end
    end
    return items_under_threshold_array
  end


  def wishlist_run
    wishlist_scrape_array = wishlist_scan
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


  def wishlist_scan
    wishlist_scrape_array = []
    url = wishlist_kindle_only_url
    page = create_mechanize_page(url)

    wishlist_scrape(page, wishlist_scrape_array)

    return wishlist_scrape_array
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

end
