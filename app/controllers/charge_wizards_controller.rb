class ChargeWizardsController < ApplicationController
  include Wicked::Wizard 
  
  before_action :authenticate_user!
  before_action :set_steps
  before_action :setup_wizard
 
  respond_to :html

  def show
    @category_ids = session[:charge_wizard_categories]
    if step.to_s.include?("charge_category")      
      @category = TrymCategory.find(step.to_s.split("_").last.to_i)
      @next_step = next_charge_step
      @previous_step = previous_charge_step
      render "charge_category"
    elsif step == :wizard_finished
      session.delete(:charge_wizard_categories)
      render_wizard
    else
      if step == :select_uncategorized_charges
        @uncategorized_charges = current_user.charges.from_link.recurring_likely_to_be.reject{ |x| x.smart_trym_category.present? } 
      end
      render_wizard
    end
  end

  def update
    if params[:charge_wizard].present?
      session[:charge_wizard_categories] = charge_wizard_category_ids

      @category = TrymCategory.find(charge_wizard_category_ids.first)
      @category_ids = session[:charge_wizard_categories]
    
      jump_to("charge_category_#{@category.id}".to_sym)
    else
      jump_to(:select_uncategorized_charges)
    end
    render_wizard
  end

  private

    def next_charge_step
      next_index = session[:charge_wizard_categories].index(@category.id) + 1
      if next_index < session[:charge_wizard_categories].size
        "charge_category_#{session[:charge_wizard_categories][next_index]}".to_sym
      else
        uncategorized_charges = current_user.charges.from_link.recurring_likely_to_be.reject{ |x| x.smart_trym_category.present? }
        if uncategorized_charges.present?
          :select_uncategorized_charges
        else
          :final_check
        end
      end
    end

    def previous_charge_step
      previous_index = session[:charge_wizard_categories].index(@category.id) - 1
      
      if previous_index >= 0
        "charge_category_#{session[:charge_wizard_categories][previous_index]}".to_sym
      else
        :select_categories
      end
    end

    def charge_wizard_category_ids
      params.require(:charge_wizard).require(:category_ids).keys.collect{ |c| c.to_i }
    end


    def set_steps
      wizard_steps = [:link_or_manual, :select_financial_institutions, :select_categories, :select_uncategorized_charges, :final_check, :wizard_finished]

      index = wizard_steps.index(:select_categories) + 1
      self.steps = wizard_steps.insert(index, TrymCategory.pluck(:id).collect{ |c| "charge_category_#{c}".to_sym } ).flatten
    end

end
