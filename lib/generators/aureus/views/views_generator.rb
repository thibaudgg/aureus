module Aureus

	module Generators

		class ViewsGenerator < Rails::Generators::Base
			include ActiveSupport::Inflector

			desc 'generates aures views for a existing model'
			source_root File.expand_path('../templates', __FILE__)
			argument :resource, :type => :string, :required => true
			argument :controller, :type => :string, :required => true
      argument :columns, :type => :array

			def generate
				model_name = resource.camelize
				folder = controller.gsub(/Controller$/,'').underscore
				target = ['app/views',folder].join '/'
				namespace = folder.split('/').slice(0...-1)
				model = model_name.constantize
				controller.constantize
				real_name = model_name.demodulize
				route = folder.gsub('/','_').singularize

				if yes? 'generate views for ''+model_name+'' to: '+target+'?'
					directory 'views', target
					replacements = {
						'MODEL' => model_name,
						'NAME_SINGULAR' => real_name.underscore.downcase,
						'NAME_PLURAL' => real_name.pluralize.underscore.downcase,
						'PATH_SINGULAR' => route,
						'PATH_PLURAL' => route.pluralize,
						'TABLE_HEADS' => columns.collect{ |c| '        - h.text t('.column_'+c+'')' }.join('\n'),
						'TABLE_CELLS' => columns.collect{ |c| '        - r.cell '+real_name.downcase+'.'+c }.join('\n'),
						'ENTRIES' => columns.collect{ |c| '        - l.entry t('.entry_'+c+''), @'+real_name.downcase+'.'+c }.join('\n'),
						'INPUTS' => columns.collect{ |c| "        = f.input :'+c+', :label => t('.field_'+c+'')" }.join('\n'),
						'FORM_PATH' => namespace.collect{ |n| '''+n+''' }.push('@'+real_name.downcase).join(',')
					}
					Dir[target+'/*.haml'].each do |file|
						replacements.each do |key,value|
							gsub_file file, '{{{#{key}}}}', value, :verbose => false
						end
					end
				end

				i18n_file = 'config/locales/'+route.gsub('_','.').pluralize+'.en.yml'
				if yes? 'generate i18n file to: '+i18n_file+'?'
					singular = real_name
					plural = real_name.pluralize
					base_i18n = {
						plural.downcase => {
      				'index' => { 'title' => plural, 'button_new' => 'Add '+singular },
      				'new' => { 'title' => 'New '+singular, 'button_cancel' => 'Cancel', 'button_save' => 'Save' },
      				'edit' => { 'title' => 'Edit '+singular, 'button_cancel' => 'Cancel', 'button_save' => 'Save' },
      				'form' => { 'box_title' => 'Details' },
      				'list' => { 'box_title' => plural+' Listing', 'destroy_confirm' => 'Really want to delete the '+singular+'?' },
      				'show' => { 'title' => singular, 'button_edit' => 'Edit '+singular, 'button_back' => 'Back' },
      				'item' => { 'box_title' => 'Details' }
      			}
					}
      		columns.each do |c|
      			base_i18n[plural.downcase]['item'][('entry_'+c)] = c.titleize
      			base_i18n[plural.downcase]['list'][('column_'+c)] = c.titleize
      			base_i18n[plural.downcase]['form'][('field_'+c)] = c.titleize
      		end
      		namespace.reverse.each do |n|
      			base_i18n = { n => base_i18n }
      		end
      		base_i18n = { 'en' => base_i18n }
					create_file i18n_file, base_i18n.to_yaml
				end

			end

		end

	end

end