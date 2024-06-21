module ApplicationHelper
  def page_title
    return t("piazza") unless content_for?(:page_title)
    
    "#{content_for(:page_title)} | #{t("piazza")}"
  end
end
