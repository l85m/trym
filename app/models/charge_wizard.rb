class ChargeWizard < ActiveRecord::Base
  belongs_to :user
  before_create :set_progress

  scope :in_progress, -> { find_by_in_progress( true ) }

  validates_uniqueness_of :user_id, conditions: -> { where( in_progress: true ) }

  # STEPS
  # :link_or_manual, :select_financial_institutions, :link_account, :select_categories, :select_categorized_charges, :validate_charge, 
  # :charge_not_found, :add_charge, :categories_complete, :select_uncategorized_charges, :final_check, :we_missed_something

  def find_step
    if account_id_pending_link.present?
      [:link_account, {financial_institution_id: account_id_pending_link.first}]
    elsif incomplete_categories.present?
      find_category_step
    end
  end

  private

  def account_id_pending_link
    progress["financial_institutions"].reject{ |_,linked| linked }.first
  end

  def find_category_step
    current_category_id = incomplete_categories.keys.first
    current_category_body = incomplete_categories.values.first

    if category_not_started?(current_category_id)
      return [:select_categorized_charges, {category_id: current_category_id}]

    elsif category_has_incomplete_charges?(current_category_id)
      charge_id = current_category_body["charges"].select{ |_,v| false }.first.keys.first
      return [:validate_charge, {charge_id: charge_id, category_id: current_category_id}]

    elsif category_has_other?(current_category_id)
      return [:charge_not_found, {category_id: current_category_id}]
    else
      [:categories_complete]
    end

  end

  def select_categories(category_ids)
    self.progress["trym_categories"] = category_ids.collect do |category_id|
      [
        category_id, 
        {
          charges: find_charges_in_category(category_id), 
          other: false,
          complete: false,
        }
      ]
    end.to_h
    self.save!
  end

  def select_categorized_charges(category_id, charge_ids, other)
    self.progress["trym_categories"][category_id]["charges"] = progress["trym_categories"][category_id]["charges"].select do |charge_id, _|
      charge_ids.include?(charge_id)
    end
    self.progress["trym_categories"][category_id]["other"] = other
    self.save!
  end

  def validate_charge(category_id, charge_id)
    if category_has_other?(category_id) && charge_is_other?(category_id, charge_id)
      self.progress["trym_categories"][category_id]["charges"]["other"] = false
    end 
    self.progress["trym_categories"][category_id]["charges"][charge_id] = true
    self.progress["trym_categories"][category_id]["complete"] = true if category_complete?(category_id)
    self.save!
  end

  def skip_adding_other_charge(category_id)
    self.progress["trym_categories"][category_id]["charges"]["other"] = false
    self.progress["trym_categories"][category_id]["complete"] = true if category_complete?(category_id)
    self.save!
  end

  private

  def category_not_started?(category_id)
    progress["trym_categories"][category_id]["charges"].select{ |_,complete| complete == false }.size == 
    progress["trym_categories"][category_id]["charges"].size
  end

  def charge_is_other?(category_id, charge_id)
    !progress["trym_categories"][category_id]["charges"].keys.include?(charge_id)
  end

  def category_has_other?(category_id)
    progress["trym_categories"][category_id]["charges"]["other"]
  end

  def category_has_incomplete_charges?(category_id)
    progress["trym_categories"][category_id]["charges"].keys.include?(charge_id)
  end

  def category_complete?(category_id)
    !progress["trym_categories"][category_id]["charges"].select{ |_,complete| complete == false }.present? &&
    !progress["trym_categories"][category_id]["other"]
  end

  def incomplete_categories
    progress["trym_categories"].select{ |c| c["complete"] == false }
  end

  def find_charges_in_category(category_id)
    if linked_account.present?
      TrymCategory.find(category_id).charges.where( user: user, linked_account: linked_account ).collect do |charge| 
        [charge.id => false]
      end.to_h
    else
      {}
    end
  end

  def set_progress
    self.progress = {trym_categories: {}, complete: false}
  end

end

=begin
**progress JSON structure
{
  financial_institutions: 
  {
    :institution_id => linked?
  },
  trym_categories:
  {
    :category_id =>
      charges: { :charge_id => complete? },
      complete: false
  },
  complete: false
}
=end