require 'spec_helper'

describe KubernetesAdapter::SymbolExtensions do

  using described_class

  it 'adds a #symbolize_hash_keys method to everything' do
    expect { Object.new.symbolize_hash_keys }.to_not raise_error
  end

  describe '#symbolize_hash_keys' do
    context 'when used on an Object' do

      subject { 'foo' }

      it 'returns the object unchanged' do
        expect(subject.symbolize_hash_keys).to eq subject
      end
    end

    context 'when used on an Hash' do

      subject { { 'a' => { 'b' => 'c' } } }

      it 'symbolizes the hash keys' do
        expect(subject.symbolize_hash_keys).to eq(a: { b: 'c' })
      end
    end

    context 'when used on an Array' do
      subject { [{ 'a' => 'b' }] }

      it 'symbolizes the keys of any embedded hashes' do
        expect(subject.symbolize_hash_keys).to eq([a: 'b'])
      end
    end
  end
end
