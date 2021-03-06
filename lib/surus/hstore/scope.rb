module Surus
  module Hstore
    module Scope
      # Adds a where condition that requires column to contain hash
      #
      # Example:
      #   User.hstore_has_pairs(:properties, "favorite_color" => "green")
      def hstore_has_pairs(column, hash)
        where("#{connection.quote_column_name(column)} @> ?", Serializer.new.dump(hash))
      end
      
      # Adds a where condition that requires column to contain key
      #
      # Example:
      #   User.hstore_has_key(:properties, "favorite_color")
      def hstore_has_key(column, key)
        where("#{connection.quote_column_name(column)} ? :key", :key => key)    
      end
      
      # Adds a where condition that requires column to contain all keys.
      #
      # Example:
      #    User.hstore_has_all_keys(:properties, "favorite_color", "favorite_song")
      #    User.hstore_has_all_keys(:properties, ["favorite_color", "favorite_song"])
      def hstore_has_all_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?& ARRAY[:keys]", :keys => keys.flatten)
      end
      
      # Adds a where condition that requires column to contain any keys.
      #
      # Example:
      #    User.hstore_has_any_keys(:properties, "favorite_color", "favorite_song")
      #    User.hstore_has_any_keys(:properties, ["favorite_color", "favorite_song"])
      def hstore_has_any_keys(column, *keys)
        where("#{connection.quote_column_name(column)} ?| ARRAY[:keys]", :keys => keys.flatten)
      end
      
      def hstore_array_has_pairs(column, hash)
        where(" exists (  SELECT * FROM  ( SELECT  hstore(unnest(#{connection.quote_column_name(column)})))  x(item)  WHERE x.item  @> ?)", Serializer.new.dump(hash) );
      end
      
      def hstore_array_not_has_pairs(column, hash)
        where("not exists (  SELECT * FROM  ( SELECT  hstore(unnest(#{connection.quote_column_name(column)})))  x(item)  WHERE x.item  @> ?)", Serializer.new.dump(hash) );
      end
    
      def hstore_array_has_any(column, value)
        where(" exists ( select * from  (SELECT svals(unnest(#{connection.quote_column_name(column)} ))) x(item) where x.item ILIKE :value ) ", :value => value)
      end
      
      def hstore_array_not_has_any(column, value)
        where(" not exists ( select * from  (SELECT svals(unnest(#{connection.quote_column_name(column)} ))) x(item) where x.item ILIKE :value ) ", :value => value)
      end
    end
  end
end

ActiveRecord::Base.extend Surus::Hstore::Scope
