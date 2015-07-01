require 'test_helper'

class LinkedAccountsControllerTest < ActionController::TestCase
  setup do
    @linked_account = linked_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:linked_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create linked_account" do
    assert_difference('LinkedAccount.count') do
      post :create, linked_account: { destroyed_at: @linked_account.destroyed_at, financial_institution_id: @linked_account.financial_institution_id, last_api_response: @linked_account.last_api_response, last_successful_sync: @linked_account.last_successful_sync, mfa_question: @linked_account.mfa_question, mfa_type: @linked_account.mfa_type, plaid_access_token: @linked_account.plaid_access_token, status: @linked_account.status, user_id: @linked_account.user_id }
    end

    assert_redirected_to linked_account_path(assigns(:linked_account))
  end

  test "should show linked_account" do
    get :show, id: @linked_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @linked_account
    assert_response :success
  end

  test "should update linked_account" do
    patch :update, id: @linked_account, linked_account: { destroyed_at: @linked_account.destroyed_at, financial_institution_id: @linked_account.financial_institution_id, last_api_response: @linked_account.last_api_response, last_successful_sync: @linked_account.last_successful_sync, mfa_question: @linked_account.mfa_question, mfa_type: @linked_account.mfa_type, plaid_access_token: @linked_account.plaid_access_token, status: @linked_account.status, user_id: @linked_account.user_id }
    assert_redirected_to linked_account_path(assigns(:linked_account))
  end

  test "should destroy linked_account" do
    assert_difference('LinkedAccount.count', -1) do
      delete :destroy, id: @linked_account
    end

    assert_redirected_to linked_accounts_path
  end
end
