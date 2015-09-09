require "admin_auto_select/version"

module AutoSelectable
  def auto_select(field, scope = {})
    create_collection_action(field, @resource, scope)
  end

  def create_collection_action(field, resource, scope = {})
    collection_action :autocomplete, :method => :get do
      if authorized?(:read, resource)
        term = ([ params[:id], params[:owner], params[:q]].compact).try(:first)
        term.gsub!('%', '\\\%')
        term.gsub!('_', '\\\_')
        first_term = term.try(:match, /\w \w/) ? (term.split(' '))[0] : term
        page = params[:page].try(:to_i)
        offset = page ? (page-1)*10+(5*(page-1)) : 0
        if params[:id]
           user = resource.where('id = ?', params[:id].to_i).select('id, first_name, last_name, email').first
           render json: user and return
        else
          effective_scope = scope[params[:scope]] || resource

          concat_cols = ->(user_table) {
            "((email || ' '::text || last_name || ' '::text || "\
            "first_name) || ' '::text || #{user_table}.id::text)"
          }

          subquery = effective_scope.
            where("#{concat_cols.call(resource.table_name)} ILIKE :term", term: "%#{first_term}%").
            select("users.id, first_name, last_name, email").to_sql

          similarity_sql =
            ActiveRecord::Base.send(:sanitize_sql_array,
              ["(similarity(a.id::text, ?) + similarity(#{concat_cols.call("a")}, ?))",
                term, term])

          user_records = resource.select('*').from("(#{subquery}) as a")
          .order("#{similarity_sql} DESC")
          .limit(15).offset(offset)
        end
        render json: user_records
      end
    end
  end
end

ActiveAdmin::ResourceDSL.send :include, AutoSelectable
