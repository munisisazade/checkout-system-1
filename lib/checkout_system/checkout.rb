module CheckoutSystem
	class Checkout
		def initialize(promotion_rules = [])
			@promo_rules = promotion_rules
			@co_products = [] # products already scanced

			# check validation of promotion rules and raise error if any
			validate_promotion_rules
		end
	
		def scan(item)
			@co_products << item
		end
	
		# subtotal price without appling promotion code
		def subtotal
			@co_products.reduce(0) { |sum, cal| sum + cal.price }
		end
	
		def total
			return subtotal unless @promo_rules
	
			promo_rules_for_item = @promo_rules.select { |rule| rule.promotion_type == 'on_item_price' }
			promo_rule_for_total = @promo_rules.find { |rule| rule.promotion_type == 'on_total_price' }
			total_price_without_promo = subtotal

			# apply promotion code for each item if any
			promo_rules_for_item.each do |rule|
				@co_products.each do |item|
					co_qty = @co_products.count { |p| p.product_code == item.product_code }
					next unless rule.applicable?(product: item, quantity: co_qty)
					# set promotion price for the product if rule can apply on this product
					item.price = rule.promotion_price
				end
			end
			# recalculate total price with promotion for item
			total_price = subtotal
			# apply promotion code for total price if any
			if promo_rule_for_total&.applicable?(total_price: total_price_without_promo)
				total_price = total_price - (promo_rule_for_total.discount_rate.to_f/100 * total_price)
			end
	
			total_price.round(2)
		end

	private

		def validate_promotion_rules
			unless @promo_rules.all?(&:valid?)
				@promo_rules.each do |rule|
					raise "Promotion #{rule.promotion_name} is not valid,\n#{rule.error_messages.join("\n")}" unless rule.valid?
				end 
			end
		end
	end
end
