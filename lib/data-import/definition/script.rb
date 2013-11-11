module DataImport
  class Definition
    class Script < Definition
      attr_accessor :body

      def run(context)
        target_database.transaction do
          context.instance_exec &body
        end
      end

      def total_steps_required
        100
      end
    end
  end
end
