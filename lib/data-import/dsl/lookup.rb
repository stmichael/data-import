module DataImport
  class Dsl
    module Lookup
      def lookup_for(name, options = {})
        attribute = options.fetch(:column) { name }
        dictionary = if options.fetch(:ignore_case) { false }
                       CaseIgnoringDictionary.new
                     else
                       Dictionary.new
                     end

        @id_mapping_container.add_dictionary(@definition.name, name, attribute, dictionary)
      end
    end
  end
end
