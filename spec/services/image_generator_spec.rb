require 'rails_helper'

RSpec.describe ImageGenerator do
  let(:flux_endpoint) { ImageModels::FluxPro::ENDPOINT }
  let(:nano_endpoint) { ImageModels::NanoBanana::ENDPOINT }

  before do
    # poll_for_result sleeps before every poll: without this each example waits 2s.
    allow_any_instance_of(described_class).to receive(:sleep)
  end

  def stub_prediction(endpoint, output:)
    stub_request(:post, endpoint)
      .to_return(status: 201, body: { urls: { get: 'https://api.replicate.com/v1/predictions/abc' } }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, 'https://api.replicate.com/v1/predictions/abc')
      .to_return(status: 200, body: { status: 'succeeded', output: output }.to_json,
                 headers: { 'Content-Type' => 'application/json' })
  end

  describe 'flux (default model)' do
    it 'posts to the flux endpoint without any image input' do
      stub_prediction(flux_endpoint, output: ['https://example.com/flux.png'])

      result = described_class.new.generate(prompt: 'a fox', aspect_ratio: '16:9')

      expect(result).to eq('https://example.com/flux.png')
      expect(WebMock).to have_requested(:post, flux_endpoint).with { |req|
        input = JSON.parse(req.body)['input']
        input['prompt'] == 'a fox' && input['aspect_ratio'] == '16:9' &&
          input['output_format'] == 'png' && !input.key?('image_input')
      }
    end

    it 'ignores reference urls, which the model does not support' do
      stub_prediction(flux_endpoint, output: ['https://example.com/flux.png'])

      described_class.new.generate(prompt: 'a fox', reference_urls: ['https://example.com/ref.png'])

      expect(WebMock).to have_requested(:post, flux_endpoint)
        .with { |req| !JSON.parse(req.body)['input'].key?('image_input') }
    end

    it 'falls back to 1:1 for a ratio the model does not accept' do
      stub_prediction(flux_endpoint, output: ['https://example.com/flux.png'])

      described_class.new.generate(prompt: 'a fox', aspect_ratio: '21:9')

      expect(WebMock).to have_requested(:post, flux_endpoint)
        .with { |req| JSON.parse(req.body)['input']['aspect_ratio'] == '1:1' }
    end
  end

  describe 'nano_banana' do
    it 'posts the reference images to the nano-banana endpoint' do
      stub_prediction(nano_endpoint, output: 'https://example.com/nano.png')

      result = described_class.new(model: :nano_banana).generate(
        prompt: 'a fox', aspect_ratio: '4:3', reference_urls: ['https://example.com/ref.png']
      )

      # nano-banana returns a plain string rather than an array
      expect(result).to eq('https://example.com/nano.png')
      expect(WebMock).to have_requested(:post, nano_endpoint).with { |req|
        input = JSON.parse(req.body)['input']
        input['image_input'] == ['https://example.com/ref.png'] &&
          input['aspect_ratio'] == '4:3' && input['output_format'] == 'png'
      }
    end

    it 'omits image_input entirely when there is no reference' do
      stub_prediction(nano_endpoint, output: 'https://example.com/nano.png')

      described_class.new(model: :nano_banana).generate(prompt: 'a fox', reference_urls: [nil, ''])

      expect(WebMock).to have_requested(:post, nano_endpoint)
        .with { |req| !JSON.parse(req.body)['input'].key?('image_input') }
    end
  end

  it 'rejects an unknown model' do
    expect { described_class.new(model: :dall_e) }.to raise_error(ArgumentError, /Unknown image model/)
  end

  it 'raises a GenerationError when the prediction fails' do
    stub_request(:post, flux_endpoint)
      .to_return(status: 201, body: { urls: { get: 'https://api.replicate.com/v1/predictions/abc' } }.to_json)
    stub_request(:get, 'https://api.replicate.com/v1/predictions/abc')
      .to_return(status: 200, body: { status: 'failed', error: 'nsfw' }.to_json)

    expect { described_class.new.generate(prompt: 'a fox') }
      .to raise_error(ImageGenerator::GenerationError, /nsfw/)
  end
end
