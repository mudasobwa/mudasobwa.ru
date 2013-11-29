class Ruhoh
  module Converter
    module Qipowl
      def self.extensions
        ['.owl', '.qipowl']
      end
      def self.convert(content)
        require 'qipowl'
        ::Qipowl::Html.parse content
      end
    end
  end
end
