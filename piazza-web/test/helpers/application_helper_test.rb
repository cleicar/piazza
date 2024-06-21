require 'test_helper'
class ApplicationHelperTest < ActionView::TestCase
  test "formats page specific title" do
    content_for(:page_title) { "Page Title" }
    assert_equal "Page Title | #{I18n.t('piazza')}", page_title
  end

  test "returns app name when page title is missing" do
    assert_equal I18n.t('piazza'), page_title
  end
end