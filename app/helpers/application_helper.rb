# frozen_string_literal: true

module ApplicationHelper
  def footnote_link(index)
    link_to(content_tag(:sup, index), "#footnote_#{index}", :class => "footnote")
  end
end
