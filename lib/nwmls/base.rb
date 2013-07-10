module Nwmls
  module Base

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def build_collection(xml)
        collection = []
        xml.root.children.each do |office|
          attributes = {}
          office.children.each do |child|
            attributes[child.name.underscore] = child.text
          end
          collection << new(attributes)
        end
        collection
      end
    end

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end
    end

  end
end
