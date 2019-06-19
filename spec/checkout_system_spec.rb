RSpec.describe CheckoutSystem do
  # Product
  let(:product_1) { CheckoutSystem::Product.new(product_code: '001', name: 'Lavender heart', price: 9.25) }
  let(:product_2) { CheckoutSystem::Product.new(product_code: '002', name: 'Personalised cufflinks', price: 45.00) }
  let(:product_3) { CheckoutSystem::Product.new(product_code: '003', name: 'Kids T-shirt', price: 19.95) }
  
  # promotion rule
  # rule when spending £60
  let(:promotion_rule_1) { CheckoutSystem::PromotionRule.new(promotion_name: 'promotion 60 price', promotion_type: 'on_total_price', 
                                             min_price: 60.0, discount_rate: 10) }
  # rule when buying 2 or more lavender product
  let(:promotion_rule_2) { 
    promo = CheckoutSystem::PromotionRule.new(promotion_name: 'promotion lavender x2', promotion_type: 'on_item_price', 
                                             promotion_price: 8.5, min_quantity: 2)
    promo.products << product_1 # add product that need to apply promotion
    promo
  }

  shared_examples_for 'return total price' do
    it do
      co = CheckoutSystem::Checkout.new(promotion_rules)
      # scan on each product
      basket.each do |item|
        co.scan(item)
      end
      expect(co.total).to eq expected_total_price
    end
  end

  describe 'payment by default promotion rules' do
    context 'product code: 001, 002, 003' do
      let(:basket) { [product_1, product_2, product_3] }
      context 'rules: spending over £60 and buy 2 or more lavender' do
        let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
        let(:expected_total_price) { 66.78 }

        it_should_behave_like 'return total price'
      end
      context 'no apply any promotions' do
        let(:promotion_rules) { [] }
        let(:expected_total_price) { 74.2 }

        it_should_behave_like 'return total price'
      end
    end

    context 'product code: 001, 003, 001' do
      let(:basket) { [product_1, product_3, product_1] }
      context 'rules: spending over £60 and buy 2 or more lavender' do
        let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
        let(:expected_total_price) { 36.95 }

        it_should_behave_like 'return total price'
      end
      context 'no apply any promotions rules' do
        let(:promotion_rules) { [] }
        let(:expected_total_price) { 38.45}

        it_should_behave_like 'return total price'
      end
    end

    context 'product code: 001, 002, 001, 003' do
      let(:basket) { [product_1, product_2, product_1, product_3] }
      context 'rules: spending over £60 and buy 2 or more lavender' do
        let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
        let(:expected_total_price) { 73.76 }

        it_should_behave_like 'return total price'
      end
      context 'no apply any promotions rules' do
        let(:promotion_rules) { [] }
        let(:expected_total_price) { 83.45 }

        it_should_behave_like 'return total price'
      end
    end

    context 'product code: 001, 003' do
      let(:basket) { [product_1, product_3] }
      context 'rules: spending over £60 and buy 2 or more lavender' do
        let(:promotion_rules) { [promotion_rule_1, promotion_rule_2] }
        let(:expected_total_price) { 29.2 } # not satify any rules

        it_should_behave_like 'return total price'
      end
      context 'no apply any promotions rules' do
        let(:promotion_rules) { [] }
        let(:expected_total_price) { 29.2 } # should be same

        it_should_behave_like 'return total price'
      end
    end
  end

  describe 'payment by custom promotion rules' do
    # if buying 3 or more than, the price will be descreased to 15.0
    let(:promotion_rule_3) { 
      rule = CheckoutSystem::PromotionRule.new(promotion_name: 'promotion kids x3', promotion_type: 'on_item_price', 
      promotion_price: 15.0, min_quantity: 3) 
      rule.products << product_3
      rule
    }
    
    context 'product code: 001, 003, 003, 003' do
      let(:basket) { [product_1, product_3, product_3, product_3] }
      context 'rules: spending over £60 and buy 3 or more kis t-shirt' do
        let(:promotion_rules) { [promotion_rule_1, promotion_rule_3] }
        let(:expected_total_price) { 48.83 } # not satify any rules

        it_should_behave_like 'return total price'
      end
      context 'no apply any promotions rules' do
        let(:promotion_rules) { [] }
        let(:expected_total_price) { 69.1 } # should be same

        it_should_behave_like 'return total price'
      end
    end
  end
end
