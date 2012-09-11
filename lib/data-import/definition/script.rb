module DataImport
  class Definition
    class Script < Definition
      attr_accessor :body

      def run(context, progress_reporter)
        context.instance_exec &body
      end

      def total_steps_required
        100
      end
    end
  end
end
