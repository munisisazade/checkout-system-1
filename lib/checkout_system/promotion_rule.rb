module CheckoutSystem
	class PromotionRule
		attr_accessor :promotion_name, :promotion_type, :min_price, 
									:min_quantity, :promotion_price, :discount_rate, 
									:status, :error_messages
	
		def initialize(attr = {})
			@promotion_name = attr[:promotion_name]
			@promotion_type = attr[:promotion_type]
			@min_price = attr[:min_price]
			@min_quantity = attr[:min_quantity]
			@promotion_price = attr[:promotion_price]
			@discount_rate = attr[:discount_rate]
			@status = attr.fetch(:status, 'active')
			# list product that can applied this promotion if promotion_type is `individual` 
			@products = []
			@error_messages = []
		end
	
		def add_product(item)
			@products << item
		end
	
		def products
			@products
		end
	
		def applicable?(product: nil, quantity: 0, total_price: 0)
			if promotion_type == 'on_item_price'
				@products.find { |item| item.product_code == product.product_code } && quantity >= min_quantity
			elsif promotion_type == 'on_total_price'
				total_price >= min_price
			end
		end

		def valid?
			return false if error.any?
			
			true
		end

	private

		def error
			errors = []
			if promotion_type == 'on_item_price'
				errors << "products is required" if products.empty?
				errors << "min_quantity is required" if min_quantity.nil?
			elsif promotion_type == 'on_total_price'
				errors << "min_price is required" if min_price.nil?
			end

			@error_messages = errors
			@error_messages
		end
	end
end
