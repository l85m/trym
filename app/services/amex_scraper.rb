class AmexScraper
  attr_accessor :session

  def initialize(user, pass, months_of_data)
    @user = user
    @pass = pass
    @months_of_data = months_of_data
    @session = Capybara::Session.new(:selenium)

    @results = []
  end

  def get_charge_list
    fully_load_statement_data if login && get_statements_page
    @results
  end

  private

  def login
    @session.visit "https://www.americanexpress.com"
    @session.fill_in('Username', with: @user)
    @session.fill_in('Password', with: @pass)
    @session.click_link('loginLink') == "ok"
  end

  def get_statements_page
    @session.click_link_or_button('Statements & Activity')
    @session.click_link_or_button('periodSelect')
    @session.fill_in("startDateTxt", with: @months_of_data.months.ago.strftime("%m/%d/%Y"))
    @session.fill_in("endDateTxt", with: Date.today.strftime("%m/%d/%Y"))
    @session.click_link_or_button('periodGo') == "ok"
  end

  def fully_load_statement_data
    if @session.has_link?("NBottom")
      load_on_multiple_pages
    else
      load_on_single_page
    end
  end

  def load_on_multiple_pages
    while not on_last_page?
      parse_statement_data
      @session.click_link("NBottom") rescue true
    end
  end

  def load_on_single_page
    while @session.has_button?("Show More Transactions") do
      @session.click_button('Show More Transactions') rescue true
    end
    parse_statement_data
  end

  def parse_statement_data
    doc = Nokogiri::HTML(@session.body)
    
    doc.search("tbody").each do |tb|
      r = []
      tb.traverse do |e|
        c = e.attr('class')
        n = e.attr('name')
        if c.present?
          r << e.children.text if c.include?("desc-behav")
          r << e.text.to_date if c ==  "trans-date-text"
          r << e.text.gsub("$","").to_f if c == "amountPos"
        elsif n.present?
          r << e.attr("value").split("~")[-2..-1] if n == "rocInfoDetails"
        end
      end  
      @results << r if r.present?
    end  
    @results.map{ |r| [:categories, :date, :description, :amount][(r.size > 3 ? 0 : 1)..-1].zip(r).to_h }
  end

  def on_last_page?
    transaction_counter = Nokogiri::HTML(@session.body).xpath("//div[contains(@id,'listNavBottom')]/span/span")
    transaction_counter = transaction_counter.text.split("\n").map{ |x| x.split("-") }.flatten.map{ |x| x.gsub(/\D/,"").strip }.select{ |x| x.present? }
    transaction_counter[-2] == transaction_counter[-1]
  end

end