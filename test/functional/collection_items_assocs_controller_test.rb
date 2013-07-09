require 'test_helper'

class CollectionItemsAssocsControllerTest < ActionController::TestCase
  setup do
    @collection_items_assoc = collection_items_assocs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collection_items_assocs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collection_items_assoc" do
    assert_difference('CollectionItemsAssoc.count') do
      post :create, collection_items_assoc: { collection_id: @collection_items_assoc.collection_id, item_id: @collection_items_assoc.item_id }
    end

    assert_redirected_to collection_items_assoc_path(assigns(:collection_items_assoc))
  end

  test "should show collection_items_assoc" do
    get :show, id: @collection_items_assoc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @collection_items_assoc
    assert_response :success
  end

  test "should update collection_items_assoc" do
    put :update, id: @collection_items_assoc, collection_items_assoc: { collection_id: @collection_items_assoc.collection_id, item_id: @collection_items_assoc.item_id }
    assert_redirected_to collection_items_assoc_path(assigns(:collection_items_assoc))
  end

  test "should destroy collection_items_assoc" do
    assert_difference('CollectionItemsAssoc.count', -1) do
      delete :destroy, id: @collection_items_assoc
    end

    assert_redirected_to collection_items_assocs_path
  end
end
