module DataImport
  class Dsl
    module Dependencies
      def dependencies(*dependencies)
        dependencies.each do |dependency|
          definition.add_dependency(dependency)
        end
      end
    end
  end
end
