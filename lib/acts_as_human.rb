module ActsAs
  module Human
    mattr_accessor :acceptable_name, :bad_name_message
    
    self.acceptable_name    = /\A[^[:cntrl:]\\<>\/&]*\z/
    self.bad_name_message   = "some characters in your name are not allowed".freeze
    
    def acts_as_human
      extend ClassMethods unless (class << self; included_modules; end).include?(ClassMethods)
      include InstanceMethods unless included_modules.include?(InstanceMethods)
    end
    
    module ClassMethods
      def self.extended(base)
        base.class_eval do
          validates_presence_of       :first_name, :message => 'please enter your first name'
          validates_length_of         :first_name, :maximum => 40, :message => 'first name is too long'
          validates_as_person_name    :first_name
          
          validates_length_of         :middle_names, :maximum => 40, :allow_nil => true,
                                      :message => 'middle names are too long'
          validates_as_person_name    :middle_names, :allow_nil => true
          
          validates_presence_of       :last_name, :message => 'please enter your last name'
          validates_length_of         :last_name, :maximum => 40,
                                      :message => 'last name is too long', :allow_blank => true
          validates_as_person_name    :last_name
        end
      end
    end
    
    module InstanceMethods
      def full_name
        return '' if first_name.blank? and last_name.blank?
    
        return "#{first_name} #{last_name}" if middle_names.blank?
        return "#{first_name} #{middle_names} #{last_name}"
      end
      
      def full_name=(names)
        names_array = names.titlecase.split
    
        self.first_name = names_array.first
        return if names_array.size < 2
    
        self.last_name = names_array.last
    
        assign_middle_names(names_array)
      end
      
      private
      
      def assign_middle_names(names_array)
        if names_array.size > 2
          self.middle_names = get_middle_names(names_array)
        else
          self.middle_names = nil
        end
      end
      
      def get_middle_names(names_array)
        names_array[1..(names_array.size-2)].join(' ')
      end
    end
  end
end