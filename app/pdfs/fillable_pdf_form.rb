require 'pdf_forms'

class FillablePdfForm

  attr_writer :template_path
  attr_reader :attributes

  def initialize
    fill_out
  end

  def export(file_name,output_file_path=nil)
    output_path = output_file_path || "#{Rails.root}/tmp/pdfs/#{SecureRandom.uuid}.pdf"
    pdftk.fill_form template_path(file_name), output_path, attributes, flatten: true
    output_path
  end

  def get_field_names
    pdftk.get_field_names template_path
  end

  def template_path(file_name)
    @template_path ||= "#{Rails.root}/lib/pdf_templates/#{file_name}.pdf"
  end

  protected

    def attributes
      @attributes ||= {}
    end

    def fill(key, value)
      attributes[key.to_s] = value
    end

    def pdftk
      @pdftk ||= PdfForms.new(ENV['PDFTK_PATH'] || '/usr/local/bin/pdftk')
    end

    def fill_out
      raise 'Must be overridden by child class'
    end

end