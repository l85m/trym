##TODO - make cancelable

class AmexScraper
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user, pass, transaction_id)
    @user = user
    @pass = pass
    @transaction = TransactionDataRequest.find(transaction_id)

    @months_of_data = 6
    @results = []
    @session = Capybara::Session.new(:poltergeist)

    handle_error( "Unable to Login" ) unless login
    @transaction.update( status: "getting statement page" )
    handle_error( "Failed to Load Statements Page" ) unless get_statements_page
    @transaction.update( status: "loading past 6 months of data" )
    handle_error( "Failed to parse Statement Data" ) unless fully_load_statement_data
    @transaction.update( status: "analyzing data to find recurring items" )
    handle_error( "Failed to parse Statement Data" ) unless analyze_statement_data

    @transaction.update( transaction_data: @results.to_json, status: "complete" ) 
    @session.driver.quit
  end

  private

  def handle_error(error_reason)
    @session.driver.quit
    @transaction.update( status: "failed", failure_reason: error_reason )
    raise error_reason
  end

  def analyze_statement_data
    @results = AmexScorer.new(@results).score rescue false
  end

  def login
    @session.visit "https://www.americanexpress.com"
    @session.fill_in('Username', with: @user)
    @session.fill_in('Password', with: @pass)
    @session.click_link('loginLink')["status"] == "success"
  end

  def get_statements_page
    if @session.click_link_or_button('Statements & Activity')["status"] == "success"
      select_statement_interval
      return true
    else
      return false
    end
  end

  def select_statement_interval
    @session.click_link_or_button('periodSelect')
    @session.fill_in("startDateTxt", with: @months_of_data.months.ago.strftime("%m/%d/%Y"))
    @session.fill_in("endDateTxt", with: Date.today.strftime("%m/%d/%Y"))
    @session.click_link_or_button('periodGo')
  end

  def fully_load_statement_data
    if @session.has_link?("NBottom")
      load_on_multiple_pages
    else
      load_on_single_page
    end
    @results.present?
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
    @results.map{ |r| [:categories, :date, :description, :amounts][(r.size > 3 ? 0 : 1)..-1].zip(r).to_h }
  end

  def on_last_page?
    transaction_counter = Nokogiri::HTML(@session.body).xpath("//div[contains(@id,'listNavBottom')]/span/span")
    transaction_counter = transaction_counter.text.split("\n").map{ |x| x.split("-") }.flatten.map{ |x| x.gsub(/\D/,"").strip }.select{ |x| x.present? }
    transaction_counter[-2] == transaction_counter[-1]
  end

end