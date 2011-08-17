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
                  content_tag(:th, "Key", :class => "nested-key") + content_tag(:th, "Value", :class => "nested-value")
                end +
                val.collect do |k,v|
                  content_tag(:tr) do
                    content_tag(:td, k) + html_for_value(v)
                  end
                end.join("")
              end
            end
          else
            return content_tag(:td, val)
        end
      end
      
      
      
      def content_tag(tag, val = '', &block)
        val = yield if block_given?
        return "<#{tag}>#{val}</#{tag}>"
      end
    end
  end
end