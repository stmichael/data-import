module DataImport
  class Importer

    def initialize(context, definition)
      @context = context
      @definition = definition
    end

    def run
      @definition.target_database.transaction do
        options = {}
        options[:primary_key] = @definition.source_primary_key
        options[:columns] = @definition.source_columns
        options[:distinct] = @definition.source_distinct_columns
        options[:order] = @definition.source_order_columns
        @definition.source_database.each_row(@definition.source_table_name, options) do |row|
          encode_row row
          import_row row
          yield if block_given?
        end
      end
      @definition.after_blocks.each do |block|
        @definition.instance_exec(@context, &block)
      end
    end

    def import_row(row)
      mapped_row = {}
      @definition.mappings.each do |old_key, new_key|
        if new_key.respond_to?(:call)
          keys = old_key
          keys = [keys] unless keys.is_a? Array
          params = [@context] + keys.map{|key| row[key.to_sym]}
          mapped_row.merge! @definition.instance_exec(*params, &new_key)
        else
          mapped_row[new_key] = row[old_key.to_sym]
        end
      end

      case @definition.mode
      when :insert
        new_id = @definition.target_database.insert_row @definition.target_table_name, mapped_row
        @definition.add_id_mapping row[@definition.source_primary_key] => new_id
      when :update
        @definition.target_database.update_row(@definition.target_table_name, mapped_row)
      end
    end
    private :import_row

    def encode_row(row)
      row.each do |key, value|
        if value.is_a?(String)
          value.force_encoding('CP850')
          row[key] = Iconv.conv('UTF-8', 'CP850', value)
        end
      end
    end
    private :encode_row

  end
end