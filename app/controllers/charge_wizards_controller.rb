class ChargeWizardsController < ApplicationController
  include Wicked::Wizard 
  steps :select_categories, :select_categorized_charges, :validate_charge, :charge_not_found, :add_charge, 
        :categories_complete, :select_uncategorized_charges, :final_check, :we_missed_something
 
  before_action :set_charge_wizard, only: [:show, :update]
  after_action :find_next_step, only: [:show, :update]

  respond_to :html

  def create
    @charge_wizard = ChargeWizard.create!( create_wizard_params )
    respond_with @charge_wizard
  end

  def show

  end

  def update

  end

  private

    def set_charge_wizard
      @charge_wizard = ChargeWizard.find(params[:id])
    end

    def find_next_step
      if [:select_categories, :select_categorized_charges, :validate_charge, :add_charge].include?(step)
        jump_to(*@charge_wizard.find_step)
      else
        render_wizard
      end
    end

    def create_wizard_params
      p = {user: current_user}
      if params[:linked_account_id].present?
        linked_account = current_user.linked_accounts.find(params[:linked_account_id])
        p.merge!.({linked_account: linked_account})
      end
      p
    end

end
