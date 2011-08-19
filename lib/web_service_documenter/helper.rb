module WebServiceDocumenter
  class Helper
    class << self
      
      def html_for_value(val)
        case val
          when Array
            return html_for_value(val.first)
          when Date, Time
            return content_tag(:td, strftime("%m/%d/%Y %Z"))
          when String
            return content_tag(:td, val[0..100])
          when Hash
            content_tag(:td) do
              content_tag(:table, :class => "nested") do
                content_tag(:tr) do
                  content_tag(:th, "Key", :class => "nested-key") + 
                  content_tag(:th, "Data Type", :class => "nested-key") + 
                  content_tag(:th, "Value", :class => "nested-value")
                end +
                val.collect do |k,v|
                  content_tag(:tr) do
                    content_tag(:td, k) + 
                    content_tag(:td, v.class.to_s, :class => v.class.to_s.dasherize.downcase) +
                    html_for_value(v)
                  end
                end.join("")
              end
            end
          else
            return content_tag(:td, val)
        end
      end
      
      def content_tag(*args, &block)
        opts = args.extract_options!
        val = block_given? ? yield : args[1]
        return "<#{args.first}#{opts.collect{|k,v| %Q{ #{k}="#{v}" }}.join("")}>#{val}</#{args.first}>"
      end
    end
  end
end