require 'string_ext'

class Gallery < ActiveRecord::Base
  has_many :gallery_items

  validates_presence_of :title
  validates_uniqueness_of :title

  before_validation_on_create :generate_file_name, :set_default_swf

  def to_xml
    out = "<?xml version='1.0' encoding='UTF-8'?><gallery>"
    out += "<album lgPath='' tnPath='' title='#{title}' description='#{description}' tn=''>"

    gallery_items.each do |item|
      out += "<img src='#{item.asset.url}' title='#{item.title}' caption='#{item.caption}' link='#{item.link}' target='_self' pause='' />"
    end

    out += "</album></gallery>"
  end

  # write the file to the specified disk location
  def publish
    File.open("#{RAILS_ROOT}/public#{self.xml_file_name}", 'w') do |f|
      f.write self.to_xml
    end
  end

  private

  def gallery_path
    "#{FlashGalleryExtension::GALLERY_PATH}/#{(title || '').to_permalink}"
  end

  def generate_file_name
    self.xml_file_name = "#{gallery_path}.xml" unless title.nil?
  end

  def set_default_swf
    self.swf_file_name = "#{FlashGalleryExtension::GALLERY_PATH}/#{FlashGalleryExtension::DEFAULT_SWF}" if swf_file_name.nil?
  end
end
