class StaticPagesController < ApplicationController
  layout "down", only: [:upgrades]

  def landing
  end

  def t
  end

  def legal
  end

  def test
  end

  def about
  end

  def upgrades
  end
  
end
