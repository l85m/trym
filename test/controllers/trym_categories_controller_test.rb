require 'test_helper'

class TrymCategoriesControllerTest < ActionController::TestCase
  setup do
    @trym_category = trym_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trym_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trym_category" do
    assert_difference('TrymCategory.count') do
      post :create, trym_category: { description: @trym_category.description, name: @trym_category.name, recurring: @trym_category.recurring }
    end

    assert_redirected_to trym_category_path(assigns(:trym_category))
  end

  test "should show trym_category" do
    get :show, id: @trym_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trym_category
    assert_response :success
  end

  test "should update trym_category" do
    patch :update, id: @trym_category, trym_category: { description: @trym_category.description, name: @trym_category.name, recurring: @trym_category.recurring }
    assert_redirected_to trym_category_path(assigns(:trym_category))
  end

  test "should destroy trym_category" do
    assert_difference('TrymCategory.count', -1) do
      delete :destroy, id: @trym_category
    end

    assert_redirected_to trym_categories_path
  end
end
