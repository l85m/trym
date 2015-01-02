module ApplicationHelper

	def title_helper(title = nil)
		"trym.io" + ( title.present? ? " | #{title}" : "" )
	end

	def flash_alert_type(type)
		{success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info"}[type.to_sym]
	end

	def class_header_link_formatting(link_path)
		"active-header-link" if current_page?(link_path)
	end

end