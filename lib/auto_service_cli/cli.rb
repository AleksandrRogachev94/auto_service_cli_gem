class AutoServiceCLI::CLI

  attr_reader :zip, :cur_sort_type
  attr_reader :scraper

  def initialize
    self.cur_sort_type = "default"
  end

  def call
    puts "Welcome to auto service centers searching CLI!"
    prompt_zip
    scrape_main_page
    list_centers
    menu
  end

  def prompt_zip
    begin
      puts "Enter you zip code:"
      zip = gets.strip
    end until AutoServiceCLI::Scraper.valid_zip?(zip)
    self.zip = zip
  end

  # Writers and Readers

  def zip=(zip)
    @zip = zip if AutoServiceCLI::Scraper.valid_zip?(zip)
  end

  def cur_sort_type=(type)
    @cur_sort_type = type if AutoServiceCLI::Scraper.valid_sort_type?(type)
  end

  #-----------------------------------------------------------------------------------
  # Menu methods

  def menu
    loop do
      help_menu
      puts "\nMake a choise:"
      input = gets.strip
      case input
      when "1"
        list_centers
      when "2"
        sort
      when "3"
        get_details
      when "10"
        goodbye
        break
      end
    end
  end

  def list_centers
    puts "-----------------------------------------------------------------------------"
    AutoServiceCLI::ServiceCenter.all.each.with_index(1) do |center,i|
      print "#{i}. #{center.name}"
      puts center.rating.nil? ? "" : ", rating: #{center.rating}"
    end
    puts "-----------------------------------------------------------------------------"
  end

  def sort
    help_sort
    puts "\tChoose type of sorting:"
    input = gets.strip
    case input
    when "1"
      self.cur_sort_type = "default"
    when "2"
      self.cur_sort_type = "distance"
    when "3"
      self.cur_sort_type = "average_rating"
    when "4"
      self.cur_sort_type = "name"
    end
    scrape_main_page
    list_centers
  end

  def get_details
    puts "\tEnter the number of center:"
    input = gets.strip

    if input.to_i >= 1 && input.to_i <= 30
      center = AutoServiceCLI::ServiceCenter.all[input.to_i - 1]
      unless center.int_url.nil?
        puts "\nObtaining data..."
        self.scraper.scrape_center_details(center)
        puts "Done"
      end

      puts "\n\tName:\n#{center.name}\n\n".blue
      puts "\tRating:\n#{center.rating}\n\n".blue unless center.rating.nil?
      puts "\tCategory:\n#{center.main_category}\n\n".blue unless center.main_category.nil?
      puts "\tAddress:\n#{center.address}\n\n".blue unless center.address.nil?
      puts"\tPhone number:\n#{center.phone_number}\n\n".blue unless center.phone_number.nil?

      unless center.int_url.nil?
        puts "\tStatus:\n#{center.open_status}\n\n".blue unless center.open_status.nil?
        puts "\tSlogan:\n#{center.slogan}\n\n".blue unless center.slogan.nil?
        puts "\tWorking hours:\n#{center.working_hours}\n".blue unless center.working_hours.nil?
        puts "\tDescription:\n#{center.description}\n\n".blue unless center.description.nil?
        puts "\tServices:\n#{center.services}\n\n".blue unless center.services.nil?
        puts "\tBrands:\n#{center.brands}\n\n".blue unless center.brands.nil?
        puts "\tPayment methods:\n#{center.payment}\n\n".blue unless center.payment.nil?
      end

      puts "\tSee more at:\n#{center.ext_url}\n\n".light_blue unless center.ext_url.nil?
    end
  end

  def scrape_main_page
    puts "Obtaining data..."
    AutoServiceCLI::ServiceCenter.reset_all!
    case self.cur_sort_type
    when "default"
      @scraper = AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "distance"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "average_rating"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "name"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "name"
    end
    self.scraper.scrape_centers
    puts "Done"
  end

  #-----------------------------------------------------------------------------------
  # Helper methods

  def help_menu
    puts "1. list centers".green
    puts "2. sort centers".green
    puts "3. details about center".green
    puts "10. exit".green
  end

  def help_sort
    puts "\t1. sort by default"
    puts "\t2. sort by distance"
    puts "\t3. sort by rating"
    puts "\t4. sort by name"
  end

  def goodbye
    puts "\nThank you for using this application!"
  end
end
