module DataImport
  class Definition
    class Script < Definition
      attr_accessor :body

      def run(context, progress_reporter)
        context.instance_exec &body
      end
    end
  end
end
