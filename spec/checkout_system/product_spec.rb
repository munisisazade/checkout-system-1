RSpec.describe CheckoutSystem::Product do
  context 'mass assignment' do
    it_should_behave_like 'mass assignment', product_code: 1, name: 'product name', price: 10.0
  end
end
