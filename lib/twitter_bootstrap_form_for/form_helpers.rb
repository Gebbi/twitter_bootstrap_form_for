require 'twitter_bootstrap_form_for'

module TwitterBootstrapFormFor::FormHelpers
  [:form_for, :fields_for].each do |method|
    module_eval do
      define_method "twitter_bootstrap_#{method}" do |record, *args, &block|
        # add the TwitterBootstrap builder to the options
        options            = args.extract_options!
        options[:layout] ||= :basic
        unless [:basic, :horizontal, :inline].include?(options[:layout])
          raise "Specified form layout #{options[:layout].to_s} is invalid. Must be one of :basic, :horizontal, or :inline."
        end
        options[:default_toggle_style] ||= :stacked
        if options[:layout] == :horizontal
          options[:default_div_class] ||= 'col-md-10'
          options[:default_label_class] ||= 'col-md-2 control-label'
          options[:default_offset_class] ||= 'col-md-offset-2'
        elsif options[:layout] == :inline
          options[:default_label_class] ||= 'sr-only'
        end
        options[:default_label_class] ||= 'control-label'

        options[:html] = {} if options[:html].nil?
        options[:html][:role] = 'form'
        options[:html][:class] = "form-#{options[:layout]}" if options[:layout] != 'basic'
        
        options[:builder]  = TwitterBootstrapFormFor::FormBuilder

        # call the original method with our overridden options
        _override_field_error_proc do
          send method, record, *(args << options), &block
        end
      end
    end
  end

  private

  BLANK_FIELD_ERROR_PROC = lambda {|input, _| input }

  def _override_field_error_proc
    original_field_error_proc           = ::ActionView::Base.field_error_proc
    ::ActionView::Base.field_error_proc = BLANK_FIELD_ERROR_PROC
    yield
  ensure
    ::ActionView::Base.field_error_proc = original_field_error_proc
  end
end
