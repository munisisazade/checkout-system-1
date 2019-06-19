RSpec.describe CheckoutSystem::Checkout do
  let(:checkout) { described_class.new(promotion_rules) }
  let(:promotion_rules) { [] }

  context 'mass assignment' do
    it_should_behave_like 'mass assignment', {}
  end

  context '#scan' do
    before { checkout.scan(1) }
    it 'assign co_products' do
      expect(checkout.instance_variable_get(:@co_products).any?).to eq true
      expect(checkout.instance_variable_get(:@co_products).first).to eq 1
    end
  end

  context '#subtotal' do
    before do
      product = CheckoutSystem::Product.new(price: 10)
      checkout.instance_variable_set(:@co_products, [product, product])
    end
    it 'return sum of price' do
      expect(checkout.subtotal).to eq 20
    end
  end

  context '#total' do
    before do
      allow_any_instance_of(CheckoutSystem::Checkout).to receive(:subtotal).and_return 10.0
    end
    context 'when promo_rules is blank' do
      it 'return subtotal if there are not any promotion rules' do
        expect(checkout.total).to eq 10
      end
    end
    context 'when promo_rules is not blank' do
      context 'when promotion type is on_total_price' do
        let(:promotion_rules) do
          [CheckoutSystem::PromotionRule.new(promotion_name: 'promotion name', promotion_type: 'on_total_price',
                                             min_price: 5.0, discount_rate: 5)]
        end

        it 'return total price' do
          expect(checkout.total).to eq 10.0 - (10.0 * 0.05)
        end
      end
    end
  end
end
