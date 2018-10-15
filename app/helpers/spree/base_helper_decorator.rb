module Spree
  BaseHelper.module_eval do

    def open_graph_data
      object = instance_variable_get('@'+controller_name.singularize)
      og = {}

      if object.kind_of? Spree::Product
        og[:title] = @product.name
        og[:type] = "product"
        og[:url] = spree.product_url(@product)
        og[:description] = @product.description
        og[:site_name] = current_store.name
      end
      og
    end

    def open_graph_tags
      open_graph_data.map do |name, content|
        tag('meta', property: "og:#{name}", content: content)
      end.join("\n")
    end

    def open_graph_image_data
      object = instance_variable_get('@'+controller_name.singularize)
      images = {}

      if object.kind_of? Spree::Product
        @product.images.each_with_index do |img, index|
          images[index] = absolute_image_url(img.attachment.url)
        end
      end
      images
    end

    def open_graph_image_tags
      open_graph_image_data.map do |index, img|
        tag('meta', property: "og:image", content: img)
      end.join("\n")
    end

    def fb_app_id
      tag('meta', property: "fb:app_id", content: Spree::Social::Config.preferred_facebook_app_id) if Spree::Social::Config.preferred_facebook_app_id.present?
    end

    def pin_it_button(product)
      return if product.images.empty?

      url = escape spree.product_url(product)
      media = absolute_product_image(product.images.first)
      description = escape product.name

      link_to('Pin It',
              "https://pinterest.com/pin/create/button/?url=#{url}&media=#{media}&description=#{description}",
              class: 'pin-it-button',
              'count-layout' => 'none', data: { 'pin-do': "buttonBookmark"}).html_safe
    end

    def absolute_product_image(image)
      escape absolute_image_url(image.attachment.url)
    end

    def absolute_image_url(url)
      return url if url.starts_with? 'http'
      request.protocol + request.host + url
    end

    private

    def escape(string)
      URI.escape string, /[^#{URI::PATTERN::UNRESERVED}]/
    end
  end
end
