shared_examples_for 'mass assignment' do |attributes|
  it 'allows to read and write' do
    attributes.each do |key, value|
      subject.send("#{key}=", value)
      expect(subject.send(key)).to eq(value)
    end
  end
end