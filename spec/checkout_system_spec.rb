class Product
  attr_accessor :product_code, :name, :price
  
  def initialize(attr = {})
    @product_code = attr[:product_code]
    @name = attr[:name]
    @price = attr[:price]
  end
end

class PromotionRule
  attr_accessor :promotion_name, :promotion_type, :min_price, 
                :min_quantity, :promotion_price, :discount_rate, :status

  def initialize(attr = {})
    @promotion_name = attr[:promotion_name]
    @promotion_type = attr[:promotion_type]
    @min_price = attr[:min_price]
    @min_quantity = attr[:min_quantity]
    @promotion_price = attr[:promotion_price]
    @discount_rate = attr[:discount_rate]
    @status = attr[:status]
    # list product that can applied this promotion if promotion_type is `individual` 
    @products = []
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
end
class Checkout
  def initialize(promotion_rules = [])
    @promo_rules = promotion_rules
    @co_products = [] # products already scanced
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
    if promo_rule_for_total&.applicable?(total_price: subtotal)
      total_price = total_price - (promo_rule_for_total.discount_rate.to_f/100 * total_price)
    end

    total_price.round(2)
  end
end

RSpec.describe CheckoutSystem do
  # Product
  let(:product_1) { Product.new(product_code: '001', name: 'Lavender heart', price: 9.25) }
  let(:product_2) { Product.new(product_code: '002', name: 'Personalised cufflinks', price: 45.00) }
  let(:product_3) { Product.new(product_code: '003', name: 'Kids T-shirt', price: 19.95) }
  
  # promotion rule
  # rule when spending £60
  let(:promotion_rule_1) { PromotionRule.new(promotion_name: 'promotion 60 price', promotion_type: 'on_total_price', 
                                             min_price: 60.0, discount_rate: 10) }
  # rule when buying 2 or more lavender product
  let(:promotion_rule_2) { 
    promo = PromotionRule.new(promotion_name: 'promotion lavender x2', promotion_type: 'on_item_price', 
                                             promotion_price: 8.5, min_quantity: 2)
    promo.products << product_1 # add product that need to apply promotion
    promo
  }
  

  shared_examples_for 'mass assignment' do |attributes|
    it 'allows to read and write' do
      attributes.each do |key, value|
        subject.send("#{key}=", value)
        expect(subject.send(key)).to eq(value)
      end
    end
  end

  describe Product do
    context 'mass assignment' do
      it_should_behave_like 'mass assignment', { product_code: 1, name: 'product name', price: 10.0 }
    end
  end

  describe PromotionRule do
    context 'mass assignment' do
      it_should_behave_like 'mass assignment', { promotion_name: "name", promotion_type: 'type', min_price: 10.0, 
                                                 status: 'active', min_quantity: 1, 
                                                 promotion_price: 9.0, discount_rate: 10 }
    end
  end

  describe Checkout do
    describe 'attributes' do
      context 'mass assignment' do
        it_should_behave_like 'mass assignment', {}
      end
    end

    describe 'payment' do
      context 'product code: 001, 002, 003' do
        let(:basket) { [product_1, product_2, product_3] }
        context 'rules: spending over £60 and buy 2 or more lavender' do
          let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
          it 'return total price' do
            co = Checkout.new(promotion_rules)
            # scan on each product
            basket.each do |item|
              co.scan(item)
            end

            expect(co.total).to eq 66.78
          end
        end
      end

      context 'product code: 001, 003, 001' do
        let(:basket) { [product_1, product_3, product_1] }
        context 'rules: spending over £60 and buy 2 or more lavender' do
          let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
          it 'return total price' do
            co = Checkout.new(promotion_rules)
            # scan on each product
            basket.each do |item|
              co.scan(item)
            end

            expect(co.total).to eq 36.95
          end
        end
      end

      context 'product code: 001, 002, 001, 003' do
        let(:basket) { [product_1, product_2, product_1, product_3] }
        context 'rules: spending over £60 and buy 2 or more lavender' do
          let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
          it 'return total price' do
            co = Checkout.new(promotion_rules)
            # scan on each product
            basket.each do |item|
              co.scan(item)
            end

            expect(co.total).to eq 73.76
          end
        end
      end
    end
  end
end
