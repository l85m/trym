class StaticPagesController < ApplicationController
  layout "down", only: [:upgrades]
  before_action :show_location_restriction

  def landing
  end

  def legal
  end

  def privacy
  end

  def test
  end

  def about
  end

  def upgrades
  end
  
end
