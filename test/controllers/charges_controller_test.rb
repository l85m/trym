require 'test_helper'

class ChargesControllerTest < ActionController::TestCase
  setup do
    @charge = charges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:charges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create charge" do
    assert_difference('Charge.count') do
      post :create, charge: { amount: @charge.amount, billed_to_date: @charge.billed_to_date, billing_day: @charge.billing_day, description: @charge.description, end_date: @charge.end_date, history: @charge.history, last_date_billed: @charge.last_date_billed, linked_account_id: @charge.linked_account_id, merchant_id: @charge.merchant_id, plaid_name: @charge.plaid_name, recurring: @charge.recurring, recurring_score: @charge.recurring_score, renewal_period_in_weeks: @charge.renewal_period_in_weeks, start_date: @charge.start_date, transaction_request_id: @charge.transaction_request_id, trym_category_id: @charge.trym_category_id, user_id: @charge.user_id, wizard_complete: @charge.wizard_complete }
    end

    assert_redirected_to charge_path(assigns(:charge))
  end

  test "should show charge" do
    get :show, id: @charge
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @charge
    assert_response :success
  end

  test "should update charge" do
    patch :update, id: @charge, charge: { amount: @charge.amount, billed_to_date: @charge.billed_to_date, billing_day: @charge.billing_day, description: @charge.description, end_date: @charge.end_date, history: @charge.history, last_date_billed: @charge.last_date_billed, linked_account_id: @charge.linked_account_id, merchant_id: @charge.merchant_id, plaid_name: @charge.plaid_name, recurring: @charge.recurring, recurring_score: @charge.recurring_score, renewal_period_in_weeks: @charge.renewal_period_in_weeks, start_date: @charge.start_date, transaction_request_id: @charge.transaction_request_id, trym_category_id: @charge.trym_category_id, user_id: @charge.user_id, wizard_complete: @charge.wizard_complete }
    assert_redirected_to charge_path(assigns(:charge))
  end

  test "should destroy charge" do
    assert_difference('Charge.count', -1) do
      delete :destroy, id: @charge
    end

    assert_redirected_to charges_path
  end
end
