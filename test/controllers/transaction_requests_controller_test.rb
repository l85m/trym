require 'test_helper'

class TransactionRequestsControllerTest < ActionController::TestCase
  setup do
    @transaction_request = transaction_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transaction_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction_request" do
    assert_difference('TransactionRequest.count') do
      post :create, transaction_request: { data: @transaction_request.data, linked_account_id: @transaction_request.linked_account_id }
    end

    assert_redirected_to transaction_request_path(assigns(:transaction_request))
  end

  test "should show transaction_request" do
    get :show, id: @transaction_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transaction_request
    assert_response :success
  end

  test "should update transaction_request" do
    patch :update, id: @transaction_request, transaction_request: { data: @transaction_request.data, linked_account_id: @transaction_request.linked_account_id }
    assert_redirected_to transaction_request_path(assigns(:transaction_request))
  end

  test "should destroy transaction_request" do
    assert_difference('TransactionRequest.count', -1) do
      delete :destroy, id: @transaction_request
    end

    assert_redirected_to transaction_requests_path
  end
end
