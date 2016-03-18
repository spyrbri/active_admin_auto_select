require 'active_admin_auto_select/version'
require 'active_admin_auto_select/rails'

module AutoSelectable
  def auto_select(*fields)
    options = fields.extract_options!
    create_collection_action(fields, options, @resource)
  end

  def create_collection_action(fields, options, resource)
    collection_action :autoselect, :method => :get do
      select_fields = "#{resource.table_name}.id, " << fields.join(', ')
      if (Module.const_get(:CanCanCan) rescue false) ? authorized?(:read, resource) :true
        term = params[:q].to_s
        term.gsub!('%', '\\\%')
        term.gsub!('_', '\\\_')
        first_term = term.try(:match, /\w \w/) ? (term.split(' '))[0] : term
        page = params[:page].try(:to_i)
        offset = page ? (page - 1) * 10 + (5 * (page - 1)) : 0

        #params[:scope] is passed through js when we define the relevate data attribute on the filter
        #default_scope is passed as a proc argument in #auto_select and overrides the default resource scope
        effective_scope = options[params[:scope]] || options['default_scope'] || ->{ resource }

        #This param exists when we have a filtered result
        if params[:ids].present?
           resources = effective_scope.call.
             where("#{resource.table_name}.id IN (?)", params[:ids]).
             select(select_fields)
           if resources.size == 1
             resources = resources.first
           else
             resources = resources.sort_by { |r| params[:ids].index(r.id.to_s) }
           end
           render json: resources and return
        else
          concat_fields = fields.join(" || ' '::text || ")
          concat_cols = "((#{concat_fields})" <<  " || ' '::text || #{resource.table_name}.id::text)"

          similarity_sql = ActiveRecord::Base.send(:sanitize_sql_array,
              ["(similarity(#{resource.table_name}.id::text, :id) + similarity(#{concat_cols}, :id))", id: term])

          resource_records = effective_scope.call.
            select(select_fields << ", #{similarity_sql} as similarity").
            where("#{concat_cols} ILIKE :term", term: "%#{first_term}%").
            order("#{similarity_sql} DESC").
            limit(15).offset(offset).
            map { |r| r.attributes.reject { |a| a == 'similarity'} }
        end

        render json: resource_records
      end
    end
  end
end

ActiveAdmin::ResourceDSL.send :include, AutoSelectable
