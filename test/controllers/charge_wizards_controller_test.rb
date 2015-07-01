require 'test_helper'

class ChargeWizardsControllerTest < ActionController::TestCase
  setup do
    @charge_wizard = charge_wizards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:charge_wizards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create charge_wizard" do
    assert_difference('ChargeWizard.count') do
      post :create, charge_wizard: { in_progress: @charge_wizard.in_progress, progress: @charge_wizard.progress, user_id: @charge_wizard.user_id }
    end

    assert_redirected_to charge_wizard_path(assigns(:charge_wizard))
  end

  test "should show charge_wizard" do
    get :show, id: @charge_wizard
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @charge_wizard
    assert_response :success
  end

  test "should update charge_wizard" do
    patch :update, id: @charge_wizard, charge_wizard: { in_progress: @charge_wizard.in_progress, progress: @charge_wizard.progress, user_id: @charge_wizard.user_id }
    assert_redirected_to charge_wizard_path(assigns(:charge_wizard))
  end

  test "should destroy charge_wizard" do
    assert_difference('ChargeWizard.count', -1) do
      delete :destroy, id: @charge_wizard
    end

    assert_redirected_to charge_wizards_path
  end
end
