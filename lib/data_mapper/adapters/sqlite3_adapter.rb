gem 'do_sqlite3', '=0.9.0'
require 'do_sqlite3'

module DataMapper
  module Adapters

    class Sqlite3Adapter < DataObjectsAdapter

      # TypeMap for SQLite 3 databases.
      #
      # ==== Returns
      # DataMapper::TypeMap:: default TypeMap for SQLite 3 databases.
      def self.type_map
        @type_map ||= TypeMap.new(super) do |tm|
          tm.map(Fixnum).to('INTEGER')
          tm.map(Class).to('VARCHAR')
        end
      end
      
      def exists?(table_name)
        query_table(table_name).size > 0
      end

      def query_table(table_name)
        query("PRAGMA table_info('#{table_name}')")
      end

      def begin_transaction(transaction)
        cmd = "BEGIN"
        transaction.connection_for(self).create_command(cmd).execute_non_query
        DataMapper.logger.debug("#{self}: #{cmd}")
      end

      def commit_transaction(transaction)
        cmd = "COMMIT"
        transaction.connection_for(self).create_command(cmd).execute_non_query
        DataMapper.logger.debug("#{self}: #{cmd}")
      end

      def prepare_transaction(transaction)
        DataMapper.logger.debug("#{self}: #prepare_transaction called, but I don't know how... I hope the commit comes pretty soon!")
      end
      
      def rollback_transaction(transaction)
        cmd = "ROLLBACK"
        transaction.connection_for(self).create_command(cmd).execute_non_query
        DataMapper.logger.debug("#{self}: #{cmd}")
      end

      def rollback_prepared_transaction(transaction)
        cmd = "ROLLBACK"
        transaction.connection.create_command(cmd).execute_non_query
        DataMapper.logger.debug("#{self}: #{cmd}")
      end

      def rewrite_uri(uri, options)
        new_uri = uri.dup
        new_uri.path = options[:path] || uri.path

        new_uri
      end
      
      protected

      def normalize_uri(uri_or_options)
        uri = super
        uri.path = File.join(Dir.pwd, File.dirname(uri.path), File.basename(uri.path)) unless File.exists?(uri.path)
        uri
      end
    end # class Sqlite3Adapter

  end # module Adapters
end # module DataMapper
