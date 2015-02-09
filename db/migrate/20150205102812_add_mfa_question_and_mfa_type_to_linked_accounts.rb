class AddMfaQuestionAndMfaTypeToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :mfa_question, :text
    add_column :linked_accounts, :mfa_type, :text
  end
end
