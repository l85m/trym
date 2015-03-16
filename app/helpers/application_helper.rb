module ApplicationHelper

	def title_helper(title = nil)
		"trym.io" + ( title.present? ? " | #{title}" : "" )
	end

	def flash_alert_type(type)
		{success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info", info: "alert-info"}[type.to_sym]
	end

	def class_header_link_formatting(link_path)
		"active-header-link" if current_page?(link_path)
	end

	def brand_color
		"rgb(129, 202, 166)"
	end

	def trym_referrer
		if request.referrer.present? && request.referrer.split("/").include?(root_url.split("/").last)
			URI(request.referrer).path
		else
			root_path
		end
	end

end