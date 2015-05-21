class CurrencyInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    input_html_classes.unshift("string")
    input_html_options[:type] ||= input_type if html5?
    template.content_tag(:span, 
    	template.content_tag(:span, "$", class: "input-group-addon")+
    	@builder.text_field(attribute_name, input_html_options), 
    class: "input-group")
  end
end