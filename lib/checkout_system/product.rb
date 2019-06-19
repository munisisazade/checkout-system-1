module CheckoutSystem
	class Product
		attr_accessor :product_code, :name, :price
	
		def initialize(attr = {})
				@product_code = attr[:product_code]
				@name = attr[:name]
				@price = attr[:price]
		end
	end
end
