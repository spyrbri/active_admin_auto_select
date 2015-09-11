require "admin_auto_select/version"

module AutoSelectable
  def auto_select(*fields)
    options = fields.extract_options!
    create_collection_action(fields, options, @resource)
  end

  def create_collection_action(fields, options, resource)
    collection_action :autoselect, :method => :get do
      select_fields = "#{resource.table_name}.id, " << fields.join(', ')
      if authorized?(:read, resource)
        term = ([ params[:id], params[:q]].compact).try(:first)
        term.gsub!('%', '\\\%')
        term.gsub!('_', '\\\_')
        first_term = term.try(:match, /\w \w/) ? (term.split(' '))[0] : term
        page = params[:page].try(:to_i)
        offset = page ? (page - 1) * 10 + (5 * (page - 1)) : 0
        effective_scope = options[params[:scope]] || options['default_scope'] || resource

        if params[:id]
           first_resource = effective_scope.call.
             where("#{resource.table_name}.id = ?", params[:id].to_i).
             select(select_fields).first
           render json: first_resource and return
        else
          concat_fields = fields.join(" || ' '::text || ")
          concat_cols = "((#{concat_fields})" <<  " || ' '::text || #{resource.table_name}.id::text)"

          similarity_sql = ActiveRecord::Base.send(:sanitize_sql_array,
              ["(similarity(#{resource.table_name}.id::text, :id) + similarity(#{concat_cols}, :id))", id: term])

          resource_records = effective_scope.call.select(select_fields).
            where("#{concat_cols} ILIKE :term", term: "%#{first_term}%").
            order("#{similarity_sql} DESC").
            limit(15).offset(offset)
        end

        render json: resource_records
      end
    end
  end
end

ActiveAdmin::ResourceDSL.send :include, AutoSelectable
