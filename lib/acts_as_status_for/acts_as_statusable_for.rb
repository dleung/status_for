module StatusFor
  def self.included(base)
    base.extend ActsAsStatusFor
  end
  

  module ActsAsStatusFor
    def acts_as_deletable_for
      def deleted_for(user)
        Message.where("idx(messages.deleted_for, #{user.id})::boolean") 
      end
      def not_deleted_for(user)
        Message.where("idx(messages.deleted_for, #{user.id}) <> 1") 
      end
      include Status_For_Utils
      include StatusInstanceMethods
    end
  end

  module Status_For_Utils
    # Taken from ACL manager, this allows the array to be saved in the database.
    def status_for_psql_array_to_array(psql_group)
      if psql_group
        eval(psql_group.gsub('NULL', '').gsub('{', '[').gsub('}', ']'))
      else
        []
      end
    end
  
    def status_for_array_to_psql_array(group)
      mgroup = group.kind_of?(Array) ? group : [group] 
      mgroup.to_s.gsub('[', '{').gsub(']', '}')
    end
  end  
  
  module StatusInstanceMethods
    def mark_as_deleted_for!(user_ids)
      if user_ids.is_a? Integer
        user_ids = [user_ids]
      end
      deleted_for_users = status_for_psql_array_to_array(self.deleted_for)
      deleted_for_users = (deleted_for_users + user_ids).flatten.uniq
      self.deleted_for = status_for_array_to_psql_array(deleted_for_users)
      self.save(validate: false)
      self
    end

    def mark_as_not_deleted_for!(user_ids)
      if user_ids.is_a? Integer
        user_ids = [user_ids]
      end
      deleted_for_users = status_for_psql_array_to_array(self.deleted_for)
      deleted_for_users = (deleted_for_users - user_ids).flatten.uniq
      self.deleted_for = status_for_array_to_psql_array(deleted_for_users)
      self.save(validate: false)
      self
    end
    
    def deleted_for?(user)
      return status_for_psql_array_to_array(self.deleted_for).include?(user.id)
    end
  end
  
end
 
ActiveRecord::Base.send :include, StatusFor