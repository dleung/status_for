module StatusFor
  def self.included(base)
    base.extend StatusFor
  end
  
  module StatusFor
    
    # Include initialize_status_for in the model class that you want the status_for to exists.
    # Step 1:
    # Example: Defining a deleted_for in Message model
    # In message.rb, include "initialize_status_for (Object)" where subject is the status for 
    # in question, like a user.  
    # Example: initialize_status_for User
    
    # Step 2:
    # In a migration, include a 'status_for' column in the model of interest.  
    # This looks something like add_column :messages, :deleted_for, "integer[]"
    # The postgres extension intarray is needed for this, so you may need to add the line
    # execute "CREATE EXTENSION IF NOT EXISTS intarray"
    # in the correct migration  
    def initialize_status_for(subject)      
      cattr_accessor :status_for_subject
      if !subject.is_a? Class
        raise "Subject must be defined as a proper class!"
      else
        self.status_for_subject = subject.name
      end      
      
      
      def method_missing(method_id, subject)
        # This creates a method for self called 'status_for(subject)' that finds all the
        # self items with the 'status_for' with the subject id.
        # Example:  Message.deleted_for(user)
        # Returns array of messages which contains user.id in the message's 'deleted_for'
        if method_id.to_s =~ /^([a-z]+)_for$/
          run_find_status_for($1, subject)

        # This creates a method for self called 'not_status_for(subject)' that finds all the
        # self items with the 'status_for' THAT DOES NOT HAVE the subject id.
        # Example:  Message.deleted_for(user)
        # Returns array of messages which DOES NOT contain user.id in the message's 'deleted_for'
        elsif method_id.to_s =~ /^not_([a-z]+)_for$/
          run_find_not_status_for($1, subject)
        else
          super
        end 
      end
       
      # Ensuring the method created for the class exists
      def respond_to?(method_id, include_private = false)
        if method_id.to_s =~ /^([a-z]+)_for$/ || method_id.to_s =~ /^not_([a-z]+)_for$/
          true
        else
          super
        end
      end
        
      # The action performed when calling Message.status_for(subject).  Uses a postgres-extension
      # query
      def run_find_status_for(method_id, subject)
        unless subject.class.name == self.status_for_subject
          raise "Acts_as_status_for is not defined for #{subject.class.name}"
        end
        self.where("idx(#{self.table_name}.#{method_id}_for, #{subject.id})::boolean")
      end

      # The action performed when calling Message.not_status_for(subject).  Uses a postgres-extension
      # query
      def run_find_not_status_for(method_id, subject)
        unless subject.class.name == self.status_for_subject
          raise "Acts_as_status_for is not defined for #{subject.class.name}"
        end
        self.where("idx(#{self.table_name}.#{method_id}_for, #{subject.id}) <> 1") 
      end
      include Status_For_Utils
      include StatusInstanceMethods
    end
  end

  module Status_For_Utils
    # Some conversion is needed to save arrays into the postgresql database tables.
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
    
    def method_missing(method_id, subject_ids)
      # This creates a method for instanced object called 'mark_as_status_for(subject)' that 
      # adds the subject id into relevant database column.
      # Example:  @message.mark_as_deleted_for(user)
      # Returns a message with the deleted_for containing the subject id
      if method_id.to_s =~ /^mark_as_([a-z]+)_for\!$/
        run_mark_as_status_for!($1, subject_ids)
      # This creates a method for instanced object called 'mark_as_not_ status_for(subject)' that 
      # removes the subject id into relevant database column.
      # Example:  @message.mark_as_not_deleted_for(user)
      # Returns a message with the subject_id in the deleted_for column removed.
      elsif method_id.to_s =~ /^mark_as_not_([a-z]+)_for\!$/
        run_mark_as_not_status_for!($1, subject_ids)
      # This creates a method for instanced object called 'check_status_for(subject)' that 
      # checks if the subject id is contained in the object.
      # Example:  @message.check_deleted_for(user)
      # Returns true or false
      elsif method_id.to_s =~ /^check_([a-z]+)_for\?$/
        run_check_status_for($1, subject_ids)
      else
        super
      end 
    end    

    # Ensuring the method created for the instanced class exists    
    def respond_to?(method_id, include_private = false)
      if method_id.to_s =~ /^mark_as_([a-z]+)_for\!$/ || method_id.to_s =~ /^mark_as_not_([a-z]+)_for\!$/ || method_id.to_s =~ /^check_([a-z]+)_for\?$/
        true
      else
        super
      end
    end

    # The action performed when calling @object.mark_as_status_for(subject).  Uses a postgres-extension
    # query
    def run_mark_as_status_for!(method_id, subject_ids)
      if !self.class.column_names.include?(method_id + '_for')
        raise "need to include the #{method_id}_for column in #{self.class.table_name} table"
      end
      if subject_ids.is_a? Integer
        subject_ids = [subject_ids]
      end
      status_for_subjects = status_for_psql_array_to_array(self.send ((method_id +'_for').to_sym))
      status_for_subjects = (status_for_subjects + subject_ids).flatten.uniq
      self.update_attribute(method_id + '_for', status_for_array_to_psql_array(status_for_subjects))
      self
    end

    # The action performed when calling @object.mark_as_not_status_for(subject).  Uses a postgres-extension
    # query
    def run_mark_as_not_status_for!(method_id, subject_ids)
      if !self.class.column_names.include?(method_id + '_for')
        raise "need to include the #{method_id}_for column in #{self.class.table_name} table"
      end
      if subject_ids.is_a? Integer
        subject_ids = [subject_ids]
      end
      status_for_subjects = status_for_psql_array_to_array(self.send ((method_id +'_for').to_sym))
      status_for_subjects = (status_for_subjects - subject_ids).flatten.uniq
      self.update_attribute(method_id + '_for', status_for_array_to_psql_array(status_for_subjects))
      self
    end

    # The action performed when calling @object.check_status_for(subject).  Uses a postgres-extension
    # query    
    def run_check_status_for(method_id, subject_id)
      if !self.class.column_names.include?(method_id + '_for')
        raise "need to include the #{method_id}_for column in #{self.class.table_name} table"
      end
      unless subject_id.is_a? Integer
        raise "subject_id must be an Integer!"
      end
      return status_for_psql_array_to_array(self.send ((method_id +'_for').to_sym)).include?(subject_id)
    end
  end
  
end
 
ActiveRecord::Base.send :include, StatusFor