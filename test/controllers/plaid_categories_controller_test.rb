require 'test_helper'

class PlaidCategoriesControllerTest < ActionController::TestCase
  setup do
    @plaid_category = plaid_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plaid_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plaid_category" do
    assert_difference('PlaidCategory.count') do
      post :create, plaid_category: { hierarchy: @plaid_category.hierarchy, plaid_id: @plaid_category.plaid_id, plaid_type: @plaid_category.plaid_type, trym_category_id: @plaid_category.trym_category_id }
    end

    assert_redirected_to plaid_category_path(assigns(:plaid_category))
  end

  test "should show plaid_category" do
    get :show, id: @plaid_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plaid_category
    assert_response :success
  end

  test "should update plaid_category" do
    patch :update, id: @plaid_category, plaid_category: { hierarchy: @plaid_category.hierarchy, plaid_id: @plaid_category.plaid_id, plaid_type: @plaid_category.plaid_type, trym_category_id: @plaid_category.trym_category_id }
    assert_redirected_to plaid_category_path(assigns(:plaid_category))
  end

  test "should destroy plaid_category" do
    assert_difference('PlaidCategory.count', -1) do
      delete :destroy, id: @plaid_category
    end

    assert_redirected_to plaid_categories_path
  end
end
