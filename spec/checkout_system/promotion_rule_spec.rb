RSpec.describe CheckoutSystem::PromotionRule do
  let(:promotion) { described_class.new(promotion_name: 'promotion name', promotion_type: 'on_total_price', 
                                              min_price: 60.0, discount_rate: 10) }

  context 'mass assignment' do
    it_should_behave_like 'mass assignment', { promotion_name: "name", promotion_type: 'type', min_price: 10.0, 
                                                status: 'active', min_quantity: 1, 
                                                promotion_price: 9.0, discount_rate: 10 }
  end

  context '#valid?' do
    context 'when promotion is valid' do
      it { expect(promotion.valid?).to eq true }
    end

    context 'when promotion is not valid' do
      let(:promotion) { described_class.new(promotion_name: 'promotion name', promotion_type: 'on_total_price') }
      it { expect(promotion.valid?).to eq false }
    end
  end

  context '#applicable?' do
    context 'when total_price is less than min_price' do
      let(:total_price) { 50.0 }
      it 'return false' do 
        expect(promotion.applicable? total_price: total_price ).to eq false
      end
    end

    context 'when total_price is greater than min_price' do
      let(:total_price) { 70.0 }
      it 'return true' do 
        expect(promotion.applicable? total_price: total_price ).to eq true
      end
    end
  end
end